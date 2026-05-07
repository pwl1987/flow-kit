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
- **R1.7** 任务过大早期信号检测
- **R1.8** 跨任务失败检查（任何 DEV 任务实现前先 grep LESSONS.md）

---

# R2 阶段关卡

- **R2.1** 无 CHANGE.md → 不得进入 REQUIREMENT 阶段
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
