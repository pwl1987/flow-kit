#!/bin/bash
# token-estimator.sh — 基于 LOC 的 Token 估算
# v1.12.10 新增：实现 /flow-kit:estimate-tokens 命令

set -euo pipefail

#------------------------------------------------------------------------------
# 依赖检查
#------------------------------------------------------------------------------
if ! command -v jq &>/dev/null; then
    printf '[错误] jq 未安装，无法执行 Token 估算。\n' >&2
    exit 1
fi

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
TOKEN_BUDGET="${TOKEN_BUDGET:-100000}"
DEFAULT_TARGET="${1:-.planning/phases}"

#------------------------------------------------------------------------------
# 统计函数
#------------------------------------------------------------------------------
count_loc_in_dir() {
    local target_dir="$1"
    local total_loc=0
    local phase_stats=()

    if [ ! -d "$target_dir" ]; then
        echo "目录不存在: $target_dir" >&2
        return 1
    fi

    while IFS= read -r -d '' file; do
        local basename=$(basename "$file")
        if [[ "$basename" =~ [Tt][Ee][Mm][Pp][Ll][Aa][Tt][Ee] ]]; then
            continue
        fi

        local loc
        loc=$(grep -c '' "$file" 2>/dev/null || echo 0)
        total_loc=$((total_loc + loc))

        local phase
        phase=$(echo "$file" | sed 's|.*/phases/||' | cut -d/ -f1 || echo "unknown")
        phase_stats+=("$phase:$loc")
    done < <(find "$target_dir" -name "*.md" -type f -print0 2>/dev/null)

    echo "$total_loc"
    for stat in "${phase_stats[@]}"; do
        echo "$stat"
    done
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local target_dir="${1:-$DEFAULT_TARGET}"

    echo "=========================================="
    echo "Token Estimation Report"
    echo "=========================================="
    echo "Target: $target_dir"
    echo ""

    local results
    results=$(count_loc_in_dir "$target_dir")
    local total_loc
    total_loc=$(echo "$results" | head -1)
    local estimated_tokens=$((total_loc * 3 / 2))

    echo "Phase Breakdown:"
    echo "| Phase | LOC | Est. Tokens |"
    echo "|-------|-----|-------------|"

    local phase_totals=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^([^:]+):([0-9]+)$ ]]; then
            local phase="${BASH_REMATCH[1]}"
            local loc="${BASH_REMATCH[2]}"
            local tokens=$((loc * 3 / 2))
            echo "| $phase | $loc | $tokens |"
            phase_totals+=("$phase:$tokens")
        fi
    done < <(echo "$results" | tail -n +2)

    echo "|-------|-----|-------------|"
    echo "| **Total** | **$total_loc** | **$estimated_tokens** |"
    echo ""
    echo "=========================================="
    echo "Total LOC: $total_loc"
    echo "Estimated Tokens: $estimated_tokens (LOC × 1.5)"
    echo "Budget: $TOKEN_BUDGET"
    echo ""

    local pct=$((estimated_tokens * 100 / TOKEN_BUDGET))
    echo "Usage: $pct%"

    if [ "$pct" -ge 100 ]; then
        echo "Status: [BLOCK] Token budget exhausted"
        return 2
    elif [ "$pct" -ge 80 ]; then
        echo "Status: [WARNING] Approaching token budget"
        return 1
    else
        echo "Status: [HEALTHY] Within budget"
        return 0
    fi
}

main "$@"