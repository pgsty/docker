REPO=pgsty
NAME=d13a
IMG=$(REPO)/$(NAME)
ARCH=arm64
CTN=$(NAME)
CTN_BASE=$(NAME)-base
CTN_UPDATE=$(NAME)-refresh
PGRX_VERSION?=0.19.3

default: exec

# Init
exec:
	docker exec -it $(CTN) /bin/bash
init: run-build exec
run-base:
	docker run --name=$(CTN_BASE) --platform=linux/$(ARCH) -d -it $(IMG) /bin/bash
run-build:
	docker run --name=$(CTN) --platform=linux/$(ARCH) -d -it $(IMG):build /bin/bash
run-update:
	-docker rm -f $(CTN_UPDATE)
	docker run --name=$(CTN_UPDATE) --platform=linux/$(ARCH) -d -it $(IMG):build /bin/bash

# Containers
clean: stop rm stop-base rm-base
start:
	docker start $(CTN)
stop:
	-docker stop $(CTN)
rm:
	-docker rm $(CTN)
start-base:
	docker start $(CTN_BASE)
stop-base:
	-docker stop $(CTN_BASE)
rm-base:
	-docker rm $(CTN_BASE)

# Incremental update
commit-build:
	docker stop $(CTN_UPDATE)
	docker commit $(CTN_UPDATE) $(IMG):build
	docker rm $(CTN_UPDATE)
refresh-build:
	$(MAKE) run-update
	$(MAKE) update-build
	$(MAKE) commit-build

# Specs
meta: exts spec

# Images
save:
	docker save $(IMG):build | gzip -c > $(NAME).tgz
load:
	cat $(NAME).tgz | gzip -d -c - | docker load
rmi:
	-docker rmi $(IMG):build
	-docker rmi $(IMG):latest
	-docker rmi $(IMG)

# Building
build: build-base build-build
build-base:
	docker build --platform=linux/$(ARCH) --target base -t $(IMG):latest -t $(IMG) -f Dockerfile .
build-build: pgext-bin
	docker build --build-context pgext=$(PGEXT_DIR) --platform=linux/$(ARCH) --target build -t $(IMG):build -f Dockerfile .
pull:
	docker pull --platform=linux/$(ARCH) debian:trixie-20261027

include ../pgext.mk
