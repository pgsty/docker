## Docker OS Environment

The 16 standard build images now use PGEXT for repository setup, build tools,
recipes, Rust and pgrx. The base stage remains an OS image. The build stage
gets a binary compiled from the sibling `../pgext` checkout through a named
Docker build context; installing PIG is no longer part of that stage.

```bash
make -C u24a build-build     # compile arm64 pgext and build pgsty/u24a:build
make -C el9 build-build     # compile amd64 pgext and build pgsty/el9:build
make -C u24a run-build
make -C u24a meta            # copy extension.csv and local DEB recipe inputs
docker exec u24a pgext pkg pgvector --pg 18 --mirror
docker exec u24a pgext mak pgvector --pg 18
```

`pgext.mk` accepts `PGEXT_SRC` (default `../../pgext` from each image directory),
`PGEXT_VERSION`, and `RECIPE_SRC`. The generated binaries live in ignored
`.pgext/<architecture>/` directories. A standalone `docker build --target build`
must also supply the named context:

```bash
make -C u24a pgext-bin
docker build --platform linux/arm64 --target build \
  --build-context pgext=./.pgext/arm64 \
  -t pgsty/u24a:pgext-test -f u24a/Dockerfile u24a
```

Metadata refresh copies the local `pgext/db/extension.csv` to
`/root/.config/pgext/extension.csv` and streams recipes without source archives
or old packages. Build commands need no `PGURL` or encoded availability matrix.
Fetch sources inside the builder with `pgext get`; copy only a specific missing
archive as a fallback. New builds put artifacts in isolated directories under
`~/ext/pkg/` and record exact paths and checksums in `~/ext/log/run-*/result.json`.

`refresh-build` updates the PGEXT binary and cargo-pgrx in a temporary container,
then commits only the `:build` image. It does not replace `:latest` with a build
image. Before a production refresh, retain the previous build image under an
explicit rollback tag or archive. A fresh `build-build` applies the complete
new environment setup; an incremental refresh reuses installed tools and
existing repositories. For legacy PIG repository files, explicitly run
`pgext env repo add pgdg pigsty --replace --mirror` to back them up and migrate
them to signed PGEXT definitions.

The PGEXT workflow and command migration are documented in
[`../pgext/docs/build-workflow.md`](../pgext/docs/build-workflow.md).


Dockerhub:

- [debian](https://hub.docker.com/_/debian)
- [ubuntu](https://hub.docker.com/_/ubuntu)
- [almalinux](https://hub.docker.com/_/almalinux)

```bash
docker pull debian:13
docker pull debian:12

docker pull ubuntu:22.04
docker pull ubuntu:24.04
docker pull ubuntu:26.04

docker pull almalinux:10
docker pull almalinux:9
docker pull almalinux:8
```
