sync:
	rsync -avz ./ ai:~/pgsty/docker/

s2:
	rsync -avz ./ j2:~/docker/

dump:
	mkdir -p img
	docker save d13a:full  | gzip -c - > img/d13a.tgz
	docker save d13:full   | gzip -c - > img/d13.tgz
	docker save d12a:full  | gzip -c - > img/d12a.tgz
	docker save d12:full   | gzip -c - > img/d12.tgz

	docker save u22a:full  | gzip -c - > img/u22a.tgz
	docker save u22:full   | gzip -c - > img/u22.tgz
	docker save u24a:full  | gzip -c - > img/u24a.tgz
	docker save u24:full   | gzip -c - > img/u24.tgz

du:
	cd d12   && make meta
	cd d12a  && make meta
	cd d13   && make meta
	cd d13a  && make meta

uu:
	cd u22   && make meta
	cd u22a  && make meta
	cd u24   && make meta
	cd u24a  && make meta

load:
	cat img/d13a.tgz | gzip -d -c - | docker load
	cat img/d13.tgz  | gzip -d -c - | docker load
	cat img/d12a.tgz | gzip -d -c - | docker load
	cat img/d12.tgz  | gzip -d -c - | docker load
	cat img/u22a.tgz | gzip -d -c - | docker load
	cat img/u22.tgz  | gzip -d -c - | docker load
	cat img/u24a.tgz | gzip -d -c - | docker load
	cat img/u24.tgz  | gzip -d -c - | docker load

sync-img:
	rsync -avz ./img/ ai:~/pgsty/docker/img/
sync-full:
	rsync -avz ./ ai:~/pgsty/docker/

build-x: build-d12 build-d13 build-u22 build-u24 build-el8 build-el9 build-el10

build-d12:
	$(MAKE) -C d12 build

build-d13:
	$(MAKE) -C d13 build

build-u22:
	$(MAKE) -C u22 build

build-u24:
	$(MAKE) -C u24 build

build-el8:
	$(MAKE) -C el8 build

build-el9:
	$(MAKE) -C el9 build

build-el10:
	$(MAKE) -C el10 build

build-a: build-d12a build-d13a build-u22a build-u24a build-el8a build-el9a build-el10a

build-d12a:
	$(MAKE) -C d12a build

build-d13a:
	$(MAKE) -C d13a build

build-u22a:
	$(MAKE) -C u22a build

build-el9a:
	$(MAKE) -C el9a build

build-el8a:
	$(MAKE) -C el8a build

build-el10a:
	$(MAKE) -C el10a build

build-u24a:
	$(MAKE) -C u24a build
