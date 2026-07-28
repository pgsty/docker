FROM jrei/systemd-ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive TZ=Asia/Shanghai LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo locales ca-certificates curl wget vim \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && mkdir -p /run/sshd && ssh-keygen -A && systemctl enable ssh \
    && sed -i 's/#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/nopasswd \
    && echo 'root:root' | chpasswd \
    && systemctl mask user@.service \
    && curl https://repo.pigsty.cc/pig | bash -s v1.6.0 \
    && pig repo set --region=china \
    && pig sty init -v 4.5.0 \
    && pig sty boot \
    && apt-get clean \
    && mkdir -p /data

# Load /etc/profile.d scripts in bash sessions
RUN echo '\n# Load /etc/profile.d scripts\nif [ -d /etc/profile.d ]; then\n  for i in /etc/profile.d/*.sh; do\n    if [ -r "$i" ]; then\n      . "$i"\n    fi\n  done\nfi' >> /root/.bashrc

COPY pigsty.yml /root/pigsty/pigsty.yml

RUN pig sty install

# Default working directory
WORKDIR /root/pigsty

# Data directory - must be mounted by user
VOLUME /data

# Ports (only exposed when mapped via -p)
# 22: SSH, 80: Nginx, 5432: PostgreSQL, 3000: Grafana
EXPOSE 22 80 5432 3000
