---
description: "Hooks 管理 - 安装/检查/诊断"
category: dev
reference: flow-kit/commands/hooks-guide.md
---

读取并执行 hooks 管理操作：

@flow-kit/commands/hooks-guide.md

支持的子命令：

- `/flow-kit:hooks install` — 安装 hooks 到 .claude/settings.json
- `/flow-kit:hooks status` — 检查 hooks 安装状态
- `/flow-kit:hooks diagnose` — 诊断 hooks 执行问题

已注册的 5 个 hooks：

1. pre-tool-guard.sh — 工具调用前安全检查
2. post-edit-format.sh — 编辑后自动格式化
3. stop-quality-gate.sh — 停止前质量门
4. session-start.sh — 会话启动初始化
5. notification.sh — 通知发送
