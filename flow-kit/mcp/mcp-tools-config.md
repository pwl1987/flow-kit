--- BEGIN flow-kit/mcp/mcp-tools-config.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】

## 优先级

本文件定义 MCP 工具分层体系。所有 MCP 操作必须遵守 tier 边界约束。

---

# MCP Tools Configuration (MCP-50)

## Tier Structure

MCP tools are tiered by destructiveness level, mirroring Claude Code permission model:

| Tier | Level | Description | Confirmation |
|------|-------|-------------|--------------|
| **core** | Read-only | Non-destructive operations, always safe | None required |
| **standard** | Local mutations | File writes, local operations | Confirmation required |
| **all** | Full execution | Destructive operations (delete, drop, truncate) | Explicit opt-in |

## Tier Definitions

### Core Tier (Read-only, Always Safe)

```
Read, Glob, Grep, WebSearch, WebFetch
```

Core tools perform read-only operations. No modification, no execution risk.

### Standard Tier (Local Mutations, Confirmation Required)

```
Write, Edit, Bash (local only)
```

Standard tools modify files locally. Require user confirmation before execution.

### All Tier (Full Execution, Explicit Opt-in)

```
Bash (full), Agent, Task, TodoWrite, Read (all files)
```

All tier includes destructive operations. Must be explicitly enabled per-project.

## Constitution Override Mechanism

Project-specific `flow-kit/config/constitution.md` can adjust tier boundaries.

### Override Examples

**Add Write to temp to core tier:**
```markdown
## Tier Overrides
- core: includes Write (to /tmp only)
```

**Restrict standard tier:**
```markdown
## Tier Restrictions
- standard: excludes Bash
```

### Override Precedence

1. `flow-kit/config/constitution.md` (project-level, highest priority)
2. `.flow-kit/user-config.md` (user-level)
3. This file (default)

## Tool List Reference

Full tool list: See `flow-kit/guardrails/GU.md`

---

## Key Links

- **Constitution override:** `flow-kit/config/constitution.md` (tier boundary adjustments)
- **Tool reference:** `flow-kit/guardrails/GU.md` (complete tool list)
- **Related MCP files:**
  - `flow-kit/mcp/git-integration.md` (git safety wrapping, MCP-51)
  - `flow-kit/mcp/external-lint-adapter.md` (external lint adapter, MCP-52)

--- END flow-kit/mcp/mcp-tools-config.md ---