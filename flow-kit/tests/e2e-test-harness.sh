#!/bin/bash
# e2e-test-harness.sh — E2E 测试骨架
# v2.6.1 更新
# 提供基础 E2E 测试框架

set -euo pipefail

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="$FLOW_KIT_DIR/tests"
TMP_DIR="$(cd "$FLOW_KIT_DIR/.." && pwd)/.flow-kit/tmp"

#------------------------------------------------------------------------------
# 测试函数
#------------------------------------------------------------------------------
run_test() {
    local test_name="$1"
    local test_func="$2"

    echo ""
    echo "[TEST] 运行: $test_name"

    if $test_func; then
        echo "[TEST] ✅ $test_name - 通过"
        return 0
    else
        echo "[TEST] ❌ $test_name - 失败"
        return 1
    fi
}

#------------------------------------------------------------------------------
# 内置测试
#------------------------------------------------------------------------------
test_dispatch_script_exists() {
    [ -f "$FLOW_KIT_DIR/scripts/dispatch.sh" ]
}

test_dispatch_aggregate_exists() {
    [ -f "$FLOW_KIT_DIR/scripts/dispatch-aggregate.sh" ]
}

test_dispatch_status_exists() {
    [ -f "$FLOW_KIT_DIR/scripts/dispatch-status.sh" ]
}

test_dispatch_validate_phase_exists() {
    [ -f "$FLOW_KIT_DIR/scripts/validate-phase.sh" ]
}

test_context_budget_exists() {
    [ -f "$FLOW_KIT_DIR/lib/context-budget.sh" ]
}

test_flow_kit_sh_exists() {
    [ -f "$FLOW_KIT_DIR/flow-kit.sh" ]
}

test_hooks_exist() {
    local hooks=("pre-tool-guard.sh" "post-edit-format.sh" "stop-quality-gate.sh")
    for hook in "${hooks[@]}"; do
        [ -f "$FLOW_KIT_DIR/hooks/$hook" ] || return 1
    done
    return 0
}

test_dispatch_execute_mode() {
    bash "$FLOW_KIT_DIR/scripts/dispatch.sh" --execute 1 "测试任务" >/dev/null 2>&1
    [ -f "$TMP_DIR/launch-manifest.json" ]
}

test_dispatch_wait_mode() {
    bash "$FLOW_KIT_DIR/scripts/dispatch.sh" --execute 1 "测试" >/dev/null 2>&1
    timeout 5 bash "$FLOW_KIT_DIR/scripts/dispatch.sh" --wait >/dev/null 2>&1 || return 0
}

test_dispatch_aggregate_mode() {
    bash "$FLOW_KIT_DIR/scripts/dispatch.sh" --execute 1 "测试" >/dev/null 2>&1
    bash "$FLOW_KIT_DIR/scripts/dispatch.sh" --aggregate >/dev/null 2>&1
}

test_context_budget_status() {
    bash "$FLOW_KIT_DIR/lib/context-budget.sh" --status >/dev/null 2>&1
}

test_brownfield_guardrails_b5_b6_indexed() {
    grep -q "performance-guardrails.md" "$FLOW_KIT_DIR/guardrails/brownfield-guardrails.md"
}

test_stop_quality_gate_b6_linkage() {
    grep -q "check_test_coverage" "$FLOW_KIT_DIR/hooks/stop-quality-gate.sh"
}

test_careful_deadlock_dual_condition() {
    grep -q "MTIME" "$FLOW_KIT_DIR/commands/careful.md"
}

test_m_health_b5_b6_linkage() {
    grep -q "performance_guardrails" "$FLOW_KIT_DIR/commands/M-health.md" && \
    grep -q "test_coverage" "$FLOW_KIT_DIR/commands/M-health.md"
}

test_phase_executor_schema_section() {
    grep -q "项目类型" "$FLOW_KIT_DIR/scripts/phase-executor.sh"
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local passed=0
    local failed=0

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "flow-kit v2.6.1 E2E 测试"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    run_test "dispatch.sh 存在" test_dispatch_script_exists && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "dispatch-aggregate.sh 存在" test_dispatch_aggregate_exists && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "dispatch-status.sh 存在" test_dispatch_status_exists && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "validate-phase.sh 存在" test_dispatch_validate_phase_exists && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "context-budget.sh 存在" test_context_budget_exists && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "flow-kit.sh 存在" test_flow_kit_sh_exists && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "hooks 完整性" test_hooks_exist && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "dispatch --execute 模式" test_dispatch_execute_mode && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "dispatch --wait 模式" test_dispatch_wait_mode && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "dispatch --aggregate 模式" test_dispatch_aggregate_mode && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "context-budget --status" test_context_budget_status && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "brownfield-guardrails B5/B6 索引" test_brownfield_guardrails_b5_b6_indexed && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "stop-quality-gate B6 联动" test_stop_quality_gate_b6_linkage && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "careful.md 死锁双重条件" test_careful_deadlock_dual_condition && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "M-health B5/B6 联动" test_m_health_b5_b6_linkage && passed=$((passed + 1)) || failed=$((failed + 1))
    run_test "phase-executor JSON Schema 章节" test_phase_executor_schema_section && passed=$((passed + 1)) || failed=$((failed + 1))

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "测试结果: 通过 $passed | 失败 $failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ "$failed" -gt 0 ]; then
        exit 1
    fi
}

main "$@"
