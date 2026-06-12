FROM rockylinux/rockylinux:8.10.20240528 AS base
USER root
WORKDIR /root/
ENV container=docker \
    TZ=Asia/Shanghai

# Rocky Linux 8.10 (Green Obsidian)
RUN groupadd -g 26 postgres && useradd -u 26 -g 26 -m -s /bin/bash postgres

RUN dnf install -y \
    systemd openssh-server openssh-clients sudo passwd \
    glibc-langpack-en glibc-locale-source tzdata ca-certificates curl wget \
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
RUN dnf install -y ca-certificates vim-minimal wget curl rsync unzip openssl-devel pkgconf-pkg-config \
    && curl -fsSL https://repo.pigsty.io/pig | bash -s v1.4.2 \
    && pig sty init -f \
    && pig repo add -ru --region=china \
    && pig sty boot -r china \
    && pig sty conf -c rich -r china \
    && pig repo add -ru --region=china \
    && pig build tool \
    && pig build spec \
    && install -d /root/.cargo \
    && printf '[source.crates-io]\nreplace-with = "rsproxy"\n\n[source.rsproxy]\nregistry = "sparse+https://rsproxy.cn/index/"\n\n[net]\ngit-fetch-with-cli = true\n' > /root/.cargo/config.toml \
    && RUSTUP_DIST_SERVER="https://rsproxy.cn" RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup" pig build rust \
    && pig build pgrx --pgrx 0.18.1 \
    && dnf clean all \
    && rm -rf /var/cache/dnf /tmp/* /var/tmp/*
