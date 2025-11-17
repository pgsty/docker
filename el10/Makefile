IMG=el10
ARCH=amd64

default: exec
exec:
	docker exec -it $(IMG) /bin/bash

mini:
	docker run --name=$(IMG) --platform=linux/$(ARCH) -d -it $(IMG):mini /bin/bash
full:
	docker run --name=$(IMG) --platform=linux/$(ARCH) -d -it $(IMG):full /bin/bash

start:
	docker start $(IMG)
stop:
	docker stop $(IMG)
clean:
	docker stop $(IMG) || /bin/true
	docker rm   $(IMG) || /bin/true
meta:
	docker cp ~/pgsty/pgext/db/extension.csv $(IMG):/root/.pig/extension.csv
spec:
	docker exec -it $(IMG) rm -rf /root/ext/rpmbuild
	docker cp -a ~/pgsty/rpm/rpmbuild $(IMG):/root/ext/rpmbuild
	docker exec -it $(IMG) rsync -avz /root/ext/rpmbuild/ /root/rpmbuild/
rmi:
	docker rmi  $(IMG) || /bin/true
save:
	docker save $(IMG):latest | gzip -c > $(IMG).tgz
load:
	cat $(IMG).tgz | gzip -d -c - | docker load
build: build-mini build-full
build-mini:
	docker build --platform=linux/$(ARCH) --target mini -t $(IMG):mini -f Dockerfile .
build-full:
	docker build --platform=linux/$(ARCH) --target full -t $(IMG):full -f Dockerfile .
pull:
	docker pull --platform=linux/$(ARCH) rockylinux/rockylinux:10