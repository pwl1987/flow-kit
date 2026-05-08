#!/bin/bash
# test-context-budget.sh — context-budget.sh 测试
# v1.12.10 新增

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$FLOW_KIT_DIR/lib/context-budget.sh"

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

test_float_cmp() {
    echo "=== test_float_cmp ==="

    if float_cmp 1.5 '>' 1.0; then
        assert_equals "true" "true" "float_cmp 1.5 > 1.0"
    else
        assert_equals "true" "false" "float_cmp 1.5 > 1.0"
    fi

    if float_cmp 0.8 '>=' 0.8; then
        assert_equals "true" "true" "float_cmp 0.8 >= 0.8"
    else
        assert_equals "true" "false" "float_cmp 0.8 >= 0.8"
    fi
}

test_float_mul() {
    echo "=== test_float_mul ==="
    local result
    result=$(float_mul 100 0.8)
    assert_equals "80" "$result" "float_mul 100 * 0.8"
}

test_estimate_tokens() {
    echo "=== test_estimate_tokens ==="

    local result
    result=$(estimate_tokens "你好世界" 0)
    assert_equals "2" "$result" "estimate_tokens Chinese"

    result=$(estimate_tokens "hello world" 0)
    assert_equals "2" "$result" "estimate_tokens English"

    result=$(estimate_tokens "function test() {}" 1)
    assert_equals "3" "$result" "estimate_tokens Code"
}

test_check_budget() {
    echo "=== test_check_budget ==="

    local result
    # check_budget 返回多行 JSON，用 jq 提取 status 字段
    result=$(check_budget 50000 | jq -r '.status' 2>/dev/null || echo "UNKNOWN")
    assert_equals "HEALTHY" "$result" "check_budget 50000 (healthy)"

    result=$(check_budget 85000 | jq -r '.status' 2>/dev/null || echo "UNKNOWN")
    assert_equals "WARNING" "$result" "check_budget 85000 (warning)"

    result=$(check_budget 110000 | jq -r '.status' 2>/dev/null || echo "UNKNOWN")
    assert_equals "BLOCK" "$result" "check_budget 110000 (block)"
}

main() {
    echo "=========================================="
    echo "Test: context-budget.sh"
    echo "=========================================="
    echo ""

    test_float_cmp
    test_float_mul
    test_estimate_tokens
    test_check_budget

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