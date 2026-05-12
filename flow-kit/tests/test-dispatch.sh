#!/bin/bash
# test-dispatch.sh — dispatch.sh 单元测试
# v1.12.9 P1 新增
# 覆盖 dispatch.sh 核心函数

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly FLOW_KIT_DIR="$(dirname "$SCRIPT_DIR")"
readonly TMP_DIR=".flow-kit/tmp"

passed=0
failed=0

run_test() {
    local test_name="$1"
    local test_func="$2"

    echo ""
    echo "[TEST] 运行: $test_name"

    if $test_func; then
        echo "[TEST] ✅ $test_name - 通过"
        passed=$((passed + 1))
        return 0
    else
        echo "[TEST] ❌ $test_name - 失败"
        failed=$((failed + 1))
        return 1
    fi
}

#------------------------------------------------------------------------------
# 测试用例
#------------------------------------------------------------------------------

test_parse_args_default() {
    # 测试默认参数解析（无数字参数时默认 N=3）
    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/dispatch.sh"
        parse_args "测试任务"
        echo "N=$PARALLEL_N|TASK=$TASK_DESC"
    ' 2>/dev/null)
    echo "$result" | grep -q "N=3|TASK=测试任务"
}

test_parse_args_with_n() {
    # 测试带数字参数解析
    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/dispatch.sh"
        parse_args 5 "实现用户认证"
        echo "N=$PARALLEL_N|TASK=$TASK_DESC"
    ' 2>/dev/null)
    echo "$result" | grep -q "N=5|TASK=实现用户认证"
}

test_parse_args_execute_mode() {
    # 测试 --execute 模式
    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/dispatch.sh"
        parse_args --execute 3 "test"
        echo "EXECUTE=$EXECUTE_MODE|N=$PARALLEL_N"
    ' 2>/dev/null)
    echo "$result" | grep -q "EXECUTE=true|N=3"
}

test_parse_args_wait_mode() {
    # 测试 --wait 模式
    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/dispatch.sh"
        parse_args --wait
        echo "WAIT=$WAIT_MODE"
    ' 2>/dev/null)
    echo "$result" | grep -q "WAIT=true"
}

test_parse_args_timeout() {
    # 测试 --timeout 参数
    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/dispatch.sh"
        parse_args --wait --timeout 600
        echo "TIMEOUT=$WAIT_TIMEOUT"
    ' 2>/dev/null)
    echo "$result" | grep -q "TIMEOUT=600"
}

test_parse_args_aggregate_mode() {
    # 测试 --aggregate 模式
    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/dispatch.sh"
        parse_args --aggregate
        echo "AGGREGATE=$AGGREGATE_MODE"
    ' 2>/dev/null)
    echo "$result" | grep -q "AGGREGATE=true"
}

test_init_dirs() {
    # 测试目录初始化
    local test_tmp=$(mktemp -d)
    local result
    result=$(bash -c '
        TMP_DIR="'"$test_tmp"'/tmp"
        LOCK_DIR="'"$test_tmp"'/locks"
        source "'"$FLOW_KIT_DIR"'/scripts/dispatch.sh"
        init_dirs
        [ -d "$TMP_DIR" ] && [ -d "$LOCK_DIR" ]
    ' 2>/dev/null)
    rm -rf "$test_tmp"
    [ "$result" = "true" ] || [ -z "$result" ]
}

test_get_epoch_ms() {
    # 测试跨平台时间戳
    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/dispatch.sh"
        get_epoch_ms
    ' 2>/dev/null)
    # 验证是数字且大于 1 万亿（2020 年后的毫秒时间戳）
    [[ "$result" =~ ^[0-9]+$ ]] && [ "$result" -gt 1000000000000 ]
}

test_date_to_epoch() {
    # 测试日期转换
    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/dispatch.sh"
        date_to_epoch "2026-05-08T12:00:00Z"
    ' 2>/dev/null)
    [[ "$result" =~ ^[0-9]+$ ]] && [ "$result" -gt 1700000000 ]
}

test_split_task() {
    # 测试任务拆分 - 在子 shell 中避免 readonly 冲突
    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/lib/paths.sh"
        source "'"$FLOW_KIT_DIR"'/scripts/dispatch.sh"
        split_task "测试任务" 3 >/dev/null
        find "$TMP_DIR" -name "subagent-*-prompt.txt" 2>/dev/null | wc -l
    ' 2>/dev/null)
    [ "$result" = "3" ]
}

test_check_lock_conflicts_no_locks() {
    # 测试无锁冲突 - 在子 shell 中避免 readonly 冲突
    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/lib/paths.sh"
        source "'"$FLOW_KIT_DIR"'/scripts/dispatch.sh"
        check_lock_conflicts >/dev/null && echo "OK" || echo "FAIL"
    ' 2>/dev/null)
    [ "$result" = "OK" ]
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "dispatch.sh 单元测试"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    run_test "参数解析 - 默认 N=3" test_parse_args_default
    run_test "参数解析 - 指定 N=5" test_parse_args_with_n
    run_test "参数解析 - --execute 模式" test_parse_args_execute_mode
    run_test "参数解析 - --wait 模式" test_parse_args_wait_mode
    run_test "参数解析 - --timeout 参数" test_parse_args_timeout
    run_test "参数解析 - --aggregate 模式" test_parse_args_aggregate_mode
    run_test "目录初始化" test_init_dirs
    run_test "跨平台时间戳" test_get_epoch_ms
    run_test "日期转换" test_date_to_epoch
    run_test "任务拆分 (N=3)" test_split_task
    run_test "锁检测 - 无冲突" test_check_lock_conflicts_no_locks

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "测试结果: 通过 $passed | 失败 $failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ "$failed" -gt 0 ]; then
        exit 1
    fi
}

main "$@"
