> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件实现 P0 审批工作流。
> D4-8: P0 Approval Workflow

# P0 Approval Workflow

## P0 定义

P0 变更 = ** irreversible destructive operations**（不可逆的破坏性操作）

具体包括：
- Breaking changes to external contracts（破坏性变更）
- Database schema changes (DDL/DML)（数据库结构变更）
- 任何可能导致永久性数据丢失的操作

## 触发条件

### 自动检测

当变更涉及以下文件时自动触发 P0：
- `BREAKING-CHANGE.md` 文件存在
- `*.sql` 文件（DDL/DML）
- `migration/` 目录下的文件

### 手动触发

```bash
/flow-kit:p0
```

强制将当前变更标记为 P0

## 审批流程

### 1. P0 检测

```
[Phase Executor] Checking P0 conditions...
[P0] Breaking change detected: {reason}
Files: {affected_files}
```

### 2. 阻止阶段

**Phase 7 (Integration) 之前阻止**

```
[P0 BLOCK] High-risk change detected
Reason: {auto-detected | manual-flag}
Files: {affected_files}

This change requires approval from Admin or Reviewer before proceeding.
Approve? (yes/no)
```

### 3. 审批判断

| 输入 | 行为 |
|------|------|
| `yes` / `y` | 记录审批，继续执行 |
| `no` / `n` | 阻止变更，要求修改 |
| 其他 | 提示正确格式 |

### 4. 审批日志

```
[P0 APPROVAL LOG]
Timestamp: {YYYY-MM-DD HH:mm:ss}
Approver: {user_id}
Role: {admin | reviewer}
Reason: {original_p0_reason}
Decision: APPROVED
```

### 5. Auto-generate Approval File

Upon decision:
1. Create `.flow-kit/approvals/` directory if not exists
2. Generate `{YYYYMMDD-HHMMSS}-P0-{change_id}.md` from template
3. Fill in all fields automatically
4. Log generation in output

Approval file format: see `flow-kit/templates/approval/approval-template.md`

## 权限要求

只有以下角色可以审批 P0：
- `admin`
- `reviewer`

`developer` 和 `viewer` 角色无法审批 P0

## 关键保证

1. **Minimal Mode 不可绕过**：即使处于 Minimal Mode（跳过 Phase 5/6），P0 审批仍然执行
2. **审批必须明确**：不接受隐式批准
3. **日志可追溯**：所有 P0 决策记录在案

## 集成点

### Phase Executor 集成

在 `flow-kit/lib/phase-executor.sh` 中：
- Phase 7 执行前检查 P0 状态
- 若 P0 未批准，阻止执行
- 批准后清除 P0 状态

### Constitution 引用

P0 定义基于 constitution.md 中的安全规则：
- SEC/DATA/DEPLOY/GIT 相关操作优先检查
- 审批人需具备相应权限

---

**关联文件**：
- `@flow-kit/lib/phase-executor.sh` (阶段执行器)
- `@flow-kit/config/constitution.md` (安全规则)
- `@flow-kit/config/team-roles.md` (角色权限)