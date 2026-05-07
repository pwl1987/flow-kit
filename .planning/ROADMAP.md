# Roadmap — flow-kit

## Overview

**7 phases** | **15 requirements mapped** | All v1.1 requirements covered ✓

| # | Phase | Goal | Requirements | Success Criteria |
|---|-------|------|--------------|------------------|
| 1 | Core Skeleton | Complete directory structure, entry point, 8-phase workflow, templates | CORE-01~03, CORE-10~19, TMPL-70~77 | 6 |
| 2 | Guardrails & Capabilities | Brownfield guardrails, skills, commands, MCP adaptation, config | GUARD-20~24, SKILL-30~36, CMD-40~43, MCP-50~52, CFG-80~81 | 5 |
| 3 | Reference Materials | Engineering rules, language specs | REF-60~69, ARCH-90 | 5 |
| 4 | Integration & Polish | Archive logic, context expiry, token estimation, offline mode, team features | v2 deferred items | 5 |
| 5 | P0 缺陷修复 | 棕地检测、断点续跑、数据库检测、skill 验证 | REQ-001~004 | 4 |
| 6 | P1 功能补充 | phases 分支、executor 续跑、GO 路由、skills 充实 | REQ-005~009 | 5 |
| 7 | P2 体验增强 | 审批流、技术栈、破坏性变更检测、扫描规则 | REQ-010~015 | 6 |

---

## Phase 1: Core Skeleton

**Goal:** Complete directory creation, entry routing, 8-phase workflow, templates

**Requirements:** CORE-01, CORE-02, CORE-03, CORE-10~19, TMPL-70~77

**Status:** ✅ Complete (2026-05-06)

**Success Criteria:**
1. All directories created per PRD spec
2. GO.md loads constitution.md and user-config.md as first priority
3. GO.md routes all commands correctly (/flow-kit:health, /flow-kit:scan, etc.)
4. All 8 phase files (0-change through 8-rollback) exist with proper structure
5. All 8 template files exist with correct placeholders
6. README.md contains cost table and scenario decision tree

---

## Phase 2: Guardrails & Capabilities

**Goal:** Complete B1-B6 brownfield guardrails, all skill packages, lateral commands, MCP tool adaptation, and configuration files.

**Requirements:** GUARD-20~24, SKILL-30~36, CMD-40~43, MCP-50~52, CFG-80~81

**Status:** ✅ Complete (2026-05-06)

**Success Criteria:**
1. B1-B6 brownfield guardrails documented with clear activation conditions
2. All 7 skill packages functional with proper templates
3. All 4 lateral commands executable
4. MCP adaptation files handle core/standard/all tool tiers
5. Constitution.md enforces highest-priority constraints

---

## Phase 3: Reference Materials

**Goal:** Complete engineering hard rules for frontend/backend, TDD standard, ADR template, all 6 language specs, and archive logic.

**Requirements:** REF-60~69, ARCH-90

**Status:** ✅ Complete (2026-05-06)

**Success Criteria:**
1. Frontend engineer rules include 11 delivery checks
2. Backend engineer rules cover common patterns
3. TDD standard defines red/green/refactor steps
4. All 6 language specs (ts/python/java/go/rust/php) include lint tools and test commands
5. Archive logic correctly moves .specs/{change-id} to archive/

---

## Phase 4: Integration & Polish

**Goal:** Integrate Phase 3 features, implement context expiry detection, token estimation, offline mode, minimal mode, and team collaboration features.

**Requirements:** v2 deferred items (context expiry, token estimation, offline mode, minimal mode, roles, approval flow, PR desc, cost report)

**Status:** ✅ Complete (2026-05-06)

**Success Criteria:**
1. Context expiry warning at 15 days, enforcement at 30 days
2. Token estimation outputs per phase with 80%/100% budget warnings
3. Offline mode skips external tool detection, uses built-in lint
4. Minimal mode skips test and review phases
5. Constitution.md includes role definitions

---

## Phase 5: P0 缺陷修复

**Goal:** 修复影响核心能力的缺陷 — 棕地/绿地检测、断点续跑、数据库类型识别、skills 验证

**Requirements:** REQ-001, REQ-002, REQ-003, REQ-004

**Plans:**
- [x] 05-01-PLAN.md — Brownfield/Greenfield detection (project-type.js)
- [x] 05-02-PLAN.md — Checkpoint resume (checkpoint.js)
- [x] 05-03-PLAN.md — Database type detection (database-type.js)
- [x] 05-04-PLAN.md — Skills validation (validate-skills.js)

**Success Criteria:**
1. phase 文件正确检测棕地/绿地项目类型
2. phase-executor 支持断点续跑，检测 `.STATE` 文件恢复执行
3. database-guardrails 自动识别 MySQL/PG/MongoDB 类型并推荐工具
4. skills 内容经实战验证达到可用标准

**Status:** ✅ Complete (2026-05-07)

---

## Phase 6: P1 功能补充

**Goal:** 补充提升生产可用性的功能 — phases 分支增强、executor 自动清窗、GO 智能路由、skills 充实

**Requirements:** REQ-005, REQ-006, REQ-007, REQ-008, REQ-009

**Plans:**
- [x] 06-01-PLAN.md — Area A+C: phases 棕地/绿地混合模式 + GO.md 智能路由
- [x] 06-02-PLAN.md — Area B: phase-executor 自动清窗 + Area D 部分: debugging + verification
- [x] 06-03-PLAN.md — Area D 剩余: code-review + task-master + subagent-execution + parallel-dispatch + requirement-clarify

**Success Criteria:**
1. phases 文件包含完整的环境检测、依赖检测、项目历史分析
2. phase-executor 实现自动清窗，超 80% token 预算时触发压缩
3. GO.md 实现智能路由，向用户展示检测结果并支持手动覆盖
4. skills 内容根据实战验证结果更新优化
5. 全链路棕地/绿地自动路由完成

**Status:** ✅ Complete — 3 plans, 6 commits (2026-05-07)

---

## Phase 7: P2 体验增强

**Goal:** 增强用户体验 — 技术栈约束、审批流、破坏性变更检测、扫描规则

**Requirements:** REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015

**Success Criteria:**
1. constitution.md 包含 TECH-01 技术栈约束和 architect/reviewer/ops 角色定义
2. P0 变更触发审批文件自动生成
3. APPROVAL.md.template 完整且与 p0-approval 命令集成
4. 多语言规格包含破坏性变更检测模式
5. M-health / I-intel-scan 扫描规则充实，输出结构化报告
6. sync-team-config.md 从团队仓库拉取配置到 `.flow-kit/`

**Status:** ✅ Complete (2026-05-07)

**Success Criteria:**
1. constitution.md 包含 TECH-01 技术栈约束和 architect/reviewer/ops 角色定义 ✅
2. P0 变更触发审批文件自动生成 ✅
3. APPROVAL.md.template 完整且与 p0-approval 命令集成 ✅
4. 多语言规格包含破坏性变更检测模式 ✅
5. M-health / I-intel-scan 扫描规则充实，输出结构化报告 ✅
6. sync-team-config.md 从团队仓库拉取配置到 `.flow-kit/` ✅

**Plans:**
- [x] 07-01-PLAN.md — Constitution TECH-01 技术栈约束 + 角色定义
- [x] 07-02-PLAN.md — P0-approval 自动生成 + APPROVAL.md.template
- [x] 07-03-PLAN.md — 多语言规格破坏性变更检测模式
- [x] 07-04-PLAN.md — M-health / I-intel-scan 扫描规则充实
- [x] 07-05-PLAN.md — sync-team-config.md 实现

**UAT:** 10/10 tests passed ✅l-scan 扫描规则充实
-[x] 07-05-PLAN.md — sync-team-config.md 实现

---

## State

See: .planning/STATE.md

---
*Last updated: 2026-05-07 after Phase 7 planning*