#!/bin/bash
# test-plan-generate.sh — plan-generate.sh 测试
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

assert_file_exists() {
    local file="$1" msg="$2"
    if [ -f "$file" ]; then
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $msg (file not found)"
        failed=$((failed + 1))
    fi
}

test_plan_generate_help() {
    echo "=== test_plan_generate_help ==="
    local output
    output=$(PROJECT_DIR=/tmp bash "$FLOW_KIT_DIR/scripts/plan-generate.sh" --help 2>&1 || true)
    assert_contains "$output" "plan-generate" "plan-generate shows help"
}

test_plan_generate_missing_review() {
    echo "=== test_plan_generate_missing_review ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    local output
    output=$(PROJECT_DIR=/tmp bash "$FLOW_KIT_DIR/scripts/plan-generate.sh" --input "/tmp/nonexist-REVIEW.md" --output "$tmp_dir" 2>&1 || true)
    # 缺少 review 文件应报错
    assert_contains "$output" "不存在" "plan-generate handles missing review"
    rm -rf "$tmp_dir"
}

test_plan_generate_creates_plan() {
    echo "=== test_plan_generate_creates_plan ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)

    # 创建 mock REVIEW.md
    cat > "$tmp_dir/REVIEW.md" << 'EOF'
# Code Review Report

## Summary
Total: 2 files reviewed

## Findings

### File: test.sh
- P1: Missing error handling
- P2: Variable not quoted

### File: lib.sh
- P0: Security vulnerability in eval
EOF

    local output
    output=$(PROJECT_DIR=/tmp bash "$FLOW_KIT_DIR/scripts/plan-generate.sh" --input "$tmp_dir/REVIEW.md" --output "$tmp_dir/DEV-PLAN.md" 2>&1 || true)
    assert_file_exists "$tmp_dir/DEV-PLAN.md" "plan-generate creates DEV-PLAN.md"
    rm -rf "$tmp_dir"
}

main() {
    echo "=========================================="
    echo "Test: plan-generate.sh"
    echo "=========================================="
    echo ""

    test_plan_generate_help
    test_plan_generate_missing_review
    test_plan_generate_creates_plan

    echo ""
    echo "=========================================="
    echo "Results: $passed passed, $failed failed"
    echo "=========================================="
    [ "$failed" -gt 0 ] && exit 1
    exit 0
}

main "$@"
