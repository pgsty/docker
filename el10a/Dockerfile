FROM rockylinux/rockylinux:10 AS mini
USER root
WORKDIR /root/
CMD ["/bin/bash"]

RUN dnf install -y ca-certificates vim-minimal wget curl rsync && \
    curl https://repo.pigsty.io/pig | bash -s v1.0.0  && pig repo add --remove && yum clean all

FROM mini AS full
RUN pig repo set && pig build tool && pig build spec && pig build rust && pig build pgrx