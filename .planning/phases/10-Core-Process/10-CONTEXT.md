# Phase 10: Core 流程增强 - Context

**Gathered:** 2026-05-07
**Status:** Ready for planning

<domain>
## Phase Boundary

`flow-kit/phases/1-requirement/1-requirement.md` 增加术语对齐前置（Alignment Check 第1步激活 ubiquitous-language）和历史教训检索（关键词匹配 `.specs/LESSONS.md`）；`flow-kit/phases/4-dev/4-dev.md` 强化 Goal-Driven Execution（TDD 硬阻断 + TASK.md 完成标准）。

**Requirements:** CORE-01, CORE-02

</domain>

<decisions>
## Implementation Decisions

### LESSONS.md 路径与定位

- **D-L01:** LESSONS.md 路径 = `.specs/LESSONS.md`（项目根目录，与 ROADMAP/STATE 同级）
- **D-L02:** `.specs/` 是 flow-kit 惯用配置目录，与 `.specs/dependency-map.md` 平级
- **D-L03:** LESSONS.md 初始内容来源 = `flow-kit/templates/LESSONS.md.template`，由 executor 填充

### Ubiquitous Language 触发时机

- **D-UL-01:** 触发位置 = Alignment Check 阶段第1步（不是预检，不是全局触发）
- **D-UL-02:** Alignment Check 开始时立即激活 `skills/ubiquitous-language.md`，输出 GLOSSARY.md 当前术语表状态
- **D-UL-03:** Alignment Check 退出标准「术语无冲突」由 ubiquitous-language 自动扫描提供支撑（与 Phase 9 D-CD-04 一致）
- **D-UL-04:** 术语冲突高优先级 → 阻断流程，进入冲突解决流程；中优先级 → 警告，继续流程

### 历史教训匹配机制

- **D-LM-01:** 匹配方式 = 关键词匹配
  - 提取需求文档中的关键词（名词、专业概念）
  - 与 `.specs/LESSONS.md` 中各条目的「适用场景」标签做字符串匹配
  - 阈值：≥1 个关键词命中即纳入候选列表
- **D-LM-02:** 展示位置 = 需求文档顶部，以引用块形式列出匹配教训
- **D-LM-03:** 用户确认 = 询问「以上历史教训是否与当前需求相关？」（可选跳过）
- **D-LM-04:** 相关教训 → 在 TASK.md 中标记为约束；不相关 → 忽略

### TDD 强制级别

- **D-TDD-01:** Enforcement = 硬阻断（符合 BP-04 Goal-Driven Execution）
  - 实现代码前必须先有对应测试
  - 未写测试就实现 → 暂停，输出「请先写验证（test/acceptance criteria）」
  - 不可测试的定义（无验证标准）→ 进入 requirement-clarify 回退流程
- **D-TDD-02:** 「验证」定义 = test case 或 acceptance criteria，满足可量化即可
- **D-TDD-03:** 硬阻断范围 = 每次 TASK.md 任务执行前检查，不允许跳过

### TASK.md 完成标准

- **D-TASK-01:** 每个 TASK.md 任务必须包含「完成标志」字段
  - 格式：`完成标志: [test passes / 验收标准 / 里程碑]`
  - 完成标志必须是可客观验证的（非「完成」等主观描述）
- **D-TASK-02:** TASK.md 模板由 executor 更新（不追溯修改现有 TASK.md）
- **D-TASK-03:** Goal-Driven Execution 规则：任务完成 = 完成标志达成，不是任务列表走完

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

- `flow-kit/phases/1-requirement/1-requirement.md` — Phase 1 主文件，Phase 10 修改目标
- `flow-kit/phases/4-dev/4-dev.md` — Phase 4 主文件，Phase 10 修改目标
- `flow-kit/skills/ubiquitous-language.md` — SKILL-37，术语冲突检测流程（Phase 9 建立）
- `flow-kit/config/GLOSSARY.md` — 全局术语权威来源（Phase 9 建立）
- `flow-kit/templates/LESSONS.md.template` — LESSONS.md 模板文件
- `.planning/ROADMAP.md` §Phase 10 — Phase 10 范围和成功标准
- `.planning/phases/09-Skills/09-CONTEXT.md` — Phase 9 决策（ubiquitous-language 触发时机、三阶段结构）
- `.planning/phases/08-Constitution/08-CONTEXT.md` — Phase 8 决策（BP-01~BP-04 四原则）

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `flow-kit/phases/1-requirement/1-requirement.md` 已包含完整四章节结构（触发条件/核心行为/边界情况/输出物）
- `flow-kit/phases/4-dev/4-dev.md` 已有 TDD 循环（Red-Green-Refactor）和项目类型检测
- Phase 9 ubiquitous-language.md 的冲突检测输出格式可复用
- Phase 9 三阶段退出标准（用户确认 + 客观检查）直接映射到 Alignment Check

### Integration Points
- `skills/ubiquitous-language.md`（SKILL-37）→ Alignment Check 第1步调用 → 输出 GLOSSARY 状态
- `.specs/LESSONS.md`（新增）→ Alignment Check 关键词匹配 → 需求文档顶部展示
- `flow-kit/phases/4-dev/4-dev.md` TDD 部分 → 硬阻断检查 + TASK.md 完成标准
- BP-04 Goal-Driven Execution 作为 TDD 硬阻断的理论基础

### Established Patterns
- Alignment Check 退出标准：目标/范围/约束已梳理 + 术语无冲突 + 用户确认「理解一致」
- 三阶段流程：Alignment Check → Deep Dive → Verification & Documentation
- 术语冲突高优先级阻断，中优先级警告

</code_context>

<deferred>
## Deferred Ideas

- **v1.3 考虑**：LESSONS.md 实时注入到 context window（cep 知识复合闭环）— 属于 v1.3 范围
- **v2.0 考虑**：TASK.md goals 到依赖图引擎的自动关联（graphify）— 属于 v2.0 范围

</deferred>

