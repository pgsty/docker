#==============================================================#
# File      :   Makefile
# Desc      :   Pigsty ARM64 systemd container management
# Usage     :   make help
#==============================================================#

IMAGE        ?= pigsty:arm64
NAME         ?= pigsty
ARCH         ?= arm64
DATA         ?= ./data
SSH_PORT     ?= 2222
HTTP_PORT    ?= 8080
PG_PORT      ?= 5432
GRAFANA_PORT ?= 3000

#--------------------------------------------------------------#
# Quick Start
#--------------------------------------------------------------#
# make build     # Build image
# make run       # Create and start container
# make ssh       # SSH into container
# make exec      # Exec bash into container
# make clean     # Stop and remove container
#--------------------------------------------------------------#

default: help

#--------------------------------------------------------------#
# Help
#--------------------------------------------------------------#
help:
	@echo "Pigsty ARM64 Systemd Container"
	@echo ""
	@echo "Usage:"
	@echo "  make build      Build Docker image"
	@echo "  make run        Create and start container (privileged, systemd)"
	@echo "  make start      Start stopped container"
	@echo "  make stop       Stop running container"
	@echo "  make restart    Restart container"
	@echo "  make rm         Remove container"
	@echo "  make clean      Stop and remove container"
	@echo "  make exec       Exec bash into container"
	@echo "  make ssh        SSH into container (port $(SSH_PORT))"
	@echo "  make log        Show container logs"
	@echo "  make status     Show systemd status inside container"
	@echo "  make save       Export image to $(NAME).tgz"
	@echo "  make load       Import image from $(NAME).tgz"
	@echo "  make push       Push image to registry"
	@echo "  make pull       Pull base image"
	@echo "  make rmi        Remove image"
	@echo ""
	@echo "Variables:"
	@echo "  NAME=$(NAME)  IMAGE=$(IMAGE)  DATA=$(DATA)"
	@echo "  SSH_PORT=$(SSH_PORT)  HTTP_PORT=$(HTTP_PORT)  PG_PORT=$(PG_PORT)  GRAFANA_PORT=$(GRAFANA_PORT)"
	@echo ""
	@echo "Examples:"
	@echo "  make build run exec              # Build, run, and exec into container"
	@echo "  make clean build run             # Rebuild from scratch"
	@echo "  DATA=/mnt/data make run          # Custom data directory"

#--------------------------------------------------------------#
# Image Management
#--------------------------------------------------------------#
build:
	docker build --platform=linux/$(ARCH) -t $(IMAGE) .

pull:
	docker pull --platform=linux/$(ARCH) jrei/systemd-ubuntu:24.04

push:
	docker push $(IMAGE)

save:
	docker save $(IMAGE) | gzip -c > $(NAME).tgz

load:
	gzip -d -c $(NAME).tgz | docker load

rmi:
	docker rmi $(IMAGE)

#--------------------------------------------------------------#
# Container Lifecycle
#--------------------------------------------------------------#
run:
	docker run -d --privileged \
		--platform=linux/$(ARCH) \
		--name=$(NAME) \
		--hostname=$(NAME) \
		-v $(DATA):/data \
		-v /sys/fs/cgroup:/sys/fs/cgroup:rw \
		-p $(SSH_PORT):22 \
		-p $(HTTP_PORT):80 \
		-p $(PG_PORT):5432 \
		-p $(GRAFANA_PORT):3000 \
		$(IMAGE)
	@echo "Container $(NAME) started"
	@echo "  Data:    $(DATA) -> /data"
	@echo "  SSH:     ssh root@localhost -p $(SSH_PORT) (password: root)"
	@echo "  HTTP:    http://localhost:$(HTTP_PORT)"
	@echo "  PG:      postgres://localhost:$(PG_PORT)"
	@echo "  Grafana: http://localhost:$(GRAFANA_PORT)"

start:
	docker start $(NAME)

stop:
	docker stop $(NAME)

restart:
	docker restart $(NAME)

rm:
	docker rm $(NAME)

clean: stop rm

#--------------------------------------------------------------#
# Container Access
#--------------------------------------------------------------#
exec:
	docker exec -it -w /root/pigsty $(NAME) /bin/bash -l

ssh:
	ssh root@localhost -p $(SSH_PORT)

log:
	docker logs -f $(NAME)

status:
	docker exec -it $(NAME) systemctl status

ps:
	docker exec -it $(NAME) ps aux

#--------------------------------------------------------------#
# Inspection
#--------------------------------------------------------------#
ip:
	@docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(NAME)

inspect:
	docker inspect $(NAME)

top:
	docker top $(NAME)

#--------------------------------------------------------------#
# Batch Operations
#--------------------------------------------------------------#
all: build run

rebuild: clean build run

.PHONY: default help build pull push save load rmi \
        run start stop restart rm clean \
        exec ssh log status ps ip inspect top \
        all rebuild
