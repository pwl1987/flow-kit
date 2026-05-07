#!/bin/bash
# stop-quality-gate.sh — Stop hook: 质量门禁
# v1.8 新增
# Reference: smallnest/autoresearch PASSING_SCORE + Claude Code Stop hook

INPUT=$(cat)

# 防止无限循环
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
    exit 0
fi

# 检查是否存在测试命令
if [ -f "package.json" ] && grep -q '"test"' package.json; then
    if ! npm test 2>&1; then
        echo "测试未通过。请修复后再结束。" >&2
        exit 2
    fi
fi

exit 0