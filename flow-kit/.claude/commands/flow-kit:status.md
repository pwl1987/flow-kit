---
description: "显示当前状态 - 阶段/模式/护栏"
category: dev
reference: flow-kit/flow-kit.sh
---

显示 flow-kit 当前项目状态：

读取以下文件并汇总输出：

- `.flow-kit/current-phase` — 当前阶段（0-8）
- `.flow-kit/mode` — 当前模式（autopilot/team/ralph）
- `.flow-kit/project-type` — 项目类型（brownfield/greenfield）
- `.specs/` — 活跃变更目录列表

输出格式：

```
flow-kit v2.7.0 状态
├─ 阶段: Phase {N} — {名称}
├─ 模式: {mode}
├─ 类型: {project_type}
└─ 活跃变更: {count} 个
```

同时执行 @flow-kit/flow-kit.sh status 子命令获取详细信息。
