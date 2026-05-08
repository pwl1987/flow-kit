#!/bin/bash
# expiry-checker.sh — 上下文过期检测
# v1.12.10 新增：实现 /flow-kit:check-expiry 命令

set -euo pipefail

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
WARNING_DAYS=15
BLOCK_DAYS=30
DEFAULT_TARGET="${1:-.planning/phases}"

#------------------------------------------------------------------------------
# 获取文件最新修改时间
#------------------------------------------------------------------------------
get_newest_mtime() {
    local target_dir="$1"
    local newest_mtime=0

    if [ ! -d "$target_dir" ]; then
        echo "0"
        return
    fi

    while IFS= read -r -d '' file; do
        local basename=$(basename "$file")
        if [[ "$basename" =~ [Tt][Ee][Mm][Pp][Ll][Aa][Tt][Ee] ]]; then
            continue
        fi

        local mtime
        if stat -c %Y "$file" >/dev/null 2>&1; then
            mtime=$(stat -c %Y "$file" 2>/dev/null)
        else
            mtime=$(stat -f %m "$file" 2>/dev/null)
        fi

        if [ "$mtime" -gt "$newest_mtime" ]; then
            newest_mtime=$mtime
        fi
    done < <(find "$target_dir" -name "*.md" -type f -print0 2>/dev/null)

    echo "$newest_mtime"
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local target_dir="${1:-$DEFAULT_TARGET}"

    echo "=========================================="
    echo "Context Expiry Check"
    echo "=========================================="
    echo "Target: $target_dir"
    echo ""

    if [ ! -d "$target_dir" ]; then
        echo "[ERROR] 目录不存在: $target_dir"
        return 1
    fi

    local newest_mtime
    newest_mtime=$(get_newest_mtime "$target_dir")

    if [ "$newest_mtime" -eq 0 ]; then
        echo "[INFO] 未找到任何 .md 文件"
        echo "Context age: 0 days (healthy)"
        return 0
    fi

    local now
    now=$(date +%s 2>/dev/null || echo "0")
    local days_since=$(( (now - newest_mtime) / 86400 ))

    local newest_date
    newest_date=$(date -d "@$newest_mtime" '+%Y-%m-%d' 2>/dev/null || date -r "$newest_mtime" '+%Y-%m-%d' 2>/dev/null || echo "unknown")

    echo "Last activity: $newest_date"
    echo "Days since: $days_since"
    echo ""

    if [ "$days_since" -ge "$BLOCK_DAYS" ]; then
        local remaining=0
        echo "[BLOCK] Context expired ($days_since days >= $BLOCK_DAYS days)"
        echo ""
        echo "Auto-archiving required. Run /flow-kit:archive to archive manually,"
        echo "or /flow-kit:recovery to restore from archive."
        return 2
    elif [ "$days_since" -ge "$WARNING_DAYS" ]; then
        local remaining=$((BLOCK_DAYS - days_since))
        echo "[WARNING] Context will expire in $remaining days"
        echo ""
        echo "Run /flow-kit:archive to archive early,"
        echo "or /flow-kit:recovery to restore from archive."
        return 1
    else
        echo "[OK] Context age: $days_since days (healthy)"
        echo ""
        echo "No action required."
        return 0
    fi
}

main "$@"