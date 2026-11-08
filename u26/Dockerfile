FROM ubuntu:resolute-20260811.1 AS base
USER root
WORKDIR /root/
ENV container=docker \
    DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Ubuntu 26.04 LTS (Resolute Raccoon)
RUN groupadd -g 543 postgres && useradd -u 543 -g 543 -m -s /bin/bash postgres

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d \
    && chmod +x /usr/sbin/policy-rc.d \
    && find /etc/apt -maxdepth 2 -type f \( -name 'sources.list' -o -name '*.list' -o -name '*.sources' \) \
        -exec sed -ri \
            -e 's|http://archive.ubuntu.com/ubuntu/?|http://mirrors.aliyun.com/ubuntu/|g' \
            -e 's|http://security.ubuntu.com/ubuntu/?|http://mirrors.aliyun.com/ubuntu/|g' \
            -e 's|http://ports.ubuntu.com/ubuntu-ports/?|http://mirrors.aliyun.com/ubuntu-ports/|g' {} + \
    && printf 'Acquire::Retries "5";\nAcquire::http::Timeout "30";\nAcquire::https::Timeout "30";\n' > /etc/apt/apt.conf.d/80-retries \
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
COPY --from=pgext /pgext /usr/local/bin/pgext
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates vim ncdu wget curl rsync unzip libssl-dev pkg-config \
    && (apt-get purge -y needrestart || true) \
    && pgext env repo --mirror \
    && pgext env tool \
    && pgext env spec --mirror \
    && pgext env rust --mirror \
    && pgext env pgrx --pgrx 0.19.3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
