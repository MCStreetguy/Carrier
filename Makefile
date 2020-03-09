BUILD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(BUILD_ARGS):;@:)

.PHONY: all build publish
default: all

all:
	@make build && make publish

build:
	@./build/build.sh --no-publish ${BUILD_ARGS}

publish:
	@./build/build.sh --push-only ${BUILD_ARGS}