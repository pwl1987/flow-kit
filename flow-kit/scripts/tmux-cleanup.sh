#!/bin/bash
# tmux-cleanup.sh — v3.3.0 P3 tmux 并行开发清理
# 清理 tmux 会话 + git worktrees + manifest

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/error-handler.sh"
source "$SCRIPT_DIR/../lib/preflight.sh"
source "$SCRIPT_DIR/../lib/session-state.sh"

require_cmd tmux "tmux 未安装"
require_cmd git "git 未安装"
require_jq

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
FORCE=false
KEEP_WORKTREES=false
SESSION_NAME=""

#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
tmux-cleanup.sh — 清理 tmux 并行开发环境

用法:
  ./tmux-cleanup.sh [选项]

选项:
  --force            跳过确认（非 TTY 必需）
  --keep-worktrees   仅清理 tmux，保留 worktrees
  --session <名称>   tmux 会话名称（默认: 从 manifest 读取）
  -h, --help         显示帮助信息

示例:
  ./tmux-cleanup.sh --force
  ./tmux-cleanup.sh --keep-worktrees
EOF
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --force)          FORCE=true; shift ;;
            --keep-worktrees) KEEP_WORKTREES=true; shift ;;
            --session)        SESSION_NAME="$2"; shift 2 ;;
            -h|--help)        show_help; exit 0 ;;
            *)                echo "[tmux-cleanup] 未知选项: $1" >&2; exit 1 ;;
        esac
    done
}

#------------------------------------------------------------------------------
# 清理 tmux 会话
#------------------------------------------------------------------------------
cleanup_tmux_session() {
    local session="$1"

    if tmux has-session -t "$session" 2>/dev/null; then
        tmux kill-session -t "$session" 2>/dev/null || true
        echo "[tmux-cleanup] tmux 会话已终止: $session"
    else
        echo "[tmux-cleanup] tmux 会话不存在: $session"
    fi
}

#------------------------------------------------------------------------------
# 清理 worktrees
#------------------------------------------------------------------------------
cleanup_worktrees() {
    local worktrees_json="$1"

    local count
    count=$(echo "$worktrees_json" | jq 'length')

    for ((i=0; i<count; i++)); do
        local wt_path branch
        wt_path=$(echo "$worktrees_json" | jq -r ".[$i].path")
        branch=$(echo "$worktrees_json" | jq -r ".[$i].branch")

        if [ -d "$wt_path" ]; then
            git -C "$PROJECT_DIR" worktree remove --force "$wt_path" 2>/dev/null || rm -rf "$wt_path"
            echo "[tmux-cleanup] worktree 已移除: $wt_path"
        fi

        # 尝试删除分支
        git -C "$PROJECT_DIR" branch -D "$branch" 2>/dev/null || true
    done
}

#------------------------------------------------------------------------------
# 清理 manifest
#------------------------------------------------------------------------------
cleanup_manifest() {
    local manifest_file="$TMP_DIR/tmux-manifest.json"

    if [ -f "$manifest_file" ]; then
        rm -f "$manifest_file"
        echo "[tmux-cleanup] manifest 已删除"
    fi

    # 清理日志
    rm -f "$TMP_DIR"/tmux-*.log 2>/dev/null || true
    rm -f "$TMP_DIR"/tmux-dag-*.json 2>/dev/null || true
    rm -f "$TMP_DIR"/dag-levels.json 2>/dev/null || true
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    parse_args "$@"

    local manifest_file="$TMP_DIR/tmux-manifest.json"

    if [ ! -f "$manifest_file" ]; then
        echo "[tmux-cleanup] 无 manifest，无需清理"
        return 0
    fi

    if [ -z "$SESSION_NAME" ]; then
        SESSION_NAME=$(jq -r '.session_name' "$manifest_file")
    fi

    local worktrees_json
    worktrees_json=$(jq -c '.worktrees' "$manifest_file")

    # 确认
    if [ "$FORCE" = false ]; then
        if [ ! -t 0 ]; then
            echo "[tmux-cleanup] 错误: 非 TTY 环境需要 --force" >&2
            exit 1
        fi
        echo "将清理: tmux session=$SESSION_NAME"
        [ "$KEEP_WORKTREES" = false ] && echo "将清理: worktrees"
        echo "将清理: manifest"
        echo ""
        read -p "确认清理? (y/n): " -r
        [[ ! $REPLY =~ ^[Yy]$ ]] && echo "[tmux-cleanup] 取消" && return 0
    fi

    echo "[tmux-cleanup] 开始清理..."

    # 1. 清理 tmux
    cleanup_tmux_session "$SESSION_NAME"

    # 2. 清理 worktrees
    if [ "$KEEP_WORKTREES" = false ]; then
        cleanup_worktrees "$worktrees_json"
    else
        echo "[tmux-cleanup] 保留 worktrees（--keep-worktrees）"
    fi

    # 3. 清理 manifest
    cleanup_manifest

    echo ""
    echo "[tmux-cleanup] ✅ 清理完成"

    session_history_add "tmux-cleanup" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
