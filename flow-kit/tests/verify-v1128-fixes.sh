#!/bin/bash
# verify-v1128-fixes.sh — v1.12.8 修复验证脚本
# 验证所有 P0/P1/P2 修复是否正确应用

PASS=0
FAIL=0
TOTAL=0

check() {
    local desc="$1"
    shift
    TOTAL=$((TOTAL + 1))
    
    if "$@" >/dev/null 2>&1; then
        echo "✅ [PASS] $desc"
        PASS=$((PASS + 1))
    else
        echo "❌ [FAIL] $desc"
        FAIL=$((FAIL + 1))
    fi
}

echo "=========================================="
echo "flow-kit v1.12.8 修复验证"
echo "=========================================="

# 确定项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$FLOW_KIT_DIR" || exit 1

# P0 验证
echo ""
echo "--- P0: 核心稳定性修复 ---"

# P0-1: stop-quality-gate.sh 除零检查
check "P0-1: stop-quality-gate.sh 除零检查" grep -q "incremental_lines.*-eq 0" hooks/stop-quality-gate.sh

# P0-2: context-budget.sh POSIX 兼容
check "P0-2: context-budget.sh awk 替代 grep -oP" grep -q "awk" lib/context-budget.sh

# P0-3: dispatch.sh 移除 set -e
check "P0-3: dispatch.sh 移除 set -e" grep -q "移除 set -e" scripts/dispatch.sh

# P0-3: dispatch.sh trap 清理
check "P0-3: dispatch.sh trap 清理" grep -q "trap cleanup_children EXIT INT TERM" scripts/dispatch.sh

# P0-4: dispatch.sh 锁冲突 blocking
check "P0-4: dispatch.sh 锁冲突 blocking" grep -q "等待解锁" scripts/dispatch.sh

# P0-5: dispatch.sh result validation
check "P0-5: dispatch.sh result validation" grep -q "验证 result JSON 有效性" scripts/dispatch.sh

# P1 验证
echo ""
echo "--- P1: 跨平台兼容性增强 ---"

# P1-1: post-edit-format.sh prettier 日志
check "P1-1: post-edit-format.sh prettier 错误日志" grep -q "prettier-errors.log" hooks/post-edit-format.sh

# P1-2: notification.sh Windows Toast
check "P1-2: notification.sh Windows Toast" grep -q "BurntToast" hooks/notification.sh

# P1-3: pre-tool-guard.sh DDL 正则
check "P1-3: pre-tool-guard.sh DDL 正则补全" grep -q "RENAME COLUMN" hooks/pre-tool-guard.sh

# P1-4: health-rotation.sh stat 兼容
check "P1-4: health-rotation.sh stat 兼容" grep -q "stat --version" lib/health-rotation.sh

# P1-5: error-handler.sh POSIX date
check "P1-5: error-handler.sh POSIX date" grep -q "get_timestamp" lib/error-handler.sh

# P2 验证
echo ""
echo "--- P2: 代码规范强化 ---"

# P2-1: hooks set -euo pipefail
HOOKS_WITH_STRICT=0
for hook in hooks/*.sh; do
    if head -3 "$hook" | grep -q "set -euo pipefail" 2>/dev/null; then
        HOOKS_WITH_STRICT=$((HOOKS_WITH_STRICT + 1))
    fi
done
check "P2-1: hooks 添加 set -euo pipefail ($HOOKS_WITH_STRICT/5)" test "$HOOKS_WITH_STRICT" -ge 4

# P2-3: dispatch.sh 版本头
check "P2-3: dispatch.sh 版本头 v1.12.8" grep -q "v1.12.8" scripts/dispatch.sh

# 版本号统一
check "版本号统一为 v1.12.10" grep -q "v1.12.10" VERSION

# CHANGELOG 更新
check "CHANGELOG 更新 v1.12.8" grep -q "1.12.8" CHANGELOG.md

# 总结
echo ""
echo "=========================================="
echo "验证结果: $PASS/$TOTAL 通过, $FAIL 失败"
echo "=========================================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0
