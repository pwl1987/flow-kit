# Phase 2 — Guardrails & Capabilities

**Domain:** Brownfield guardrails, skill packages, lateral commands, MCP tool adaptation, configuration files, and archive logic.

---

## Canonical Refs

- `prd.md` — Full PRD specification (source of truth)
- `.planning/ROADMAP.md` — Phase 2 goal and success criteria
- `.planning/REQUIREMENTS.md` — GUARD-20~24, SKILL-30~36, CMD-40~43, MCP-50~52, CFG-80~81
- `.planning/phases/01-core-skeleton/01-CONTEXT.md` — Phase 1 decisions (carried forward)
- `.planning/PROJECT.md` — flow-kit project context
- `.planning/STATE.md` — Current project state

---

## Decisions

### G1: Brownfield Guardrail Activation

**Decision:** Auto-detect brownfield projects + manual trigger for guardrail activation.

Behavior:
1. **Detection:** On GO.md load, scan for `.git/` + `package.json` / `go.mod` / `pom.xml` / `Cargo.toml` → classify as brownfield if both exist (versioned project with package manager)
2. **Manual trigger:** User calls `/flow-kit:guardrails` or `@flow-kit/guardrails` to activate B1-B6 guardrails
3. **No auto-injection:** Guardrails do NOT auto-activate — user must intentionally invoke

**Why:** Manual trigger prevents guardrails from interrupting greenfield work; detection provides context awareness.

---

### G2: Skill Package Granularity

**Decision:** 7 independent .md files + GO.md auto-routes based on context.

Structure:
```
flow-kit/skills/
├── requirement-clarify.md    # SKILL-30
├── task-master.md           # SKILL-31
├── subagent-execution.md    # SKILL-32
├── code-review.md           # SKILL-33
├── debugging.md            # SKILL-34
├── parallel-dispatch.md     # SKILL-35
└── verification.md         # SKILL-36
```

GO.md routes to appropriate skill file based on phase context. Each file is standalone — user can also @flow-kit/skill-XXX directly.

**Why:** Independent files allow selective use; GO.md routing provides context-aware suggestions.

---

### G3: Lateral Command Format

**Decision:** `/flow-kit:health` style — Claude Code native slash command format.

Commands:
- `/flow-kit:health` — M-health (CMD-40)
- `/flow-kit:scan` — I-intel-scan (CMD-41)
- `/flow-kit:update-context` — update-context (CMD-42)
- `/flow-kit:sync-team` — sync-team-config (CMD-43)

GO.md handles routing for all 4 commands. Each command is a self-contained .md file under `commands/` directory.

**Why:** Matches Claude Code's native command style; consistent with existing `/flow-kit:health` routing precedent from Phase 1.

---

### G4: MCP Tool Tiering (core/standard/all)

**Decision:** Tiered by destructiveness — read < write < execute.

| Tier | Tools | Description |
|------|-------|-------------|
| core | Read, Glob, Grep, WebSearch | Read-only, always safe |
| standard | Write, Edit, Bash (local) | Local mutations, requires confirmation |
| all | Bash (full), Agent, Task,危险操作 | Full execution, needs explicit opt-in |

`mcp-tools-config.md` defines each tier's tool清单. Constitution constraints can override tier boundaries per project.

**Why:** Destructiveness is the clearest risk metric; matches how Claude Code already handles permissions.

---

### G5: Constitution vs User-Config Priority

**Decision:** Tiered merge — Constitution as safety floor, user-config as augmentation.

Priority order (highest to lowest):
1. **Constitution.md** — Safety-critical rules (security, data integrity, deployment guardrails)
2. **user-config.md** — Project-specific preferences (team conventions, workflow style)
3. **Default values** — Flow-kit defaults for unspecified items

Conflict resolution: Safety rules in Constitution CANNOT be overridden by user-config. Non-safety rules merge with user-config winning on conflicts.

**Why:** Constitution provides safety guarantees; user-config provides flexibility; tiered approach balances both.

---

### G6: ARCH-90 Archive Location

**Decision:** ARCH-90 (archive-change.md) belongs to Phase 2 scope as a Phase 2 sub-task.

Archive logic is referenced in Phase 3 requirements (ROADMAP misalignment) but REQUIREMENTS.md maps it to Phase 2. Implementation: `flow-kit/archive/archive-change.md` created in Phase 2, documented in Phase 3 reference materials.

**Why:** REQUIREMENTS.md is the authoritative source for requirement-to-phase mapping; ROADMAP.md will be corrected to reflect this.

---

## Carried Forward from Phase 1

- `phases/` top-level + flat per-phase structure
- `{{PLACEHOLDER}}` placeholder format
- Trigger/Behavior/Boundary structure for phase files
- `/flow-kit:health` command routing pattern (extends to all CMD-40~43)

---

## Deferred Ideas

- **Phase naming conflict** — `phases/01-core-skeleton/` vs `phases/0-change/` share `phases/` namespace; defer to Phase 4 cleanup.

---

## Next Steps

1. Implement B1-B6 brownfield guardrails in `guardrails/` (GUARD-20~24)
2. Create 7 skill packages in `skills/` (SKILL-30~36)
3. Implement 4 lateral commands in `commands/` (CMD-40~43)
4. Create MCP adaptation files in `mcp/` (MCP-50~52)
5. Create constitution.md and default-user-config.md in `config/` (CFG-80~81)
6. Create archive-change.md in `archive/` (ARCH-90)
