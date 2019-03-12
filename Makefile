# Benchmark multiple service meshes

include mk/istio.makefile
include mk/sink.makefile

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

ISTIO_NS ?= istio-system

HAS_HELM := $(shell command -v helm;)

.PHONY: bootstrap
bootstrap:
	@# Bootstrap the local required binaries
ifndef HAS_HELM
	echo "Install helm: https://helm.sh/" && exit 1
endif

tmp:
	mkdir -p tmp

.PHONY: disk-clean
disk-clean:
	rm -rf tmp

.PHONY: clean
clean: clean-disk istio-clean
	@# Clean both the local system and remote cluster
