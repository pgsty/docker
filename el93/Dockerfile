FROM rockylinux/rockylinux:9.3.20231119 AS base
USER root
WORKDIR /root/
ENV container=docker \
    TZ=Asia/Shanghai

# Rocky Linux 9.3 (Blue Onyx)
RUN groupadd -g 26 postgres && useradd -u 26 -g 26 -m -s /bin/bash postgres

RUN sed -ri -e 's!^mirrorlist=!#mirrorlist=!g' -e 's!^#baseurl=http://dl.rockylinux.org/\$contentdir/\$releasever/!baseurl=https://mirrors.aliyun.com/rockylinux-vault/9.3/!g' /etc/yum.repos.d/rocky*.repo

RUN dnf install -y \
    systemd openssh-server openssh-clients sudo passwd \
    glibc-langpack-en glibc-locale-source tzdata ca-certificates curl-minimal wget \
    vim-minimal rsync unzip lsof \
    procps-ng iproute net-tools iputils \
    findutils which tar gzip xz \
    && dnf clean all \
    && rm -rf /var/cache/dnf /tmp/* /var/tmp/*

RUN cd /usr/lib/systemd/system/sysinit.target.wants/ \
    && find . -mindepth 1 -maxdepth 1 ! -name 'systemd-tmpfiles-setup.service' -delete \
    && rm -f /usr/lib/systemd/system/multi-user.target.wants/* \
    && rm -f /etc/systemd/system/*.wants/* \
    && rm -f /usr/lib/systemd/system/local-fs.target.wants/* \
    && rm -f /usr/lib/systemd/system/sockets.target.wants/*udev* \
    && rm -f /usr/lib/systemd/system/sockets.target.wants/*initctl* \
    && rm -f /usr/lib/systemd/system/basic.target.wants/* \
    && rm -f /usr/lib/systemd/system/anaconda.target.wants/* \
    && rm -f /usr/lib/systemd/system/plymouth* \
    && rm -f /usr/lib/systemd/system/systemd-update-utmp* \
    && ln -sf /usr/lib/systemd/system/multi-user.target /etc/systemd/system/default.target

RUN ln -sf /dev/null /etc/systemd/system/dev-hugepages.mount \
    && ln -sf /dev/null /etc/systemd/system/sys-fs-fuse-connections.mount \
    && ln -sf /dev/null /etc/systemd/system/systemd-update-utmp.service \
    && ln -sf /dev/null /etc/systemd/system/console-getty.service \
    && mkdir -p /etc/ssh/sshd_config.d \
    && printf 'PermitRootLogin yes\nPasswordAuthentication yes\n' > /etc/ssh/sshd_config.d/99-pigsty.conf

RUN localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && echo 'LANG=en_US.UTF-8' > /etc/locale.conf \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN mkdir -p /run/sshd /root/.ssh \
    && chmod 700 /root/.ssh \
    && ssh-keygen -A \
    && ln -sf /usr/lib/systemd/system/sshd.service /etc/systemd/system/multi-user.target.wants/sshd.service

RUN ssh-keygen -t rsa -b 2048 -N '' -f /root/.ssh/id_rsa \
    && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
    && chmod 600 /root/.ssh/authorized_keys \
    && printf 'Host *\n    StrictHostKeyChecking no\n    UserKnownHostsFile /dev/null\n' >> /etc/ssh/ssh_config

RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/nopasswd \
    && chmod 440 /etc/sudoers.d/nopasswd \
    && echo 'root:pigsty' | chpasswd

RUN mkdir -p /data
VOLUME ["/data"]
STOPSIGNAL SIGRTMIN+3
CMD ["/usr/sbin/init"]

FROM base AS build
RUN printf 'minrate=1\ntimeout=300\nretries=100\nmax_parallel_downloads=1\n' >> /etc/dnf/dnf.conf \
    && dnf install -y ca-certificates vim-minimal wget curl-minimal rsync unzip openssl-devel pkgconf-pkg-config \
    && curl -fsSL https://repo.pigsty.cc/pig | bash -s v1.8.0 \
    && pig sty init -v 4.5.0 -f \
    && sed -i 's!${baseurl}/rocky${suffix}/\\$releasever/!https://mirrors.aliyun.com/rockylinux-vault/9.3/!g' /root/pigsty/bootstrap \
    && pig repo add --mirror --remove \
    && sed -ri 's!https://mirrors.aliyun.com/rockylinux/\$releasever/!https://mirrors.aliyun.com/rockylinux-vault/9.3/!g; s!rhel-9\.3-!rhel-9-!g' /etc/yum.repos.d/node.repo /etc/yum.repos.d/pgsql.repo \
    && pig sty boot --mirror --keep \
    && pig sty conf --mirror -c rich \
    && pig repo set --mirror \
    && sed -ri 's!https://mirrors.aliyun.com/rockylinux/\$releasever/!https://mirrors.aliyun.com/rockylinux-vault/9.3/!g; s!rhel-9\.3-!rhel-9-!g' /etc/yum.repos.d/node.repo /etc/yum.repos.d/pgsql.repo \
    && dnf install -y --setopt=install_weak_deps=False \
       --repofrompath=rocky94-appstream,https://mirrors.aliyun.com/rockylinux-vault/9.4/AppStream/x86_64/os/ \
       --setopt=rocky94-appstream.gpgcheck=1 \
       --setopt=rocky94-appstream.gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-9 \
       clang-devel-17.0.6-5.el9 llvm-devel-17.0.6-5.el9 \
    && sed -i 's/^best=.*/best=False/' /etc/dnf/dnf.conf \
    && pig build tool \
    && pig build spec --mirror \
    && pig build rust --mirror \
    && pig build pgrx \
    && dnf clean all \
    && rm -rf /var/cache/dnf /tmp/* /var/tmp/*
