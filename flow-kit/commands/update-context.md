--- BEGIN flow-kit/commands/update-context.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】

## 优先级加载（任何逻辑不得违反）

1. **立即加载** `@flow-kit/config/constitution.md`（全局最高优先级）
2. **立即加载** `@flow-kit/config/default-user-config.md`，若存在 `.flow-kit/user-config.md` 则优先加载用户自定义配置
3. 后续所有逻辑必须遵守这两份配置

---

# Update Context

## Command

`/flow-kit:update-context`

## Purpose

Incrementally update `.planning/CONTEXT.md` with new decisions, blockers, state changes, and progress. Preserve existing locked decisions and structure.

## Input

1. **Current phase** — which phase is active
2. **What changed** — decisions made, blockers encountered, state transitions
3. **Timestamp** — when the change occurred

## Execution

### 1. Read Existing Context

Load `.planning/CONTEXT.md` if exists. If not found, use standard template:

```markdown
# Context

## Decisions

| ID | Decision | Rationale | Date |
|----|----------|-----------|------|
| [LOCKED] | ... | ... | ... |

## Blockers

| Blocker | Status | Since |
|---------|--------|-------|
| ... | open/resolved | ... |

## State

**Phase**: [current]
**Last Updated**: [timestamp]

## Change Log

| Date | Change | Phase |
|------|--------|-------|
```

### 2. Merge New Information

**Decisions**: Append new decisions with auto-increment ID. Preserve existing (locked).

**Blockers**:
- Update status: `open` → `resolved` when resolved
- Add new blockers with `open` status
- Never delete blocker history

**State Changes**:
- Update current phase
- Record last updated timestamp
- Note transition triggers

### 3. Structured Insertion

Add entries to appropriate sections:

**Decisions section**:
```markdown
| [next-id] | [decision text] | [rationale] | [timestamp] |
```

**Blockers section**:
```markdown
| [blocker description] | open | [timestamp] |
```

**Change log section**:
```markdown
| [timestamp] | [description of what changed] | [phase] |
```

### 4. Preserve Locked Decisions

Entries marked `[LOCKED]` or in locked sections must not be modified. Skip them during merge.

### 5. Write Back

Write updated content to `.planning/CONTEXT.md`.

## Output

```
## Context Updated

**File**: .planning/CONTEXT.md

| Section | Changes |
|---------|---------|
| Decisions | +3 new |
| Blockers | +1 new, -0 resolved |
| State | Phase 02 → Phase 02 (continued) |

**Last Updated**: [timestamp]
```

## Rules

1. **Never lose information** — append only, never delete history
2. **Lock protection** — `[LOCKED]` marked entries immutable
3. **Traceability** — every change links to a phase
4. **Timestamp accuracy** — use ISO 8601 format

## Usage

```bash
@flow-kit/commands/update-context.md
```

--- END flow-kit/commands/update-context.md ---