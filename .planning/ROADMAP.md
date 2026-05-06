# Roadmap — flow-kit

## Overview

**4 phases** | **4 phases** | **56 requirements mapped** | All v1 requirements covered ✓

| # | Phase | Goal | Requirements | Success Criteria |
|---|-------|------|--------------|------------------|
| 1 | Core Skeleton | Complete directory structure, entry point, 8-phase workflow, templates | CORE-01~03, CORE-10~19, TMPL-70~77 | 6 |
| 2 | Guardrails & Capabilities | Brownfield guardrails, skills, commands, MCP adaptation, config | GUARD-20~24, SKILL-30~36, CMD-40~43, MCP-50~52, CFG-80~81 | 5 |
| 3 | Reference Materials | Engineering rules, language specs | REF-60~69, ARCH-90 | 3 |
| 4 | Integration & Polish | Archive logic, context expiry, token estimation, offline mode, team features | v2 deferred items | 3 |

---

## Phase 1: Core Skeleton

**Goal:** Complete directory creation, entry routing, 8-phase workflow, templates

**Requirements:** CORE-01, CORE-02, CORE-03, CORE-10~19, TMPL-70~77

**Plans:** 5 plans

**Plan list:**
- [ ] 01-01-PLAN.md — Directory structure creation
- [ ] 01-02-PLAN.md — GO.md entry point with routing
- [ ] 01-03-PLAN.md — README.md with cost table and decision tree
- [ ] 01-04-PLAN.md — 8 phase files (0-change through 8-rollback)
- [ ] 01-05-PLAN.md — 8 template files

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

**Success Criteria:**
1. Context expiry warning at 15 days, enforcement at 30 days
2. Token estimation outputs per phase with 80%/100% budget warnings
3. Offline mode skips external tool detection, uses built-in lint
4. Minimal mode skips test and review phases
5. Constitution.md includes role definitions

---

## State

See: .planning/STATE.md

---
*Last updated: 2026-05-06 after Phase 1 planning*
