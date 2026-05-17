#!/bin/bash
# project-info.sh — 项目信息获取库
# v3.5.1 新增：从 phase-executor.sh 提取

set -euo pipefail

readonly _PI_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_PI_SCRIPT_DIR/paths.sh" 2>/dev/null || true

#------------------------------------------------------------------------------
# 获取项目类型
# 返回: brownfield | greenfield
#------------------------------------------------------------------------------
get_project_type() {
    local type_file="${PROJECT_DIR:-$(_pi_detect_project_dir)}/.flow-kit/project-type"
    if [[ -f "$type_file" ]]; then
        local project_type
        project_type=$(grep -m1 "^project_type:" "$type_file" 2>/dev/null | cut -d' ' -f2 || true)
        if [[ -n "$project_type" ]]; then
            echo "$project_type"
            return
        fi
    fi
    echo "brownfield"
}

# 探测项目目录
_pi_detect_project_dir() {
    local dir="${BASH_SOURCE[1]}"
    while [[ "$dir" != "/" ]]; do
        [[ -d "$dir/.git" ]] && echo "$dir" && return
        dir="$(dirname "$dir")"
    done
    echo "$(pwd)"
}

#------------------------------------------------------------------------------
# 加载工作流文件
# 参数: $1=phase $2=project_type
# 返回: 工作流文件路径
#------------------------------------------------------------------------------
load_workflow() {
    local phase="${1:-}"
    local project_type="${2:-brownfield}"
    local workflow_file=""

    [[ -z "$phase" ]] && return

    local phases_dir="${PHASES_DIR:-$(_pi_get_phases_dir)}"
    local phase_dir
    phase_dir=$(ls -d "$phases_dir/${phase}" "$phases_dir/${phase}-"* 2>/dev/null | head -1)

    [[ -z "$phase_dir" ]] && return

    case "$project_type" in
        brownfield)
            workflow_file="$phase_dir/brownfield.md"
            [[ -f "$workflow_file" ]] || workflow_file=""
            ;;
        greenfield)
            workflow_file="$phase_dir/greenfield.md"
            [[ -f "$workflow_file" ]] || workflow_file=""
            ;;
    esac

    if [[ -z "$workflow_file" || ! -f "$workflow_file" ]]; then
        local main_md="$phase_dir/${phase##*-}.md"
        [[ -f "$main_md" ]] && workflow_file="$main_md" || workflow_file=$(ls "$phase_dir"/*.md 2>/dev/null | grep -v -e brownfield.md -e greenfield.md | head -1)
    fi

    echo "${workflow_file:-}"
}

_pi_get_phases_dir() {
    local dir="${BASH_SOURCE[1]}"
    dir="$(dirname "$dir")"
    dir="$(dirname "$dir")"
    echo "$dir/phases"
}