# flow-kit

## What This Is

flow-kit is a Claude Code development framework — a comprehensive toolkit providing 8-phase structured workflow (change → requirement → design → task → dev → test → review → integration → rollback), guardrails for brownfield projects, skill packages, templates, and engineering reference materials. It guides Claude Code through complex development work with built-in safety rails and best practices.

## Core Value

Provide comprehensive development structure and guardrails for Claude Code — enabling consistent, high-quality AI-assisted development without adding unnecessary complexity for simple tasks.

## Requirements

### Validated

(None yet — ship to validate)

### Active

**Phase 1 — Core Skeleton:**
- [ ] `flow-kit/GO.md` — Single entry point with routing logic
- [ ] `flow-kit/README.md` — Quick start + cost table + scenario decision tree
- [ ] `flow-kit/core/` — 8 phase files (0-change through 8-rollback)
- [ ] `flow-kit/templates/` — All template files

**Phase 2 — Guardrails & Core Capabilities:**
- [ ] `flow-kit/guardrails/` — B1-B6 brownfield guardrails
- [ ] `flow-kit/skills/` — 7 skill packages
- [ ] `flow-kit/commands/` — 4 lateral commands
- [ ] `flow-kit/mcp/` — MCP tool adaptation files
- [ ] `flow-kit/reference/` — Engineering rules + language specs
- [ ] `flow-kit/config/` — Constitution and default config

**Phase 3 — Full Scenario Adaptation:**
- [ ] Context expiry detection (15-day warning, 30-day enforcement)
- [ ] Token usage estimation per phase
- [ ] Offline mode full adaptation
- [ ] Minimal mode (skip test/review for simple changes)

**Phase 4 — Team Collaboration:**
- [ ] Role definitions in constitution
- [ ] P0 change approval workflow
- [ ] PR description generation
- [ ] Team config sync command
- [ ] Monthly cost report generation

### Out of Scope

- Runtime execution engine — flow-kit is markdown files, not executable code
- Web UI / CLI interface — files are designed for Claude Code consumption
- Language-specific framework bindings — all content is framework-agnostic guidance

## Context

- **Project type:** Greenfield — building flow-kit from scratch
- **Target users:** Developers using Claude Code for complex/large projects, especially team environments
- **Delivery format:** Markdown files only, zero dependencies, copy-paste deployable
- **PRD source:** `/data/Code/flow-kit/prd.md` — comprehensive specification provided

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

---

*Last updated: 2026-05-06 after initialization*
