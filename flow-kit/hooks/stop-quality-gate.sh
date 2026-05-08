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

## 参考来源
- [Claude Code Hooks 官方文档](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [garrytan/gstack](https://github.com/garrytan/gstack) — /careful 破坏性命令警告模式
- [smallnest/autoresearch](https://github.com/smallnest/autoresearch) — PASSING_SCORE 质量门禁思想