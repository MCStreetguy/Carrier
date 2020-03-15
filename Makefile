BUILD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(BUILD_ARGS):;@:)

.PHONY: all build publish fix-permissions
default: all

all: fix-permissions
	@./build/build.sh

build: fix-permissions
	@./build/build.sh --no-publish ${BUILD_ARGS}

publish:
	@./build/build.sh --push-only ${BUILD_ARGS}

fix-permissions:
	@chmod +x container/bin/*
	@chmod +x container/usr/bin/*
	@chmod +x container/etc/carrier/defaultenv
	@chmod +x container/etc/carrier/prepare