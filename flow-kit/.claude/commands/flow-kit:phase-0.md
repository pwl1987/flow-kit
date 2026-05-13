---
description: "变更立项 - 评估影响范围，生成 change-id"
category: dev
reference: flow-kit/phases/0-change/
---

读取并执行以下 Phase 工作流文件：

@flow-kit/phases/0-change/0-change.md

执行条件路由时，参考 @flow-kit/scripts/phase-executor.sh 中棕地/绿地分叉逻辑。
当前项目类型从 @flow-kit/.flow-kit/project-type 读取（若不存在，Phase 0 自动检测）。
