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
| ROLE-01 | Role definitions for architect/reviewer/ops in external reference | team |

> **All role-based approvals must respect the BEHAVIORAL PRINCIPLES** — if a design violates "Simplicity First", the architect must reject it.

### External References

- `flow-kit/config/tech-constraints.md` — Language, framework, and toolchain constraints
- `flow-kit/config/team-roles.md` — Architect/Reviewer/Ops role definitions

> 【CLAUDE CODE INSTRUCTION 强制约束·规则链】
> 本文件定义最高原则。所有可执行规则定义在 @flow-kit/config/system-rules.md 中。
> 两者为互补关系：constitution = 原则（WHAT），system-rules = 规则（HOW）。
> 任何代理在执行前必须确认已加载 system-rules.md 中的 R1-R8。
> 若 system-rules.md 中的规则与本文件中的原则冲突，以 system-rules.md 为准（可执行规则优先于原则声明）。

## BEHAVIORAL PRINCIPLES（最高优先级）

> **Unoverridable** — 本章节优先级高于其他所有规则

All agents, sub‑agents, and review processes MUST adhere to the following four principles at all times. No other rule, instruction, or optimization may override them.

### BP-01: Think Before Coding
首先理解问题域，再探索方案，最后才实现

### BP-02: Simplicity First
每增加一个抽象必须证明其必要性，只记录必要的依赖信息

### BP-03: Surgical Changes
最小变更集，只改必要的，零顺手修改

### BP-04: Goal-Driven Execution
结果导向而非活动导向，不是任务列表走完，是目标达成

## Priority Statement

Constitution rules CANNOT be overridden by:
- `.flow-kit/user-config.md`
- `flow-kit/config/default-user-config.md`
- Any other configuration file

User-config MAY override non-safety settings in default-user-config.md, but Constitution safety rules remain enforced regardless.

--- END flow-kit/config/constitution.md ---
