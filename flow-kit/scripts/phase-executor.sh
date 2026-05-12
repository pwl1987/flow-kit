#!/bin/bash
# phase-executor.sh — 条件路由脚本 v1.0
# 根据项目类型加载不同的工作流文件
# 用法: ./phase-executor.sh <phase-num>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"

PHASE_NUM="${1:-}"

# 获取项目类型
get_project_type() {
    local type_file="$PROJECT_DIR/.flow-kit/project-type"
    if [ -f "$type_file" ]; then
        grep -m1 "^project_type:" "$type_file" | cut -d' ' -f2
    else
        # 未检测，默认棕地（保守策略）
        echo "brownfield"
    fi
}

# 加载工作流文件
load_workflow() {
    local phase="$1"
    local project_type="$2"
    local workflow_file=""

    # 查找 Phase 目录（支持 0-change, 1-requirement 等格式）
    local phase_dir
    phase_dir=$(find "$PHASES_DIR" -maxdepth 1 -name "${phase}" -o -name "${phase}-*" 2>/dev/null | head -1)

    if [ -z "$phase_dir" ]; then
        echo ""
        return
    fi

    # 优先加载项目类型专用工作流
    case "$project_type" in
        brownfield)
            workflow_file=$(find "$phase_dir" -name "brownfield.md" 2>/dev/null | head -1)
            ;;
        greenfield)
            workflow_file=$(find "$phase_dir" -name "greenfield.md" 2>/dev/null | head -1)
            ;;
        *)
            workflow_file=""
            ;;
    esac

    # 如果没有专用工作流，加载通用工作流
    if [ -z "$workflow_file" ] || [ ! -f "$workflow_file" ]; then
        workflow_file=$(find "$phase_dir" -maxdepth 1 -name "*.md" ! -name "brownfield.md" ! -name "greenfield.md" 2>/dev/null | head -1)
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

    echo "[phase-executor] 项目类型: $project_type"
    echo "[phase-executor] Phase: $PHASE_NUM"

    local workflow_file
    workflow_file=$(load_workflow "$PHASE_NUM" "$project_type")

    if [ -z "$workflow_file" ]; then
        echo "[phase-executor] 错误: 未找到 Phase $PHASE_NUM 的工作流文件"
        exit 1
    fi

    echo "[phase-executor] 加载工作流: $workflow_file"
    echo ""

    # 加载工作流文件内容
    cat "$workflow_file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
