> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件定义团队角色权限边界。
> D4-5: Team Role Definitions
> Safety Floor Reference: constitution.md 始终不可覆盖

# Team Roles

## 角色定义

### admin

| 权限 | 说明 |
|------|------|
| 命令执行 | 全部 flow-kit 命令 |
| 配置管理 | 可修改团队配置 |
| 配置同步 | 可同步分发团队配置 |
| 限制 | 不得覆盖 Constitution 安全规则 |

### reviewer

| 权限 | 说明 |
|------|------|
| 命令执行 | 审查相关命令 |
| 审批操作 | 可批准/拒绝变更 |
| 限制 | 不得修改核心配置 |
| 约束 | 必须遵守 Constitution 安全规则 |

### developer

| 权限 | 说明 |
|------|------|
| 命令执行 | 开发流程命令 |
| 版本控制 | 在限定范围内提交和推送 |
| 限制 | 不得修改团队配置 |
| 约束 | 必须遵守 Constitution 安全规则 |

### viewer

| 权限 | 说明 |
|------|------|
| 命令执行 | 无（只读） |
| 查看内容 | 可查看阶段摘要和状态 |
| 限制 | 不得执行工作流命令 |
| 约束 | 不得修改任何配置 |

## 权限边界声明

```
Constitution.md remains the immutable safety floor.
Roles define workflow permissions only.
No role can override SEC/DATA/DEPLOY/GIT rules.
```

## 角色验证规则

1. **未知角色拒绝**：加载配置时识别未知角色并拒绝
2. **默认回退**：未指定角色时默认使用 `viewer`
3. **角色列表**：`admin`, `reviewer`, `developer`, `viewer`

## Constitution 引用

Constitution.md 作为安全基础：
- SEC/DATA/DEPLOY/GIT 规则不可绕过
- 角色权限是附加的，不修改安全规则
- 所有角色都必须遵守安全规则

---

**关联文件**：
- `@flow-kit/config/constitution.md` (安全基础)
- `@flow-kit/commands/sync-team-config.md` (配置同步)