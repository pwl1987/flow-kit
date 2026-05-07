# Phase 10: Core 流程增强 - Discussion Log

**讨论日期：** 2026-05-07
**参与 Gray Areas：** 5 个
**决策数量：** 10 个

---

## Gray Area 1: LESSONS.md 路径

**议题：** LESSONS.md 应该放在哪里？

**选项：**
1. `.specs/LESSONS.md`（推荐）— 项目根目录，与 ROADMAP/STATE 同级
2. `flow-kit/.specs/LESSONS.md` — 放在 flow-kit 子目录内
3. `.flow-kit/LESSONS.md` — 隐藏配置目录

**决策：** `.specs/LESSONS.md`
**理由：** 项目根目录，与 `.specs/dependency-map.md` 平级，路径清晰

**对应决策：** D-L01, D-L02, D-L03

---

## Gray Area 2: Ubiquitous Language 触发时机

**议题：** ubiquitous-language 在 Phase 1 中如何触发？

**选项：**
1. 预检步骤（最早）— 在 requirement-clarify skill 调用之前
2. Alignment Check 第1步 — 融入 Alignment Check 阶段
3. 仅在检测到术语时 — 不主动触发

**决策：** Alignment Check 第1步
**理由：** 与 Phase 9 三阶段结构无缝融合，术语状态输出在 Alignment Check 开始时

**对应决策：** D-UL-01, D-UL-02, D-UL-03, D-UL-04

---

## Gray Area 3: 历史教训匹配机制

**议题：** 历史教训如何匹配当前需求？

**选项：**
1. 关键词匹配（推荐）— 需求关键词与 LESSONS.md 适用场景标签匹配
2. 变更类型匹配 — P0/P1/P2 类型匹配
3. 全量展示 + 用户筛选 — 列出所有条目由用户判断

**决策：** 关键词匹配
**理由：** 自动化的最小摩擦方案，≥1 关键词命中即纳入候选

**对应决策：** D-LM-01, D-LM-02, D-LM-03, D-LM-04

---

## Gray Area 4: TDD 强制级别

**议题：** TDD「先写验证」如何 enforcement？

**选项：**
1. 硬阻断（推荐）— 未写测试就实现 → 暂停
2. 软警告 — 输出警告但允许继续
3. 仅文档说明 — 不做 enforcement

**决策：** 硬阻断
**理由：** 符合 BP-04 Goal-Driven Execution，不可测试的定义需要澄清

**对应决策：** D-TDD-01, D-TDD-02, D-TDD-03

---

## Gray Area 5: TASK.md 目标覆盖

**议题：** Goal-Driven Execution 如何覆盖 TASK.md？

**选项：**
1. 每个 TASK 有完成标准 — TASK.md 中有「完成标志」字段
2. 任务链接到父级 Goal — 间接覆盖
3. 更新 TASK.md 模板 — 不追溯修改现有文件

**决策：** 每个 TASK 有完成标准
**理由：** 最直接可验证，完成标志 = 任务完成的唯一标准

**对应决策：** D-TASK-01, D-TASK-02, D-TASK-03

---

## 讨论总结

| Gray Area | 决策 | 关键约束 |
|-----------|------|---------|
| LESSONS 路径 | `.specs/LESSONS.md` | 与 dependency-map.md 平级 |
| UL 触发 | Alignment Check 第1步 | 不是预检，不是仅检测时 |
| LESSONS 匹配 | 关键词匹配 | ≥1 命中纳入候选 |
| TDD 强制 | 硬阻断 | 符合 BP-04 |
| TASK 完成标准 | 每 TASK 有完成标志 | 可客观验证 |

