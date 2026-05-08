#!/bin/bash
# e2e-test-harness.sh — E2E 测试骨架
# v1.12.5 P3 新增
# 提供基础 E2E 测试框架

set -e

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="$FLOW_KIT_DIR/tests"
TMP_DIR=".flow-kit/tmp"

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

#------------------------------------------------------------------------------
# 测试列表
#------------------------------------------------------------------------------
TESTS=(
    "dispatch.sh 存在:test_dispatch_script_exists"
    "dispatch-aggregate.sh 存在:test_dispatch_aggregate_exists"
    "dispatch-status.sh 存在:test_dispatch_status_exists"
    "flow-kit.sh 存在:test_flow_kit_sh_exists"
    "hooks 完整性:test_hooks_exist"
    "brownfield-guardrails B5/B6 索引:test_brownfield_guardrails_b5_b6_indexed"
    "stop-quality-gate B6 联动:test_stop_quality_gate_b6_linkage"
    "careful.md 死锁双重条件:test_careful_deadlock_dual_condition"
    "M-health B5/B6 联动:test_m_health_b5_b6_linkage"
)

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local passed=0
    local failed=0

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "flow-kit v1.12.5 E2E 测试"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    for test_entry in "${TESTS[@]}"; do
        local test_name="${test_entry%%:*}"
        local test_func="${test_entry##*:}"

        if run_test "$test_name" "$test_func"; then
            ((passed++)) || true
        else
            ((failed++)) || true
        fi
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "测试结果: 通过 $passed | 失败 $failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ "$failed" -gt 0 ]; then
        exit 1
    fi
}

main "$@"
