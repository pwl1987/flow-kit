# Phase 8: Constitution 四原则集成 - Research

**Researched:** 2026/05/07
**Domain:** flow-kit 配置文件结构、Karpathy 四原则英文措辞
**Confidence:** HIGH

## Summary

Phase 8 目标明确：在 `flow-kit/config/constitution.md` 中新增 `BEHAVIORAL PRINCIPLES` 章节，融入 Karpathy 四原则作为最高优先级行为约束，并在 Technology Stack 区域新增 ROLE-01 条目引用 team-roles.md。

**Primary recommendation:** 直接按照 prd1.2.md 提供的原文插入，不要自行修改措辞。

## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-A01:** 四原则作为独立章节，放在 UNOVERRIDABLE RULES 之后新建 `BEHAVIORAL PRINCIPLES`
- **D-B01~B04:** 四原则措辞已选定（Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution）
- **D-C01:** Constitution.md 新增 ROLE-01 条目，指向 team-roles.md，并在后补充 "All role-based approvals must respect the BEHAVIORAL PRINCIPLES"
- **D-D01:** Simplicity First 和 Surgical Changes 约束体现在 brownfield-guardrails.md B1 入场扫描逻辑中

### Claude's Discretion
- 四原则条款编号：BP-01 ~ BP-04（已采纳）
- 章节标题：`## BEHAVIORAL PRINCIPLES（最高优先级）`（已采纳）

### Deferred Ideas (OUT OF SCOPE)
无 — 讨论严格保持在 Phase 8 范围内

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| 四原则融入 constitution.md | 配置层 | — | 纯配置文件修改，无代码层变更 |
| ROLE-01 指向 team-roles.md | 配置层 | — | 外部引用模式复用 |
| GUARD-01 约束 dependency-map 生成 | 配置层 | — | brownfield-guardrails.md 已存在，仅需确认逻辑对应 |

## Existing Constitution.md Structure (VERIFIED)

```
# Constitution.md — Safety Floor
├── UNOVERRIDABLE RULES
│   ├── Security (SEC-01 ~ SEC-05)
│   ├── Data Integrity (DATA-01 ~ DATA-05)
│   ├── Deployment (DEPLOY-01 ~ DEPLOY-05)
│   ├── Git Safety (GIT-01 ~ GIT-05)
│   ├── Technology Stack (TECH-01, TECH-02)
│   └── External References
└── Priority Statement
```

**插入位置分析：**
- `BEHAVIORAL PRINCIPLES` 应插入在 `UNOVERRIDABLE RULES` 末尾（`External References` 之后），与安全规则并列平级
- `ROLE-01` 应插入 Technology Stack 区域，编号接续 TECH-02

## Standard Stack

本 phase 无需引入新依赖库，纯配置文件修改。

## 四原则原文 (from prd1.2.md)

| ID | 标题 | 核心内容 |
|----|------|----------|
| BP-01 | Think Before Coding | 先理解问题域，再探索方案，最后才实现 |
| BP-02 | Simplicity First | 每增加一个抽象必须证明其必要性 |
| BP-03 | Surgical Changes | 最小变更集，只改必要的，零顺手修改 |
| BP-04 | Goal-Driven Execution | 完成标志 = 目标达成，不是任务列表走完 |

**完整插入文本（prd1.2.md lines 40-64）：**
```markdown
### BEHAVIORAL PRINCIPLES (Highest Priority for All Agents)

All agents, sub‑agents, and review processes MUST adhere to the following four principles at all times. No other rule, instruction, or optimization may override them.

1. **Think Before Coding**
   - Always state assumptions explicitly. If uncertain, ask before acting.
   - When multiple interpretations are possible, list them and choose the most conservative.
   - If a simpler implementation is possible, point it out before writing code.
   - If confused, stop and request clarification. Never guess silently.

2. **Simplicity First**
   - Solve the problem with the minimum amount of code.
   - Do not add features, abstractions, or configurations that were not requested.
   - Do not introduce a new abstraction for single‑use code.
   - If a 200‑line module can be reduced to 50 lines without losing clarity, refactor immediately.

3. **Surgical Changes**
   - Only modify code that is directly required by the change. Do not touch adjacent files, comments, formatting, or unrelated code.
   - Clean up only the orphaned references you yourself created. Do not "fix" pre‑existing style issues unless explicitly asked.

4. **Goal‑Driven Execution**
   - Translate every imperative task into a verifiable goal. "Add validation" → write a failing test first, then make it pass.
   - "Fix a bug" → write a reproduction test first, then fix.
   - Never implement without a clear, testable definition of "done".
```

## ROLE-01 插入方案

**位置：** Technology Stack 区域内，TECH-02 之后

**插入文本（prd1.2.md lines 66-68）：**
```markdown
| ROLE-01 | Role definitions for architect/reviewer/ops in external reference | team |
```

**并在 ROLE-01 后立即补充：**
```markdown
- All role‑based approvals must respect the BEHAVIORAL PRINCIPLES above: if a design violates "Simplicity First", the architect must reject it.
```

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| CONST-01 | 四原则融入 constitution.md | BP-01~BP-04 原文和插入位置已确认 |
| GUARD-01 | dependency-map.md 生成遵循原则 | Simplicity First 和 Surgical Changes 约束在 brownfield-guardrails.md B1 中体现 |

## Architecture Patterns

### 文件修改模式
- **Constitution.md:** 表格格式复用，新增 `### BEHAVIORAL PRINCIPLES` 子章节和 `ROLE-01` 表格行
- **外部引用模式:** TECH-01/02/ROLE-01 均引用外部文件（tech-constraints.md, team-roles.md）

### 验证要点
1. 四原则章节必须在 UNOVERRIDABLE RULES 之后
2. BP-01~BP-04 编号连续不重复
3. ROLE-01 在 Technology Stack 区域且编号不冲突
4. "All role-based approvals must respect..." 声明紧跟 ROLE-01 条目

## Common Pitfalls

### Pitfall 1: 插入位置错误
**What goes wrong:** 把 BEHAVIORAL PRINCIPLES 放在 Priority Statement 之后，导致语义降级
**How to avoid:** 明确在 `External References` 段落之后、`Priority Statement` 之前插入
**Warning signs:** 生成的 constitution.md 中四原则不在 UNOVERRIDABLE RULES 内部

### Pitfall 2: 原则措辞被擅自修改
**What goes wrong:** 因觉得英文不够流畅而修改原文，导致语义偏离
**How to avoid:** 直接使用 prd1.2.md 提供的原文，不做任何改动

## Assumptions Log

> List all claims tagged `[ASSUMED]` in this research.

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | 四原则的 "Highest Priority for All Agents" 标记与 "Unoverridable" 地位一致 | 四原则原文 | 低 — prd1.2.md 原文已提供 |

**If this table is empty:** All claims in this research were verified or cited — no user confirmation needed.

## Open Questions

无 — 所有决策已在 discuss-phase 确认，prd1.2.md 提供完整插入原文。

## Environment Availability

Step 2.6: SKIPPED (no external dependencies — pure configuration file modification)

## Validation Architecture

跳过 nyquist_validation 检查：
- 本 phase 仅修改 markdown 配置文件，无可执行代码
- 验证方式：人工审查 constitution.md 结构完整性

## Sources

### Primary (HIGH confidence)
- `/data/Code/flow-kit/flow-kit/config/constitution.md` — 现有文件结构验证
- `/data/Code/flow-kit/flow-kit/config/team-roles.md` — ROLE-01 引用目标
- `/data/Code/flow-kit/prd1.2.md` — 四原则原文和插入规范

### Secondary (MEDIUM confidence)
- CONTEXT.md — 已确认决策

## Metadata

**Confidence breakdown:**
- Standard stack: N/A — 无依赖库
- Architecture: HIGH — 纯配置文件修改，结构清晰
- Pitfalls: HIGH — 决策已锁定，陷阱已识别

**Research date:** 2026/05/07
**Valid until:** 永久有效（配置文件结构不随时间变化）