---
phase: 02-guardrails
plan: 05
subsystem: config
tags: [safety, constitution, config-priority, guardrails]
dependency_graph:
  requires: []
  provides: [CFG-80, CFG-81]
  affects: [GO.md, user-config]
tech_stack:
  added: [markdown-config]
  patterns: [safety-floor, priority-override]
key_files:
  created:
    - flow-kit/config/constitution.md
    - flow-kit/config/default-user-config.md
decisions:
  - Safety rules are unoverridable (Constitution priority)
  - User-config wins on non-safety conflicts
  - Priority: Constitution > user-config > defaults
metrics:
  duration: "~5 minutes"
  completed: "2026-05-06T11:12:00Z"
  tasks_completed: 2
  files_created: 2
  commits: 2
---

# Phase 2 Plan 5 Summary: Configuration Guardrails

## One-liner

Constitution.md (safety floor) and default-user-config.md with priority order enforcement.

## Completed Tasks

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create constitution.md (safety floor) | f4fc9ac | flow-kit/config/constitution.md |
| 2 | Create default-user-config.md | a91892a | flow-kit/config/default-user-config.md |

## What Was Built

### flow-kit/config/constitution.md (CFG-80)

Safety floor with 20 unoverridable rules across 4 categories:

- **Security (SEC-01 to SEC-05)**: No secrets in code, input validation, parameterized queries
- **Data Integrity (DATA-01 to DATA-05)**: Backup before delete, transactions, verify impact
- **Deployment (DEPLOY-01 to DEPLOY-05)**: Rollback plan required, no prod credentials in code
- **Git Safety (GIT-01 to GIT-05)**: No --no-verify, no force-push without flags, always verify

### flow-kit/config/default-user-config.md (CFG-81)

Default configuration with override mechanism:

- **Workflow Settings**: default_phase, parallel_tasks_max, context_budget_warning
- **Model Preferences**: executor_model, planner_model, haiku_subagent
- **Team Settings**: review_required, min_reviewers, commit_style, branch_prefix
- **Linting & Quality**: lint_on_save, lint_tools, auto_fix, typecheck
- **Verification Strictness**: verify_commits, verify_deploy, strict_mode

**Priority Order Enforced:**
1. Constitution (highest) — safety rules cannot be overridden
2. User Config — `.flow-kit/user-config.md` wins on conflicts
3. Default User Config (lowest) — fallback values

## Deviations from Plan

None — plan executed exactly as written.

## Self-Check

- [x] constitution.md exists at flow-kit/config/constitution.md
- [x] default-user-config.md exists at flow-kit/config/default-user-config.md
- [x] f4fc9ac commit exists
- [x] a91892a commit exists
- [x] Constitution has 4+ rule categories (security, data, deployment, git)
- [x] Safety rules marked as unoverridable (CANNOT override)
- [x] Default-user-config.md documents override mechanism
- [x] Priority order clearly stated

## Self-Check: PASSED
