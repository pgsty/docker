FROM rockylinux/rockylinux:10.2.20260525.0 AS base
USER root
WORKDIR /root/
ENV container=docker \
    TZ=Asia/Shanghai

# Rocky Linux 10.2 (Red Quartz)
RUN groupadd -g 26 postgres && useradd -u 26 -g 26 -m -s /bin/bash postgres

RUN sed -ri \
    -e 's!^mirrorlist=!#mirrorlist=!g' \
    -e 's!^#baseurl=http://dl.rockylinux.org/\$contentdir/!baseurl=https://mirrors.aliyun.com/rockylinux/!g' \
    /etc/yum.repos.d/rocky*.repo

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
RUN dnf install -y ca-certificates vim-minimal wget curl-minimal rsync unzip openssl-devel pkgconf-pkg-config \
    && wget -qO /tmp/pig.rpm https://repo.pigsty.io/pkg/pig/v1.4.2/pig-1.4.2-1.x86_64.rpm \
    && rpm -Uvh /tmp/pig.rpm \
    && rm -f /tmp/pig.rpm \
    && pig sty init -f \
    && pig repo add --remove \
    && sed -ri 's#repo\.pigsty\.io#repo.pigsty.cc#g; s#https://nginx\.org#http://nginx.org#g; s#https://mirrors\.edge\.kernel\.org/fedora-epel#https://mirrors.aliyun.com/epel#g; s#https://dl\.rockylinux\.org/pub/rocky#https://mirrors.aliyun.com/rockylinux#g' /etc/yum.repos.d/*.repo \
    && /root/pigsty/bootstrap -r china -k \
    && pig sty conf -c rich -r china \
    && pig repo add -ru --region=china

RUN pig build tool

RUN set -eux; \
    n=0; \
    until [ "$n" -ge 5 ]; do \
        pig build spec -f -m && break; \
        n=$((n + 1)); \
        echo "pig build spec retry: $n"; \
        sleep 3; \
    done; \
    test "$n" -lt 5

RUN install -d /root/.cargo \
    && printf '[source.crates-io]\nreplace-with = "rsproxy"\n\n[source.rsproxy]\nregistry = "sparse+https://rsproxy.cn/index/"\n\n[net]\ngit-fetch-with-cli = true\n' > /root/.cargo/config.toml \
    && RUSTUP_DIST_SERVER="https://rsproxy.cn" RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup" pig build rust \
    && pig build pgrx --pgrx 0.18.1 \
    && dnf clean all \
    && rm -rf /var/cache/dnf /tmp/* /var/tmp/*
