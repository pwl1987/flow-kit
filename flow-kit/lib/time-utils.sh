#!/bin/bash
# time-utils.sh — 共享时间工具函数
# v2.9.0: 添加 date_to_epoch，消除 dispatch.sh 重复

set -euo pipefail

# 防重复 source
if [ -n "${_TIME_UTILS_LOADED:-}" ]; then
    return 0
fi
readonly _TIME_UTILS_LOADED=true

# 获取毫秒级时间戳（兼容 GNU date / macOS / Python / Perl）
get_epoch_ms() {
    if date +%s%3N 2>/dev/null | grep -qE '^[0-9]+$'; then
        date +%s%3N
    elif python3 -c "import time; print(int(time.time() * 1000))" >/dev/null 2>&1; then
        python3 -c "import time; print(int(time.time() * 1000))"
    elif command -v perl &>/dev/null; then
        perl -MTime::HiRes -e 'printf "%d\n", int(Time::HiRes::time() * 1000)'
    else
        echo "$(date +%s)000"
    fi
}

# ISO 8601 日期转 Unix epoch（兼容 macOS / Linux）
date_to_epoch() {
    local iso_date="$1"
    if [ -z "$iso_date" ] || [ "$iso_date" = "null" ]; then
        echo "0"
        return 0
    fi
    local epoch=0
    if date -j -f "%Y-%m-%dT%H:%M:%SZ" "$iso_date" +%s >/dev/null 2>&1; then
        epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$iso_date" +%s 2>/dev/null || echo "0")
    elif date -d "$iso_date" +%s >/dev/null 2>&1; then
        epoch=$(date -d "$iso_date" +%s 2>/dev/null || echo "0")
    fi
    if [ "$epoch" = "0" ] || [ -z "$epoch" ]; then
        echo "0"
    else
        echo "$epoch"
    fi
}
