DIST = ubuntu:focal
DIST_ALT = $(subst :,-,$(DIST))
GR_VERSION = 3.9.4
DOCKERHUB_REPO = $(USER)

.PHONY: all build push

all: build

build: Dockerfile
	docker build \
	--build-arg dist=$(DIST) \
	--build-arg gr_version=$(GR_VERSION) \
	-t $(DOCKERHUB_REPO)/gnuradio-oot-dev \
	-t $(DOCKERHUB_REPO)/gnuradio-oot-dev:$(GR_VERSION)-$(DIST_ALT) \
	.

push: build
	docker push $(DOCKERHUB_REPO)/gnuradio-oot-dev:$(GR_VERSION)-$(DIST_ALT)
	docker push $(DOCKERHUB_REPO)/gnuradio-oot-dev
