---
description: "注册斜杠命令 - 一键注册所有命令"
category: dev
reference: flow-kit/commands/register-commands.md
---

一键注册 flow-kit 斜杠命令到 Claude Code：

参考文档：
@flow-kit/commands/register-commands.md

执行步骤：

1. 运行 `bash flow-kit/scripts/generate-commands.sh --force`
2. 验证 `.claude/commands/` 下生成 21 个命令文件
3. 输出注册结果摘要

安装方式：

```bash
# 自动注册（推荐）
bash flow-kit/scripts/generate-commands.sh --force

# 验证
ls .claude/commands/flow-kit:*.md | wc -l  # → 21
```

如需在 Claude Code 中使用，输入 `/flow-kit:` 查看自动补全。
