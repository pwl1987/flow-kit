#!/bin/bash
# metrics.sh — /metrics 命令 CLI
# v3.7.0 新增

set -uo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPTS_DIR")/lib"

source "$LIB_DIR/error-handler.sh"
source "$LIB_DIR/paths.sh"
source "$LIB_DIR/metrics-logger.sh"

usage() {
    cat << 'EOF'
/metrics — 查看执行指标

用法:
  /metrics --summary   聚合摘要
  /metrics --detail    详细列表
  /metrics --clear     清空指标日志

默认: --summary
EOF
}

case "${1:---summary}" in
    --summary)
        echo "=== 指标汇总 ==="
        metrics_summary
        ;;
    --detail)
        echo "=== 指标详情 ==="
        if [[ -f "$METRICS_LOG_FILE" ]]; then
            cat "$METRICS_LOG_FILE"
        else
            echo "暂无指标数据"
        fi
        ;;
    --clear)
        if [[ -f "$METRICS_LOG_FILE" ]]; then
            : > "$METRICS_LOG_FILE"
            echo "指标日志已清空"
        else
            echo "无指标日志"
        fi
        ;;
    -h|--help)
        usage
        ;;
    *)
        echo "未知参数: $1" >&2
        usage
        ;;
esac
