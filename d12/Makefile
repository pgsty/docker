REPO=pgsty
NAME=d12
IMG=$(REPO)/$(NAME)
ARCH=amd64
CTN=$(NAME)
CTN_BASE=$(NAME)-base

default: exec

# Init
exec:
	docker exec -it $(CTN) /bin/bash
init: run-build exec
run-base:
	docker run --name=$(CTN_BASE) --platform=linux/$(ARCH) -d -it $(IMG) /bin/bash
run-build:
	docker run --name=$(CTN) --platform=linux/$(ARCH) -d -it $(IMG):build /bin/bash

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

# Specs
meta: exts spec
exts:
	docker cp ~/pgsty/pgext/db/extension.csv $(CTN):/root/.pig/extension.csv
spec:
	docker exec -it $(CTN) rm -rf /root/ext/debbuild
	docker cp -a ~/pgsty/deb/debbuild $(CTN):/root/ext/debbuild
	docker exec -it $(CTN) rsync -avz /root/ext/debbuild/ /root/debbuild/

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
build-build:
	docker build --platform=linux/$(ARCH) --target build -t $(IMG):build -f Dockerfile .
pull:
	docker pull --platform=linux/$(ARCH) debian:12.13
