#!/bin/bash
# test-health-scheduler.sh — health-scheduler.sh 单元测试
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 计数器
PASS=0; FAIL=0; SKIP=0

assert_contains() {
    local desc="$1" haystack="$2" needle="$3"
    if echo "$haystack" | grep -qF "$needle"; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
        echo "FAIL: $desc | expected to contain: '$needle'"
    fi
}

# 准备 mock 项目目录（需要 .git 欺骗 paths.sh，需要 tmp/logs 避免 find 管道失败）
setup() {
    TEST_DIR=$(mktemp -d "/tmp/test-health-$$-XXXXXX")
    mkdir -p "$TEST_DIR/.git" "$TEST_DIR/.flow-kit/logs" "$TEST_DIR/.flow-kit/tmp"
}

teardown() {
    rm -rf "$TEST_DIR"
}

# === 测试用例 ===

# 正常路径：完整 session-state.json → 报告显示完整
test_health_check_with_valid_session_state() {
    echo "=== test_health_check_with_valid_session_state ==="
    setup

    mkdir -p "$TEST_DIR/.flow-kit"
    echo '{"v":2,"change":"test","phase":1,"status":"wip"}' > "$TEST_DIR/.flow-kit/session-state.json"

    local output
    output=$(CLAUDE_PROJECT_DIR="$TEST_DIR" MODE=oneshot \
        bash "$PROJECT_DIR/scripts/health-scheduler.sh" 2>/dev/null || true)

    assert_contains "report shows session complete" "$output" "session-state.json 完整"
    assert_contains "report has title" "$output" "健康巡检报告"

    teardown
}

# 边界条件：无 session-state.json → 报告显示不存在
test_health_check_no_session_state() {
    echo "=== test_health_check_no_session_state ==="
    setup

    local output
    output=$(CLAUDE_PROJECT_DIR="$TEST_DIR" MODE=oneshot \
        bash "$PROJECT_DIR/scripts/health-scheduler.sh" 2>/dev/null || true)

    assert_contains "report shows session not exist" "$output" "session-state.json 不存在"

    teardown
}

# 边界条件：损坏的 session-state.json → 报告显示损坏
test_health_check_corrupt_session_state() {
    echo "=== test_health_check_corrupt_session_state ==="
    setup

    mkdir -p "$TEST_DIR/.flow-kit"
    echo 'NOT VALID JSON {{{' > "$TEST_DIR/.flow-kit/session-state.json"

    local output
    output=$(CLAUDE_PROJECT_DIR="$TEST_DIR" MODE=oneshot \
        bash "$PROJECT_DIR/scripts/health-scheduler.sh" 2>/dev/null || true)

    assert_contains "report shows session corrupt" "$output" "session-state.json 损坏"

    teardown
}

# 正常路径：--now 创建报告文件
test_health_check_creates_report_file() {
    echo "=== test_health_check_creates_report_file ==="
    setup

    CLAUDE_PROJECT_DIR="$TEST_DIR" \
        bash "$PROJECT_DIR/scripts/health-scheduler.sh" --now >/dev/null 2>&1 || true

    local report_count
    report_count=$(find "$TEST_DIR/.flow-kit/logs" -name 'health-report-*.md' 2>/dev/null | wc -l)
    if [ "$report_count" -ge 1 ]; then
        PASS=$((PASS + 1))
    else
        FAIL=$((FAIL + 1))
        echo "FAIL: report file not created in logs dir"
    fi

    teardown
}

# 错误路径：无参数 + MODE!=oneshot → 显示用法
test_no_args_shows_usage() {
    echo "=== test_no_args_shows_usage ==="
    setup

    local output
    output=$(CLAUDE_PROJECT_DIR="$TEST_DIR" MODE=manual \
        bash "$PROJECT_DIR/scripts/health-scheduler.sh" 2>&1 || true)

    assert_contains "shows usage hint" "$output" "用法"

    teardown
}

# === 执行 ===
test_health_check_with_valid_session_state
test_health_check_no_session_state
test_health_check_corrupt_session_state
test_health_check_creates_report_file
test_no_args_shows_usage

# === 报告 ===
echo ""
echo "=== 测试结果: test-health-scheduler.sh ==="
echo "通过: $PASS"
echo "失败: $FAIL"
[[ $FAIL -eq 0 ]] && echo "全部通过" || echo "存在失败"
exit $FAIL
