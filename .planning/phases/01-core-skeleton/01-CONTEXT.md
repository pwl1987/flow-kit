# Phase 1 — Core Skeleton

**Domain:** Complete directory creation, entry routing, 8-phase basic templates, and core template files for flow-kit.

---

## Canonical Refs

- `prd.md` — Full PRD specification (source of truth)
- `.planning/ROADMAP.md` — Phase 1 goal and success criteria
- `.planning/PROJECT.md` — CORE-01, CORE-02, CORE-03 requirements

---

## Decisions

### Directory Layout

**Decision:** `phases/` top-level + flat per phase (no subdirectories).

Structure:
```
flow-kit/
├── GO.md                  # Entry point
├── README.md              # Quick start + cost table + decision tree
├── CONSTITUTION.md        # Core principles and rules
├── phases/
│   ├── 01-core-skeleton/
│   ├── 02-guardrails/
│   ├── 03-reference/
│   ├── 04-integration/
│   ├── 0-change/
│   ├── 1-requirement/
│   ├── 2-design/
│   ├── 3-task/
│   ├── 4-dev/
│   ├── 5-test/
│   ├── 6-review/
│   ├── 7-integration/
│   └── 8-rollback/
├── templates/
└── skills/
```

**Why:** `phases/` aligns with PRD naming; numeric prefixes for ordering; no subdirectory nesting within each phase directory.

---

### GO.md Routing

**Decision:** Exact match first, then fuzzy fallback with Levenshtein distance.

Behavior:
1. Exact match → route directly
2. No exact match → fuzzy search (Levenshtein ≤ 2 or substring match)
3. If fuzzy finds candidate → prompt "Did you mean `{closest}`? [y/n]"
4. If no match → show available commands + usage hint

**Why:** Exact-first prevents false positives; fuzzy fallback catches typos; confirmation prevents wrong command execution.

---

### Phase File Structure

**Decision:** Trigger/Behavior/Boundary format.

```markdown
# Phase X: {Name}

## 触发条件
{{TRIGGER}}

## 核心行为
{{CORE_BEHAVIOR}}

## 边界情况
{{BOUNDARY_CASES}}

## 输出物
{{OUTPUTS}}
```

**Why:** Trigger-first clarifies when to use the phase; boundary cases prevent misuse; outputs make success measurable.

---

### Template Placeholder Format

**Decision:** `{{PLACEHOLDER}}` — lowercase with double curly braces.

Standard placeholders:
- `{{PHASE_NAME}}`, `{{PHASE_NUMBER}}`
- `{{GOAL}}`, `{{TRIGGER}}`, `{{OUTPUTS}}`
- `{{STEPS}}`, `{{BOUNDARY_CASES}}`
- `{{TEMPLATE_VERSION}}`, `{{DATE}}`

**Why:** `{{}}` is visually distinct; lowercase is readable; matches common template conventions.

---

## Deferred Ideas

- **Phase naming conflict** — `phases/01-core-skeleton/` vs `phases/0-change/` share `phases/` namespace; consider renaming numeric-only phases to `phase-0-change/` for consistency (defer to Phase 2).

---

## Next Steps

1. Create directory structure per CORE-01
2. Write GO.md with routing logic
3. Write 8 phase files (0-change through 8-rollback) with Trigger/Behavior/Boundary structure
4. Write 8 template files with `{{placeholder}}` format
5. Write README.md with cost table and scenario decision tree