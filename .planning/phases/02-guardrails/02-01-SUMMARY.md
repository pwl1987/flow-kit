---
phase: 02-guardrails
plan: 01
subsystem: guardrails
tags: [guardrails, brownfield, breaking-change, database, security, ui]
dependency_graph:
  requires: []
  provides: [GUARD-20, GUARD-21, GUARD-22, GUARD-23, GUARD-24, ARCH-90]
  affects: [flow-kit/guardrails/brownfield-guardrails.md, flow-kit/guardrails/breaking-change.md, flow-kit/guardrails/database-guardrails.md, flow-kit/guardrails/security-checklist.md, flow-kit/guardrails/ui-guardrails.md, flow-kit/archive/archive-change.md]

tech_stack:
  added: [guardrail documentation, YAML checklist, archive logic]
  patterns: [Trigger/Behavior/Boundary/Output format, P0/P1/P2 classification]

key_files:
  created:
    - flow-kit/guardrails/brownfield-guardrails.md
    - flow-kit/guardrails/breaking-change.md
    - flow-kit/guardrails/database-guardrails.md
    - flow-kit/guardrails/security-checklist.md
    - flow-kit/guardrails/ui-guardrails.md
    - flow-kit/archive/archive-change.md

decisions:
  - Brownfield detection via .git/ + package manager coexistence
  - B1-B6 guardrail index with individual file references
  - P0 fast-track for emergency changes (post-hoc review)
  - Archive path: archive/{YYYY-MM}/{change-id}/
---

# Phase 2 Plan 1: Guardrails & Capabilities Summary

## One-liner

5 guardrail files (B1-B6) and archive logic with Trigger/Behavior/Boundary/Output format.

## Completed Tasks

| # | Task | Status | Commit |
|---|------|--------|--------|
| 1 | Create brownfield-guardrails.md (B1-B6 index) | DONE | e2018ba |
| 2 | Create breaking-change.md (P0/P1/P2) | DONE | 5926ad3 |
| 3 | Create database-guardrails.md (DDL/DML) | DONE | 028ee3f |
| 4 | Create security-checklist.md (YAML) | DONE | f7771b1 |
| 5 | Create ui-guardrails.md (visual vocabulary) | DONE | f4407b2 |
| 6 | Create archive-change.md (ARCH-90) | DONE | 85472ae |

## Artifacts Created

### B1: brownfield-guardrails.md
- B1-B6 guardrail index referencing individual files
- Manual activation: `/flow-kit:guardrails` or `@flow-kit/guardrails`
- Auto-detection: `.git/` + package manager file coexistence
- P0 fast-track boundary for emergency changes

### B2: breaking-change.md
- P0: Emergency bypass (post-hoc review required)
- P1: Breaking API/contract (senior approval required)
- P2: Non-breaking enhancement (team lead approval)
- Breaking Change Classification Report output

### B3: database-guardrails.md
- DDL safety: schema changes require review
- DML safety: WHERE clause enforcement, batch limits
- Rollback requirements for all operations

### B4: security-checklist.md
- Valid YAML with sections: authentication, authorization, input_validation, secrets, sql_injection, xss_prevention, rate_limiting
- Each section contains check items with id, title, description, check state

### B5: ui-guardrails.md
- Design token consistency (color, typography, spacing)
- Typography scale definition
- Color system alignment
- Component review checklist

### ARCH-90: archive-change.md
- Archive path: `archive/{YYYY-MM}/{change-id}/`
- README.md and metadata.yaml creation
- .specs/INDEX.md update after archive

## Key Links Established

| From | To | Via |
|------|----|-----|
| brownfield-guardrails.md | breaking-change.md | B1 references breaking-change.md |
| brownfield-guardrails.md | database-guardrails.md | B2 references database-guardrails.md |
| brownfield-guardrails.md | security-checklist.md | B3 references security-checklist.md |
| brownfield-guardrails.md | ui-guardrails.md | B4 references ui-guardrails.md |
| archive-change.md | GO.md | /flow-kit:archive command route |

## Deviations from Plan

None - plan executed exactly as written.

## Metrics

- **Duration:** ~15 minutes
- **Files created:** 6
- **Commits:** e2018ba, 5926ad3, 028ee3f, f7771b1, f4407b2, 85472ae
- **Completed:** 2026-05-06

## Self-Check

- [x] All 6 files exist under flow-kit/guardrails/ and flow-kit/archive/
- [x] B1-B6 index references all guardrail files
- [x] P0/P1/P2 classification defined in breaking-change.md
- [x] DDL and DML sections present in database-guardrails.md
- [x] Valid YAML structure in security-checklist.md
- [x] Visual vocabulary sections defined in ui-guardrails.md
- [x] Archive path structure specified in archive-change.md
- [x] All files use Trigger/Behavior/Boundary/Output format
- [x] CLAUDE CODE INSTRUCTION headers present
