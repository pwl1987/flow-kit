#!/bin/bash
# dispatch-status.sh — 多代理编排状态查看命令
# v1.12.5 P3 新增
# 查看当前 dispatch 任务执行状态

set -euo pipefail

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"
# 注意：TMP_DIR/LOCK_DIR 复用 paths.sh 中的定义

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
dispatch-status.sh — 多代理编排状态查看

用法:
  ./dispatch-status.sh

输出:
  格式化状态表，展示当前 dispatch 任务状态
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

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "多代理编排状态表"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # 检查是否有任务在运行
    if [ ! -f "$summary_file" ]; then
        echo "  (暂无正在执行的任务)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "启动新任务: ./dispatch.sh [N] \"任务描述\""
        return
    fi

    if ! jq -e . "$summary_file" >/dev/null 2>&1; then
        echo "  (dispatch 状态文件不是有效 JSON: $summary_file)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        return 1
    fi

    # 基本信息
    echo "任务ID:   $(jq -r '.task_id' "$summary_file")"
    echo "任务描述: $(jq -r '.task_desc' "$summary_file")"
    echo "并行数:   $(jq -r '.parallel_n' "$summary_file")"
    echo "创建时间: $(jq -r '.created_at' "$summary_file")"

    local executed_at
    executed_at=$(jq -r '.executed_at // "未执行"' "$summary_file")
    echo "执行时间: $executed_at"
    echo ""

    # 执行统计
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

    # 子代理状态表
    echo "子代理状态:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "%-12s %-18s %-10s %s\n" "代理ID" "角色" "状态" "执行时间"
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
        local duration
        duration=$(echo "$agent_json" | jq -r '.duration // "-"')
        local status_text=""
        case "$status" in
            SUCCESS) status_text="✅ 成功" ;;
            FAILED) status_text="❌ 失败" ;;
            PARTIAL) status_text="⚠️ 部分" ;;
            QUEUED) status_text="⏳ 排队中" ;;
            RUNNING) status_text="🔄 运行中" ;;
            *) status_text="$status" ;;
        esac
        printf "%-12s %-18s %-10s %s\n" "$id" "$role" "$status_text" "${duration:-}"
    done < <(jq -c '.agents[]' "$summary_file" 2>/dev/null)

    if [ "$has_agents" != true ]; then
        echo "  (暂无子代理)"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 锁状态
    echo ""
    echo "锁状态:"
    local locks_count=0
    if [ -d "$LOCK_DIR" ]; then
        locks_count=$(find "$LOCK_DIR" -name "*.lock" -type d 2>/dev/null | wc -l)
    fi
    echo "  活跃锁数: $locks_count"

    echo ""
    echo "⏳ 使用 ./dispatch-aggregate.sh 查看完整报告"
}

# v1.12.9 改进：仅在直接执行时运行 main，source 时不执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
