#!/bin/bash
set -euo pipefail

# === CLI ===
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat << 'EOHELP'
session-start — SessionStart hook: 注册命令 + 恢复会话状态

用法: session-start

无参数运行，hook 自动生效。

-h, --help  显示此帮助
EOHELP
    exit 0
fi

CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

# 注册斜杠命令
if [[ -f "${CLAUDE_PROJECT_DIR}/scripts/generate-commands.sh" ]]; then
    cd "${CLAUDE_PROJECT_DIR}"
    ./scripts/generate-commands.sh --force 2>/dev/null || true
    echo "[flow-kit] hooks ready"
fi

# v3.0.0: 记忆系统恢复
# v3.3.0: 冲突检测
if [[ -f "${CLAUDE_PROJECT_DIR}/lib/session-state.sh" ]]; then
    source "${CLAUDE_PROJECT_DIR}/lib/session-state.sh"
    session_resume_prompt

    # 检测未处理的冲突
    if [[ -f "${CLAUDE_PROJECT_DIR}/lib/conflict-detector.sh" ]]; then
        source "${CLAUDE_PROJECT_DIR}/lib/conflict-detector.sh"
        current_status=$(session_get status 2>/dev/null || echo "")
        if [[ "$current_status" == "paused" || "$current_status" == "replan" ]]; then
            echo "[flow-kit] ⚠️  检测到未处理的冲突状态: $current_status"
            echo "[flow-kit] 运行 /flow-kit:status 查看详情"
        fi
    fi
fi

exit 0
