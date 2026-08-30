FROM centos:7.9.2009 AS base
USER root
WORKDIR /root/
ENV container=docker \
    TZ=Asia/Shanghai

# CentOS Linux 7.9.2009 (Core)
RUN groupadd -g 26 postgres && useradd -u 26 -g 26 -m -s /bin/bash postgres

RUN mkdir -p /etc/yum.repos.d/original \
    && mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/original/ \
    && printf '[base]\nname=CentOS 7.9 Base\nbaseurl=https://mirrors.aliyun.com/centos-vault/7.9.2009/os/$basearch/\nenabled=1\ngpgcheck=1\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7\n\n[updates]\nname=CentOS 7.9 Updates\nbaseurl=https://mirrors.aliyun.com/centos-vault/7.9.2009/updates/$basearch/\nenabled=1\ngpgcheck=1\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7\n\n[extras]\nname=CentOS 7.9 Extras\nbaseurl=https://mirrors.aliyun.com/centos-vault/7.9.2009/extras/$basearch/\nenabled=1\ngpgcheck=1\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7\n\n[epel]\nname=EPEL 7 Archive\nbaseurl=https://mirrors.aliyun.com/epel/7/$basearch/\nenabled=1\ngpgcheck=0\n\n[centos-sclo-sclo]\nname=CentOS 7 SCLo sclo\nbaseurl=https://mirrors.aliyun.com/centos-vault/7.9.2009/sclo/$basearch/sclo/\nenabled=1\ngpgcheck=1\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo\n\n[centos-sclo-rh]\nname=CentOS 7 SCLo rh\nbaseurl=https://mirrors.aliyun.com/centos-vault/7.9.2009/sclo/$basearch/rh/\nenabled=1\ngpgcheck=1\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo\n' > /etc/yum.repos.d/CentOS-Base.repo \
    && yum update -y \
    && yum install -y \
    systemd dbus openssh-server openssh-clients sudo passwd \
    glibc-common tzdata ca-certificates curl wget \
    vim-minimal rsync unzip lsof \
    procps-ng iproute net-tools iputils \
    findutils which tar gzip xz \
    && yum clean all \
    && rm -rf /var/cache/yum /tmp/* /var/tmp/*

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
    && sed -ri \
        -e 's/^#?PermitRootLogin .*/PermitRootLogin yes/' \
        -e 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config

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
# Legacy build image: install the available native toolchain, but no Rust/cargo/pgrx.
RUN set -eux; \
    yum install -y \
        gcc gcc-c++ make autoconf automake libtool bison flex pkgconfig git \
        rpm-build yum-utils readline-devel zlib-devel libxml2-devel libxslt-devel \
        openssl-devel krb5-devel libcurl-devel openldap-devel; \
    for package in cmake3 ninja-build lz4 lz4-devel libzstd-devel ncdu jq rpmdevtools python3 python3-devel python3-pip ansible sshpass; do \
        yum install -y "$package" \
        || printf 'warning: optional package %s is unavailable on el7\n' "$package" >&2; \
    done; \
    curl -fsSL https://repo.pigsty.cc/pig -o /tmp/install-pig; \
    bash /tmp/install-pig v1.8.0; \
    pig sty init -v 4.5.0 -f || printf 'warning: Pigsty init is unavailable on el7\n' >&2; \
    pig repo add pgsql infra --mirror || printf 'warning: optional Pigsty/PGDG repositories are unavailable on el7\n' >&2; \
    yum makecache fast || printf 'warning: one or more optional repositories failed to update on el7\n' >&2; \
    pig sty boot --mirror --keep || printf 'warning: Pigsty bootstrap is only partially available on el7\n' >&2; \
    pig sty conf --mirror -c rich || printf 'warning: Pigsty rich configuration is unavailable on el7\n' >&2; \
    if [ -d /etc/yum.repos.d/backup ]; then \
        rm -f /etc/yum.repos.d/el7.repo; \
        for repo in CentOS-Base.repo infra.repo pgsql.repo; do \
            if [ -f "/etc/yum.repos.d/backup/${repo}" ]; then \
                cp "/etc/yum.repos.d/backup/${repo}" "/etc/yum.repos.d/${repo}"; \
            fi; \
        done; \
        sed -i '/^\[centos-sclo-sclo\]/,/^$/ s/^gpgcheck=.*/gpgcheck=0/' /etc/yum.repos.d/CentOS-Base.repo; \
        sed -i '/^\[centos-sclo-rh\]/,/^$/ s/^gpgcheck=.*/gpgcheck=0/' /etc/yum.repos.d/CentOS-Base.repo; \
    fi; \
    yum makecache fast || printf 'warning: legacy build repositories failed to update on el7\n' >&2; \
    yum install -y devtoolset-11-gcc devtoolset-11-gcc-c++ devtoolset-11-binutils \
        || printf 'warning: devtoolset-11 is unavailable on el7\n' >&2; \
    for package in vray pgdg-srpm-macros; do \
        yum install -y "$package" \
        || printf 'warning: optional package %s is unavailable on el7\n' "$package" >&2; \
    done; \
    for version in 14 15 16 17 18; do \
        yum install -y "postgresql${version}-server" "postgresql${version}-devel" \
        || printf 'warning: PostgreSQL %s build packages are unavailable on el7\n' "$version" >&2; \
    done; \
    if [ -x /usr/bin/cmake3 ]; then ln -sf /usr/bin/cmake3 /usr/local/bin/cmake; fi; \
    if [ -x /usr/bin/ninja-build ]; then ln -sf /usr/bin/ninja-build /usr/local/bin/ninja; fi; \
    if [ -d /opt/rh/devtoolset-11/root/usr/bin ]; then \
        printf 'source /opt/rh/devtoolset-11/enable\n' > /etc/profile.d/devtoolset-11.sh; \
    fi; \
    pig build spec --mirror || printf 'warning: build spec download is unavailable on el7\n' >&2; \
    yum clean all; \
    rm -rf /var/cache/yum /tmp/* /var/tmp/*

ENV PATH=/opt/rh/devtoolset-11/root/usr/bin:${PATH} \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-11/root/usr/lib64
