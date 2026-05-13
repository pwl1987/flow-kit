---
description: "生成斜杠命令 - 重新生成 21 个核心命令"
category: dev
reference: flow-kit/commands/generate-commands.md
---

重新生成 flow-kit 斜杠命令文件：

执行脚本：

```bash
bash flow-kit/scripts/generate-commands.sh --force
```

参考文档：
@flow-kit/commands/generate-commands.md

生成规则：

- 输出到项目根 `.claude/commands/` 目录
- 生成 21 个核心命令（12 基础 + 9 Phase）
- 自动清理旧格式命令
- 使用 `--force` 覆盖已有文件

验证：

```bash
ls .claude/commands/flow-kit:*.md | wc -l  # 应输出 21
```
