#!/bin/bash
# pre-tool-guard.sh — PreToolUse hook: 阻止危险命令和敏感文件编辑
# v1.8 新增
# Reference: gstack /careful + Morph Claude Code Hooks

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# 阻止危险的 Bash 命令
if [ "$TOOL" = "Bash" ]; then
    if echo "$COMMAND" | grep -qE 'rm -rf|git push --force|git reset --hard|DROP TABLE|TRUNCATE|dd if='; then
        echo "BLOCKED: 危险命令被 flow-kit 护栏拦截。请确认后重试。" >&2
        exit 2
    fi
fi

# 阻止编辑敏感文件
if [ "$TOOL" = "Edit" ] || [ "$TOOL" = "Write" ]; then
    if echo "$FILE_PATH" | grep -qE '\.env$|migrations/|package-lock\.json|\.git/'; then
        echo "BLOCKED: $FILE_PATH 是受保护文件。" >&2
        exit 2
    fi
fi

exit 0

## 参考来源
- [Claude Code Hooks 官方文档](https://docs.anthropic.com/en/docs/claude-code/hooks)