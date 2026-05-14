#!/bin/bash
# test-conflict-detector.sh — conflict-detector.sh 测试
# v3.5.0 新增

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

passed=0
failed=0

assert_equals() {
    local expected="$1" actual="$2" msg="$3"
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

assert_contains() {
    local haystack="$1" needle="$2" msg="$3"
    if echo "$haystack" | grep -qF "$needle"; then
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $msg"
        echo "  Expected to contain: $needle"
        failed=$((failed + 1))
    fi
}

test_classify_requirement() {
    echo "=== test_classify_requirement ==="
    source "$FLOW_KIT_DIR/lib/conflict-detector.sh" 2>/dev/null || true

    local result
    result=$(classify_requirement "修复登录 bug")
    assert_equals "紧急修复" "$result" "classify bug fix"

    result=$(classify_requirement "重构架构设计")
    assert_equals "架构调整" "$result" "classify refactor"

    result=$(classify_requirement "添加新功能")
    assert_equals "功能增强" "$result" "classify feature"

    result=$(classify_requirement "update docs")
    assert_equals "其他" "$result" "classify other"
}

test_detect_conflict_no_change() {
    echo "=== test_detect_conflict_no_change ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/.flow-kit"
    echo '{"v":2,"change":"","phase":0,"status":"init"}' > "$tmp_dir/.flow-kit/session-state.json"

    local result
    result=$(PROJECT_DIR="$tmp_dir" SESSION_STATE_FILE="$tmp_dir/.flow-kit/session-state.json" \
        source "$FLOW_KIT_DIR/lib/conflict-detector.sh" 2>/dev/null && \
        detect_conflict "test task" && echo "conflict" || echo "no-conflict")

    assert_equals "no-conflict" "$result" "no conflict when no active change"
    rm -rf "$tmp_dir"
}

test_detect_file_conflicts() {
    echo "=== test_detect_file_conflicts ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/.flow-kit"
    mkdir -p "$tmp_dir/.specs/change-A"

    # 创建包含文件引用的 specs
    echo "修改 flow-kit/lib/paths.sh" > "$tmp_dir/.specs/change-A/TASK.md"
    echo "修改 flow-kit/lib/paths.sh" > "$tmp_dir/.specs/change-A/REQUIREMENT.md"

    echo '{"v":2,"change":"change-A","phase":2,"status":"wip"}' > "$tmp_dir/.flow-kit/session-state.json"

    local result
    result=$(PROJECT_DIR="$tmp_dir" SESSION_STATE_FILE="$tmp_dir/.flow-kit/session-state.json" \
        source "$FLOW_KIT_DIR/lib/conflict-detector.sh" 2>/dev/null && \
        detect_file_conflicts "change-A" "$tmp_dir" && echo "found" || echo "none")

    assert_contains "found" "found" "file conflict detected for same change"
    rm -rf "$tmp_dir"
}

test_handle_conflict_decision() {
    echo "=== test_handle_conflict_decision ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/.flow-kit"
    echo '{"v":2,"change":"test","phase":1,"status":"wip"}' > "$tmp_dir/.flow-kit/session-state.json"

    local output
    output=$(PROJECT_DIR="$tmp_dir" SESSION_STATE_FILE="$tmp_dir/.flow-kit/session-state.json" \
        source "$FLOW_KIT_DIR/lib/conflict-detector.sh" 2>/dev/null && \
        handle_conflict_decision 1 2>&1 || true)

    assert_contains "$output" "暂停" "decision 1 pauses change"

    output=$(PROJECT_DIR="$tmp_dir" SESSION_STATE_FILE="$tmp_dir/.flow-kit/session-state.json" \
        source "$FLOW_KIT_DIR/lib/conflict-detector.sh" 2>/dev/null && \
        handle_conflict_decision 2 2>&1 || true)

    assert_contains "$output" "backlog" "decision 2 adds to backlog"

    rm -rf "$tmp_dir"
}

main() {
    echo "=========================================="
    echo "Test: conflict-detector.sh"
    echo "=========================================="
    echo ""

    test_classify_requirement
    test_detect_conflict_no_change
    test_detect_file_conflicts
    test_handle_conflict_decision

    echo ""
    echo "=========================================="
    echo "Results: $passed passed, $failed failed"
    echo "=========================================="
    [ "$failed" -gt 0 ] && exit 1
    exit 0
}

main "$@"
