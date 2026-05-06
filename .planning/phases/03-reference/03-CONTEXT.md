# Phase 3 — Reference Materials

**Domain:** Engineering hard rules (frontend/backend), TDD standard, ADR template, 6 language specs (ts/python/java/go/rust/php)

---

## Canonical Refs

- `prd.md` — Full PRD specification (source of truth)
- `.planning/ROADMAP.md` — Phase 3 goal and success criteria
- `.planning/REQUIREMENTS.md` — REF-60~69
- `.planning/phases/02-guardrails/02-CONTEXT.md` — Phase 2 decisions
- `.planning/phases/01-core-skeleton/01-CONTEXT.md` — Phase 1 decisions
- `.planning/PROJECT.md` — flow-kit project context
- `flow-kit/templates/` — Existing template files (CONTEXT.md.template, REVIEW.md.template, etc.)

---

## Decisions

### R1: Language Spec Content Depth

**Decision:** Command reference + core language concepts. No framework-specific content. No code examples.

Structure per language (ts/python/java/go/rust/php):
```
## [LANG] Engineer Reference

### Toolchain
- Lint: [command]
- Test: [command]
- Type check: [command]
- Build: [command]

### Core Concepts
- [Language-specific paradigm] — [1-2 sentence explanation]
- [Key pattern] — [1-2 sentence explanation]

### Debug Guide
- [How to diagnose issues in this language]
```

**Why:** Framework-agnostic keeps flow-kit portable; core concepts prevent "just commands"平淡感; no code examples avoids维护负担.

---

### R2: Frontend Engineer Rules Scope

**Decision:** Generic delivery checks. 11 items, framework-agnostic.

11 delivery checks:
1. **Lint clean** — `eslint` / `tslint` / `pylint` pass
2. **Type check** — TypeScript passes / Python type hints check
3. **Unit tests** — All unit tests green
4. **Integration tests** — Critical paths covered
5. **Build** — Production build succeeds
6. **Bundle size** — Within defined budget
7. **Accessibility** — axe-core / lighthouse a11y score ≥ 90
8. **Performance** — LCP < 2.5s, FID < 100ms
9. **Security headers** — CSP, HSTS, X-Frame-Options configured
10. **Cross-browser** — Chrome/Firefox/Safari baseline works
11. **Mobile responsive** — Layout adapts to viewport

**Why:** Generic checks apply to any FE stack; 11 items gives comprehensive coverage without framework lock-in.

---

### R3: TDD Standard Scope

**Decision:** Pure process standard. Red/green/refactor steps + naming conventions + skip criteria. No framework comparison.

Content:
```
## TDD Standard

### The Cycle
1. **Red** — Write failing test. One assertion only.
2. **Green** — Minimal code to pass. No optimization.
3. **Refactor** — Improve code, maintain passing tests.

### Naming Conventions
- Unit: `[unit]-[behavior]` (e.g., `calculator-adds-two-numbers`)
- Integration: `[flow]-[outcome]` (e.g., `user-submits-form-success`)
- E2E: `[user-journey]-[result]` (e.g., `customer-completes-purchase`)

### When to Skip TDD
- Spike / exploration
- Trivial changes (typos, docs)
- Config-only changes
- When test maintenance cost > test value

### Integration with verification.md
- TDD standard defines the WHAT of testing
- verification.md skill defines the HOW of verification
- They are orthogonal — TDD for writing, verification for validating
```

**Why:** No framework comparison avoids opinionated bias; integration point with verification.md skill avoids duplication.

---

### R4: ADR Template Structure

**Decision:** Minimal template with 5 fields + actionability requirement.

Template:
```
# ADR-[N]: [Title]

**Status:** Accepted | Deprecated | Superseded by ADR-[N]

## Context
[Problem statement — what prompted this decision]

## Decision
[What was decided — specific and actionable]

## Consequences
- **Immediate:** [What happens now]
- **Long-term:** [What changes over time]
- **Reversed:** [How to undo this decision if needed]
```

**Why:** 5 fields are necessary and sufficient; actionability in Consequences (Immediate/Long-term/Reversed) prevents vague outcomes.

---

## Carried Forward from Phase 1 & 2

- `phases/` top-level + flat per-phase structure
- `{{PLACEHOLDER}}` placeholder format
- Trigger/Behavior/Boundary structure for phase files
- `/flow-kit:health` command routing pattern
- Brownfield guardrail activation (manual trigger, not auto)
- Constitution as safety floor, user-config as augmentation

---

## Deferred Ideas

- **Phase naming conflict** — `phases/01-core-skeleton/` vs `phases/0-change/` share `phases/` namespace; defer to Phase 4 cleanup.

---

## Next Steps

1. Create 6 language spec files in `flow-kit/reference/language-specs/` (ts/python/java/go/rust/php)
2. Create frontend-engineer-rules.md in `flow-kit/reference/`
3. Create backend-engineer-rules.md in `flow-kit/reference/`
4. Create tdd-standard.md in `flow-kit/reference/`
5. Create adr-template.md in `flow-kit/templates/` or `flow-kit/reference/`