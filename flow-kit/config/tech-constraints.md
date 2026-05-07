> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件定义技术栈约束规范。
> D4-5: Technology Stack Constraints
> Safety Floor Reference: constitution.md 始终不可覆盖

# Technology Stack Constraints

## TEAM-01: Technology Stack Constraints

### Language Constraints

| Language | Allowed | Notes |
|----------|---------|-------|
| TypeScript | Yes | Primary for flow-kit |
| Python | Yes | Data/ML workflows |
| Go | Yes | Infrastructure tooling |
| Java | Yes | Enterprise integrations |
| Rust | Yes | Performance-critical components |
| PHP | Yes | Legacy system support |
| Bash | Yes | Shell scripting and automation |
| Markdown | Yes | Documentation only |

### Framework Constraints

**Frontend**

| Framework | Allowed | Notes |
|-----------|---------|-------|
| React | Yes | UI component library |
| Vue | Yes | Alternative UI framework |
| Next.js | Yes | Full-stack React framework |
| Svelte | Yes | Lightweight alternative |
| Astro | Yes | Content-focused framework |
| Nuxt | Yes | Vue full-stack framework |

**Backend**

| Framework | Allowed | Notes |
|-----------|---------|-------|
| Express | Yes | Node.js web framework |
| FastAPI | Yes | Python async API framework |
| Spring | Yes | Java enterprise framework |
| Gin | Yes | Go web framework |
| Django | Yes | Python full-stack framework |
| Rails | Yes | Ruby full-stack framework |
| Laravel | Yes | PHP framework |

### Toolchain Constraints

**Build Tools**

| Tool | Allowed | Notes |
|------|---------|-------|
| npm | Yes | Node.js package manager |
| pnpm | Yes | Preferred - faster, more efficient |
| yarn | Yes | Alternative Node.js package manager |
| go mod | Yes | Go module management |
| maven | Yes | Java build tool |
| gradle | Yes | Java/Kotlin build tool |
| cargo | Yes | Rust package manager |
| composer | Yes | PHP package manager |

**Task Runners**

| Tool | Allowed | Notes |
|------|---------|-------|
| make | Yes | Classic build automation |
| just | Yes | Modern make alternative |
| task | Yes | Go-based task runner |
| nx | Yes | Monorepo tooling |
| turbo | Yes | Next-gen monorepo |

**Testing**

| Tool | Allowed | Notes |
|------|---------|-------|
| jest | Yes | JavaScript/TypeScript testing |
| vitest | Yes | Vite-native test runner |
| pytest | Yes | Python testing framework |
| go test | Yes | Go testing framework |
| cargo test | Yes | Rust testing framework |

### External Dependencies

| Dependency | Allowed | Notes |
|------------|---------|-------|
| jose | Yes | JWT handling (TypeScript) |
| zod | Yes | Schema validation |
| prisma | Yes | Database ORM |
| sqlx | Yes | Rust database toolkit |
| axios | Yes | HTTP client |

### Constraint Enforcement

1. **New language addition**: Requires architect approval + TEAM-01 update
2. **New framework addition**: Requires reviewer approval + TEAM-01 update
3. **New toolchain addition**: Requires ops approval + documentation
4. **External dependency approval**: Requires security review for production use

### Constitution Reference

TEAM-01 constraints are enforced as safety rules:
- TECH-01: Technology stack constraints defined in this external reference
- TECH-02: Role definitions for architect/reviewer/ops in external reference

All constraints are immutable safety floor extensions. Violations result in immediate halt per Constitution rules.

---

**关联文件**：
- `@flow-kit/config/constitution.md` (安全基础)
- `@flow-kit/config/team-roles.md` (角色定义)
