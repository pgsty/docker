REPO=pgsty
NAME=el100
IMG=$(REPO)/$(NAME)
ARCH=amd64
CTN=$(NAME)
CTN_BASE=$(NAME)-base
CTN_UPDATE=$(NAME)-refresh
PIG_VERSION?=1.8.0
PGRX_VERSION?=0.19.1

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
update-build:
	docker exec $(CTN_UPDATE) bash -lc 'set -eux; pig update --region=china --version $(PIG_VERSION); pig build pgrx --pgrx $(PGRX_VERSION)'
commit-build:
	docker stop $(CTN_UPDATE)
	docker commit $(CTN_UPDATE) $(IMG):build
	docker tag $(IMG):build $(IMG):latest
	docker tag $(IMG):build $(IMG)
	docker rm $(CTN_UPDATE)
refresh-build: run-update update-build commit-build

# Specs
meta:
	docker cp ~/pgsty/pgext/db/extension.csv $(CTN):/root/.pig/extension.csv
spec:
	docker exec -it $(CTN) rm -rf /root/ext/rpmbuild
	docker cp -a ~/pgsty/rpm/rpmbuild $(CTN):/root/ext/rpmbuild
	docker exec -it $(CTN) rsync -avz /root/ext/rpmbuild/ /root/rpmbuild/

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
	docker pull --platform=linux/$(ARCH) rockylinux/rockylinux:10.0.20250606
