# Roadmap — flow-kit

## Overview

**19 phases total** | **v1.0 + v1.1 shipped** | **v1.2 🔄 Active**

| # | Phase | Goal | Status |
|---|-------|------|--------|
| 1-4 | v1.0 MVP | Core skeleton, guardrails, reference materials, integration | ✅ Complete |
| 5-7 | v1.1 Enhancement | P0 bugfix, P1 supplement, P2 experience | ✅ Complete |
| 8-11 | v1.2 Enhancement | 需求质量与结构化增强 | 🔄 Active |
| 12+ | TBD | Rollback workflow + enhancements | 📋 Planned |

---

## Milestones

- ✅ **v1.0 MVP** — Phases 1-4 (shipped 2026-05-06)
- ✅ **v1.1 Enhancement** — Phases 5-7 (shipped 2026-05-07)
- 🔄 **v1.2 Enhancement** — Phases 8-11 (in progress 2026-05-07)
- 📋 **v2.0** — Phase 12+ (planned)

---

## Phases

<details>
<summary>✅ v1.0 MVP (Phases 1-4) — SHIPPED 2026-05-06</summary>

### Phase 1: Core Skeleton
**Goal:** Complete directory creation, entry routing, 8-phase workflow, templates
**Status:** ✅ Complete (2026-05-06)

### Phase 2: Guardrails & Capabilities
**Goal:** Complete B1-B6 brownfield guardrails, all skill packages, lateral commands, MCP tool adaptation, and configuration files.
**Status:** ✅ Complete (2026-05-06)

### Phase 3: Reference Materials
**Goal:** Complete engineering hard rules for frontend/backend, TDD standard, ADR template, all 6 language specs, and archive logic.
**Status:** ✅ Complete (2026-05-06)

### Phase 4: Integration & Polish
**Goal:** Integrate Phase 3 features, implement context expiry detection, token estimation, offline mode, minimal mode, and team collaboration features.
**Status:** ✅ Complete (2026-05-06)

</details>

<details>
<summary>✅ v1.1 Enhancement (Phases 5-7) — SHIPPED 2026-05-07</summary>

### Phase 5: P0 缺陷修复
**Goal:** 修复影响核心能力的缺陷 — 棕地/绿地检测、断点续跑、数据库类型识别、skills 验证
**Status:** ✅ Complete (2026-05-07)
**Requirements:** REQ-001~004
**Plans:** 4 plans — [archived to milestones/v1.1-ROADMAP.md](milestones/v1.1-ROADMAP.md)

### Phase 6: P1 功能补充
**Goal:** 补充提升生产可用性的功能 — phases 分支增强、executor 自动清窗、GO 智能路由、skills 充实
**Status:** ✅ Complete (2026-05-07)
**Requirements:** REQ-005~009
**Plans:** 5 plans + gap closure — [archived to milestones/v1.1-ROADMAP.md](milestones/v1.1-ROADMAP.md)

### Phase 7: P2 体验增强
**Goal:** 增强用户体验 — 技术栈约束、审批流、破坏性变更检测、扫描规则
**Status:** ✅ Complete (2026-05-07)
**Requirements:** REQ-010~015
**Plans:** 5 plans, UAT 10/10 passed — [archived to milestones/v1.1-ROADMAP.md](milestones/v1.1-ROADMAP.md)

</details>

---

### Phase 8: Constitution 四原则
**Goal:** 将 Karpathy 四原则融入 `config/constitution.md`，作为最高行为约束
**Status:** 🔄 Planning
**Requirements:** CONST-01
**Success Criteria:**
1. `config/constitution.md` 包含 `BEHAVIORAL PRINCIPLES` 段落（Think Before Coding、Simplicity First、Surgical Changes、Goal-Driven Execution）
2. `ROLE-01` 之后补充"All role-based approvals must respect the BEHAVIORAL PRINCIPLES"
3. 四原则覆盖所有 agent、sub-agent 和 review 流程
4. 验证：constitution.md 包含 "Highest Priority" 关键词

### Phase 9: Skills 质量升级
**Goal:** 重写 `requirement-clarify.md`（一次一问 + grill-with-docs + 术语冲突检测），新增 `ubiquitous-language.md`
**Status:** 🔄 Planning
**Requirements:** SKILL-01, SKILL-02
**Success Criteria:**
1. `skills/requirement-clarify.md` 包含三个 Phase：Alignment Check、Deep Dive（一次一问）、Verification & Documentation
2. `skills/requirement-clarify.md` 激活 `skills/ubiquitous-language.md` 并执行术语冲突检测
3. `skills/requirement-clarify.md` 包含"强制清窗"规则
4. `skills/ubiquitous-language.md` 触发于 1-requirement、2-design、4-dev、6-review 四个阶段
5. `skills/ubiquitous-language.md` 维护 `GLOSSARY.md` 作为单一真相来源
6. `skills/ubiquitous-language.md` 包含冲突检测规则

### Phase 10: Core 流程增强
**Goal:** `core/1-requirement.md` 增加术语对齐前置和历史教训检索，`core/4-dev.md` 强化 Goal-Driven Execution
**Status:** ✅ Planned
**Requirements:** CORE-01, CORE-02
**Plans:** 1 plan
**Plan list:**
- [ ] 10-01-PLAN.md — CORE-01/CORE-02 术语对齐+历史教训检索+TDD硬阻断
**Success Criteria:**
1. `core/1-requirement.md` 激活 `skills/ubiquitous-language.md` 并在开始时输出术语表状态
2. `core/1-requirement.md` 加载 `.specs/LESSONS.md` 并在需求文件顶部列出匹配教训
3. `core/1-requirement.md` 询问用户历史教训是否相关
4. `core/4-dev.md` TDD 部分强制"先写验证再实现"
5. `core/4-dev.md` Goal-Driven Execution 规则覆盖所有 TASK.md 任务

### Phase 11: Templates + Commands
**Goal:** 新增 `templates/GLOSSARY.md.template` 和 `commands/cross-session-search.md`
**Status:** 🔄 Planning
**Requirements:** TPL-01, CMD-01
**Success Criteria:**
1. `templates/GLOSSARY.md.template` 存在且包含完整模板结构
2. `templates/GLOSSARY.md.template` 包含 Usage Rules
3. `commands/cross-session-search.md` 实现 `/flow-kit:search-lessons` 命令
4. `commands/cross-session-search.md` 支持按关键词检索 LESSONS.md

---

### Phase 12: Rollback Workflow (Planned)
**Goal:** Rollback workflow for reverting executed phases
**Status:** 📋 Planned

---

## Phase Map

| REQ-ID | Phase |
|--------|-------|
| CONST-01 | Phase 8 |
| SKILL-01 | Phase 9 |
| SKILL-02 | Phase 9 |
| GUARD-01 | Phase 8 |
| CORE-01 | Phase 10 |
| CORE-02 | Phase 10 |
| TPL-01 | Phase 11 |
| CMD-01 | Phase 11 |

---

## State

See: .planning/STATE.md

---
*Last updated: 2026-05-07 — v1.2 roadmap created (Phases 8-11)*
*Archived: milestones/v1.0-ROADMAP.md, milestones/v1.1-ROADMAP.md, milestones/v1.0-REQUIREMENTS.md, milestones/v1.1-REQUIREMENTS.md*
