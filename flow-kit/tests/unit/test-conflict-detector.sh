#!/bin/bash
# test-conflict-detector.sh — conflict-detector.sh 单元测试
# v3.5.4 TDD 增强：文件冲突检测 + 依赖冲突检测

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

passed=0
failed=0

assert_equals() {
    local expected="$1" actual="$2" msg="$3"
    if [[ "$expected" == "$actual" ]]; then
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
        echo "  Haystack: $haystack"
        failed=$((failed + 1))
    fi
}

assert_success() {
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}: $desc"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $desc"
        failed=$((failed + 1))
    fi
}

assert_failure() {
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then
        echo -e "${RED}FAIL${NC}: $desc (expected failure but succeeded)"
        failed=$((failed + 1))
    else
        echo -e "${GREEN}PASS${NC}: $desc"
        passed=$((passed + 1))
    fi
}

#------------------------------------------------------------------------------
# 测试：classify_requirement 分类"bug"/"修复"关键词
#------------------------------------------------------------------------------
test_classify_bug_keyword() {
    echo "=== test_classify_bug_keyword ==="
    source "$FLOW_KIT_DIR/lib/conflict-detector.sh" 2>/dev/null || true

    local result
    result=$(classify_requirement "修复登录 bug")
    assert_equals "紧急修复" "$result" "修复+bug → 紧急修复"

    result=$(classify_requirement "BUG 导致崩溃")
    assert_equals "紧急修复" "$result" "BUG全大写 → 紧急修复"

    result=$(classify_requirement "修复安全漏洞")
    assert_equals "紧急修复" "$result" "修复安全漏洞 → 紧急修复"

    result=$(classify_requirement "error 处理优化")
    assert_equals "紧急修复" "$result" "error → 紧急修复"
}

#------------------------------------------------------------------------------
# 测试：detect_file_conflict 检测两个变更修改同一文件
#------------------------------------------------------------------------------
test_detect_file_conflict_between_changes() {
    echo "=== test_detect_file_conflict_between_changes ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/.specs/change-A"
    mkdir -p "$tmp_dir/.specs/change-B"

    # change-A 修改 paths.sh 和 session-state.sh
    echo "修改 flow-kit/lib/paths.sh" > "$tmp_dir/.specs/change-A/TASK.md"
    echo "修改 flow-kit/lib/session-state.sh" >> "$tmp_dir/.specs/change-A/TASK.md"
    echo "需求：优化路径处理" > "$tmp_dir/.specs/change-A/REQUIREMENT.md"

    # change-B 也修改 paths.sh（冲突）
    echo "修改 flow-kit/lib/paths.sh" > "$tmp_dir/.specs/change-B/TASK.md"
    echo "需求：添加新路径解析" > "$tmp_dir/.specs/change-B/REQUIREMENT.md"

    source "$FLOW_KIT_DIR/lib/conflict-detector.sh" 2>/dev/null || true

    local result
    set +e
    result=$(detect_file_conflict "change-A" "change-B" "$tmp_dir" 2>&1)
    local ec=$?
    set -e

    assert_contains "$result" "paths.sh" "文件冲突检测到 paths.sh"
    rm -rf "$tmp_dir"
}

#------------------------------------------------------------------------------
# 测试：detect_file_conflict 检测并发编辑同一文件
#------------------------------------------------------------------------------
test_detect_concurrent_edit_conflict() {
    echo "=== test_detect_concurrent_edit_conflict ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/.specs/change-A"
    mkdir -p "$tmp_dir/.specs/change-B"

    # 两个变更都修改 conflict-detector.sh
    echo "修改 conflict-detector.sh 添加新检测" > "$tmp_dir/.specs/change-A/TASK.md"
    echo "修改 conflict-detector.sh 修复bug" > "$tmp_dir/.specs/change-B/TASK.md"

    local result
    result=$(source "$FLOW_KIT_DIR/lib/conflict-detector.sh" 2>/dev/null && \
        detect_file_conflict "change-A" "change-B" "$tmp_dir" 2>&1 || echo "no-conflict")

    assert_contains "$result" "conflict-detector.sh" "并发编辑检测到 conflict-detector.sh"
    rm -rf "$tmp_dir"
}

#------------------------------------------------------------------------------
# 测试：detect_dependency_conflict 检测依赖文件被删除
#------------------------------------------------------------------------------
test_detect_dependency_conflict_deleted() {
    echo "=== test_detect_dependency_conflict_deleted ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/.specs/change-A"

    # change-A 修改 session-state.sh
    echo "修改 lib/session-state.sh" > "$tmp_dir/.specs/change-A/TASK.md"

    # 检测目标：session-state.sh 被修改 → 依赖它的模块冲突
    local result
    result=$(source "$FLOW_KIT_DIR/lib/conflict-detector.sh" 2>/dev/null && \
        detect_dependency_conflict "lib/session-state.sh" "change-A" "$tmp_dir" 2>&1 || echo "no-conflict")

    assert_contains "$result" "session-state.sh" "依赖冲突检测到 session-state.sh"
    rm -rf "$tmp_dir"
}

#------------------------------------------------------------------------------
# 测试：detect_dependency_conflict 检测依赖模块被修改
#------------------------------------------------------------------------------
test_detect_dependency_conflict_modified() {
    echo "=== test_detect_dependency_conflict_modified ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/.specs/change-A"

    echo "修改 lib/paths.sh" > "$tmp_dir/.specs/change-A/TASK.md"

    # paths.sh 被修改，影响依赖它的 module
    local result
    result=$(source "$FLOW_KIT_DIR/lib/conflict-detector.sh" 2>/dev/null && \
        detect_dependency_conflict "lib/paths.sh" "change-A" "$tmp_dir" 2>&1 || echo "no-conflict")

    assert_contains "$result" "paths.sh" "依赖冲突检测到 paths.sh"
    rm -rf "$tmp_dir"
}

#------------------------------------------------------------------------------
# 测试：无冲突时应返回失败
#------------------------------------------------------------------------------
test_no_conflict_returns_failure() {
    echo "=== test_no_conflict_returns_failure ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/.specs/change-A"
    mkdir -p "$tmp_dir/.specs/change-B"

    # change-A 修改 paths.sh
    echo "修改 lib/paths.sh" > "$tmp_dir/.specs/change-A/TASK.md"

    # change-B 修改其他文件（无冲突）
    echo "修改 docs/README.md" > "$tmp_dir/.specs/change-B/TASK.md"

    local result
    result=$(source "$FLOW_KIT_DIR/lib/conflict-detector.sh" 2>/dev/null && \
        detect_file_conflict "change-A" "change-B" "$tmp_dir" 2>&1 && echo "found" || echo "none")

    assert_equals "none" "$result" "无冲突时返回 none"
    rm -rf "$tmp_dir"
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    echo "=========================================="
    echo "TDD 测试: conflict-detector.sh 增强"
    echo "=========================================="
    echo ""

    test_classify_bug_keyword
    test_detect_file_conflict_between_changes
    test_detect_concurrent_edit_conflict
    test_detect_dependency_conflict_deleted
    test_detect_dependency_conflict_modified
    test_no_conflict_returns_failure

    echo ""
    echo "=========================================="
    echo "Results: $passed passed, $failed failed"
    echo "=========================================="
    [[ "$failed" -gt 0 ]] && exit 1
    exit 0
}

main "$@"