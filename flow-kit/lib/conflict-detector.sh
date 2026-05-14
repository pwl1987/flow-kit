#!/bin/bash
# conflict-detector.sh — v3.3.0 P1 需求冲突检测与决策引导
# 检测新需求与当前变更冲突，分类需求类型，引导用户决策

set -euo pipefail

readonly _CD_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_CD_SCRIPT_DIR/session-state.sh" 2>/dev/null || true

#------------------------------------------------------------------------------
# 需求分类
#------------------------------------------------------------------------------
classify_requirement() {
    local req="$1"

    # 紧急修复关键词
    if echo "$req" | grep -qiE "bug|修复|紧急|crash|error|错误|崩溃|异常|失败"; then
        echo "紧急修复"
        return
    fi

    # 架构调整关键词
    if echo "$req" | grep -qiE "重构|架构|refactor|design|设计|优化架构|重新设计"; then
        echo "架构调整"
        return
    fi

    # 功能增强关键词
    if echo "$req" | grep -qiE "添加|新增|优化|add|feature|功能|增强|改进|扩展"; then
        echo "功能增强"
        return
    fi

    # 默认
    echo "其他"
}

#------------------------------------------------------------------------------
# 冲突检测
#------------------------------------------------------------------------------
detect_conflict() {
    local new_req="${1:-}"
    [ -z "$new_req" ] && return 1

    # 读取当前状态
    local current_change current_phase current_status
    current_change=$(session_get change 2>/dev/null || echo "")
    current_phase=$(session_get phase 2>/dev/null || echo "0")
    current_status=$(session_get status 2>/dev/null || echo "init")

    # 无进行中变更，无冲突
    if [ -z "$current_change" ] || [ "$current_status" = "init" ]; then
        return 1
    fi

    # 有进行中变更，检测冲突
    if [ "$current_status" = "wip" ] || [ "$current_status" = "pending" ]; then
        local req_type
        req_type=$(classify_requirement "$new_req")

        echo ""
        echo "=========================================="
        echo "[conflict] 检测到需求冲突"
        echo "=========================================="
        echo ""
        echo "当前状态: phase=${current_phase}(${current_status}) change=${current_change}"
        echo "新需求: ${new_req}"
        echo "分类: ${req_type}"
        echo ""
        echo "选择:"
        echo "  1. 中断当前 → 保存进度，切换到新需求"
        echo "  2. 纳入后续 → 添加到 backlog，当前继续"
        echo "  3. 合并重规划 → 暂停，重新规划包含两个需求"
        echo ""

        return 0
    fi

    return 1
}

#------------------------------------------------------------------------------
# 文件冲突检测
#------------------------------------------------------------------------------
detect_file_conflicts() {
    local new_change="${1:-}"
    local project_dir="${2:-$PROJECT_DIR}"
    [ -z "$new_change" ] && return 1

    local current_change
    current_change=$(session_get change 2>/dev/null || echo "")
    [ -z "$current_change" ] && return 1

    # 提取两个变更涉及的文件列表
    local current_files new_files
    current_files=$(_extract_change_files "$current_change" "$project_dir")
    new_files=$(_extract_change_files "$new_change" "$project_dir")

    [ -z "$current_files" ] || [ -z "$new_files" ] && return 1

    # 找交集（按行精确匹配）
    local conflicts=""
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        if echo "$current_files" | grep -qxF "$f"; then
            [ -n "$conflicts" ] && conflicts="$conflicts,"
            conflicts="${conflicts}${f}"
        fi
    done <<< "$new_files"

    if [ -n "$conflicts" ]; then
        echo "$conflicts"
        return 0
    fi
    return 1
}

# 从 .specs/<change>/ 提取涉及的文件列表
_extract_change_files() {
    local change="$1"
    local project_dir="$2"
    local specs_dir="$project_dir/.specs/$change"

    [ -d "$specs_dir" ] || return

    # 从 TASK.md/REQUIREMENT.md 提取文件引用
    grep -oE '[a-zA-Z0-9_/-]+\.(sh|md|json|js|ts)' "$specs_dir"/*.md 2>/dev/null | sort -u || true
}

#------------------------------------------------------------------------------
# 依赖冲突检测
#------------------------------------------------------------------------------
detect_dependency_conflicts() {
    local target_module="${1:-}"
    local project_dir="${2:-$PROJECT_DIR}"
    [ -z "$target_module" ] && return 1

    local current_change
    current_change=$(session_get change 2>/dev/null || echo "")
    [ -z "$current_change" ] && return 1

    # 检查当前变更是否修改了目标模块
    local current_files
    current_files=$(_extract_change_files "$current_change" "$project_dir")

    if echo "$current_files" | grep -qF "$target_module"; then
        echo "$target_module"
        return 0
    fi
    return 1
}

#------------------------------------------------------------------------------
# 决策处理
#------------------------------------------------------------------------------
handle_conflict_decision() {
    local choice="${1:-}"
    [ -z "$choice" ] && return 1

    case "$choice" in
        1)
            session_set status paused
            session_decision_add "conflict" "interrupt"
            echo ""
            echo "[conflict] ✅ 已暂停当前变更，可启动新需求"
            echo "[conflict] 恢复当前变更: /flow-kit:resume"
            ;;
        2)
            session_decision_add "conflict" "backlog"
            echo ""
            echo "[conflict] ✅ 新需求已记录到 backlog，当前变更继续"
            ;;
        3)
            session_set status replan
            session_decision_add "conflict" "replan"
            echo ""
            echo "[conflict] ✅ 已标记为重规划状态"
            echo "[conflict] 建议: 重新运行 /flow-kit:phase-0 合并需求"
            ;;
        *)
            echo "[conflict] ❌ 无效选择: $choice" >&2
            return 1
            ;;
    esac
}

#------------------------------------------------------------------------------
# 交互式冲突处理
#------------------------------------------------------------------------------
interactive_conflict_resolution() {
    local new_req="${1:-}"

    if ! detect_conflict "$new_req"; then
        return 1
    fi

    # 非交互式环境，仅显示冲突
    if [ ! -t 0 ]; then
        echo "[conflict] 非交互式环境，请手动处理冲突"
        return 0
    fi

    read -p "输入选择(1/2/3): " -r choice
    handle_conflict_decision "$choice"
}
