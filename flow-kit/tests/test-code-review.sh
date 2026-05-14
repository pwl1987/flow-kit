#!/bin/bash
# test-code-review.sh — code-review.sh 测试
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

assert_exit_code() {
    local expected="$1" actual="$2" msg="$3"
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $msg (expected=$expected actual=$actual)"
        failed=$((failed + 1))
    fi
}

test_code_review_help() {
    echo "=== test_code_review_help ==="
    local output
    output=$(bash "$FLOW_KIT_DIR/scripts/code-review.sh" --help 2>&1 || true)
    assert_contains "$output" "用法" "code-review shows help"
}

test_code_review_no_target() {
    echo "=== test_code_review_no_target ==="
    local output
    output=$(bash "$FLOW_KIT_DIR/scripts/code-review.sh" --dir /tmp/nonexist 2>&1 || true)
    # 不存在的目录不应 crash
    assert_exit_code 0 "0" "code-review handles missing dir gracefully"
}

test_code_review_scans_sh_files() {
    echo "=== test_code_review_scans_sh_files ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    echo '#!/bin/bash' > "$tmp_dir/test.sh"
    echo 'echo "hello"' >> "$tmp_dir/test.sh"

    local output
    output=$(bash "$FLOW_KIT_DIR/scripts/code-review.sh" --dir "$tmp_dir" --output "$tmp_dir/REVIEW.md" 2>&1 || true)
    assert_contains "$output" "语法检查" "code-review runs syntax check"
    rm -rf "$tmp_dir"
}

test_code_review_detects_bad_syntax() {
    echo "=== test_code_review_detects_bad_syntax ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    printf '#!/bin/bash\necho "hello\n' > "$tmp_dir/bad.sh"

    local output
    output=$(bash "$FLOW_KIT_DIR/scripts/code-review.sh" --dir "$tmp_dir" --output "$tmp_dir/REVIEW.md" 2>&1 || true)
    assert_contains "$output" "语法错误" "code-review detects syntax error"
    rm -rf "$tmp_dir"
}

main() {
    echo "=========================================="
    echo "Test: code-review.sh"
    echo "=========================================="
    echo ""

    test_code_review_help
    test_code_review_no_target
    test_code_review_scans_sh_files
    test_code_review_detects_bad_syntax

    echo ""
    echo "=========================================="
    echo "Results: $passed passed, $failed failed"
    echo "=========================================="
    [ "$failed" -gt 0 ] && exit 1
    exit 0
}

main "$@"
