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

load:
	cat img/d13a.tgz  | gzip -d -c - | docker load
	cat img/d13.tgz   | gzip -d -c - | docker load

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