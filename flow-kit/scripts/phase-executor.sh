#!/bin/bash
# phase-executor.sh — 条件路由脚本 v1.0
# 根据项目类型加载不同的工作流文件
# 用法: ./phase-executor.sh <phase-num>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/session-state.sh"

PHASE_NUM="${1:-}"

# 获取项目类型
get_project_type() {
    local type_file="$PROJECT_DIR/.flow-kit/project-type"
    if [ -f "$type_file" ]; then
        local project_type
        project_type=$(grep -m1 "^project_type:" "$type_file" 2>/dev/null | cut -d' ' -f2 || true)
        if [ -n "$project_type" ]; then
            echo "$project_type"
            return
        fi
    fi

    # 未检测，默认棕地（保守策略）
    echo "brownfield"
}

# 加载工作流文件
load_workflow() {
    local phase="$1"
    local project_type="$2"
    local workflow_file=""

    # 查找 Phase 目录（支持 0-change, 1-requirement 等格式）
    local phase_dir
    phase_dir=$(ls -d "$PHASES_DIR/${phase}" "$PHASES_DIR/${phase}-"* 2>/dev/null | head -1)

    if [ -z "$phase_dir" ]; then
        echo ""
        return
    fi

    # 优先加载项目类型专用工作流
    case "$project_type" in
        brownfield)
            workflow_file="$phase_dir/brownfield.md"
            [ -f "$workflow_file" ] || workflow_file=""
            ;;
        greenfield)
            workflow_file="$phase_dir/greenfield.md"
            [ -f "$workflow_file" ] || workflow_file=""
            ;;
        *)
            workflow_file=""
            ;;
    esac

    # 如果没有专用工作流，加载通用工作流
    if [ -z "$workflow_file" ] || [ ! -f "$workflow_file" ]; then
        local main_md="$phase_dir/${phase##*-}.md"
        [ -f "$main_md" ] && workflow_file="$main_md" || workflow_file=$(ls "$phase_dir"/*.md 2>/dev/null | grep -v -e brownfield.md -e greenfield.md | head -1)
    fi

    echo "$workflow_file"
}

main() {
    if [ -z "$PHASE_NUM" ]; then
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

    if [ -z "$workflow_file" ]; then
        echo "[phase-executor] 错误: 未找到 Phase $PHASE_NUM 的工作流文件"
        exit 1
    fi

    echo "[phase-exec] workflow=$workflow_file"
    echo ""

    # 加载工作流文件内容
    cat "$workflow_file"

    echo ""
    local guard_cmd="minimal"
    [ "$project_type" = "brownfield" ] && guard_cmd="full"
    echo "[phase-exec] guard: /flow-kit:guard $guard_cmd"

    # v3.5.0: 护栏自动激活提示
    local guard_active_file="$PROJECT_DIR/.flow-kit/guardrails-active"
    if [ ! -f "$guard_active_file" ]; then
        echo "[phase-exec] 💡 建议激活护栏: /flow-kit:guard $guard_cmd"
        echo "[phase-exec] 激活后将不再提示"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
