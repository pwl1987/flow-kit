#!/bin/bash
# dispatch-status.sh — 多代理编排状态查看

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"

main() {
    if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
        echo "用法: ./dispatch-status.sh [summary_file]"
        exit 0
    fi

    local summary_file="${1:-$TMP_DIR/dispatch-summary.json}"

    echo ""

    if [ ! -f "$summary_file" ]; then
        echo "[status] 暂无执行中任务"
        echo "[status] 启动: ./dispatch.sh [N] \"任务描述\""
        return
    fi

    if ! jq -e . "$summary_file" >/dev/null 2>&1; then
        echo "[status] 无效JSON: $summary_file" >&2
        return 1
    fi

    echo "[status] task=$(jq -r '.task_id' "$summary_file")"
    echo "[status] desc=$(jq -r '.task_desc' "$summary_file")"
    echo "[status] parallel=$(jq -r '.parallel_n' "$summary_file")"

    local total successful failed partial
    total=$(jq -r '.summary.total // 0' "$summary_file")
    successful=$(jq -r '.summary.successful // 0' "$summary_file")
    failed=$(jq -r '.summary.failed // 0' "$summary_file")
    partial=$(jq -r '.summary.partial // 0' "$summary_file")

    echo "[status] total=$total ok=$successful fail=$failed partial=$partial"
    echo ""

    echo "子代理状态:"
    while read -r agent_json; do
        local id role status duration
        id=$(echo "$agent_json" | jq -r '.id')
        role=$(echo "$agent_json" | jq -r '.role')
        status=$(echo "$agent_json" | jq -r '.status')
        duration=$(echo "$agent_json" | jq -r '.duration // "-"')
        echo "  $id ($role): $status ${duration:-}"
    done < <(jq -c '.agents[]' "$summary_file" 2>/dev/null)

    echo ""
    local locks_count=0
    [ -d "$LOCK_DIR" ] && locks_count=$(ls -d "$LOCK_DIR"/*.lock 2>/dev/null | wc -l || echo 0)
    echo "[status] locks=$locks_count"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
