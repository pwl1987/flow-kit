---
name: phase-0
description: 变更立项
disable-model-invocation: true
---

# Phase 0: Change ID - 变更识别与立项

## 触发条件

- 用户通过自然语言、Issue 或 Ticket 描述变更需求
- 系统识别到需要创建新的 Change ID 的场景
- 外部系统（如 GitHub Issue、Jira Ticket）触发变更请求

## 核心行为

1. **变更需求解析**：解析用户输入，提取核心变更意图
2. **Change ID 生成**：为每个变更分配唯一标识符，格式：`{slugified-function}-{YYYYMMDD}`