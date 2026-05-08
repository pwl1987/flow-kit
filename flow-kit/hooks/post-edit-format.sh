#!/bin/bash
# post-edit-format.sh — PostToolUse hook: 自动格式化代码
# v1.12.5 P2 修复: source 路径基于 CLAUDE_PROJECT_DIR
# Reference: Claude Code hooks 社区最佳实践

INPUT=$(cat)

# 获取项目目录（基于 INPUT 中的 project_dir）
PROJECT_DIR=$(echo "$INPUT" | jq -r '.project_dir // empty')
if [ -z "$PROJECT_DIR" ]; then
    PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

# 引入统一错误处理框架
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PROJECT_DIR/flow-kit/lib/error-handler.sh"

START_TIME=$(date +%s%3N)

TOOL=$(echo "$INPUT" | jq -r '.tool_name')

# 仅处理 Edit 和 Write
if [ "$TOOL" != "Edit" ] && [ "$TOOL" != "Write" ]; then
    exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# 尝试用 prettier 格式化（v1.12.4 修复: 同步执行 + timeout 3）
if command -v npx &> /dev/null; then
    if ! timeout 3 npx prettier --write "$FILE_PATH" 2>/dev/null; then
        echo "[flow-kit] prettier 格式化失败或超时: $FILE_PATH" >&2
    fi
fi

# hooks 执行遥测
END_TIME=$(date +%s%3N)
ELAPSED=$((END_TIME - START_TIME))
mkdir -p "$PROJECT_DIR/.flow-kit/logs"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [post-edit-format] [OK] [${ELAPSED}ms]" >> "$PROJECT_DIR/.flow-kit/logs/hooks-execution.log" 2>/dev/null || true

exit 0

## 参考来源
- [Claude Code Hooks 官方文档](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [garrytan/gstack](https://github.com/garrytan/gstack) — /careful 破坏性命令警告模式