---
description: "推进到下一阶段 - 递增 current-phase"
category: dev
reference: flow-kit/scripts/next-phase.sh
---

读取并执行阶段推进逻辑：

@flow-kit/scripts/next-phase.sh

执行步骤：

1. 读取 `.flow-kit/current-phase` 获取当前阶段号
2. 验证当前阶段产物是否完整
3. 递增阶段号并写回 `.flow-kit/current-phase`
4. 输出新阶段信息

如果当前阶段为 7（集成归档），推进后将标记流程完成。
阶段 8（回滚）为独立流程，不通过 next 推进。
