#!/bin/bash
# health-rotation.sh — 健康历史轮转脚本
# v1.12.5 P2 新增（可选）
# 当 health-history.json 超过 500KB 时自动归档

set -e

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
MAX_SIZE_KB=500
HISTORY_FILE=".flow-kit/health-history.json"
ARCHIVE_DIR=".flow-kit/health-archive"

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    if [ ! -f "$HISTORY_FILE" ]; then
        echo "[health-rotation] 文件不存在: $HISTORY_FILE"
        exit 0
    fi

    local size_kb=$(stat -c%s "$HISTORY_FILE" 2>/dev/null || echo 0)
    size_kb=$((size_kb / 1024))

    if [ "$size_kb" -lt "$MAX_SIZE_KB" ]; then
        echo "[health-rotation] 健康历史文件大小 ${size_kb}KB < ${MAX_SIZE_KB}KB，无需轮转"
        exit 0
    fi

    echo "[health-rotation] 健康历史文件超过 ${MAX_SIZE_KB}KB (当前: ${size_kb}KB)，开始轮转..."

    mkdir -p "$ARCHIVE_DIR"

    local timestamp=$(date -u +%Y%m%d%H%M%S)
    local archive_file="$ARCHIVE_DIR/health-history-${timestamp}.json"

    mv "$HISTORY_FILE" "$archive_file"
    echo "{}" > "$HISTORY_FILE"

    echo "[health-rotation] 已归档到: $archive_file"
    echo "[health-rotation] 新文件已创建: $HISTORY_FILE"

    # 保留最近 5 个归档
    local archives=$(ls -t "$ARCHIVE_DIR"/health-history-*.json 2>/dev/null | tail -n +6)
    if [ -n "$archives" ]; then
        echo "[health-rotation] 清理旧归档..."
        rm -f $archives
    fi
}

main "$@"
