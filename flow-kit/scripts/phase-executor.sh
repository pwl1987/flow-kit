#!/bin/bash
# phase-executor.sh — 条件路由脚本 v1.0
# 根据项目类型加载不同的工作流文件
# 用法: ./phase-executor.sh <phase-num>

set -euo pipefail

usage() {
    cat << 'EOF'
用法: phase-executor.sh [选项] <phase-num>

选项:
  -h, --help     显示此帮助

参数:
  phase-num      Phase 编号 (0-8)，如 0、1、2... 或 0-change、1-requirement 等

示例:
  phase-executor.sh 0
  phase-executor.sh 4-dev
  phase-executor.sh --help
EOF
}

# 参数解析
while getopts ":h" opt; do
    case "$opt" in
        h)
            usage
            exit 0
            ;;
        \?)
            echo "未知选项: -$OPTARG" >&2
            usage >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/session-state.sh"
source "$SCRIPT_DIR/../lib/project-info.sh"

PHASE_NUM="${1:-}"

main() {
    if [[ -z "$PHASE_NUM" ]]; then
        echo "用法: $0 <phase-num>"
        echo "示例: $0 0-change"
        exit 1
    fi

    local project_type
    project_type=$(get_project_type)

    echo "[phase-exec] type=$project_type phase=$PHASE_NUM"

    # v2.9.0: 持久化当前阶段到 .flow-kit/current-phase
    # v3.0.0: 同时更新 session-state.json
    # v3.3.0: 追加执行历史
    local phase_num_only="${PHASE_NUM%%-*}"
    [[ "$phase_num_only" =~ ^[0-9]+$ ]] || phase_num_only="0"
    mkdir -p "$(dirname "$CURRENT_PHASE_FILE")"
    printf '%s\n' "$phase_num_only" > "$CURRENT_PHASE_FILE"
    session_set phase "$phase_num_only"
    session_set status wip
    session_history_add "phase-${phase_num_only}"

    local workflow_file
    workflow_file=$(load_workflow "$PHASE_NUM" "$project_type")

    if [[ -z "$workflow_file" ]]; then
        echo "[phase-executor] 错误: 未找到 Phase $PHASE_NUM 的工作流文件"
        exit 1
    fi

    echo "[phase-exec] workflow=$workflow_file"
    echo ""

    # 加载工作流文件内容
    cat "$workflow_file"

    echo ""
    local guard_cmd="minimal"
    [[ "$project_type" == "brownfield" ]] && guard_cmd="full"
    echo "[phase-exec] guard: /flow-kit:guard $guard_cmd"

    # v3.5.0: 护栏自动激活提示
    local guard_active_file="$PROJECT_DIR/.flow-kit/guardrails-active"
    if [[ ! -f "$guard_active_file" ]]; then
        echo "[phase-exec] 💡 建议激活护栏: /flow-kit:guard $guard_cmd"
        echo "[phase-exec] 激活后将不再提示"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
