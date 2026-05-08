#!/bin/bash
# test-error-handler.sh — error-handler.sh 测试
# v1.12.10 新增

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$FLOW_KIT_DIR/lib/error-handler.sh"

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

test_error_handler_creation() {
    echo "=== test_error_handler_creation ==="

    local err_file="/tmp/test-error-handler-$$.json"
    trap "rm -f '$err_file'" RETURN

    create_error_context "$err_file" "TEST_ERROR" "test-context"
    if [ -f "$err_file" ]; then
        assert_equals "true" "true" "create_error_context creates file"
    else
        assert_equals "true" "false" "create_error_context creates file"
    fi
}

test_safe_exit() {
    echo "=== test_safe_exit ==="
    local err_file="/tmp/test-error-handler-$$.json"
    trap "rm -f '$err_file'" RETURN

    create_error_context "$err_file" "TEST_ERROR" "test-context"

    local exit_code
    exit_code=0
    safe_exit 0 "$err_file" "test message" 2>/dev/null || exit_code=$?
    assert_equals "0" "$exit_code" "safe_exit 0 returns exit code 0"
}

test_error_context_file_format() {
    echo "=== test_error_context_file_format ==="

    local err_file="/tmp/test-error-handler-$$.json"
    trap "rm -f '$err_file'" RETURN

    create_error_context "$err_file" "TEST_ERROR" "test-context"

    if command -v jq &>/dev/null; then
        local has_type
        has_type=$(jq -r '.type // empty' "$err_file" 2>/dev/null || echo "")
        assert_equals "TEST_ERROR" "$has_type" "error context has type field"

        local has_context
        has_context=$(jq -r '.context // empty' "$err_file" 2>/dev/null || echo "")
        assert_equals "test-context" "$has_context" "error context has context field"
    else
        echo "  SKIP: jq not available"
    fi
}

main() {
    echo "=========================================="
    echo "Test: error-handler.sh"
    echo "=========================================="
    echo ""

    test_error_handler_creation
    test_safe_exit
    test_error_context_file_format

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