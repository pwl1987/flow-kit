# flow-kit

## What This Is

flow-kit is a Claude Code development framework — a comprehensive toolkit providing 8-phase structured workflow (change → requirement → design → task → dev → test → review → integration → rollback), guardrails for brownfield projects, skill packages, templates, and engineering reference materials. It guides Claude Code through complex development work with built-in safety rails and best practices.

## Core Value

Provide comprehensive development structure and guardrails for Claude Code — enabling consistent, high-quality AI-assisted development without adding unnecessary complexity for simple tasks.

---

## Current State

**Shipped Version:** v1.2 (planned)
**Milestones:** v1.0 ✅ (Phases 1-4), v1.1 ✅ (Phases 5-7), v1.2 🔄 (Phases 8+)

### What's Delivered (v1.1)

| Phase | Requirements | Status |
|-------|--------------|--------|
| Phase 5: P0 缺陷修复 | REQ-001~004 | ✅ |
| Phase 6: P1 功能补充 | REQ-005~009 | ✅ |
| Phase 7: P2 体验增强 | REQ-010~015 | ✅ |

**Total:** 15/15 requirements satisfied. UAT: 10/10 passed.

---

## Current Milestone: v1.2 增量升级 — 需求质量与结构化增强

**Goal:** 吸收 5 库精华（Karpathy 行为约束、mattpocock 领域语言与 grill-docs 机制、graphify 依赖图导航），补齐 v1.1 在需求澄清质量、术语一致性、老项目上下文结构化上的短板。

**Target features:**
- Karpathy 四原则融入 constitution.md（行为约束最高优先级）
- requirement-clarify.md 重写：一次一问 + grill-with-docs + 术语冲突检测
- 新增 ubiquitous-language.md：全流程术语检查
- brownfield-guardrails.md B1 增加依赖关系表生成
- 1-requirement.md 增加术语对齐前置 + LESSONS.md 检索
- 4-dev.md 强化 Goal-Driven Execution（TDD 先写验证再实现）
- 新增 GLOSSARY.md.template 术语表模板
- 新增 cross-session-search.md 跨会话经验搜索

**Key context:** 零破坏性修改，所有变更均为增量

### In Scope for v1.2

- constitution.md 融入 Karpathy 四原则（BEHAVIORAL PRINCIPLES）
- requirement-clarify.md 整合 grill-with-docs，一次一问，术语冲突检测
- 新增 ubiquitous-language.md 领域语言统一技能
- brownfield-guardrails.md B1 增加 dependency-map.md 生成
- core/1-requirement.md 增加术语对齐前置 + 历史教训自动检索
- core/4-dev.md 强化 Goal-Driven Execution
- 新增 templates/GLOSSARY.md.template
- 新增 commands/cross-session-search.md

### Out of Scope

- Runtime execution engine — flow-kit is markdown files, not executable code
- Web UI / CLI interface — files are designed for Claude Code consumption
- Language-specific framework bindings — all content is framework-agnostic guidance
- v2.0 路线图内容（rollback workflow、team collaboration 增强）

---

<details>
<summary>v1.0 + v1.1 Context (archived 2026-05-07)</summary>

## Requirements

### Validated

**v1.0 — 核心骨架完成 ✓**

- flow-kit/GO.md — 单入口路由 ✓
- flow-kit/core/ — 8 阶段文件 ✓
- flow-kit/guardrails/ — 棕地护轨 B1-B6 ✓
- flow-kit/skills/ — 7 个技能包 ✓
- flow-kit/commands/ — 4 个横向命令 ✓
- flow-kit/templates/ — 模板文件 ✓
- flow-kit/reference/ — 工程规则 + 多语言规格 ✓
- flow-kit/config/ — Constitution + 默认配置 ✓
- phase-executor.md — 阶段执行器 ✓
- check-expiry.md — 上下文过期检测 ✓
- estimate-tokens.md — Token 估算 ✓
- offline-mode.md — 离线模式 ✓
- minimal-mode.md — 最小模式 ✓

**v1.1 — 迭代优化（Phase 5-7）✓**

- [x] phases 文件增加棕地/绿地分支检测
- [x] phase-executor 增加断点续跑和自动清窗
- [x] database-guardrails 增加数据库类型自动检测
- [x] skills 文件内容充实 + 实战验证
- [x] GO.md 增加棕地/绿地自动路由
- [x] constitution 增加技术栈约束和角色定义
- [x] 增加审批文件自动生成
- [x] 补充 APPROVAL.md.template
- [x] 多语言规格增加破坏性变更检测模式
- [x] M-health / I-intel-scan 充实具体扫描规则
- [x] sync-team-config.md 实现

## Context

- **Project type:** Brownfield → flow-kit 迭代开发
- **Target users:** Developers using Claude Code for complex/large projects, especially team environments
- **Delivery format:** Markdown files only, zero dependencies, copy-paste deployable
- **PRD source:** `prd1.1.md` — v1.1 迭代规格

## Constraints

- **Format**: All files must start with `> 【CLAUDE CODE INSTRUCTION 强制约束】` block
- **Output format**: Files wrapped with `--- BEGIN filename ---` / `--- END filename ---`
- **Directory structure**: Must follow PRD specification exactly
- **File ordering**: Build directory structure first, then write files sequentially

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Markdown-only files | Zero dependencies, maximum portability | ✓ Confirmed |
| CLAUDE CODE INSTRUCTION blocks | Ensures Claude Code respects priority and constraints | ✓ Confirmed |
| 8-phase workflow | Balances structure vs. simplicity | ✓ Confirmed |
| B1-B6 brownfield guardrails | Critical for existing project safety | ✓ Confirmed |
| Minimal mode for simple changes | Avoids over-engineering small tasks | ✓ Confirmed |
| v1.1 P0-first approach | Fix production blockers before adding features | ✓ Confirmed |

</details>

---

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---

*Last updated: 2026-05-07 — v1.2 milestone started*
*Archived: milestones/v1.0-ROADMAP.md, milestones/v1.1-ROADMAP.md, milestones/v1.0-REQUIREMENTS.md, milestones/v1.1-REQUIREMENTS.md*