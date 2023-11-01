DIST = ubuntu:jammy
DIST_ALT = $(subst :,-,$(DIST))
GR_VERSION = 3.10.7.0
DOCKERHUB_REPO = $(USER)

.PHONY: all build push

all: build

build: docker/oot-dev.dockerfile
	docker build \
	-f docker/oot-dev.dockerfile \
	--build-arg dist=$(DIST) \
	--build-arg gr_version=$(GR_VERSION) \
	-t $(DOCKERHUB_REPO)/gnuradio-oot-dev \
	-t $(DOCKERHUB_REPO)/gnuradio-oot-dev:$(GR_VERSION)-$(DIST_ALT) \
	.

push: build
	docker push $(DOCKERHUB_REPO)/gnuradio-oot-dev:$(GR_VERSION)-$(DIST_ALT)
	docker push $(DOCKERHUB_REPO)/gnuradio-oot-dev
