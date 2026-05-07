# Phase 12: Rollback Workflow - Context

**Gathered:** 2026-05-07
**Status:** Ready for planning

<domain>
## Phase Boundary

实现 flow-kit 的回滚工作流，为已执行的阶段提供完整的回滚能力。包括回滚粒度（commit + 文件）、多模式触发（手动+自动+监控）、稳定点标记机制、安全护栏和回滚后处理流程。

**Canonical refs:** `flow-kit/phases/8-rollback/8-rollback.md`（已有占位框架）

</domain>

<decisions>
## Implementation Decisions

### 回滚粒度（D-RB-01）

- **D-RB-01:** 回滚粒度 = 两者兼有（Git commit + 生成文件）
  - 回滚时同时 revert commit 记录并清理/标记生成文件
  - 完整状态回滚保证一致性

### 触发方式（D-RB-02）

- **D-RB-02:** 触发方式 = 手动 + 自动 + 监控
  - 手动：`/flow-kit:rollback` 命令显式触发
  - 自动：下游阶段验证失败且满足自动回滚条件
  - 监控：外部监控系统检测到异常指标（如错误率飙升）

### 回滚深度（D-RB-03~04）

- **D-RB-03:** 回滚深度 = 仅已标记的稳定点
  - 不支持任意历史回滚，仅可回滚到显式标记为「稳定点」的状态
  - 需要预先建立稳定点标记机制
- **D-RB-04:** 稳定点标记 = 混合模式
  - 执行器自动标记为主（每个阶段执行完成时自动标记）
  - 用户可升級/降级标记（用户可调整哪些点是稳定点）

### 安全护栏（D-RB-05）

- **D-RB-05:** 安全护栏 = 全启用 + `--force` 跳过机制
  - 确认提示：回滚前必须用户确认
  - 备份机制：回滚前自动创建备份 branch/tag
  - 不可逆警告：明确告知操作不可逆
  - 影响范围预览：回滚前显示将被影响的文件列表
  - `--force` 跳过所有护栏（谨慎使用）

### 回滚后处理（D-RB-06）

- **D-RB-06:** 回滚后处理 = LESSONS 记录 + 用户选择
  - 回滚完成后自动将回滚原因和教训写入 `.specs/LESSONS.md`
  - 由用户选择后续路径：重新修复 / 废弃 / 其他

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Rollback Framework
- `flow-kit/phases/8-rollback/8-rollback.md` — 已有占位框架（Phase 8 建立的四章节结构：触发条件/核心行为/边界情况/输出物）

### Phase Executor
- `flow-kit/lib/phase-executor.md` — 阶段执行器（7个集成点，需新增回滚集成点）

### LESSONS System
- `.specs/LESSONS.md` — Phase 10 建立的教训记录系统（回滚后写入目标）
- `flow-kit/templates/LESSONS.md.template` — LESSONS.md 模板

### Related Phases
- `.planning/phases/10-Core-Process/10-CONTEXT.md` — LESSONS.md 路径和匹配机制决策
- `.planning/phases/11-Templates/11-CONTEXT.md` — 混合模式决策参考

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `flow-kit/phases/8-rollback/8-rollback.md` 四章节骨架 — 已有模板结构，只需填充内容
- Phase 10 的 `.specs/LESSONS.md` 写入机制 — 可复用 LESSONS 追加逻辑

### Established Patterns
- 四章节模板结构（触发条件/核心行为/边界情况/输出物）— Phase 8 建立的标准
- 混合标记模式 — 参考 Phase 11 的混合模式决策

### Integration Points
- `flow-kit/lib/phase-executor.md` — 新增回滚集成点（当前7个 → 8个）
- `flow-kit/commands/` — 新增 `/flow-kit:rollback` 命令
- `.specs/LESSONS.md` — 回滚后教训写入目标

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 12-Rollback Workflow*
*Context gathered: 2026-05-07*
