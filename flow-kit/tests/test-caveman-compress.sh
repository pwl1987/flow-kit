#!/bin/bash
# test-caveman-compress.sh — caveman-compress.sh 测试
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

test_caveman_script_exists() {
    echo "=== test_caveman_script_exists ==="
    [ -f "$FLOW_KIT_DIR/scripts/caveman-compress.sh" ]
    echo -e "${GREEN}PASS${NC}: caveman-compress.sh exists"
    passed=$((passed + 1))
}

test_caveman_has_set_eu() {
    echo "=== test_caveman_has_set_eu ==="
    local content
    content=$(cat "$FLOW_KIT_DIR/scripts/caveman-compress.sh")
    assert_contains "$content" "set -" "caveman-compress has set directive"
}

test_caveman_has_compress_output() {
    echo "=== test_caveman_has_compress_output ==="
    local content
    content=$(cat "$FLOW_KIT_DIR/scripts/caveman-compress.sh")
    assert_contains "$content" "compressed" "caveman-compress produces compressed output"
}

test_caveman_has_max_lines() {
    echo "=== test_caveman_has_max_lines ==="
    local content
    content=$(cat "$FLOW_KIT_DIR/scripts/caveman-compress.sh")
    assert_contains "$content" "MAX_LINES" "caveman-compress has MAX_LINES config"
}

main() {
    echo "=========================================="
    echo "Test: caveman-compress.sh"
    echo "=========================================="
    echo ""

    test_caveman_script_exists
    test_caveman_has_set_eu
    test_caveman_has_compress_output
    test_caveman_has_max_lines

    echo ""
    echo "=========================================="
    echo "Results: $passed passed, $failed failed"
    echo "=========================================="
    [ "$failed" -gt 0 ] && exit 1
    exit 0
}

main "$@"
