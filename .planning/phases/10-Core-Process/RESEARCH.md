# Phase 10: Core 流程增强 - 技术实现方案

## 1. 修改点详细分析

### 1.1 CORE-01: 术语对齐前置（Alignment Check 第1步激活 ubiquitous-language）

**目标文件**: `flow-kit/phases/1-requirement/1-requirement.md`

**决策依据** (D-UL-01 ~ D-UL-04):
- D-UL-01: 触发位置 = Alignment Check 阶段第1步（不是预检，不是全局触发）
- D-UL-02: Alignment Check 开始时立即激活 `skills/ubiquitous-language.md`，输出 GLOSSARY.md 当前术语表状态
- D-UL-03: Alignment Check 退出标准「术语无冲突」由 ubiquitous-language 自动扫描提供支撑
- D-UL-04: 术语冲突高优先级 → 阻断流程；中优先级 → 警告，继续流程

**当前 Phase 1 结构**:
```
## Phase 1: Requirements - 需求澄清与确认
### 触发条件
### 核心行为        ← Alignment Check 位置
### 边界情况
### 输出物
```

**Phase 9 ubiquitous-language skill 触发节点映射**:
| 阶段 | 触发时机 | GLOSSARY 操作 |
|------|----------|---------------|
| 1-requirement | Alignment Check 结束前 | 扫描候选术语 |
| 2-design | 设计评审前 | 验证术语一致性 |
| 4-dev | 代码提交前 | 验证实现术语 |
| 6-review | 文档评审前 | 最终术语确认 |

**冲突检测输出格式** (来自 Phase 9 EXAMPLE):
```
## 术语冲突检测报告
**扫描时间：** YYYY-MM-DD HH:MM
**扫描文件：** prd.md, user-story-1.md
### 高优先级冲突（阻断流程）
| 术语 | 冲突类型 | 定义 A | 定义 B | 涉及文档 |
|------|----------|--------|--------|----------|
| 用户 | 同名不同义 | ... | ... | prd.md L5 |
**处理：** 暂停流程，请产品负责人确认「用户」的定义。
```

---

### 1.2 CORE-02: 历史教训检索（关键词匹配 `.specs/LESSONS.md`）

**目标文件**: `flow-kit/phases/1-requirement/1-requirement.md`

**决策依据** (D-LM-01 ~ D-LM-04):
- D-LM-01: 关键词匹配（≥1个关键词命中即纳入候选）
- D-LM-02: 展示位置 = 需求文档顶部引用块
- D-LM-03: 用户确认（询问"是否相关"）
- D-LM-04: 相关教训 → TASK.md 标记为约束

**关键发现**: `.specs/LESSONS.md` 当前 **不存在**（.specs/ 目录也不存在）

**模板位置**: `flow-kit/templates/LESSONS.md.template` (55 个占位符)

**LESSONS.md.template 主要章节**:
- What Worked (成功实践)
- What Didn't Work (问题描述/根本原因/教训)
- Patterns Established (技术/流程/代码模式)
- Key Decisions (决策/替代方案/理由/结果)
- 统计数据 (任务完成数/缺陷数/重做任务数/总工时)
- 建议

---

### 1.3 4-dev.md TDD 硬阻断强化

**目标文件**: `flow-kit/phases/4-dev/4-dev.md`

**决策依据** (D-TDD-01 ~ D-TDD-03):
- D-TDD-01: Enforcement = 硬阻断，实现代码前必须先有对应测试；未写测试就实现 → 暂停
- D-TDD-02: 「验证」定义 = test case 或 acceptance criteria
- D-TDD-03: 硬阻断范围 = 每次 TASK.md 任务执行前检查，不允许跳过

**当前 Phase 4 已有**:
- TDD 循环（Red-Green-Refactor）
- 项目类型检测（Phase 6 增强）
- Guardrails 联动提示

---

### 1.4 TASK.md 完成标准

**决策依据** (D-TASK-01 ~ D-TASK-03):
- D-TASK-01: 每个任务必须有「完成标志」字段（可客观验证）
- D-TASK-02: 新任务模板由 executor 更新（不追溯现有文件）
- D-TASK-03: Goal-Driven Execution：完成标志达成 = 任务完成

---

## 2. 实现方案（备选）

### 方案 A: 最小侵入性修改（推荐）

**CORE-01 实现**:
1. 在 `1-requirement.md` 核心行为章节 Alignment Check 部分，在"第1步"之前插入：
   ```
   **第0步 - 术语对齐（UL 激活）**
   1. 激活 `skills/ubiquitous-language.md`
   2. 扫描当前需求文档中的候选术语
   3. 对比 `config/GLOSSARY.md` 输出术语冲突报告
   4. 高优先级冲突 → 阻断，进入冲突解决流程
   5. 中优先级 → 警告，继续 Alignment Check
   ```
2. Alignment Check 退出标准增加"术语无冲突"一项

**CORE-02 实现**:
1. 在需求文档顶部（输出物之前）增加引用块：
   ```
   > **历史教训匹配**（如有）
   > - 关键词: `xxx`
   > - 相关教训: `...`
   > - 是否相关? [是/否]
   ```
2. 在 Alignment Check 结束后、进入需求澄清前，增加历史教训检索步骤
3. 检索逻辑：读取 `.specs/LESSONS.md`（如存在），用关键词匹配（≥1个命中），展示候选教训

**TDD 硬阻断实现**:
1. 在 `4-dev.md` 核心行为章节 TASK 执行前增加：
   ```
   **TDD 硬阻断检查**
   - 每次执行 TASK.md 任务前验证：是否存在对应测试/验收标准
   - 无测试/验收标准 → 暂停，输出「请先写验证（test/acceptance criteria）」
   - 硬阻断不允许跳过
   ```

**TASK.md 完成标准实现**:
1. 在 `4-dev.md` 输出物章节增加：
   ```
   - TASK.md 每项任务必须包含「完成标志」（客观可验证的检查点）
   ```

**优点**: 利用现有结构，改动最小，风险低
**缺点**: 步骤分散在多处

---

### 方案 B: 集中式新增 section

**CORE-01/CORE-02 实现**:
在 `1-requirement.md` 核心行为章节中新增独立 section：
```
### Alignment Check 与历史教训检索
#### 第0步 - 术语对齐（UL 激活）
...
#### 第1步 - 历史教训检索
...
```

**TDD 硬阻断实现**:
在 `4-dev.md` 新增独立章节：
```
### TDD 硬阻断机制
- 每次 TASK 执行前检查
- 验证未写不允许实现
...
```

**优点**: 结构清晰，逻辑集中
**缺点**: 对现有文件结构改动较大

---

### 方案 C: 创建独立子文档（不推荐）

将 CORE-01/CORE-02 拆分为独立文档如 `1-requirement-ul.md`，通过引用方式集成。

**缺点**: 增加流程复杂度，不符合 flow-kit 简洁设计原则

---

## 3. 开放问题

| # | 问题 | 影响 | 建议处理 |
|---|------|------|----------|
| O1 | `.specs/LESSONS.md` 不存在，首次执行时如何处理？ | 跳过历史教训检索步骤 | 增加条件判断：文件不存在则跳过，输出「无历史教训」 |
| O2 | LESSONS.md 关键词如何提取？ | 检索准确性 | 使用需求文档标题/核心名词作为关键词候选 |
| O3 | TASK.md 模板是否需要更新？ | D-TASK-02 | 新任务模板由 executor 更新（不追溯现有文件），但建议提供更新后的模板文件 |
| O4 | TDD 验证代码必须可执行，但 flow-kit 不强制特定测试框架？ | D-TDD-02 | 在 4-dev.md 中明确「可执行的测试代码」的定义范围（任何能被自动化执行的验证） |
| O5 | Alignment Check 退出标准中「术语无冲突」是自动判断还是人工确认？ | D-UL-03 | 建议采用自动扫描 + 高优先级冲突人工确认机制 |

---

## 4. 风险点

| 风险 | 等级 | 缓解措施 |
|------|------|----------|
| `.specs/LESSONS.md` 不存在导致历史教训功能形同虚设 | 中 | 明确创建流程，在 Phase 0 或项目初始化时创建；或在 Alignment Check 中主动提示创建 |
| 关键词匹配过于宽泛（≥1个关键词命中）产生噪音 | 中 | 提供用户确认环节（符合 D-LM-03），用户可标记不相关 |
| TDD 硬阻断可能导致流程卡死（无测试框架项目） | 中 | 在 4-dev.md 中明确：验证 = test case 或 acceptance criteria，不强制特定测试框架 |
| 修改已有 phase 文件可能影响现有流程 | 低 | 最小侵入修改，充分测试 |

---

## 5. 验证方法

### 5.1 单元验证（文件内容验证）

**1-requirement.md 验证清单**:
- [ ] Alignment Check 章节包含"第0步 - 术语对齐"
- [ ] 激活 `skills/ubiquitous-language.md` 引用
- [ ] 输出 GLOSSARY.md 术语表状态
- [ ] 退出标准包含"术语无冲突"
- [ ] 历史教训检索步骤存在（关键词匹配 .specs/LESSONS.md）
- [ ] 展示位置 = 需求文档顶部引用块
- [ ] 用户确认机制存在

**4-dev.md 验证清单**:
- [ ] TDD 硬阻断检查存在于 TASK 执行前
- [ ] 验证未写不允许实现的硬阻断规则明确
- [ ] TASK.md 每项任务包含「完成标志」要求

### 5.2 集成验证（流程验证）

使用以下测试场景验证修改后的流程：
1. **无术语冲突场景**: Alignment Check 正常通过
2. **有术语冲突场景**: 高优先级冲突阻断流程，输出冲突报告
3. **无 LESSONS.md 场景**: 跳过历史教训步骤，输出提示
4. **有 LESSONS.md 场景**: 关键词匹配，展示候选教训，用户确认
5. **TDD 硬阻断场景**: 无测试代码时暂停，输出错误信息
6. **TASK 完成标志验证**: 完成标志达成后任务标记为完成

---

## 6. 文件清单

| 文件 | 操作 | 修改内容 |
|------|------|----------|
| `flow-kit/phases/1-requirement/1-requirement.md` | Edit | CORE-01 + CORE-02 |
| `flow-kit/phases/4-dev/4-dev.md` | Edit | TDD 硬阻断 + TASK 完成标准 |
| `.specs/LESSONS.md` | Create (if needed) | 历史教训文档（非本次修改范围，但需了解位置） |

---

## 7. 决策要点速查

| 决策 ID | 内容 | 关键约束 |
|---------|------|----------|
| D-UL-01 | UL 触发位置 | Alignment Check 第1步，不是预检 |
| D-UL-02 | UL 激活时机 | Alignment Check 开始时立即激活 |
| D-UL-04 | 冲突处理 | 高优先级阻断，中优先级警告 |
| D-LM-01 | 匹配规则 | ≥1个关键词命中即纳入候选 |
| D-LM-02 | 展示位置 | 需求文档顶部引用块 |
| D-LM-03 | 用户确认 | 询问"是否相关" |
| D-LM-04 | 相关教训处理 | TASK.md 标记为约束 |
| D-TDD-01 | TDD 强制级别 | 硬阻断，未写验证不允许实现 |
| D-TDD-02 | 验证定义 | test case 或 acceptance criteria |
| D-TDD-03 | 阻断范围 | 每次 TASK 执行前，不允许跳过 |
| D-TASK-01 | 完成标志 | 每任务必须有，可客观验证 |
| D-TASK-02 | 模板更新 | executor 更新，不追溯现有文件 |
| D-TASK-03 | 完成标准 | Goal-Driven Execution |
