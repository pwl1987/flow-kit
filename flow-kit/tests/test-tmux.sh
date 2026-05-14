#!/bin/bash
# test-tmux.sh — tmux 脚本基础测试
# v3.5.0 新增

set -euo pipefail

FLOW_KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
passed=0
failed=0

assert_contains() {
    local haystack="$1" needle="$2" msg="$3"
    if echo "$haystack" | grep -qF "$needle"; then
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $msg"
        echo "  Expected: $needle"
        failed=$((failed + 1))
    fi
}

test_tmux_scripts_source_error_handler() {
    echo "=== test_tmux_scripts_source_error_handler ==="
    for script in tmux-init tmux-run tmux-aggregate tmux-cleanup; do
        local f="$FLOW_KIT_DIR/scripts/$script.sh"
        assert_contains "$(cat "$f")" "error-handler" "$script.sh sources error-handler"
    done
}

test_tmux_scripts_have_set_eu() {
    echo "=== test_tmux_scripts_have_set_eu ==="
    for script in tmux-init tmux-run tmux-aggregate tmux-cleanup; do
        local f="$FLOW_KIT_DIR/scripts/$script.sh"
        assert_contains "$(cat "$f")" "set -euo pipefail" "$script.sh has set -euo pipefail"
    done
}

test_tmux_init_no_tmux() {
    echo "=== test_tmux_init_no_tmux ==="
    # 无 tmux 时应报错而非 crash
    local output
    output=$(PATH="/usr/bin:/bin" bash "$FLOW_KIT_DIR/scripts/tmux-init.sh" 2>&1 || true)
    assert_contains "$output" "tmux" "tmux-init mentions tmux dependency"
}

main() {
    echo "=========================================="
    echo "Test: tmux scripts"
    echo "=========================================="
    echo ""

    test_tmux_scripts_source_error_handler
    test_tmux_scripts_have_set_eu
    test_tmux_init_no_tmux

    echo ""
    echo "=========================================="
    echo "Results: $passed passed, $failed failed"
    echo "=========================================="
    [ "$failed" -gt 0 ] && exit 1
    exit 0
}

main "$@"
