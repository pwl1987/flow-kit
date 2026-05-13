---
description: "模式切换 - 切换开发模式"
category: dev
reference: flow-kit/GO.md
---

读取并执行模式切换操作：

@flow-kit/GO.md

支持的子命令：

- `/flow-kit:mode autopilot` — 自动驾驶模式（默认）
- `/flow-kit:mode team` — 团队协作模式
- `/flow-kit:mode ralph` — Ralph 模式
- `/flow-kit:mode offline` — 离线模式（内置 lint）
- `/flow-kit:mode online` — 恢复在线模式
- `/flow-kit:mode minimal` — 极简模式（跳过非必要步骤）

当前模式保存在 `.flow-kit/mode` 文件中。
