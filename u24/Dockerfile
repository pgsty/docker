FROM ubuntu:24.04 AS mini
USER root
WORKDIR /root/
ENV DEBIAN_FRONTEND=noninteractive TZ=Asia/Shanghai
CMD ["/bin/bash"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates vim ncdu wget curl rsync unzip tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone && \
    curl https://repo.pigsty.cc/pig | bash -s v1.0.0  && \
    pig repo add --remove && apt-get clean

FROM mini AS full
ENV TZ=Asia/Shanghai
RUN pig repo set --region=china && \
    pig build tool && \
    pig build spec && \
    pig build rust && \
    pig build pgrx