#!/bin/bash
# performance-regression.sh — 性能退化检测
# v3.6.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"

THRESHOLD="${THRESHOLD:-10}"

measure_script() {
    local script="$1"
    local n="${2:-3}"
    local total=0
    local i
    for ((i=0; i<n; i++)); do
        local start=$(date +%s%N)
        bash -c "source '$script'" >/dev/null 2>&1 || true
        local end=$(date +%s%N)
        total=$((total + (end - start) / 1000000))
    done
    echo $((total / n))
}

detect_regression() {
    local threshold="${1:-10}"
    local history_file="$PROJECT_DIR/.flow-kit/benchmarks/performance-history.json"
    mkdir -p "$(dirname "$history_file")"

    local current
    current=$(measure_script "$SCRIPT_DIR/../lib/paths.sh" 3)

    if [[ -f "$history_file" ]]; then
        local baseline_ms
        baseline_ms=$(jq -r '.paths.mean_ms // 0' "$history_file" 2>/dev/null)
        if [[ "$baseline_ms" -gt 0 ]]; then
            local diff=$(( (current - baseline_ms) * 100 / baseline_ms ))
            if [[ "$diff" -gt "$threshold" ]]; then
                echo "⚠️  性能退化: ${diff}% (当前 ${current}ms vs 基线 ${baseline_ms}ms)"
            else
                echo "✅ 性能正常: ${current}ms (基线 ${baseline_ms}ms)"
            fi
        fi
    fi

    jq -n --argjson ms "$current" '{paths: {mean_ms: $ms, measured_at: now}}' > "$history_file"
    echo "[perf] current: ${current}ms"
}

main() {
    local threshold="$THRESHOLD"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --threshold) threshold="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    detect_regression "$threshold"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"