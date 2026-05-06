> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 Brownfield 项目（已有仓库）Guardrail 索引，定义 B1-B6 护栏激活条件与路由规则。
> 所有护栏文件遵循 Trigger/Behavior/Boundary/Output 标准格式。

# Brownfield Guardrails (B1-B6)

## 触发条件

### 手动激活
- 命令：`/flow-kit:guardrails` 或 `@flow-kit/guardrails`
- 场景：用户显式请求护栏检查

### 自动检测
- `.git/` 目录存在（已有仓库）
- 包管理器文件共存：`package.json` + `package-lock.json` / `yarn.lock` / `pnpm-lock.yaml`
- 多语言共存：`requirements.txt` + `Pipfile` / `pyproject.toml`
- 混合技术栈检测：同时存在 `Gemfile` + `Podfile` 等

## 核心行为

### B1: Breaking Change Classification
**文件**：`@flow-kit/guardrails/breaking-change.md`

变更影响范围识别与 P0/P1/P2 分类。

### B2: Database Safety
**文件**：`@flow-kit/guardrails/database-guardrails.md`

DDL/DML 操作安全审查。

### B3: Security Checklist
**文件**：`@flow-kit/guardrails/security-checklist.md`

安全检查清单验证。

### B4: UI Vocabulary Alignment
**文件**：`@flow-kit/guardrails/ui-guardrails.md`

视觉词汇一致性检查。

### B5: Performance Guardrail
**文件**：（待定义）

### B6: Testing Coverage Gate
**文件**：（待定义）

## 边界情况

### P0 快速通道
- **定义**：紧急变更需要立即执行
- **触发**：用户明确标记 `P0` 或 `EMERGENCY`
- **行为**：先执行后审查，触发 B1-B4 后置检查
- **要求**：执行后必须补充变更记录

### 未分类变更
- 检测到不在 B1-B4 范围内的变更时，降级为标准变更流程
- 记录为 `B0: Unclassified`

## 输出物

```
Guardrail Activation Report
============================
Project Type: Brownfield
Guardrails Active: B1, B2, B3, B4
Auto-detected: [.git/, package.json, package-lock.json]

Classification: [P0/P1/P2]
Database Impact: [None/Low/Medium/High]
Security Review: [Required/Skipped]
UI Changes: [Yes/No]
```

---

**关联文件**：
- `@flow-kit/guardrails/breaking-change.md` (B1)
- `@flow-kit/guardrails/database-guardrails.md` (B2)
- `@flow-kit/guardrails/security-checklist.md` (B3)
- `@flow-kit/guardrails/ui-guardrails.md` (B4)
