#!/bin/bash
set -euo pipefail
# session-start.sh — SessionStart hook: 注册命令 + 恢复会话状态
# v3.0.0: 完整记忆恢复（caveman 风格，~30 token）

CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

# 注册斜杠命令
if [ -f "${CLAUDE_PROJECT_DIR}/scripts/generate-commands.sh" ]; then
    cd "${CLAUDE_PROJECT_DIR}"
    ./scripts/generate-commands.sh --force 2>/dev/null || true
    echo "[flow-kit] hooks ready"
fi

# v3.0.0: 记忆系统恢复
if [ -f "${CLAUDE_PROJECT_DIR}/lib/session-state.sh" ]; then
    source "${CLAUDE_PROJECT_DIR}/lib/session-state.sh"
    session_resume_prompt
fi

exit 0
