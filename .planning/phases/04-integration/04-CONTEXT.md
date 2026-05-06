# Phase 4 — Integration & Polish

**Domain:** Integration of Phase 3 features, context expiry detection, token estimation, offline mode, minimal mode, and team collaboration features.

---

## Canonical Refs

- `prd.md` — Full PRD specification (source of truth)
- `.planning/ROADMAP.md` — Phase 4 goal and success criteria
- `.planning/REQUIREMENTS.md` — v2 deferred items
- `.planning/phases/03-reference/03-CONTEXT.md` — Phase 3 decisions (language specs, TDD, ADR, engineering rules)
- `.planning/phases/02-guardrails/02-CONTEXT.md` — Phase 2 decisions (brownfield, skills, MCP tiering)
- `.planning/phases/01-core-skeleton/01-CONTEXT.md` — Phase 1 decisions (directory structure, GO.md routing)
- `.planning/PROJECT.md` — flow-kit project context
- `flow-kit/archive/archive-change.md` — Existing archive logic (reused for context expiry)
- `flow-kit/config/constitution.md` — Safety floor (Phase 4 extends with roles)
- `flow-kit/commands/sync-team-config.md` — CMD-43 team config sync (already exists)

---

## Decisions

### 4-1: Context Expiry Mechanism

**Decision:** 15-day warning → 30-day auto-archive with notification and one-click recovery.

Behavior:
- **15 days:** Warning notification — user is informed context will expire in 15 days
- **30 days:** Auto-archive to `archive/` — reuses existing `archive-change.md` logic; context is compressed and moved to archive
- **On archive:** User receives notification with:
  - "Context archived. N files archived."
  - "One-click recovery: [command to restore]"
  - Recovery command restores from archive to active state

**Why:** Auto-archive with recovery reduces operational burden; notification ensures user awareness; one-click recovery lowers friction for resuming archived work.

---

### 4-2: Token Estimation Method

**Decision:** Phase file LOC (lines of code) based estimation. 80% = warning, 100% = block.

Behavior:
- **Data source:** Count lines in each phase's `.md` files (excluding templates)
- **Formula:** `estimated_tokens = sum(phase_file_LOC) *经验系数` — coefficient tuned against real usage
- **80% budget:** Soft warning — "Approaching token budget (80%). Consider archiving or condensing context."
- **100% budget:** Hard block — "Token budget exhausted. Archive or condense context before continuing."

**Why:** LOC-based is simple, requires no external API calls, and directly reflects reading workload.

---

### 4-3: Offline Mode Detection & Fallback

**Decision:** Hybrid mode — user-triggered + auto-detect on tool failure. Built-in lint = file structure integrity only.

Detection:
- **Manual trigger:** `/flow-kit:offline` — user explicitly activates offline mode
- **Auto-detect:** On tool failure (network error / timeout / tool unreachable), auto-degrade to offline mode
- **Resume:** Auto-detect is one-shot; user can re-enable online mode manually

Offline built-in lint scope (file structure integrity):
- Placeholder completeness (`{{PLACEHOLDER}}` format check)
- Required files existence (per phase requirements)
- YAML/JSON format validation (config files)
- No code content analysis (deferred to online mode)

**Why:** Hybrid balances reliability (manual override) with automation (failover); file structure check is fast and requires no external tools.

---

### 4-4: Minimal Mode Determination

**Decision:** Whitelist + user override. Auto-activates for whitelisted types; user can manually flag any change.

Auto-minimal whitelist:
- `README.md`, `CHANGELOG.md`, `LICENSE` — documentation-only files
- `*.config.js`, `*.config.ts`, `*.config.json`, `*.yaml`, `*.yml` — config files
- Single-file changes with `< 50 lines diff` and `< 3 files changed`
- `flow-kit/` internal files (templates, docs)

User override:
- Any change can be manually marked `/flow-kit:minimal` to force minimal mode
- Minimal mode skips: Phase 5 (Test) and Phase 6 (Review) — proceeds directly from Phase 4 (Dev) to Phase 7 (Integration)

**Why:** Whitelist covers common low-risk cases; user override provides flexibility for experienced users.

---

### 4-5: Constitution Role Definitions

**Decision:** Independent file `config/team-roles.md`. 3-role system: Admin / Reviewer / Developer.

File location: `flow-kit/config/team-roles.md`

Role definitions:
| Role | Responsibilities |
|------|-----------------|
| **Admin** | Constitution management, safety rule enforcement, breaking-change approval, team roles assignment |
| **Reviewer** | Phase 6 review sign-off, PR approval, quality gate verification |
| **Developer** | Execute changes, create CONTEXT, run tests, submit for review |

Relationship to Constitution:
- `team-roles.md` is referenced by Constitution's "Priority Statement" section
- Safety rules in Constitution remain unoverridable regardless of role
- Non-safety role permissions can be configured per-project in `user-config.md`

**Why:** Independent file keeps Constitution clean (safety floor); 3-role balance covers governance needs without over-engineering.

---

### 4-6: PR Description Generation

**Decision:** Semi-automatic — template fields auto-fill + AI supplements "motivation" and "technical details".

Template fields (auto-filled):
- Change ID, Title, Summary
- Affected files / modules
- Test results (from Phase 5 verification)
- Rollback plan reference

AI-generated (supplemented):
- **Motivation:** Why this change was needed
- **Technical details:** Key implementation decisions, non-obvious choices, trade-offs made

User workflow: AI generates draft → user reviews and approves → final PR description.

**Why:** Template fields are deterministic and reliable; AI supplementation handles the creative/interpretive parts; user review prevents hallucinations.

---

### 4-7: Cost Report Metrics

**Decision:** Monthly cost report = Token consumption + Phase completion rate + average cost per change.

Report contents:
| Metric | Description |
|--------|-------------|
| Total Token consumption | Monthly Claude Code token usage (estimated via Phase file LOC method) |
| Phase completion rate | % of changes completing each phase (Phase 1–8) |
| Avg cost per change | Total tokens / number of changes |
| Change count | Total changes in period |

Output format: Markdown table + summary paragraph. Generated on-demand via `/flow-kit:cost-report`.

**Why:** Token + phase progress covers both efficiency and throughput; per-change cost enables team benchmarking.

---

### 4-8: P0 Approval Workflow Trigger

**Decision:** Combined trigger — auto-detect breaking-change/DDL + manual flag. Admin or Reviewer approval required.

Auto-trigger conditions:
- Breaking change: `BREAKING-CHANGE.md` file present in change set
- Database change: DDL/DML files detected in change set (`.sql`, `migration/`)
- User manual flag: `/flow-kit:p0` on any change

Approval requirement: Admin or Reviewer must explicitly approve before Phase 7 (Integration) proceeds.

**Why:** Combined trigger covers both technical (breaking/DDL) and intentional (manual) high-risk changes; explicit approval enforces governance.

---

### 4-9: Team Config Sync Scope

**Decision:** Sync `config/constitution.md` + `config/team-roles.md` only.

Scope:
- `flow-kit/config/constitution.md` — safety floor (must be shared for consistent enforcement)
- `flow-kit/config/team-roles.md` — role definitions (referenced by constitution)

Excluded: `user-config.md` (may contain team-private settings), `skills/`, `commands/`, `templates/`.

Sync mechanism: Existing `commands/sync-team-config.md` (CMD-43) extended to handle these two files.

**Why:** Narrow scope (2 files) minimizes merge conflicts and privacy concerns; constitution + roles are the governance minimum.

---

## Carried Forward from Phase 1–3

- `phases/` top-level + flat per-phase structure
- `{{PLACEHOLDER}}` placeholder format
- Trigger/Behavior/Boundary structure for phase files
- `/flow-kit:health` command routing pattern
- Constitution as safety floor, user-config as augmentation
- MCP tiering (core/standard/all) from Phase 2
- Archive logic (Phase 3) — reused for context expiry
- Language spec files (Phase 3) — LOC estimation references these

---

## Deferred Ideas

- **Phase naming cleanup** — `phases/01-core-skeleton/` vs `phases/0-change/` share `phases/` namespace; deferred from Phase 3
- **Context expiry recovery detail** — recovery command format (CLI flag? prompt? file?) not yet specified; defer to implementation
- **Token coefficient calibration** —经验系数 needs real-world tuning after Phase 4 ships

---

## Next Steps

1. Create `config/team-roles.md` with 3-role definitions
2. Extend `commands/sync-team-config.md` to sync constitution + roles
3. Extend `archive/archive-change.md` to handle context (not just change) archival
4. Implement context expiry detection (15d warning / 30d archive trigger)
5. Implement token estimation per phase
6. Implement offline mode with file structure lint
7. Implement minimal mode whitelist + override
8. Implement P0 approval workflow
9. Implement PR description generation (template + AI supplement)
10. Implement cost report generation
