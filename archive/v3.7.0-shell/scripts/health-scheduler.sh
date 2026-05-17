#!/bin/bash
# health-scheduler.sh — 自动化健康巡检
# v3.6.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/error-handler.sh" 2>/dev/null || true

MODE="${MODE:-oneshot}"

run_health_check() {
    local report_file="$PROJECT_DIR/.flow-kit/logs/health-report-$(date +%Y%m%d).md"
    mkdir -p "$(dirname "$report_file")"

    {
        echo "# 健康巡检报告"
        echo "**时间**: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        echo "## 检查项"
        echo ""

        local ss="$PROJECT_DIR/.flow-kit/session-state.json"
        if [[ -f "$ss" ]]; then
            jq . "$ss" >/dev/null 2>&1 && echo "✅ session-state.json 完整" || echo "❌ session-state.json 损坏"
        else
            echo "⚠️  session-state.json 不存在"
        fi

        local tmp_count
        tmp_count=$(find "$PROJECT_DIR/.flow-kit/tmp" -name '*.tmp' -o -name '*.pid' 2>/dev/null | wc -l)
        [[ "$tmp_count" -eq 0 ]] && echo "✅ 临时文件已清理" || echo "⚠️  临时文件残留: $tmp_count 个"

        local log_count
        log_count=$(find "$PROJECT_DIR/.flow-kit/logs" -name '*.log' 2>/dev/null | wc -l)
        echo "📄 日志文件数: $log_count"
        echo ""
    } > "$report_file"

    echo "巡检完成: $report_file"
    cat "$report_file"
}

main() {
    if [[ "${1:-}" == "--now" ]] || [[ "$MODE" == "oneshot" ]]; then
        run_health_check
    else
        echo "[health-scheduler] 用法: bash health-scheduler.sh --now"
    fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"