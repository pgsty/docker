IMG=u24a
ARCH=arm64

default: exec

# Init
exec:
	docker exec -it $(IMG) /bin/bash
init: full exec
mini:
	docker run --name=$(IMG) --platform=linux/$(ARCH) -d -it $(IMG):mini /bin/bash
full:
	docker run --name=$(IMG) --platform=linux/$(ARCH) -d -it $(IMG):full /bin/bash

# Containers
clean: stop rm
start:
	docker start $(IMG)
stop:
	docker stop $(IMG)
rm:
	docker rm $(IMG)

# Specs
meta: exts spec
exts:
	docker cp ~/pgsty/pgext/db/extension.csv $(IMG):/root/.pig/extension.csv
spec:
	docker exec -it $(IMG) rm -rf /root/ext/debbuild
	docker cp -a ~/pgsty/deb/debbuild $(IMG):/root/ext/debbuild
	docker exec -it $(IMG) rsync -avz /root/ext/debbuild/ /root/debbuild/

# Images
save:
	docker save $(IMG):latest | gzip -c > $(IMG).tgz
load:
	cat $(IMG).tgz | gzip -d -c - | docker load
rmi:
	docker rmi   $(IMG):mini
	docker rmi   $(IMG):full

# Building
build: build-mini build-full
build-mini:
	docker build --no-cache --platform=linux/$(ARCH) --target mini -t $(IMG):mini -f Dockerfile .
build-full:
	docker build --no-cache --platform=linux/$(ARCH) --target full -t $(IMG):full -f Dockerfile .
pull:
	docker pull --platform=linux/$(ARCH) ubuntu:24.04