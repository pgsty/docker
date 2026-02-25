FROM debian:12 AS mini
USER root
WORKDIR /root/
CMD ["/bin/bash"]

RUN apt update && apt install -y ca-certificates vim ncdu wget curl rsync unzip && \
    curl https://repo.pigsty.io/pig | bash -s v1.0.0 && pig repo add --remove && apt clean

FROM mini AS full
RUN pig repo set --region=china && pig build tool && pig build spec && pig build rust && pig build pgrx