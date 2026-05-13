#!/bin/bash
# test-paths.sh — paths.sh 测试
# v2.7.0 新增

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$FLOW_KIT_DIR/lib/paths.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

passed=0
failed=0

assert_equals() {
    local expected="$1"
    local actual="$2"
    local msg="$3"

    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $msg"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        failed=$((failed + 1))
    fi
}

test_paths_loaded() {
    echo "=== test_paths_loaded ==="
    assert_equals "true" "${PATHS_LOADED:-false}" "PATHS_LOADED is set"
}

test_flow_kit_dir() {
    echo "=== test_flow_kit_dir ==="
    assert_equals "true" "$([ -d "$FLOW_KIT_DIR" ] && echo true || echo false)" "FLOW_KIT_DIR exists"
    assert_equals "true" "$([ -d "$LIB_DIR" ] && echo true || echo false)" "LIB_DIR exists"
    assert_equals "true" "$([ -d "$SCRIPTS_DIR" ] && echo true || echo false)" "SCRIPTS_DIR exists"
}

test_scripts_dir() {
    echo "=== test_scripts_dir ==="
    assert_equals "true" "$([ -d "$SCRIPTS_DIR" ] && echo true || echo false)" "SCRIPTS_DIR exists"
    assert_equals "true" "$([ -f "$SCRIPTS_DIR/dispatch.sh" ] && echo true || echo false)" "dispatch.sh exists"
}

test_lib_dir() {
    echo "=== test_lib_dir ==="
    assert_equals "true" "$([ -d "$LIB_DIR" ] && echo true || echo false)" "LIB_DIR exists"
    assert_equals "true" "$([ -f "$LIB_DIR/context-budget.sh" ] && echo true || echo false)" "context-budget.sh exists"
    assert_equals "true" "$([ -f "$LIB_DIR/error-handler.sh" ] && echo true || echo false)" "error-handler.sh exists"
}

test_runtime_dirs() {
    echo "=== test_runtime_dirs ==="
    assert_equals "true" "$([ -d "$TMP_DIR" ] && echo true || echo false)" "TMP_DIR is accessible"
    assert_equals "true" "$([ -d "$LOCK_DIR" ] && echo true || echo false)" "LOCK_DIR is accessible"
}

main() {
    echo "=========================================="
    echo "Test: paths.sh"
    echo "=========================================="
    echo ""

    test_paths_loaded
    test_flow_kit_dir
    test_scripts_dir
    test_lib_dir
    test_runtime_dirs

    echo ""
    echo "=========================================="
    echo "Results: $passed passed, $failed failed"
    echo "=========================================="

    if [ "$failed" -gt 0 ]; then
        exit 1
    fi
    exit 0
}

main "$@"