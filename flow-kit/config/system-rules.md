【CLAUDE CODE INSTRUCTION 强制约束·最高优先级】
本文件包含 flow-kit 系统级硬规则（R1-R8），在所有阶段、所有子代理中强制生效。
与 config/constitution.md 互补：constitution = 原则（WHAT），system-rules = 规则（HOW）。

---

# R1 上下文与 Token 预算

- **R1.1** 信号触发上下文窗口刷新（input >50k tokens、自我重复、相同错误 ≥2次、用户感到卡住）
- **R1.2** 阶段切换输出 SUMMARY.md 作为唯一上下文来源
- **R1.3** 历史决策通过 @filepath 引用，不使用粘贴
- **R1.4** 禁止"I remember we said..."式对话依赖
- **R1.5** 重启协议：窗口清理前写入 PROGRESS.md，更新 STATE interruption 字段，输出重启指令
- **R1.6** 反重复检查（读取 PROGRESS.md "excluded approaches"，确认新方案不同）
- **R1.8** 跨任务失败检查（任何 DEV 任务实现前先 grep LESSONS.md）

> v1.10 补充：任务过大时，恢复后第一动作不是继续干，而是把它在 TASK.md 里就地拆为 ≥2 个子任务（编号沿用 -1/-2），然后从最近一个未完成子任务起步。

- **R1.9** 渐进披露规则（进入任何阶段前必读三类文件加载策略）
- **R1.10** 文件加载策略表（REFERENCE 禁止默认整读，只 grep/read offset）

---

# R2 阶段关卡

flow-kit 文件按加载策略分三类：

| 类型                | 路径示例                             | 典型长度  | 加载方式                                |
| ------------------- | ------------------------------------ | --------- | --------------------------------------- |
| SPEC（项目产物）    | .specs/{change-id}/\*.md             | < 200 行  | 整读OK                                  |
| REFERENCE（查阅型） | flow-kit/reference/\*.md             | 75~470 行 | **禁止默认整读，只 grep / read offset** |
| PROMPT/TEMPLATE     | flow-kit/phases/_.md, templates/_.md | < 150 行  | 整读OK                                  |

首轮消息约束：进入任何阶段时，首轮加载的 REFERENCE 总行数 ≤ 150 行。超过 → 拆到后面按需拉。

**R2.1** 无 CHANGE.md → 不得进入 REQUIREMENT 阶段

- **R2.2** 无 REQUIREMENT.md → 不得进入 DESIGN 阶段
- **R2.3** 无 TASK.md → 不得编写代码
- **R2.4** Verify 通过后才能标记任务完成
- **R2.5** REVIEW.md 中"severe"级别问题必须修复，或明确标注"known accepted"并获得人工确认

---

# R3 角色红线

- **R3.1** 架构师不能直接编写实现代码
- **R3.2** 开发者不能修改 REQUIREMENT/DESIGN
- **R3.3** 评审员不能修改代码
- **R3.4** 每个会话单一角色，角色切换触发窗口刷新

---

# R4 提交与交付物

- **R4.1** 每个任务一个原子化 git commit
- **R4.2** 测试变更伴随代码变更
- **R4.3** Bug 修复需要回归测试
- **R4.4** 无 verify 命令输出不能声称"完成"
- **R4.5** Schema 变更必伴随迁移文件（强制）：AI 改 ORM model/entity/schema 时，必须同次提交附带迁移文件（SQL/Prisma migration/Alembic version 等），禁止只改 model 不写迁移就提交
- **R4.6** 破坏性变更高门槛（强制）：命中删除既有代码 ≥5 行、改公共导出/API、删除文件或重命名导出符号时，必须先走破坏性变更协议（grep 引用图→反问用户→回归测试覆盖）

---

# R5 测试纪律

- **R5.1** 禁止提交测试失败的代码
- **R5.2** 新功能需要正常/边界/错误路径测试
- **R5.3** 覆盖率下降需要解释并获得人工确认

---

# R6 反幻觉

- **R6.1** 禁止编造 API/库/配置
- **R6.2** 不确定行为必须先 grep 源码
- **R6.3** 无 git commit 却声称"完成" = 未完成，触发 R2.4

---

# R7 范围控制

- **R7.1** 不修改与当前任务无关的文件
- **R7.2** 额外修改 → 记录在 TASK.md 并先与用户确认
- **R7.3** 禁止"顺便重构"（未在 TASK.md 声明）
- **R7.4** DEV 阶段不修改 .specs 工件文件（SUMMARY.md 写入或 ISSUES 追加除外）

---

# R8 语言与术语

- **R8.1** 代码标识符使用项目既定语言
- **R8.2** 文档和注释使用与用户对话相同的语言
- **R8.3** 术语必须与 GLOSSARY.md 对齐

---

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit/blob/main/RULES.md) — R1-R10 系统级硬规则体系（R1.1 Token 预算与重启协议、R1.9 渐进披露、R1.10 文件加载策略表、R2 阶段门、R3 角色红线、R6 反幻觉、R7 范围控制）
- [alchaincyf/huashu-design](https://github.com/alchaincyf/huashu-design) — 5 维设计哲学 + OKLCH 色彩空间
- [smallnest/autoresearch](https://github.com/smallnest/autoresearch) — PASSING_SCORE 自动迭代循环
- [bytedance/deer-flow](https://github.com/bytedance/deer-flow) — YAML TIL 结构化格式
- [garrytan/gstack](https://github.com/garrytan/gstack) — 并行执行协调协议
