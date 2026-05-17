#!/bin/bash
# metrics-logger.sh — JSONL 指标日志库
# v3.7.0 新增

METRICS_LOG_DIR="${METRICS_LOG_DIR:-$LOGS_DIR}"
METRICS_LOG_FILE="${METRICS_LOG_FILE:-$METRICS_LOG_DIR/metrics.jsonl}"

# 写入一条指标事件
metrics_log_event() {
    local event_type="$1"
    local detail="${2:-}"
    local ts
    ts=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

    mkdir -p "$METRICS_LOG_DIR" 2>/dev/null || true

    # 原子追加写入
    local line
    line=$(printf '{"event_type":"%s","timestamp":"%s","detail":"%s"}\n' \
        "$event_type" "$ts" "$detail")

    # 使用 flock 防止并发交叉写入（如果可用）
    if command -v flock &>/dev/null; then
        (
            flock -x 200
            echo "$line" >> "$METRICS_LOG_FILE"
        ) 200>>"$METRICS_LOG_FILE.lock"
    else
        echo "$line" >> "$METRICS_LOG_FILE"
    fi
}

# 按事件类型查询
metrics_query() {
    local event_type="$1"

    if [[ ! -f "$METRICS_LOG_FILE" ]]; then
        return 0
    fi

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if echo "$line" | grep -q "\"event_type\":\"$event_type\""; then
            echo "$line"
        fi
    done < "$METRICS_LOG_FILE"
}

# 汇总统计
metrics_summary() {
    if [[ ! -f "$METRICS_LOG_FILE" ]]; then
        echo "total: 0"
        return 0
    fi

    declare -A counts
    local total=0

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        # 跳过非法 JSON
        local etype
        etype=$(echo "$line" | sed -n 's/.*"event_type":"\([^"]*\)".*/\1/p' 2>/dev/null)
        [[ -z "$etype" ]] && continue
        counts["$etype"]=$(( ${counts["$etype"]:-0} + 1 ))
        total=$((total + 1))
    done < "$METRICS_LOG_FILE"

    for key in "${!counts[@]}"; do
        echo "$key: ${counts[$key]}"
    done
    echo "total: $total"
}
