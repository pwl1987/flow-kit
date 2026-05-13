#!/bin/bash
# dispatch-lock.sh — dispatch.sh 锁管理模块
# v3.4.0 从 dispatch.sh 拆分

set -uo pipefail

#------------------------------------------------------------------------------
# 锁冲突检测
#------------------------------------------------------------------------------
check_lock_conflicts() {
    echo "[dispatch] 🔒 检查锁冲突..."

    local locks_count=0
    if [ -d "$LOCK_DIR" ]; then
        locks_count=$(find "$LOCK_DIR" -name "*.lock" -type d 2>/dev/null | wc -l)
    fi

    echo "[dispatch] 当前活跃锁数: $locks_count"

    if [ "$locks_count" -gt 0 ]; then
        echo "[dispatch] 🚫 检测到 $locks_count 个活跃锁，等待解锁..."

        local wait_timeout=30
        local wait_elapsed=0
        local wait_interval=2

        while [ "$wait_elapsed" -lt "$wait_timeout" ]; do
            local current_locks
            current_locks=$(find "$LOCK_DIR" -name "*.lock" -type d 2>/dev/null | wc -l)

            if [ "$current_locks" -eq 0 ]; then
                echo "[dispatch] ✅ 锁已释放，继续执行"
                return 0
            fi

            echo "[dispatch]    等待中... ($wait_elapsed/$wait_timeout 秒)"
            sleep "$wait_interval"
            wait_elapsed=$((wait_elapsed + wait_interval))
        done

        echo "[dispatch] ❌ 锁冲突超时 (${wait_timeout}s)，终止执行" >&2
        return 1
    else
        echo "[dispatch] ✅ 无锁冲突"
    fi
}

#------------------------------------------------------------------------------
# 并发池控制
#------------------------------------------------------------------------------
acquire_slot() {
    local max_conc="$1"
    local slot_num=""
    for ((i=0; i<max_conc; i++)); do
        local lockdir="$TMP_DIR/slot-$i.lock"
        if mkdir "$lockdir" 2>/dev/null; then
            slot_num="$i"
            echo "$i" > "$TMP_DIR/slot-$$.id"
            return 0
        fi
    done
    return 1
}

release_slot() {
    local slot_id_file="$TMP_DIR/slot-$$.id"
    if [[ -f "$slot_id_file" ]]; then
        local slot_num
        slot_num=$(cat "$slot_id_file" 2>/dev/null || echo "")
        if [[ -n "$slot_num" ]]; then
            local lockdir="$TMP_DIR/slot-$slot_num.lock"
            rmdir "$lockdir" 2>/dev/null || true
        fi
        rm -f "$slot_id_file"
    fi
}

release_slot_from_trap() {
    local slot_id_file="$TMP_DIR/slot-$BASHPID.id"
    if [[ -f "$slot_id_file" ]]; then
        local slot_num
        slot_num=$(cat "$slot_id_file" 2>/dev/null || echo "")
        if [[ -n "$slot_num" ]]; then
            local lockdir="$TMP_DIR/slot-$slot_num.lock"
            rmdir "$lockdir" 2>/dev/null || true
        fi
        rm -f "$slot_id_file"
    fi
}
