FROM almalinux:9 AS mini
USER root
WORKDIR /root/
CMD ["/bin/bash"]

RUN dnf install -y ca-certificates vim-minimal wget rsync && \
    curl https://repo.pigsty.cc/pig | bash -s v0.7.2 && pig repo add --remove && yum clean all

FROM mini AS full
RUN pig repo set --region=china && pig build tool && pig build spec && pig build rust && pig build pgrx