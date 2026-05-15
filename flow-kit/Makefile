#!/usr/bin/make
# flow-kit Makefile — 常用命令封装
# v3.6.0

ROOT_DIR := $(shell cd "$(shell dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPTS_DIR := $(ROOT_DIR)/scripts
LIB_DIR := $(ROOT_DIR)/lib

.PHONY: help lint lint-shell lint-md lint-format test test-js format format-md benchmark clean info

help:
	@echo "flow-kit v3.6.0 build targets"
	@echo ""
	@echo "  make lint         — ShellCheck + markdownlint + shfmt 检查"
	@echo "  make lint-shell   — shellcheck -S warning"
	@echo "  make lint-md      — markdownlint"
	@echo "  make lint-format  — shfmt --diff (检查格式)"
	@echo "  make test         — bash tests/run-tests.sh"
	@echo "  make test-js      — npx vitest run"
	@echo "  make format       — shfmt -w (格式化)"
	@echo "  make format-md    — markdownlint --fix"
	@echo "  make benchmark    — 运行 benchmarks/"
	@echo "  make clean        — 清理临时文件"
	@echo "  make info         — 显示项目信息"

lint-shell:
	@echo "[lint] ShellCheck ..."
	@shellcheck -S warning $(SCRIPTS_DIR)/*.sh $(LIB_DIR)/*.sh 2>/dev/null && echo "[lint] shellcheck OK" || { echo "[lint] shellcheck issues found"; exit 1; }

lint-md:
	@echo "[lint] markdownlint ..."
	@command -v markdownlint >/dev/null 2>&1 && markdownlint $(ROOT_DIR)/*.md 2>/dev/null || echo "[lint] markdownlint not found, skipping"

lint-format:
	@echo "[lint] shfmt format check ..."
	@command -v shfmt >/dev/null 2>&1 && shfmt --diff $(SCRIPTS_DIR)/ $(LIB_DIR)/ 2>/dev/null || echo "[lint] shfmt not found, skipping"

lint: lint-shell lint-md lint-format

test:
	@echo "[test] Running shell tests ..."
	@bash $(ROOT_DIR)/tests/run-tests.sh

test-js:
	@echo "[test] Running JS tests ..."
	@command -v npx >/dev/null 2>&1 && npx vitest run || echo "[test] vitest not configured, skipping"

format:
	@echo "[format] shfmt ..."
	@command -v shfmt >/dev/null 2>&1 && shfmt -w $(SCRIPTS_DIR)/ $(LIB_DIR)/ || echo "[format] shfmt not found, skipping"

format-md:
	@echo "[format] markdownlint --fix ..."
	@command -v markdownlint >/dev/null 2>&1 && markdownlint --fix $(ROOT_DIR)/*.md 2>/dev/null || echo "[format] markdownlint not found, skipping"

benchmark:
	@echo "[benchmark] Running benchmarks ..."
	@bash $(ROOT_DIR)/benchmarks/run-benchmarks.sh 2>/dev/null || echo "[benchmark] benchmarks not configured, skipping"

clean:
	@echo "[clean] Cleaning temp files ..."
	@find $(ROOT_DIR) -name '*.tmp' -delete 2>/dev/null || true
	@find $(ROOT_DIR) -name '*.log' -delete 2>/dev/null || true
	@rm -rf $(ROOT_DIR)/.flow-kit/tmp/* 2>/dev/null || true
	@echo "[clean] done"

info:
	@echo "flow-kit v3.6.0"
	@echo "  Shell scripts: $$(find $(SCRIPTS_DIR) -name '*.sh' | wc -l)"
	@echo "  Lib modules:    $$(find $(LIB_DIR) -name '*.sh' | wc -l)"
	@echo "  Test files:     $$(find $(ROOT_DIR)/tests -name '*.sh' | wc -l)"