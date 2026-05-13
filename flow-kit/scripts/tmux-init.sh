#!/bin/bash
# tmux-init.sh — v3.3.0 P3 tmux 并行开发初始化
# 创建 tmux session + git worktrees，生成 manifest

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/preflight.sh"
source "$SCRIPT_DIR/../lib/session-state.sh"

require_cmd tmux "tmux 未安装。安装: brew install tmux / apt install tmux"
require_cmd git "git 未安装"
require_jq

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
SESSION_NAME=""
WORKTREE_COUNT=2
BASE_BRANCH=""

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
tmux-init.sh — 创建 tmux 并行开发环境

用法:
  ./tmux-init.sh [选项]

选项:
  --name <名称>      tmux 会话名称（默认: flow-kit-<timestamp>）
  --worktrees <N>    worktree 数量（默认: 2）
  --base <分支>      基础分支（默认: HEAD）
  -h, --help         显示帮助信息

功能:
  1. 前置检查（tmux/git 版本）
  2. 创建 git worktrees
  3. 创建 tmux 会话 + 窗口
  4. 写入 manifest 文件

示例:
  ./tmux-init.sh --worktrees 3
  ./tmux-init.sh --name my-session --worktrees 4 --base main
EOF
}

#------------------------------------------------------------------------------
# 参数解析
#------------------------------------------------------------------------------
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --name)      SESSION_NAME="$2"; shift 2 ;;
            --worktrees)
                WORKTREE_COUNT="$2"
                if [[ ! "$WORKTREE_COUNT" =~ ^[1-9][0-9]*$ ]]; then
                    echo "[tmux-init] 错误: worktree 数量必须是正整数" >&2
                    exit 1
                fi
                shift 2
                ;;
            --base)      BASE_BRANCH="$2"; shift 2 ;;
            -h|--help)   show_help; exit 0 ;;
            *)           echo "[tmux-init] 未知选项: $1" >&2; exit 1 ;;
        esac
    done

    SESSION_NAME="${SESSION_NAME:-flow-kit-$(date +%s)}"
    BASE_BRANCH="${BASE_BRANCH:-HEAD}"
}

#------------------------------------------------------------------------------
# 前置检查
#------------------------------------------------------------------------------
preflight_tmux() {
    # 不在 tmux 内运行
    if [ -n "${TMUX:-}" ]; then
        echo "[tmux-init] 错误: 不能在 tmux 会话内运行" >&2
        exit 1
    fi

    # tmux 版本 >= 2.0
    local tmux_ver
    tmux_ver=$(tmux -V 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' || echo "0.0")
    local major minor
    major=$(echo "$tmux_ver" | cut -d. -f1)
    minor=$(echo "$tmux_ver" | cut -d. -f2)
    if [ "$major" -lt 2 ]; then
        echo "[tmux-init] 错误: tmux 版本 >= 2.0 需要（当前 $tmux_ver）" >&2
        exit 1
    fi

    # git 仓库检查
    if ! git -C "$PROJECT_DIR" rev-parse --git-dir &>/dev/null; then
        echo "[tmux-init] 错误: 不在 git 仓库中" >&2
        exit 1
    fi
}

#------------------------------------------------------------------------------
# 创建 worktrees
#------------------------------------------------------------------------------
create_worktrees() {
    local count="$1"
    local base="$2"
    local worktree_dir="$PROJECT_DIR/.flow-kit/worktrees"

    mkdir -p "$worktree_dir"

    local worktrees="["

    for ((i=1; i<=count; i++)); do
        local wt_path="$worktree_dir/worker-$i"
        local branch_name="flow-kit/worker-$i"

        # 清理已存在的 worktree
        if [ -d "$wt_path" ]; then
            git -C "$PROJECT_DIR" worktree remove --force "$wt_path" 2>/dev/null || rm -rf "$wt_path"
        fi

        # 创建 worktree
        if ! git -C "$PROJECT_DIR" worktree add -b "$branch_name" "$wt_path" "$base" 2>/dev/null; then
            # 分支可能已存在，用已有分支
            git -C "$PROJECT_DIR" worktree add "$wt_path" "$base" 2>/dev/null || {
                echo "[tmux-init] 错误: 无法创建 worktree $wt_path" >&2
                exit 1
            }
        fi

        if [ "$worktrees" != "[" ]; then
            worktrees+=","
        fi
        worktrees+="{\"index\":$i,\"path\":\"$wt_path\",\"branch\":\"$branch_name\"}"

        echo "[tmux-init] worktree $i: $wt_path"
    done

    worktrees+="]"
    echo "$worktrees"
}

#------------------------------------------------------------------------------
# 创建 tmux 会话
#------------------------------------------------------------------------------
create_tmux_session() {
    local name="$1"
    local count="$2"
    local worktrees_json="$3"

    # 创建会话
    tmux new-session -d -s "$name" -x 200 -y 50

    # 为每个 worker 创建窗口
    for ((i=1; i<=count; i++)); do
        local wt_path
        wt_path=$(echo "$worktrees_json" | jq -r ".[$((i-1))].path")

        if [ "$i" -eq 1 ]; then
            # 第一个窗口使用默认窗口
            tmux send-keys -t "$name" "cd $wt_path && clear" Enter
        else
            tmux new-window -t "$name" -n "worker-$i"
            tmux send-keys -t "$name:worker-$i" "cd $wt_path && clear" Enter
        fi

        echo "[tmux-init] pane $i: cd $wt_path"
    done

    echo "[tmux-init] 会话创建: $name ($count 窗口)"
}

#------------------------------------------------------------------------------
# 写入 manifest
#------------------------------------------------------------------------------
write_manifest() {
    local session="$1"
    local worktrees_json="$2"
    local manifest_file="$TMP_DIR/tmux-manifest.json"

    mkdir -p "$TMP_DIR"

    jq -n \
        --arg session "$session" \
        --argjson worktrees "$worktrees_json" \
        --argjson count "$WORKTREE_COUNT" \
        --arg created "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            session_name: $session,
            worktree_count: $count,
            worktrees: $worktrees,
            created_at: $created,
            status: "ready"
        }' > "$manifest_file"

    echo "[tmux-init] manifest: $manifest_file"
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    parse_args "$@"
    preflight_tmux

    echo "[tmux-init] 初始化 tmux 并行开发环境"
    echo "[tmux-init] 会话: $SESSION_NAME | worktrees: $WORKTREE_COUNT | base: $BASE_BRANCH"
    echo ""

    local worktrees_json
    worktrees_json=$(create_worktrees "$WORKTREE_COUNT" "$BASE_BRANCH")

    echo ""
    create_tmux_session "$SESSION_NAME" "$WORKTREE_COUNT" "$worktrees_json"
    write_manifest "$SESSION_NAME" "$worktrees_json"

    echo ""
    echo "[tmux-init] ✅ 初始化完成"
    echo "[tmux-init] 连接: tmux attach -t $SESSION_NAME"
    echo "[tmux-init] 状态: ./tmux-status.sh"
    echo "[tmux-init] 清理: ./tmux-cleanup.sh --force"

    session_history_add "tmux-init" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
