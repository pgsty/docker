FROM almalinux:9 AS mini
USER root
WORKDIR /root/
CMD ["/bin/bash"]
ENV TZ=Asia/Shanghai

RUN dnf install -y ca-certificates vim-minimal wget rsync && \
    curl https://repo.pigsty.cc/pig | bash -s v1.0.0  && pig repo add --remove && yum clean all

FROM mini AS full
RUN pig repo set --region=china && pig build tool && pig build spec && pig build rust && pig build pgrx