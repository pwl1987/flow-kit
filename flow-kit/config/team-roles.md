> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件定义团队角色权限边界。
> D4-5: Team Role Definitions
> Safety Floor Reference: constitution.md 始终不可覆盖

# Team Roles

## TEAM-01: Role Definitions

### Architect

- **Purpose**: Technology decisions and architecture
- **Capabilities**:
  - Approve P0 changes
  - Define tech stack constraints
  - Review architecture decisions
  - Add or modify TEAM-01 technology constraints
- **Constraints**:
  - Cannot override Constitution safety rules (SEC/DATA/DEPLOY/GIT)
  - All decisions subject to reviewer concurrence for P1+

### Reviewer

- **Purpose**: Code and design review
- **Capabilities**:
  - Approve P0 changes
  - Review all changes
  - Approve deployments
  - Request changes before approval
- **Constraints**:
  - Cannot override Constitution safety rules
  - Must maintain review documentation

### Ops

- **Purpose**: Operations and deployment
- **Capabilities**:
  - Execute deployments
  - Manage configurations
  - Monitor health
  - Approve toolchain changes
  - Manage CI/CD pipeline
- **Constraints**:
  - Cannot deploy without reviewer approval
  - Cannot override Constitution safety rules

## Permission Boundary Statement

```
Constitution.md remains the immutable safety floor.
Roles define workflow permissions only.
No role can override SEC/DATA/DEPLOY/GIT rules.
```

## Role Validation Rules

1. **Unknown role rejection**: Config loading识别未知角色并拒绝
2. **Default fallback**: 未指定角色时默认使用 `viewer`
3. **Role list**: `architect`, `reviewer`, `ops`, `viewer`

## Constitution Reference

Constitution.md 作为安全基础：
- SEC/DATA/DEPLOY/GIT 规则不可绕过
- 角色权限是附加的，不修改安全规则
- 所有角色都必须遵守安全规则

---

**关联文件**：
- `@flow-kit/config/constitution.md` (安全基础)
- `@flow-kit/config/tech-constraints.md` (技术栈约束)
