#!/bin/bash
set -euo pipefail
# next-phase.sh — 推进到下一个 Phase
# v1.13 新增

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"

get_current_phase() {
    local current
    if [ -f "$CURRENT_PHASE_FILE" ]; then
        current=$(cat "$CURRENT_PHASE_FILE")
    else
        current="0"
    fi

    if [[ ! "$current" =~ ^[0-9]+$ ]]; then
        echo "错误: 阶段文件内容非法: $current" >&2
        exit 1
    fi

    echo "$current"
}

advance_phase() {
    local current="$1"
    local next=$((current + 1))

    if [ $next -gt 8 ]; then
        echo "已经是最后一个 Phase (8)"
        echo "流程完成！"
        return 0
    fi

    # 更新状态文件
    mkdir -p "$(dirname "$CURRENT_PHASE_FILE")"
    echo "$next" > "$CURRENT_PHASE_FILE"

    echo ""
    echo "=========================================="
    echo "flow-kit Phase 推进"
    echo "=========================================="
    echo ""
    echo "📍 当前阶段: Phase $current"
    echo "📍 推进到: Phase $next"
    echo ""
    echo "📌 下一步操作:"
    echo ""
    echo "   输入 /flow-kit:phase-$next 启动 Phase $next"
    echo ""
    echo "💡 或继续使用 /flow-kit:next 逐步推进"
}

main() {
    local current
    current=$(get_current_phase)
    advance_phase "$current"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
