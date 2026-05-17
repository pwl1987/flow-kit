#!/bin/bash
set -euo pipefail

usage() {
    cat << 'EOF'
用法: next-phase.sh [选项]

选项:
  -h, --help     显示此帮助

描述:
  推进当前 Phase 到下一个 Phase (0→1→2...→8)

示例:
  next-phase.sh
  next-phase.sh --help
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

get_current_phase() {
    local current
    if [[ -f "$CURRENT_PHASE_FILE" ]]; then
        current=$(cat "$CURRENT_PHASE_FILE")
    else
        current="0"
    fi

    if [[ ! "$current" =~ ^[0-9]+$ ]]; then
        echo "错误: 阶段文件内容非法: $current" >&2
        exit 1
    fi

    echo "$current"
}

advance_phase() {
    local current="$1"
    local next=$((current + 1))

    if [[ $next -gt 8 ]]; then
        echo "已经是最后一个 Phase (8)"
        echo "流程完成！"
        return 0
    fi

    # v2.8.0: 使用原子写入防止并发竞态
    mkdir -p "$(dirname "$CURRENT_PHASE_FILE")"
    local tmp_file="$CURRENT_PHASE_FILE.tmp.$$"
    echo "$next" > "$tmp_file"
    mv "$tmp_file" "$CURRENT_PHASE_FILE"

    # v3.0.0: 更新会话状态
    # v3.3.0: 追加执行历史
    session_set phase "$next"
    session_set status pending
    session_next "run /flow-kit:phase-$next"
    session_history_add "next->$next"

    echo "phase $current → $next"
    echo "run /flow-kit:phase-$next"
}

main() {
    local current
    current=$(get_current_phase)
    advance_phase "$current"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
