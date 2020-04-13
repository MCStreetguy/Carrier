BUILD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(BUILD_ARGS):;@:)

.PHONY: default all build publish fix-permissions all-alpine build-alpine publish-alpine all-ubuntu build-ubuntu publish-ubuntu test-alpine test-ubuntu
default: all

all: fix-permissions all-alpine all-ubuntu

build: fix-permissions build-alpine build-ubuntu

publish: publish-alpine publish-ubuntu

all-alpine: fix-permissions
	./build/build-alpine.sh

build-alpine: fix-permissions
	./build/build-alpine.sh --no-publish ${BUILD_ARGS}

publish-alpine:
	./build/build-alpine.sh --push-only ${BUILD_ARGS}

all-ubuntu: fix-permissions
	./build/build-ubuntu.sh

build-ubuntu: fix-permissions
	./build/build-ubuntu.sh --no-publish ${BUILD_ARGS}

publish-ubuntu:
	./build/build-ubuntu.sh --push-only ${BUILD_ARGS}

test-alpine: fix-permissions
	./build/build-alpine.sh --no-publish latest && docker run -it mcstreetguy/carrier:alpine-edge /bin/bash -it

test-ubuntu: fix-permissions
	./build/build-ubuntu.sh --no-publish latest && docker run -it mcstreetguy/carrier:latest /bin/bash -it

fix-permissions:
	chmod +x container/bin/*
	chmod +x container/usr/bin/*
	chmod +x container/etc/carrier/bin/*
	chmod +x build/alpine/contents/sbin/*
	chmod +x build/ubuntu/contents/sbin/*