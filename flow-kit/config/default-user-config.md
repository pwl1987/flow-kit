--- BEGIN flow-kit/config/default-user-config.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】
> User can override via .flow-kit/user-config.md in project root
> Priority: Constitution > user-config > defaults

# Default User Configuration

## Configuration Priority

1. **Constitution** (highest) — Safety rules, cannot be overridden
2. **User Config** — `.flow-kit/user-config.md` in project root
3. **Default User Config** (lowest) — This file

## USER CONFIGURATION

### Workflow Settings

| Setting | Default | Description |
|---------|---------|-------------|
| default_phase | 1-requirement | Starting phase for new changes |
| parallel_tasks_max | 4 | Maximum parallel task execution |
| context_budget_warning | 70% | Warn when context reaches threshold |
| auto_checkpoint_threshold | 5 file changes | Trigger checkpoint after N changes |
| auto_mode | false | Enable YOLO auto-approval mode |

### Model Preferences

| Setting | Default | Description |
|---------|---------|-------------|
| executor_model | claude-sonnet-4-20250501 | Model for task execution |
| planner_model | claude-opus-4-20250501 | Model for planning |
|Haiku_subagent | claude-haiku-4-20250501 | Model for read-only exploration |

### Team Settings

| Setting | Default | Description |
|---------|---------|-------------|
| review_required | true | Require review before commit |
| min_reviewers | 1 | Minimum reviewers for merge |
| commit_style | conventional | Commit message format |
| branch_prefix | feat/ | Branch naming prefix |
| pr_template | default | PR template to use |

### Linting & Quality

| Setting | Default | Description |
|---------|---------|-------------|
| lint_on_save | true | Run linter on file save |
| lint_tools | [eslint, prettier] | Enabled linting tools |
| auto_fix | true | Auto-fix linting issues |
| typecheck | true | Run type checking |
| test_on_commit | true | Run tests before commit |

### Verification Strictness

| Setting | Default | Description |
|---------|---------|-------------|
| verify_commits | true | Always verify before commit |
| verify_deploy | true | Verify before deployment |
| strict_mode | false | Enable strict type checking |
| fail_on_warn | false | Treat warnings as errors |

## Override Mechanism

### Creating User Config

1. Create `.flow-kit/user-config.md` in project root
2. Copy sections to override from default-user-config.md
3. Modify values as needed

### Merge Rules

- **Constitution wins always** — Safety rules cannot be overridden
- **User-config wins on conflict** — Non-safety settings can be customized
- **Unspecified settings use defaults** — Only override what you need

### Example user-config.md

```markdown
--- BEGIN .flow-kit/user-config.md ---
> Override specific settings only

## Workflow Settings
| Setting | Value |
|---------|-------|
| parallel_tasks_max | 8 |
| auto_mode | true |

## Team Settings
| Setting | Value |
|---------|-------|
| min_reviewers | 2 |
--- END .flow-kit/user-config.md ---
```

## Reference

- Constitution: `@flow-kit/config/constitution.md`
- User Config: `.flow-kit/user-config.md`
- This file: `@flow-kit/config/default-user-config.md`

--- END flow-kit/config/default-user-config.md ---
