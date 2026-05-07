# Phase 12: Rollback Workflow - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-07
**Phase:** 12-Rollback Workflow
**Areas discussed:** 回滚粒度与触发条件, 回滚深度与目标状态, 回滚安全护栏, 回滚后处理流程

---

## Area 1: 回滚粒度与触发条件

| Option | Description | Selected |
|--------|-------------|----------|
| 仅 Git 提交 | revert commit 记录，保留生成文件（轻量，适合已验证的文件变更） | |
| 仅生成文件 | 删除/标记废弃文件，保留 commit 历史（适合文件结构变更） | |
| 两者兼有 | 完整状态回滚 — commit + 文件（最彻底，操作最重） | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| 仅手动 | 用户显式调用命令才触发（安全优先） | |
| 手动 + 自动 | 手动触发为主，下游验证失败时可自动触发（平衡） | |
| 手动 + 自动 + 监控 | 全量触发条件（最灵活但复杂度最高） | ✓ |

**User's choice:** 两者兼有 + 手动+自动+监控
**Notes:** 用户选择最完整的粒度和最灵活的触发方式

---

## Area 2: 回滚深度与目标状态

| Option | Description | Selected |
|--------|-------------|----------|
| 仅最近一次 | 只能回滚到上一个已执行阶段的状态（最简单） | |
| 任意历史状态 | 可选择任意历史稳定点（需要状态索引，灵活但复杂） | |
| 仅已标记的稳定点 | 仅回滚到显式标记为「可回滚点」的稳定状态（需预先标记机制） | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| 执行器自动标记 | 每个阶段执行完成时自动标记为稳定点（省心，但可能标记未验证状态） | |
| 用户手动标记 | 人工决定何时是稳定状态（更安全，但增加用户负担） | |
| 混合模式 | 执行器自动标记为主 + 用户可升級/降级（平衡） | ✓ |

**User's choice:** 仅已标记的稳定点 + 混合模式
**Notes:** 执行器自动标记，用户可调整

---

## Area 3: 回滚安全护栏

| Option | Description | Selected |
|--------|-------------|----------|
| 全启用（确认+备份+警告+预览） | 最安全，但流程较重 | ✓ |
| 确认+备份+警告（无预览） | 平衡安全和效率 | |
| 确认+备份（无警告+预览） | 精简流程，保留核心保护 | |

**User's choice:** 全启用 + --force 跳过机制
**Notes:** 用户要求完整安全措施但需保留 --force 跳过能力

---

## Area 4: 回滚后处理流程

| Option | Description | Selected |
|--------|-------------|----------|
| LESSONS 记录 + 重新修复 | 记录教训后进入诊断修复流程 | |
| LESSONS 记录 + 废弃 | 记录教训后标记变更废弃，退出流程 | |
| LESSONS 记录 + 用户选择 | 记录教训后由用户决定（重新修复/废弃/其他） | ✓ |

**User's choice:** LESSONS 记录 + 用户选择

---

## Deferred Ideas

None — discussion stayed within phase scope.
