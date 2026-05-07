#!/bin/bash
# post-edit-format.sh — PostToolUse hook: 自动格式化代码
# v1.8 新增
# Reference: Claude Code hooks 社区最佳实践

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')

# 仅处理 Edit 和 Write
if [ "$TOOL" != "Edit" ] && [ "$TOOL" != "Write" ]; then
    exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# 尝试用 prettier 格式化
if command -v npx &> /dev/null; then
    npx prettier --write "$FILE_PATH" 2>/dev/null &
fi

exit 0