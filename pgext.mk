# Shared PGEXT builder integration. Run from one of the 16 image directories.
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
PGEXT_SRC ?= ../../pgext
PGEXT_DIR ?= ../.pgext/$(ARCH)
PGEXT_BINARY ?= $(PGEXT_DIR)/pgext
PGEXT_VERSION ?= dev
PGEXT_COMMIT := $(shell git -C $(PGEXT_SRC) describe --always --dirty)
RECIPE_FAMILY := $(if $(filter el%,$(NAME)),rpm,deb)
RECIPE_SRC ?= ../../$(RECIPE_FAMILY)/$(RECIPE_FAMILY)build

.PHONY: pgext-bin update-build exts spec
pgext-bin:
	mkdir -p $(PGEXT_DIR) $(dir $(PGEXT_BINARY))
	@pgext_bin_tmp=$$(mktemp $(abspath $(PGEXT_DIR))/.pgext-bin.XXXXXX); \
	trap 'rm -f "$$pgext_bin_tmp"' EXIT; \
	cd $(PGEXT_SRC); \
	CGO_ENABLED=0 GOOS=linux GOARCH=$(ARCH) go build -ldflags '-X pgext/cmd.Version=$(PGEXT_VERSION) -X pgext/cmd.Commit=$(PGEXT_COMMIT)' -o "$$pgext_bin_tmp" .; \
	mv -f "$$pgext_bin_tmp" $(abspath $(PGEXT_BINARY))

update-build: pgext-bin
	@pgext_install_tmp=$$(docker exec $(CTN_UPDATE) mktemp /usr/local/bin/.pgext.XXXXXX); \
	trap 'docker exec $(CTN_UPDATE) rm -f "$$pgext_install_tmp"' EXIT; \
	docker cp $(PGEXT_BINARY) $(CTN_UPDATE):"$$pgext_install_tmp"; \
	docker exec $(CTN_UPDATE) chmod 0755 "$$pgext_install_tmp"; \
	docker exec $(CTN_UPDATE) mv -f "$$pgext_install_tmp" /usr/local/bin/pgext
	docker exec $(CTN_UPDATE) pgext env pgrx --pgrx $(PGRX_VERSION)

exts:
	docker exec $(CTN) mkdir -p /root/.config/pgext
	docker cp $(PGEXT_SRC)/db/extension.csv $(CTN):/root/.config/pgext/extension.csv

spec:
	@set -eu; pgext_stage=$$(docker exec $(CTN) mktemp -d /tmp/pgext-recipes.XXXXXX); \
	trap 'docker exec $(CTN) rm -rf "$$pgext_stage"' EXIT; \
	tar -C $(RECIPE_SRC) --exclude='./SOURCES' --exclude='./RPMS' --exclude='./SRPMS' --exclude='./DEBS' --exclude='./BUILD' --exclude='./BUILDROOT' --exclude='./*/build' --exclude='./*/build-[0-9][0-9]' --exclude='target' --exclude='*.deb' --exclude='*.ddeb' --exclude='*.rpm' -cf - . | docker exec -i $(CTN) tar -C "$$pgext_stage" -xf -; \
	docker exec $(CTN) pgext env spec --from "$$pgext_stage"
