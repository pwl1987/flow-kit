#!/bin/bash
# benchmarks/run-benchmarks.sh — flow-kit 性能基准测试
# v3.6.0
# 使用 hyperfine（如果可用）或内置计时

set -uo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly BENCHMARK_DIR="$ROOT_DIR/.flow-kit/benchmarks"

mkdir -p "$BENCHMARK_DIR"

log() { echo "[benchmark] $(date +%H:%M:%S) $*"; }

#------------------------------------------------------------------------------
# 基准测试函数
#------------------------------------------------------------------------------
run_benchmark() {
    local name="$1"
    local cmd="$2"
    local iterations="${3:-10}"

    log "Running: $name"

    if command -v hyperfine >/dev/null 2>&1; then
        local out
        out=$(hyperfine --runs="$iterations" --warmup=1 --export-json="$BENCHMARK_DIR/${name}.json" "$cmd" 2>/dev/null)
        local ms
        ms=$(echo "$out" | grep 'mean' | awk '{print $2}' | tr -d 'ms')
        local stddev
        stddev=$(echo "$out" | grep 'stddev' | awk '{print $2}' | tr -d 'ms')
        echo "$name | ${ms}ms | stddev ${stddev}ms" | tee -a "$BENCHMARK_DIR/summary.txt"
    else
        local total=0
        local i
        for ((i=0; i<iterations; i++)); do
            local start
            start=$(date +%s%N)
            bash -c "$cmd" >/dev/null 2>&1
            local end
            end=$(date +%s%N)
            local elapsed=$(( (end - start) / 1000000 ))
            total=$((total + elapsed))
        done
        local avg=$((total / iterations))
        echo "$name | ${avg}ms | (n=$iterations)" | tee -a "$BENCHMARK_DIR/summary.txt"
    fi
}

#------------------------------------------------------------------------------
# 主流程
#------------------------------------------------------------------------------
main() {
    echo ""
    log "flow-kit v3.6.0 benchmarks"
    log "Output: $BENCHMARK_DIR"
    echo ""

    rm -f "$BENCHMARK_DIR/summary.txt"

    log "=== Phase Executor ==="
    run_benchmark "phase-executor" "bash '$ROOT_DIR/scripts/phase-executor.sh' '0-change'" 5

    log "=== Dispatch Parse ==="
    run_benchmark "dispatch-parse" "bash -c 'source \"$ROOT_DIR/scripts/dispatch-parse.sh\"; parse_args 3 \"test task\"'" 5

    log "=== Session State Init ==="
    run_benchmark "session-init" "bash -c 'source \"$ROOT_DIR/lib/session-state.sh\"; session_init' 2>/dev/null || true" 5

    log "=== Paths Init ==="
    run_benchmark "paths-init" "bash -c 'source \"$ROOT_DIR/lib/paths.sh\"; echo \"\$FLOW_KIT_ROOT\"'" 5

    log "=== Error Handler ==="
    run_benchmark "error-handler" "bash -c 'source \"$ROOT_DIR/lib/error-handler.sh\"; log_info \"test\"' 2>/dev/null || true" 5

    echo ""
    log "=== Summary ==="
    if [ -f "$BENCHMARK_DIR/summary.txt" ]; then
        cat "$BENCHMARK_DIR/summary.txt"
    fi

    echo ""
    log "Benchmarks complete. Results saved to $BENCHMARK_DIR/"
}

main "$@"