#!/bin/bash
# dispatch-aggregate.sh — 多代理编排聚合报告生成器
# v1.12.5 P1 新增
# 读取 dispatch-summary.json 生成聚合报告

set -euo pipefail

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"
# 注意：TMP_DIR 复用 paths.sh 中的定义

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
dispatch-aggregate.sh — 多代理编排聚合报告生成器

用法:
  ./dispatch-aggregate.sh [summary_file]

参数:
  summary_file  dispatch-summary.json 路径（默认: .flow-kit/tmp/dispatch-summary.json）

输出:
  格式化聚合报告，包含执行统计、子代理状态、修改文件清单
EOF
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
        show_help
        exit 0
    fi

    local summary_file="${1:-$TMP_DIR/dispatch-summary.json}"

    if [ ! -f "$summary_file" ]; then
        echo "[dispatch-aggregate] 错误: 文件不存在 $summary_file" >&2
        echo "[dispatch-aggregate] 提示: 请先运行 ./dispatch.sh --execute" >&2
        exit 1
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "多代理编排聚合报告"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "任务ID: $(jq -r '.task_id' "$summary_file")"
    echo "任务描述: $(jq -r '.task_desc' "$summary_file")"
    echo "执行时间: $(jq -r '.executed_at // "未执行"' "$summary_file")"
    echo ""

    local total
    total=$(jq -r '.summary.total // 0' "$summary_file")
    local successful
    successful=$(jq -r '.summary.successful // 0' "$summary_file")
    local failed
    failed=$(jq -r '.summary.failed // 0' "$summary_file")
    local partial
    partial=$(jq -r '.summary.partial // 0' "$summary_file")

    echo "执行统计:"
    echo "  总代理数: $total"
    echo "  成功: $successful"
    echo "  失败: $failed"
    echo "  部分: $partial"
    echo ""

    echo "子代理状态:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    local has_agents=false
    while read -r agent_json; do
        has_agents=true
        local id
        id=$(echo "$agent_json" | jq -r '.id')
        local role
        role=$(echo "$agent_json" | jq -r '.role')
        local status
        status=$(echo "$agent_json" | jq -r '.status')
        local status_icon="⚪"
        case "$status" in
            SUCCESS) status_icon="✅" ;;
            FAILED) status_icon="❌" ;;
            PARTIAL) status_icon="⚠️" ;;
            QUEUED) status_icon="⏳" ;;
        esac
        echo "  $status_icon $id ($role): $status"
    done < <(jq -c '.agents[]' "$summary_file" 2>/dev/null)

    if [ "$has_agents" != true ]; then
        echo "  (尚未执行，请使用 --execute 运行)"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 收集所有修改的文件（使用 jq 数组输入聚合）
    echo ""
    echo "修改文件清单:"
    local all_files
    local result_files=("$TMP_DIR"/subagent-*-result.json)
    if [ ${#result_files[@]} -gt 0 ] && [ -f "${result_files[0]}" ]; then
        all_files=$(jq -s '[.[].files_modified // [] | flatten] | add | unique' "${result_files[@]}" 2>/dev/null || echo "[]")
    else
        all_files="[]"
    fi
    echo "$all_files" | jq -r '.[]' 2>/dev/null || echo "  (无)"

    echo ""
    echo "⏳ 使用 /flow-kit:dispatch-status 查看最新状态"
}

# v1.12.9 改进：仅在直接执行时运行 main，source 时不执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
