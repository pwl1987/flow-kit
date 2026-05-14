.PHONY: lint test format format-check lint-md benchmark clean

# flow-kit Makefile v3.5.0

SH_FILES := $(shell find flow-kit -name '*.sh' -not -path '*/.git/*')
MD_FILES := $(shell find flow-kit -name '*.md' -not -path '*/.git/*')

lint:
	shellcheck -s bash $(SH_FILES)

lint-md:
	markdownlint $(MD_FILES)

test:
	bash flow-kit/tests/run-tests.sh

format:
	shfmt -w $(SH_FILES)

format-check:
	shfmt -d $(SH_FILES)

benchmark:
	@echo "Benchmark not yet configured. Install hyperfine."

TMP_DIR := flow-kit/.flow-kit/tmp

clean:
	rm -rf $(TMP_DIR)/*.tmp $(TMP_DIR)/*.pid
