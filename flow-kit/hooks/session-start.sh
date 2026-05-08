#!/bin/bash
# session-start.sh — SessionStart hook: 自动注册斜杠命令
# v1.8 新增
# Reference: flow-kit register-commands.md

CLAUDE_PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# 检查并注册斜杠命令
if [ -f "$CLAUDE_PROJECT_DIR/scripts/generate-commands.sh" ]; then
    cd "$CLAUDE_PROJECT_DIR"
    ./scripts/generate-commands.sh --dry-run 2>/dev/null || true
echo "[flow-kit] hooks 已就绪"

exit 0

## 参考来源
- [Claude Code Hooks 官方文档](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [garrytan/gstack](https://github.com/garrytan/gstack) — /careful 破坏性命令警告模式