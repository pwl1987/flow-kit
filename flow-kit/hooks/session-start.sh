#!/bin/bash
set -euo pipefail
# session-start.sh — SessionStart hook: 自动注册斜杠命令
# v1.12.17 P2 修复: 实际执行注册而非 dry-run，仅在新命令缺失时更新
# v1.8 新增
# Reference: flow-kit register-commands.md

CLAUDE_PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# 检查并注册斜杠命令（仅在新命令缺失时更新）
if [ -f "${CLAUDE_PROJECT_DIR}/scripts/generate-commands.sh" ]; then
    cd "${CLAUDE_PROJECT_DIR}"
    # v1.12.17: 实际执行注册，而非 dry-run
    ./scripts/generate-commands.sh --force 2>/dev/null || true
    echo "[flow-kit] hooks 已就绪"
fi

exit 0

# v1.12.10 修复：URL 放在 bash 注释中避免被解析
# 参考来源：
# - Claude Code Hooks 官方文档：https://docs.anthropic.com/en/docs/claude-code/hooks
# - garrytan/gstack：https://github.com/garrytan/gstack
