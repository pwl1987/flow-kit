--- BEGIN flow-kit/mcp/git-integration.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】

## 优先级

本文件定义 Git 安全包装规则。所有 git 操作必须通过 MCP 适配器执行。

---

# Git Integration (MCP-51)

## Purpose

Safely wrap git operations via MCP adapter. Prevent accidental destructive actions.

## Safety Rules

### Prohibited Operations

| Operation | Reason | Alternative |
|-----------|--------|-------------|
| `git push -f` | Destroys remote history | `git push` with branch check |
| `git push` to main/master | Bypasses review | Create feature branch |
| `git reset --hard` | Destroys uncommitted work | `git reset --soft` or `git stash` |
| `git rebase` without approval | Rewrites history | Merge instead |
| `git clean -fdx` | Permanently deletes untracked | Manual review required |

### Required Pre-conditions

- **Branch exists before modification:** Always create branch before commit/push
- **Commit message format enforced:** See format below
- **Working tree clean or staged:** No uncommitted changes without explicit approval

## Operations Wrapped

### Safe Operations (No Confirmation)

```
git status
git log
git diff
git show
git branch (list only)
git checkout (read-only branches)
```

### Confirmation Required

```
git commit     - Format check required
git push       - Branch name validation
git stash      - Warns about untracked files
git revert     - Allowed in emergencies
```

### Blocked Without Explicit Approval

```
git reset (any form)
git rebase
git push --force
git push to protected branches
git checkout -B (force branch creation)
```

## Commit Message Format

```
{type}({phase}-{plan}): {concise description}

- {change 1}
- {change 2}
```

### Valid Types

| Type | Use When |
|------|----------|
| `feat` | New feature, endpoint, component |
| `fix` | Bug fix, error correction |
| `test` | Test-only changes (TDD RED phase) |
| `refactor` | Code cleanup, no behavior change |
| `perf` | Performance improvement |
| `docs` | Documentation only |
| `style` | Formatting, whitespace |
| `chore` | Config, tooling, dependencies |

## Branch Naming Conventions

```
worktree-agent-{id}     # Claude Code worktree agents
feature/{description}   # Feature branches
fix/{description}       # Bug fix branches
hotfix/{description}    # Emergency fixes
```

**Protected branches:** `main`, `master`, `develop`, `trunk`, `release/*`

## Emergency Rollback

`git revert` is **always allowed** in emergencies — does not require approval.

---

## Key Links

- **MCP tools config:** `flow-kit/mcp/mcp-tools-config.md` (tier definitions)
- **Lint adapter:** `flow-kit/mcp/external-lint-adapter.md` (post-commit validation)
- **Constitution:** `flow-kit/config/constitution.md` (project-level git rules)

--- END flow-kit/mcp/git-integration.md ---