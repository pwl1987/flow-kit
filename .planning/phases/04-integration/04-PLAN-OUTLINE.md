# Phase 4 — Integration & Polish: Plan Outline

## Wave Structure

| Wave | Plans | Dependencies |
|------|-------|--------------|
| 1 | 04-1, 04-2 | None (foundation) |
| 2 | 04-3, 04-4 | Wave 1 complete |

---

## Plan Outline

| Plan ID | Objective | Wave | Depends On | Requirements |
|---------|-----------|------|------------|--------------|
| 04-1 | Context expiry detection + token estimation | 1 | — | D4-1, D4-2 |
| 04-2 | Offline mode + minimal mode | 1 | — | D4-3, D4-4 |
| 04-3 | Role definitions + team config sync | 2 | Wave 1 | D4-5, D4-9 |
| 04-4 | PR description + cost report + P0 approval | 2 | Wave 1 | D4-6, D4-7, D4-8 |

---

## Plan 04-1: Observability Foundation

**Decisions:** D4-1 (Context Expiry), D4-2 (Token Estimation)

**Tasks:**
1. Extend `archive/archive-change.md` for context expiry (15d warning, 30d archive)
2. Implement LOC-based token estimation with 80%/100% budget warnings
3. Create notification system for expiry warnings

**Files modified:** `flow-kit/archive/archive-change.md`, new expiry detection module, token estimator

---

## Plan 04-2: Execution Flexibility

**Decisions:** D4-3 (Offline Mode), D4-4 (Minimal Mode)

**Tasks:**
1. Implement offline mode: hybrid trigger (manual + auto-failover), built-in file structure lint
2. Implement minimal mode: whitelist + user override, skips Phase 5/6
3. Add `/flow-kit:offline` and `/flow-kit:minimal` command handlers

**Files modified:** `flow-kit/commands/`, new offline/minimal mode modules

---

## Plan 04-3: Constitutional Extension

**Decisions:** D4-5 (Role Definitions), D4-9 (Team Config Sync)

**Tasks:**
1. Create `flow-kit/config/team-roles.md` with 3-role system (Admin/Reviewer/Developer)
2. Extend `commands/sync-team-config.md` (CMD-43) to sync constitution + roles
3. Link team-roles.md from Constitution.md Priority Statement

**Files modified:** `flow-kit/config/team-roles.md`, `flow-kit/config/constitution.md`, `flow-kit/commands/sync-team-config.md`

---

## Plan 04-4: Workflow Enhancements

**Decisions:** D4-6 (PR Description), D4-7 (Cost Report), D4-8 (P0 Approval)

**Tasks:**
1. Implement PR description generation: template auto-fill + AI supplement for motivation/tech details
2. Implement cost report: token consumption, phase completion rate, avg cost per change
3. Implement P0 approval workflow: breaking-change/DDL detection + manual flag + Admin/Reviewer approval gate

**Files modified:** `flow-kit/commands/`, new PR desc generator, cost report module, approval workflow module

---

## OUTLINE COMPLETE

**4 plans** in **2 waves**