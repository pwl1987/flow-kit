--- BEGIN flow-kit/config/constitution.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】
> SAFETY FLOOR — THIS FILE CANNOT BE OVERRIDDEN BY USER CONFIG OR DEFAULTS
> Priority: HIGHEST (loaded first, enforced last)

# Constitution.md — Safety Floor

## UNOVERRIDABLE RULES

These rules CANNOT be overridden by user-config or any other configuration. Violation results in immediate halt.

### Security

| Rule | Description | Category |
|------|-------------|----------|
| SEC-01 | Never commit secrets, credentials, API keys, or tokens to repository | security |
| SEC-02 | Always validate external input before processing | security |
| SEC-03 | Never disable security checks for convenience | security |
| SEC-04 | Never expose sensitive data in logs or output | security |
| SEC-05 | Always use parameterized queries, never string concatenation for SQL | security |

### Data Integrity

| Rule | Description | Category |
|------|-------------|----------|
| DATA-01 | Never delete data without backup confirmation | data |
| DATA-02 | Always use transactions for multi-step database changes | data |
| DATA-03 | Verify delete impact before execution | data |
| DATA-04 | Never truncate tables without explicit confirmation | data |
| DATA-05 | Always verify foreign key relationships before cascade operations | data |

### Deployment

| Rule | Description | Category |
|------|-------------|----------|
| DEPLOY-01 | Never deploy without rollback plan | deployment |
| DEPLOY-02 | Production credentials never in code | deployment |
| DEPLOY-03 | Deployment requires review approval | deployment |
| DEPLOY-04 | Never skip CI/CD safety gates | deployment |
| DEPLOY-05 | Always verify environment before production deployment | deployment |

### Git Safety

| Rule | Description | Category |
|------|-------------|----------|
| GIT-01 | Never use `git commit --no-verify` | git |
| GIT-02 | Never force-push to shared branches without explicit confirmation | git |
| GIT-03 | Always run verification before commit | git |
| GIT-04 | Never amend commits that have been pushed | git |
| GIT-05 | Always provide meaningful commit messages | git |

### Technology Stack

| Rule | Description | Category |
|------|-------------|----------|
| TECH-01 | Technology stack constraints defined in external reference | tech |
| TECH-02 | Role definitions for architect/reviewer/ops in external reference | team |

### External References

- `flow-kit/config/tech-constraints.md` — Language, framework, and toolchain constraints
- `flow-kit/config/team-roles.md` — Architect/Reviewer/Ops role definitions

## Priority Statement

Constitution rules CANNOT be overridden by:
- `.flow-kit/user-config.md`
- `flow-kit/config/default-user-config.md`
- Any other configuration file

User-config MAY override non-safety settings in default-user-config.md, but Constitution safety rules remain enforced regardless.

--- END flow-kit/config/constitution.md ---
