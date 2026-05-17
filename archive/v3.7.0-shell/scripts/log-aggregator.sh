#!/bin/bash
# log-aggregator.sh — hooks 执行日志聚合分析器
# v3.6.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"

DAYS="${DAYS:-7}"
OUTPUT_FILE="${OUTPUT_FILE:-}"

show_help() {
    cat << 'EOF'
用法: ./log-aggregator.sh [--days N] [--output FILE] [--error-only]
EOF
}

aggregate_logs() {
    local days="$1"
    local out_file="$2"

    local cutoff
    cutoff=$(date -d "$days days ago" +%Y-%m-%d 2>/dev/null || date -v-${days}d +%Y-%m-%d)

    local tmp_err
    tmp_err=$(mktemp)
    trap "rm -f '$tmp_err'" EXIT

    local log_file="$PROJECT_DIR/.flow-kit/logs/hooks-execution.log"
    if [[ -f "$log_file" ]]; then
        while IFS= read -r line; do
            local d
            d=$(echo "$line" | awk '{print $1}' | head -c 10)
            if [[ "$d" > "$cutoff" ]]; then
                echo "$line"
            fi
        done < "$log_file" | grep -iE 'error|failed|exception|fatal' > "$tmp_err"
    fi

    local count
    count=$(wc -l < "$tmp_err" 2>/dev/null || echo 0)

    {
        echo "# Hooks 日志聚合报告"
        echo ""
        echo "**周期**: 最近 $days 天"
        echo "**错误数**: $count"
        echo ""
        if [[ "$count" -eq 0 ]]; then
            echo "✅ 无错误"
        else
            echo "### 错误类型统计"
            grep -oE '(error|failed|exception|fatal)' "$tmp_err" 2>/dev/null | sort | uniq -c | sort -rn | head -5
            echo ""
            echo "### 最近错误"
            tail -5 "$tmp_err" 2>/dev/null
        fi
    } > "${out_file:-/dev/stdout}"
}

main() {
    local days="$DAYS"
    local out_file=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --days) days="$2"; shift 2 ;;
            --output) out_file="$2"; shift 2 ;;
            -h|--help) show_help; exit 0 ;;
            *) shift ;;
        esac
    done

    aggregate_logs "$days" "$out_file"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"