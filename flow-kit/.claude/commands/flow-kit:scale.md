---
description: "扩展级别评估 - L0~L3 复杂度"
category: dev
reference: flow-kit/commands/scale-level.md
---

读取并执行扩展级别评估：

@flow-kit/commands/scale-level.md

评估维度：

- **L0 极简**（1-3 文件）：跳过测试/审查，直接开发
- **L1 标准**（4-10 文件）：标准 9 阶段 (Phase 0-8)流程
- **L2 并行**（11-30 文件）：启用子代理并行执行
- **L3 团队**（30+ 文件）：完整团队协作流程

评估输入：

- 变更文件数
- 影响模块数
- 是否涉及数据库/安全/UI 变更
- 是否有跨团队依赖

输出评估结果并推荐对应流程和护栏级别。
