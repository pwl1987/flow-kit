#!/bin/bash
set -euo pipefail
# health-rotation.sh — 健康历史轮转脚本
# v1.12.5 P2 新增（可选）
# v1.12.8 P1 修复: stat 命令 Linux/BSD 兼容 + set -euo pipefail
# 当 health-history.json 超过 500KB 时自动归档

#------------------------------------------------------------------------------
# 配置（v1.12.17 P2 修复：使用 readonly 防止意外修改）
#------------------------------------------------------------------------------
readonly MAX_SIZE_KB=500
readonly HISTORY_FILE=".flow-kit/health-history.json"
readonly ARCHIVE_DIR=".flow-kit/health-archive"

#------------------------------------------------------------------------------
# 获取文件大小（KB），Linux/BSD 兼容
#------------------------------------------------------------------------------
get_file_size_bytes() {
    local file="$1"

    # P1 修复：统一 stat 命令 Linux/BSD 检测
    if stat --version >/dev/null 2>&1; then
        # Linux (GNU stat)
        stat -c%s "$file" 2>/dev/null || echo "0"
    else
        # macOS/BSD (BSD stat)
        stat -f%z "$file" 2>/dev/null || echo "0"
    fi
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    if [ ! -f "$HISTORY_FILE" ]; then
        echo "[health-rotation] 文件不存在: $HISTORY_FILE"
        exit 0
    fi

    local size_bytes
    size_bytes=$(get_file_size_bytes "$HISTORY_FILE")
    local size_kb=$((size_bytes / 1024))

    if [ "$size_kb" -lt "$MAX_SIZE_KB" ]; then
        echo "[health-rotation] 健康历史文件大小 ${size_kb}KB < ${MAX_SIZE_KB}KB，无需轮转"
        exit 0
    fi

    echo "[health-rotation] 健康历史文件超过 ${MAX_SIZE_KB}KB (当前: ${size_kb}KB)，开始轮转..."

    mkdir -p "$ARCHIVE_DIR"

    local timestamp
    timestamp=$(date -u +%Y%m%d%H%M%S)
    local archive_file="$ARCHIVE_DIR/health-history-${timestamp}.json"

    mv "$HISTORY_FILE" "$archive_file"
    echo "{}" > "$HISTORY_FILE"

    echo "[health-rotation] 已归档到: $archive_file"
    echo "[health-rotation] 新文件已创建: $HISTORY_FILE"

    # 保留最近 5 个归档
    local archives
    archives=$(ls -t "$ARCHIVE_DIR"/health-history-*.json 2>/dev/null | tail -n +6 || echo "")
    if [ -n "$archives" ]; then
        echo "[health-rotation] 清理旧归档..."
        # P2 修复：变量引用加引号
        echo "$archives" | while IFS= read -r archive; do
            rm -f "$archive"
        done
    fi
}

main "$@"
