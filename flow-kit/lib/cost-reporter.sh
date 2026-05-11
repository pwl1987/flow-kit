#!/bin/bash
# cost-reporter.sh — 成本报告生成
# v1.12.17 P2 修复: 复用 token-estimator.sh 的 count_loc_in_dir 函数
# v1.12.10 新增：实现 /flow-kit:cost-report 命令

set -euo pipefail

#------------------------------------------------------------------------------
# 依赖检查
#------------------------------------------------------------------------------
if ! command -v jq &>/dev/null; then
    printf '[错误] jq 未安装，无法执行成本报告。\n' >&2
    exit 1
fi

#------------------------------------------------------------------------------
# 引入共享的 LOC 统计函数
#------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/token-estimator.sh"

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
readonly DEFAULT_PHASES="${1:-.planning/phases}"
readonly DEFAULT_OUTPUT="${2:-.flow-kit/reports/cost-report-$(date +%Y%m).md}"

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local phases_dir="${1:-$DEFAULT_PHASES}"
    local report_file="${2:-$DEFAULT_OUTPUT}"

    echo "=========================================="
    echo "Cost Report Generator"
    echo "=========================================="
    echo "Phases: $phases_dir"
    echo "Output: $report_file"
    echo ""

    if [ ! -d "$phases_dir" ]; then
        echo "[ERROR] 目录不存在: $phases_dir"
        return 1
    fi

    mkdir -p "$(dirname "$report_file")"

    local month
    month=$(date '+%Y-%m')

    {
        echo "# Cost Report — $month"
        echo ""
        echo "## Token Consumption"
        echo ""
        echo "| Phase | LOC | Est. Tokens |"
        echo "|-------|-----|-------------|"

        local phase_totals=()
        local total_loc=0

        while IFS= read -r line; do
            if [[ "$line" =~ ^([^:]+):([0-9]+)$ ]]; then
                local phase="${BASH_REMATCH[1]}"
                local loc="${BASH_REMATCH[2]}"
                local tokens=$((loc * 3 / 2))
                echo "| $phase | $loc | $tokens |"
                phase_totals+=("$phase:$tokens")
                total_loc=$((total_loc + loc))
            fi
        done < <(count_loc_in_dir "$phases_dir")

        local total_tokens=$((total_loc * 3 / 2))
        echo "|-------|-----|-------------|"
        echo "| **Total** | **$total_loc** | **$total_tokens** |"
        echo ""
        echo "## Summary"
        echo ""
        echo "| Metric | Value |"
        echo "|--------|-------|"
        echo "| Total Changes | ${#phase_totals[@]} |"
        echo "| Total LOC | $total_loc |"
        echo "| Est. Tokens | $total_tokens |"
        echo "| Avg Tokens/Phase | $([ ${#phase_totals[@]} -gt 0 ] && echo "$(( total_tokens / ${#phase_totals[@]} ))" || echo "0") |"
        echo ""
        echo "## Recommendations"
        echo ""

        local budget=100000
        local pct=0
        if [ "$budget" -gt 0 ] && [ "$total_tokens" -gt 0 ]; then
            pct=$((total_tokens * 100 / budget))
        fi

        if [ "$pct" -gt 80 ]; then
            echo "- Token usage high ($pct%). Consider archiving expired contexts."
        fi

        if [ ${#phase_totals[@]} -gt 0 ]; then
            local avg_phase_loc=$((total_loc / ${#phase_totals[@]}))
            if [ "$avg_phase_loc" -gt 1000 ]; then
                echo "- Phase documentation verbose. Consider summarizing."
            fi
        fi

        echo ""
        echo "*Report generated at $(date '+%Y-%m-%d %H:%M:%S')*"
    } > "$report_file"

    echo "[OK] Report generated: $report_file"
    echo ""
    echo "Summary:"
    echo "  Total LOC: $total_loc"
    echo "  Est. Tokens: $total_tokens"
    echo "  Phases: ${#phase_totals[@]}"
}

main "$@"