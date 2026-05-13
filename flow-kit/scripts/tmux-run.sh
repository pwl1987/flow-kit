#!/bin/bash
# tmux-run.sh — v3.3.0 P3 tmux 并行任务执行
# 读取 manifest + 任务文件，按 DAG 顺序发送命令到 tmux panes

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/preflight.sh"
source "$SCRIPT_DIR/../lib/session-state.sh"

require_cmd tmux "tmux 未安装"
require_jq

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
TASK_FILE=""
TIMEOUT=600
SESSION_NAME=""

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
tmux-run.sh — 在 tmux 会话中并行执行任务

用法:
  ./tmux-run.sh [选项]

选项:
  --tasks <文件>     任务文件（JSON 格式）
  --timeout <秒>     超时时间（默认: 600）
  --session <名称>   tmux 会话名称（默认: 从 manifest 读取）
  -h, --help         显示帮助信息

任务文件格式 (JSON):
  [
    {"name": "task1", "pane": 1, "command": "echo hello", "wait_for": []},
    {"name": "task2", "pane": 2, "command": "echo world", "wait_for": ["task1"]}
  ]

示例:
  ./tmux-run.sh --tasks tasks.json
  ./tmux-run.sh --tasks tasks.json --timeout 300
EOF
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --tasks)    TASK_FILE="$2"; shift 2 ;;
            --timeout)  TIMEOUT="$2"; shift 2 ;;
            --session)  SESSION_NAME="$2"; shift 2 ;;
            -h|--help)  show_help; exit 0 ;;
            *)          echo "[tmux-run] 未知选项: $1" >&2; exit 1 ;;
        esac
    done
}

#------------------------------------------------------------------------------
# 读取 manifest
#------------------------------------------------------------------------------
read_manifest() {
    local manifest_file="$TMP_DIR/tmux-manifest.json"

    if [ ! -f "$manifest_file" ]; then
        echo "[tmux-run] 错误: manifest 不存在，先运行 tmux-init.sh" >&2
        exit 1
    fi

    if [ -z "$SESSION_NAME" ]; then
        SESSION_NAME=$(jq -r '.session_name' "$manifest_file")
    fi

    echo "$manifest_file"
}

#------------------------------------------------------------------------------
# 解析任务文件
#------------------------------------------------------------------------------
parse_task_file() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "[tmux-run] 错误: 任务文件不存在 $file" >&2
        exit 1
    fi

    if ! jq -e '.' "$file" >/dev/null 2>&1; then
        echo "[tmux-run] 错误: 无效 JSON $file" >&2
        exit 1
    fi

    local count
    count=$(jq 'length' "$file")
    echo "[tmux-run] 任务数: $count"
}

#------------------------------------------------------------------------------
# DAG 拓扑排序
#------------------------------------------------------------------------------
resolve_dag() {
    local tasks="$1"
    local sorted_file="$TMP_DIR/tmux-dag-sorted.json"

    # 提取任务名和依赖
    local task_names
    task_names=$(echo "$tasks" | jq -r '.[].name')

    local levels_file="$TMP_DIR/dag-levels.json"
    echo '[]' > "$levels_file"

    local completed="[]"
    local remaining="$tasks"
    local level=0

    while true; do
        local ready
        ready=$(echo "$remaining" | jq --argjson done "$completed" '
            [.[] | select((.wait_for // [] | length) == 0 or (
                (.wait_for // []) | map(. as $w | $done | map(.name) | index($w)) | all(. != null)
            ))]
        ')

        local ready_count
        ready_count=$(echo "$ready" | jq 'length')

        if [ "$ready_count" -eq 0 ]; then
            local remain_count
            remain_count=$(echo "$remaining" | jq 'length')
            if [ "$remain_count" -gt 0 ]; then
                echo "[tmux-run] 错误: 检测到循环依赖" >&2
                exit 1
            fi
            break
        fi

        # 记录层级
        local level_tasks
        level_tasks=$(echo "$ready" | jq --argjson level "$level" '[.[] + {level: $level}]')
        local tmp
        tmp=$(jq --argjson lt "$level_tasks" '. + $lt' "$levels_file")
        echo "$tmp" > "$levels_file"

        completed=$(echo "$completed" | jq --argjson r "$ready" '. + $r')
        remaining=$(echo "$remaining" | jq --argjson r "$ready" '
            [.[] | . as $item | $r | map(.name) | index($item.name) | if . == null then $item else empty end]
        ')

        level=$((level + 1))
    done

    cat "$levels_file"
}

#------------------------------------------------------------------------------
# 发送命令到 pane
#------------------------------------------------------------------------------
send_to_pane() {
    local session="$1"
    local pane="$2"
    local command="$3"

    local target
    if [ "$pane" -eq 1 ]; then
        target="$session"
    else
        target="$session:worker-$pane"
    fi

    tmux send-keys -t "$target" "$command" Enter
}

#------------------------------------------------------------------------------
# 检查 pane 状态
#------------------------------------------------------------------------------
check_pane_status() {
    local session="$1"
    local pane="$2"

    local target
    if [ "$pane" -eq 1 ]; then
        target="$session"
    else
        target="$session:worker-$pane"
    fi

    local output
    output=$(tmux capture-pane -t "$target" -p -S -10 2>/dev/null || echo "")

    if echo "$output" | grep -q "FLOW-KIT-DONE"; then
        echo "done"
    elif echo "$output" | grep -q "FLOW-KIT-ERROR"; then
        echo "error"
    else
        echo "running"
    fi
}

#------------------------------------------------------------------------------
# 执行任务
#------------------------------------------------------------------------------
run_tasks() {
    local session="$1"
    local tasks="$2"
    local timeout="$3"

    local sorted
    sorted=$(resolve_dag "$tasks")

    local max_level
    max_level=$(echo "$sorted" | jq '[.[].level] | max // 0')

    local total_tasks
    total_tasks=$(echo "$sorted" | jq 'length')

    echo "[tmux-run] 执行 $total_tasks 个任务 ($((max_level + 1)) 层级)"

    for ((level=0; level<=max_level; level++)); do
        local level_tasks
        level_tasks=$(echo "$sorted" | jq --argjson l "$level" '[.[] | select(.level == $l)]')

        local level_count
        level_count=$(echo "$level_tasks" | jq 'length')

        echo "[tmux-run] 层级 $level: $level_count 个任务"

        # 并行发送
        echo "$level_tasks" | jq -c '.[]' | while IFS= read -r task; do
            local name pane command
            name=$(echo "$task" | jq -r '.name')
            pane=$(echo "$task" | jq -r '.pane')
            command=$(echo "$task" | jq -r '.command')

            echo "[tmux-run] 发送: $name → pane $pane"
            send_to_pane "$session" "$pane" "$command"
            send_to_pane "$session" "$pane" "echo FLOW-KIT-DONE"
        done

        # 等待当前层级完成
        local elapsed=0
        local check_interval=5
        while [ "$elapsed" -lt "$timeout" ]; do
            local all_done=true
            echo "$level_tasks" | jq -c '.[]' | while IFS= read -r task; do
                local pane
                pane=$(echo "$task" | jq -r '.pane')
                local status
                status=$(check_pane_status "$session" "$pane")
                if [ "$status" = "running" ]; then
                    all_done=false
                fi
            done

            if [ "$all_done" = true ]; then
                break
            fi

            sleep "$check_interval"
            elapsed=$((elapsed + check_interval))
            echo "[tmux-run] 等待... (${elapsed}s/${timeout}s)"
        done
    done

    echo "[tmux-run] ✅ 所有任务已发送"
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    parse_args "$@"

    if [ -z "$TASK_FILE" ]; then
        echo "[tmux-run] 错误: 需要 --tasks 参数" >&2
        show_help
        exit 1
    fi

    read_manifest
    parse_task_file "$TASK_FILE"

    local tasks
    tasks=$(cat "$TASK_FILE")

    echo "[tmux-run] 会话: $SESSION_NAME | 超时: ${timeout}s"
    echo ""

    run_tasks "$SESSION_NAME" "$tasks" "$TIMEOUT"

    session_history_add "tmux-run" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
