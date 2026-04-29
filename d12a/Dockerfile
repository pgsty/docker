FROM debian:bookworm-20260421 AS base
USER root
WORKDIR /root/
ENV container=docker \
    DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Debian 12.13 (Bookworm)
RUN groupadd -g 543 postgres && useradd -u 543 -g 543 -m -s /bin/bash postgres

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d \
    && chmod +x /usr/sbin/policy-rc.d \
    && printf 'Acquire::Retries "5";\nAcquire::http::Timeout "30";\nAcquire::https::Timeout "30";\n' > /etc/apt/apt.conf.d/80-retries \
    && sed -i 's|http://deb.debian.org/debian|http://mirrors.aliyun.com/debian|g; s|http://deb.debian.org/debian-security|http://mirrors.aliyun.com/debian-security|g' /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    systemd systemd-sysv dbus dbus-user-session \
    openssh-server openssh-client sudo passwd \
    locales tzdata ca-certificates curl wget \
    vim ncdu rsync unzip lsof \
    procps iproute2 net-tools iputils-ping \
    && (apt-get purge -y needrestart || true) \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && find . -mindepth 1 -maxdepth 1 ! -name 'systemd-tmpfiles-setup.service' -delete \
    && rm -f /lib/systemd/system/multi-user.target.wants/* \
    && rm -f /etc/systemd/system/*.wants/* \
    && rm -f /lib/systemd/system/local-fs.target.wants/* \
    && rm -f /lib/systemd/system/sockets.target.wants/*udev* \
    && rm -f /lib/systemd/system/sockets.target.wants/*initctl* \
    && rm -f /lib/systemd/system/basic.target.wants/* \
    && rm -f /lib/systemd/system/anaconda.target.wants/* \
    && rm -f /lib/systemd/system/plymouth* \
    && rm -f /lib/systemd/system/systemd-update-utmp* \
    && ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target

RUN ln -sf /dev/null /etc/systemd/system/dev-hugepages.mount \
    && ln -sf /dev/null /etc/systemd/system/sys-fs-fuse-connections.mount \
    && ln -sf /dev/null /etc/systemd/system/systemd-update-utmp.service \
    && ln -sf /dev/null /etc/systemd/system/console-getty.service \
    && mkdir -p /etc/ssh/sshd_config.d \
    && printf 'PermitRootLogin yes\nPasswordAuthentication yes\n' > /etc/ssh/sshd_config.d/99-pigsty.conf

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone

RUN mkdir -p /run/sshd /root/.ssh \
    && chmod 700 /root/.ssh \
    && ssh-keygen -A \
    && ln -sf /lib/systemd/system/ssh.service /etc/systemd/system/multi-user.target.wants/ssh.service

RUN ssh-keygen -t rsa -b 2048 -N '' -f /root/.ssh/id_rsa \
    && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
    && chmod 600 /root/.ssh/authorized_keys \
    && printf 'Host *\n    StrictHostKeyChecking no\n    UserKnownHostsFile /dev/null\n' >> /etc/ssh/ssh_config

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/nopasswd \
    && chmod 440 /etc/sudoers.d/nopasswd \
    && echo 'root:pigsty' | chpasswd

RUN mkdir -p /data
VOLUME ["/data"]
STOPSIGNAL SIGRTMIN+3
CMD ["/lib/systemd/systemd"]

FROM base AS build
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates vim ncdu wget curl rsync unzip libssl-dev pkg-config gnupg \
    && (apt-get purge -y needrestart || true) \
    && curl -fsSL https://repo.pigsty.io/pig | bash -s v1.4.1 \
    && pig sty init -f \
    && install -d /etc/apt/keyrings /usr/share/postgresql-common/pgdg \
    && curl -fsSL https://repo.pigsty.cc/key | gpg --dearmor -o /etc/apt/keyrings/pigsty.gpg \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc \
    && pig repo add -ru --region=china \
    && pig sty boot -r china \
    && pig sty conf -c rich -r china \
    && pig repo add -ru --region=china \
    && pig build tool \
    && pig build spec \
    && install -d /root/.cargo \
    && printf '[source.crates-io]\nreplace-with = "rsproxy"\n\n[source.rsproxy]\nregistry = "sparse+https://rsproxy.cn/index/"\n\n[net]\ngit-fetch-with-cli = true\n' > /root/.cargo/config.toml \
    && RUSTUP_DIST_SERVER="https://rsproxy.cn" RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup" pig build rust \
    && pig build pgrx --pgrx 0.18.0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
