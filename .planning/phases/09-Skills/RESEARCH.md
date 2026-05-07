# Phase 9: Skills 质量升级 - Research

**Researched:** 2026-05-07
**Domain:** Skill package architecture + terminology management + process flow control
**Confidence:** HIGH

## Summary

Phase 9 要求重写 `requirement-clarify.md` 并新增 `ubiquitous-language.md`。核心是建立三阶段需求澄清流程（Alignment Check → Deep Dive → Verification & Documentation），集成术语冲突检测，并添加强制清窗规则。

项目结构确认：`flow-kit/` 子目录位于 `/data/Code/flow-kit/flow-kit/`。Skills 路径 = `flow-kit/skills/`，Config 路径 = `flow-kit/config/`。GLOSSARY.md 不存在，需要新建。

**Primary recommendation:** 基于现有 GRILL-ME 模板扩展三阶段结构，Deep Dive 采用「一次一问」逐点深入模式，Alignment Check 触发术语冲突扫描，Verification & Documentation 输出完整文档。

---

## User Constraints (from CONTEXT.md)

### Locked Decisions

**Phase Structure（三阶段结构设计）**
- D-Phase-01: 有条件循环（B）- Alignment Check → Deep Dive → Verification & Documentation
  - Deep Dive 发现歧义影响整体目标 → 退回 Alignment Check
  - Deep Dive 发现歧义仅影响局部细节 → 本阶段补充澄清，不回溯
  - Verification 失败 → 退回 Deep Dive
- D-Phase-02: 「用户确认 + 客观检查」双条件退出标准

**UL/GLOSSARY（三阶段退出标准与术语系统联动）**
- D-UL-01: GLOSSARY.md 路径 = `flow-kit/config/GLOSSARY.md`
- D-UL-02: ubiquitous-language.md 路径 = `skills/ubiquitous-language.md`
- D-UL-03: 职责分离 = GLOSSARY = 静态权威文档，ubiquitous-language = 动态流程工具
- D-UL-04: 初始建立 = 半自动（自动提取候选术语 + 人工审核确认）
- D-UL-05: 维护机制 = 触发变更 → 产品负责人审批 → 仅更新 GLOSSARY（版本号+1）
- D-UL-06: Constitution 引用 GLOSSARY.md 作为唯一权威来源

**Conflict Detection（术语冲突检测机制）**
- D-CD-01: 自动扫描为主（强制触发）+ 显式调用为辅
- D-CD-02: 冲突分级 = 高优先级（阻断流程：同名不同义）+ 中优先级（警告：同义不同名）
- D-CD-03: 冲突处理流程：冲突报告 → 按优先级处理 → 更新 GLOSSARY → 重新扫描 → 流程继续
- D-CD-04: Alignment Check 的「术语无冲突」退出标准由自动扫描提供支撑

**Clear Window（强制清窗规则）**
- D-CW-01: 触发条件可量化双模式（自动预警 + 用户主动触发）
- D-CW-02: 两级清窗 = 软清窗（退回 Alignment Check）+ 硬清窗（极端情况终止）
- D-CW-03: 决策机制 = 自动预警 + 用户确认
- D-CW-04: 联动闭环 = 三阶段流程 + 术语冲突检测 + 维护日志

### Claude's Discretion
- 三阶段内部的具体执行顺序和节点
- GRILL-ME 模板如何适配三阶段
- 「一次一问」的具体交互格式

### Deferred Ideas
None

---

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SKILL-01 | 重写 requirement-clarify.md | GRILL-ME 模板扩展为三阶段，一次一问模式，术语冲突检测集成 |
| SKILL-02 | 新增 ubiquitous-language.md | GLOSSARY.md 作为单一真相来源，冲突检测规则，四阶段触发机制 |

**Success Criteria（from ROADMAP）:**
1. `skills/requirement-clarify.md` 包含三个 Phase：Alignment Check、Deep Dive（一次一问）、Verification & Documentation
2. `skills/requirement-clarify.md` 激活 `skills/ubiquitous-language.md` 并执行术语冲突检测
3. `skills/requirement-clarify.md` 包含"强制清窗"规则
4. `skills/ubiquitous-language.md` 触发于 1-requirement、2-design、4-dev、6-review 四个阶段
5. `skills/ubiquitous-language.md` 维护 `GLOSSARY.md` 作为单一真相来源
6. `skills/ubiquitous-language.md` 包含冲突检测规则

---

## Project Structure Analysis

**实际路径（验证）：**
```
/data/Code/flow-kit/flow-kit/
├── skills/
│   ├── requirement-clarify.md  (重写目标)
│   ├── ubiquitous-language.md  (新增目标)
│   └── ...
├── config/
│   ├── GLOSSARY.md             (新增目标)
│   ├── constitution.md         (已有，BP-01~04 约束)
│   └── team-roles.md          (已有，审批规则参考)
```

**现有 Skills 格式（四段式）：**
```markdown
## WHEN_TO_USE
## HOW_TO_USE
## EXAMPLE
## NOTES
```

---

## Standard Stack

| Item | Path | Purpose | Notes |
|------|------|---------|-------|
| requirement-clarify.md | `flow-kit/skills/requirement-clarify.md` | 需求澄清技能（重写） | GRILL-ME 模板为基础 |
| ubiquitous-language.md | `flow-kit/skills/ubiquitous-language.md` | 术语冲突检测（新增） | 调用 GLOSSARY.md |
| GLOSSARY.md | `flow-kit/config/GLOSSARY.md` | 全局术语权威（新增） | Constitution 引用为唯一来源 |
| constitution.md | `flow-kit/config/constitution.md` | 行为约束 | BP-01~04 约束所有技能行为 |

---

## Architecture Patterns

### Pattern 1: Three-Phase Flow with Conditional Loop

```
[Alignment Check] ──(通过)──→ [Deep Dive] ──(通过)──→ [Verification & Documentation]
      ↑                      │                              │
      │                      │ (歧义影响目标)                │ (失败)
      └──────(退回)──────────┘ ←────────────────────────────┘
```

**退出标准（双条件）：**

| Phase | 客观检查 | 用户确认 |
|-------|----------|----------|
| Alignment Check | 目标/范围/约束已梳理 + 术语无冲突（自动扫描） | 用户确认「理解一致」 |
| Deep Dive | 所有需求点一次一问完成 + 术语冲突已解决 | 用户确认「细节无异议」 |
| Verification & Documentation | 完整文档 + 可验证验收标准 | 用户确认「可作后续依据」 |

### Pattern 2: One-Question-at-a-Time (一次一问)

Deep Dive 阶段核心模式：
- 每个需求点单独深入问
- 上一问题未澄清不进入下一问题
- GRILL-ME 模板适配：Goal → Role → Input → Limitation → Logic → Metric → Edge

### Pattern 3: Dual-Condition Exit Standard

- **客观检查**：自动扫描结果、文档完整性
- **用户确认**：显式表达理解一致

### Pattern 4: Clear Window Mechanism

**触发条件（可量化）：**

| 阶段 | 自动预警条件 |
|------|-------------|
| Alignment Check | 目标/范围失败>2次 或 高优先级术语冲突连续2次 |
| Deep Dive | 同一需求点反复澄清>2次 或 未解决歧义积累>3个 |
| 全流程通用 | 偏离目标>2次 或 模糊表述>30% |

**清窗分级：**

| 级别 | 场景 | 后果 |
|------|------|------|
| 软清窗（默认） | 歧义积累超阈值 | 退回 Alignment Check，保留已澄清内容 |
| 硬清窗（极端） | 连续2次软清窗仍无法对齐 | 终止流程，标记「无法达成共识」 |

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| 术语定义 | 自建术语表 | GLOSSARY.md | 项目级权威，Constitution 引用 |
| 冲突检测逻辑 | 自己实现检测算法 | 扫描工具 + 人工审核 | 半自动平衡精度与效率 |
| 退出标准 | 主观判断 | 双条件模式（自动+确认） | 可验证、可量化 |

---

## Implementation Design

### 1. requirement-clarify.md 重写结构

```markdown
# Skill: Requirement Clarification (SKILL-30)

## WHEN_TO_USE
- Phase: 1-requirement
- Trigger: 用户提出模糊/不完整/存在歧义的需求

## HOW_TO_USE

### Phase 1: Alignment Check
[目标/范围/约束梳理 + 触发 ubiquitous-language 术语冲突扫描]
退出标准：目标已澄清 + 术语无冲突 + 用户确认

### Phase 2: Deep Dive (一次一问)
[逐个需求点深入，使用 GRILL-ME 扩展模板]
退出标准：所有需求点已澄清 + 冲突已解决 + 用户确认

### Phase 3: Verification & Documentation
[生成完整文档 + 验收标准 + 用户最终确认]
退出标准：文档完整 + 验收标准可验证 + 用户确认

### 强制清窗规则
[触发条件 + 清窗分级 + 决策机制]
```

### 2. ubiquitous-language.md 新增结构

```markdown
# Skill: Ubiquitous Language (SKILL-37)

## WHEN_TO_USE
- Trigger: 1-requirement、2-design、4-dev、6-review 阶段
- 自动扫描节点：Alignment Check 结束前 / 设计评审前 / 代码提交前 / 文档评审前

## HOW_TO_USE

### Conflict Detection
[自动扫描流程 + 冲突分级处理]

### GLOSSARY Maintenance
[半自动建立流程 + 变更审批机制]

## NOTES
- GLOSSARY.md 是单一真相来源
- 冲突检测触发双条件模式
```

### 3. GLOSSARY.md 新增结构

```markdown
# GLOSSARY — Project Terminology Authority

**Version:** 1.0
**Last Updated:** 2026-05-07
**Authority:** flow-kit/config/GLOSSARY.md

## Terminology Entries

| Term | Definition | Source | Version |
|------|------------|--------|---------|
| [term] | [definition] | [source doc] | 1.0 |

## Maintenance Log

| Date | Change | Approved By |
|------|--------|-------------|
```
[VERSIONING: 每次变更 version +1]

## Integration Points

| Source | Trigger | GLOSSARY Update |
|--------|---------|----------------|
| requirement-clarify.md | Alignment Check | 扫描候选术语 |
| 2-design | 设计评审前 | 验证术语一致性 |
| 4-dev | 代码提交前 | 验证实现术语 |
| 6-review | 文档评审前 | 最终术语确认 |
```

---

## Common Pitfalls

### Pitfall 1: 清窗触发条件过于模糊
**What goes wrong:** 「模糊表述>30%」难以量化，执行时无法判断
**How to avoid:** 定义具体指标：未澄清名词数量 / 总名词数量 > 30%
**Warning signs:** 用户抱怨「不知道什么时候触发清窗」

### Pitfall 2: 一次一问变成连续追问
**What goes wrong:** Deep Dive 阶段一次性抛出多个问题，用户压力过大
**How to avoid:** 严格单问题模式，上一问题澄清前不提出下一问题
**Warning signs:** 用户回应「等等，一个一个来」

### Pitfall 3: 术语冲突检测流于形式
**What goes wrong:** 自动扫描输出大量警告但不解决
**How to avoid:** 高优先级冲突必须阻断流程，直到解决
**Warning signs:** 连续多个高优先级冲突未被处理

### Pitfall 4: GLOSSARY 版本号不同步
**What goes wrong:** GLOSSARY 更新但版本号未变，导致缓存问题
**How to avoid:** 每次 GLOSSARY 变更必须 version +1，文档头部显示版本号

---

## Code Examples

### Clear Window Output Format

```markdown
## [流程预警：触发软清窗条件]

**原因：**
- Alignment Check 目标/范围失败已超过 2 次
- 未解决歧义积累 4 个（阈值：3）

**当前状态：**
- 已澄清：3/7 需求点
- 待澄清：4 个歧义点

**请选择：**
1. [执行软清窗] — 退回 Alignment Check，保留已澄清内容
2. [继续讨论] — 暂不清窗，继续当前阶段
3. [执行硬清窗] — 极端情况，终止当前流程
```

### One-Question-at-a-Time Format

```markdown
## Deep Dive — 需求点 #3/7

**需求：** 用户可以上传头像图片

**当前问题：** 图片格式和大小限制未定义

---

**Q1 (Goal):** 上传头像的目的是什么？
- A: 识别用户身份 / 个性化展示 / 其他
[等待用户回答后进入 Q2]
```

### Conflict Detection Report

```markdown
## 术语冲突检测报告

**扫描时间：** 2026-05-07 14:30
**扫描文件：** prd.md, design.md, core/1-requirement.md

### 高优先级冲突（阻断流程）

| 术语 | 冲突类型 | 定义 A | 定义 B | 涉及文档 |
|------|----------|--------|--------|----------|
| 用户 | 同名不同义 | 注册者 | 管理员 | prd.md L5, design.md L12 |

**处理建议：** 请产品负责人确认「用户」在本项目中的唯一定义，更新 GLOSSARY 后继续。

### 中优先级警告

| 术语 | 冲突类型 | 别名 A | 别名 B | 推荐标准术语 |
|------|----------|--------|--------|--------------|
| 订单 | 同义不同名 | Order | Purchase | Order |
```

---

## Open Questions

1. **GLOSSARY 初始建立**
   - What we know: 半自动流程（自动提取 + 人工审核）
   - What's unclear: 自动提取工具是什么？正则匹配？LLM 识别？
   - Recommendation: Phase 9 实现计划中明确使用「人工驱动扫描 + 辅助工具」

2. **ubiquitous-language.md 触发时机**
   - What we know: 1-requirement、2-design、4-dev、6-review 四个阶段
   - What's unclear: 如何与 core/*.md 流程文件集成？
   - Recommendation: 这些 core 文件需要在适当时机引用 ubiquitous-language.md

3. **硬清窗的「重新发起」流程**
   - What we know: 标记「无法达成共识」，需重新发起
   - What's unclear: 重新发起是否需要新 phase？如何记录历史？
   - Recommendation: 暂时标记状态，人工介入处理

---

## Sources

### Primary (HIGH confidence)
- `/data/Code/flow-kit/.planning/phases/09-Skills/09-CONTEXT.md` — Phase 9 决策（已验证）
- `/data/Code/flow-kit/flow-kit/config/constitution.md` — BP-01~04 行为约束（已验证）
- `/data/Code/flow-kit/flow-kit/config/team-roles.md` — 角色审批规则（已验证）

### Secondary (MEDIUM confidence)
- `/data/Code/flow-kit/flow-kit/skills/requirement-clarify.md` — 现有模板结构（已验证）
- `/data/Code/flow-kit/flow-kit/skills/task-master.md` — Skill 格式参考（已验证）

### Tertiary (LOW confidence)
- 无

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — 项目结构已验证，所有路径确认
- Architecture: HIGH — 三阶段模型 + 术语冲突检测模式清晰
- Pitfalls: MEDIUM — 基于常见流程问题推断，需实际验证

**Research date:** 2026-05-07
**Valid until:** 2026-06-07（30天内配置/流程稳定）