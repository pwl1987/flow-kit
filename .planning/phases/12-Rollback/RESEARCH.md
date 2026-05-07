# Phase 12: Rollback Workflow - Research

**Researched:** 2026/05/07
**Domain:** 回滚工作流实现 / phase-executor 集成
**Confidence:** HIGH

## Summary

Phase 12 实现 flow-kit 的回滚工作流，依赖已建立的四章节模板结构（8-rollback.md）、8个集成点的 executor 机制（phase-executor.md）、以及 LESSONS 教训记录系统（Phase 10 建立）。核心任务是新增第9个集成点、创建 `/flow-kit:rollback` 命令、完善稳定点标记机制。

**Primary recommendation:** 利用现有四章节模板填充内容，新增 executor 集成点 + 命令文件，稳定点标记复用 Phase 11 混合模式决策。

---

## User Constraints (from 12-CONTEXT.md)

### Locked Decisions

- **D-RB-01:** 回滚粒度 = Git commit + 生成文件（两者兼有）
- **D-RB-02:** 触发方式 = 手动 + 自动 + 监控（三模式并存）
- **D-RB-03:** 回滚深度 = 仅已标记的稳定点（不支持任意历史回滚）
- **D-RB-04:** 稳定点标记 = 混合模式（自动为主 + 用户可调整）
- **D-RB-05:** 安全护栏 = 全启用 + `--force` 跳过机制
- **D-RB-06:** 回滚后处理 = LESSONS 记录 + 用户选择后续路径

### Claude's Discretion

- 回滚报告格式细节
- 自动触发条件阈值配置
- 监控集成具体实现方式

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| 回滚命令解析 | API/Backend | — | `/flow-kit:rollback` 是 CLI 命令 |
| 稳定点标记管理 | API/Backend | — | 状态存储在 `.planning/` 目录 |
| Git revert 执行 | API/Backend | — | 涉及 git 操作，属后端逻辑 |
| 生成文件清理/标记 | API/Backend | — | 文件系统操作，后端处理 |
| LESSONS.md 追加 | API/Backend | — | 写入 `.specs/LESSONS.md` |
| 安全护栏确认 | API/Backend | Frontend Server | 用户交互在 CLI 层 |
| 监控触发 | External | — | 外部监控系统 |

**结论：** 回滚逻辑主要属 API/Backend 层，CLI 命令是入口点。

---

## Standard Stack

### Core Files (Existing)

| File | Purpose | Why Standard |
|------|---------|--------------|
| `flow-kit/phases/8-rollback/8-rollback.md` | 四章节模板 | Phase 8 建立的标准结构 |
| `flow-kit/lib/phase-executor.md` | 阶段执行器 + 集成点 | 已有8个集成点，回滚是第9个 |
| `.specs/LESSONS.md` | 教训记录目标 | Phase 10 建立，写入格式已定 |
| `flow-kit/templates/LESSONS.md.template` | LESSONS 模板 | Phase 10 确定格式 |

### New Files to Create

| File | Purpose | Format |
|------|---------|--------|
| `flow-kit/commands/rollback.md` | `/flow-kit:rollback` 命令规格 | 四章节结构 |
| `flow-kit/phases/8-rollback/8-rollback.md` (填充后) | 回滚阶段完整定义 | 四章节结构 |

---

## Architecture Patterns

### System Architecture Diagram

```
User/监控系统
      │
      ▼
┌─────────────────────────────────────────────────────┐
│              /flow-kit:rollback 命令                │
│  - 解析参数（phase、--force等）                      │
│  - 调用安全护栏确认                                  │
└────────────────────┬────────────────────────────────┘
                   │
      ┌────────────┴────────────┐
      ▼                         ▼
[稳定点检查]              [备份创建]
  │ 验证目标                   │ 创建 backup branch/tag
  │ 是否为稳定点               │
      │                         │
      └────────────┬────────────┘
                   ▼
         ┌─────────────────┐
         │   执行回滚       │
         │ Git revert      │
         │ 文件清理/标记    │
         └────────┬────────┘
                  │
      ┌───────────┴───────────┐
      ▼                       ▼
[写入 LESSONS.md]      [更新状态]
  回滚原因 + 教训        标记 phase 状态
      │                       │
      └───────────┬───────────┘
                  ▼
         [用户选择后续路径]
           重新修复/废弃/其他
```

### 8-Rollback.md 四章节填充方案

**触发条件章节：**
```markdown
## 触发条件

### 手动触发
- 用户执行 `/flow-kit:rollback {phase}` 命令
- 需要确认：影响范围预览、不可逆警告

### 自动触发
- 下游阶段验证失败且满足自动回滚条件
- 条件阈值由配置决定

### 监控触发
- 外部监控系统检测到异常指标（如错误率飙升）
- 通过 webhook 或 CLI 调用触发
```

**核心行为章节：**
```markdown
## 核心行为

1. **稳定点验证**：检查目标 phase 是否为稳定点
2. **安全护栏检查**：
   - 确认提示（除非 --force）
   - 备份创建（backup branch/tag）
   - 影响范围预览
3. **回滚执行**：
   - Git revert commit
   - 清理/标记生成文件
4. **LESSONS 记录**：写入 `.specs/LESSONS.md`
5. **状态更新**：标记 phase 状态为 Rolled-back
6. **后续选择**：用户选择重新修复/废弃/其他
```

### Phase Executor 集成点扩展

当前 8 个集成点 → 新增第 9 个：

| # | 集成点 | 触发时机 | 当前状态 |
|---|--------|----------|----------|
| 1 | Offline Mode | 执行前检查 | 已有 |
| 2 | Minimal Mode | Phase 5/6 跳过 | 已有 |
| 3 | P0 Approval | Phase 7 前 | 已有 |
| 4 | PR Description | Phase 7 后 | 已有 |
| 5 | Check Expiry | 启动时 | 已有 |
| 6 | Token Estimation | Phase 加载时 | 已有 |
| 7 | Checkpoint Resume | 启动时 | 已有 |
| 8 | Auto Cleanup | 100% 预算 | 已有 |
| **9** | **Rollback Trigger** | **回滚执行时** | **NEW** |

**Rollback 集成点伪代码：**
```
On rollback triggered:
  1. Check target phase is stable point
  2. Create backup branch/tag
  3. Execute git revert
  4. Mark/clean generated files
  5. Append to .specs/LESSONS.md
  6. Update phase state to Rolled-back
```

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|------------|-------------|-----|
| LESSONS.md 追加 | 自己实现追加逻辑 | 复用 Phase 10 追加机制 | 格式已定，追加逻辑已验证 |
| 备份机制 | 手动 git 操作 | 创建 backup branch/tag | 防止数据丢失 |
| 影响范围预览 | 自行实现文件扫描 | 复用 checkpoint-state 机制 | 已有状态追踪 |

---

## Common Pitfalls

### Pitfall 1: 稳定点标记遗漏

**What goes wrong:** Phase 执行完成后未自动标记稳定点，导致无法回滚
**Why it happens:** 集成点未正确触发自动标记逻辑
**How to avoid:** 在 phase-executor 第7集成点（Checkpoint Resume）附近新增稳定点标记逻辑
**Warning signs:** 回滚时提示 "Phase X is not a stable point"

### Pitfall 2: LESSONS.md 写入冲突

**What goes wrong:** 回滚后 LESSONS.md 追加时与其他写入冲突
**Why it happens:** 多进程/多 session 同时写入
**How to avoid:** 使用文件锁或追加模式（已有 Phase 10 机制复用）
**Warning signs:** "LESSONS.md write failed"

### Pitfall 3: 备份覆盖风险

**What goes wrong:** 多次回滚导致 backup branch/tag 被覆盖
**Why it happens:** 备份命名未包含唯一标识（如 timestamp）
**How to avoid:** 备份命名格式：`backup/{phase}-{YYYY-MM-DD-HHMMSS}`
**Warning signs:** "Backup already exists" 或历史备份丢失

---

## Code Examples

### 稳定点标记机制（伪代码）

```javascript
// Source: phase-executor.md integration point pattern
function markStablePoint(phase, reason = "auto") {
  const checkpointDir = '.planning/checkpoints';
  const markerPath = `${checkpointDir}/${phase}-stable.json`;

  fs.writeFileSync(markerPath, JSON.stringify({
    phase,
    markedAt: new Date().toISOString(),
    reason,  // "auto" or "manual"
    canRollback: true
  }));
}
```

### LESSONS.md 追加模式（复用 Phase 10）

```javascript
// Source: 10-CONTEXT.md D-L03
function appendLesson(lessonEntry) {
  const lessonsPath = '.specs/LESSONS.md';

  // 追加到 ### Entries section（结构化追加）
  const content = `\n### 回滚教训: ${lessonEntry.phase}\n\n`
    + `- **回滚原因**: ${lessonEntry.reason}\n`
    + `- **影响文件**: ${lessonEntry.files.join(', ')}\n`
    + `- **教训**: ${lessonEntry.lesson}\n`;

  fs.appendFileSync(lessonsPath, content);
}
```

### 安全护栏确认流程

```javascript
// Source: 12-CONTEXT.md D-RB-05
async function safetyCheck(targetPhase, force = false) {
  if (force) return { allowed: true, reason: "force flag" };

  // 1. 影响范围预览
  const affected = await getAffectedFiles(targetPhase);

  // 2. 用户确认
  const confirmed = await confirm(`回滚将影响 ${affected.length} 个文件: ${affected.join(', ')}`);

  if (!confirmed) throw new Error('Rollback cancelled by user');

  return { allowed: true, affected };
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| 无回滚机制 | 稳定点回滚 | Phase 12 | 可回滚已标记阶段 |
| 手动回滚 | 半自动回滚（命令触发） | Phase 12 | 一致性提升 |
| 无 LESSONS 记录 | 回滚后自动记录 | Phase 12 | 知识积累 |

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | phase-executor.md 支持第9个集成点扩展 | Architecture Patterns | 低 — 8个集成点模式已验证，扩展机制存在 |
| A2 | 备份 branch/tag 创建权限正常 | Common Pitfalls | 中 — git 权限问题可能导致回滚失败 |
| A3 | LESSONS.md 追加无并发冲突 | Common Pitfalls | 低 — 单用户 flow-kit 假设 |

---

## Open Questions

1. **自动触发条件阈值**
   - What we know: 下游阶段验证失败触发
   - What's unclear: 具体阈值（如连续3次失败）
   - Recommendation: 配置化，由用户设置

2. **监控触发接口**
   - What we know: 外部监控系统可触发
   - What's unclear: webhook 格式 / CLI 调用方式
   - Recommendation: 提供 `/flow-kit:rollback --trigger=monitor` 模式

3. **生成文件标记 vs 清理**
   - What we know: D-RB-01 说"清理/标记"
   - What's unclear: 何时清理何时标记
   - Recommendation: 稳定点文件保留，非稳定点文件清理

---

## Environment Availability

Step 2.6: SKIPPED（无外部依赖，纯代码/配置变更）

---

## Security Domain

> Required when security_enforcement is enabled (absent = enabled). Omit only if explicitly false in config.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V4 Access Control | yes | 文件系统权限（备份创建需要写权限） |
| V5 Input Validation | yes | 命令参数验证（phase 名称格式） |

### Known Threat Patterns for flow-kit

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| 未授权回滚 | Elevation of Privilege | 安全护栏确认机制 |
| 回滚后数据丢失 | Information Disclosure | 备份 branch/tag 先于回滚 |
| LESSONS.md 注入 | Tampering | 参数化追加，无直接文件写入 |

---

## Sources

### Primary (HIGH confidence)
- `flow-kit/phases/8-rollback/8-rollback.md` — 四章节模板结构
- `flow-kit/lib/phase-executor.md` — 8个集成点，扩展模式已验证
- `.planning/phases/12-Rollback/12-CONTEXT.md` — 6项锁定决策
- `flow-kit/templates/LESSONS.md.template` — Phase 10 确定格式

### Secondary (MEDIUM confidence)
- `.planning/phases/10-Core-Process/10-CONTEXT.md` — LESSONS.md 路径决策
- `.planning/phases/11-Templates/11-CONTEXT.md` — 混合模式参考

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — 全部复用现有文件
- Architecture: HIGH — 基于已验证的 phase-executor 模式
- Pitfalls: MEDIUM — 基于已知模式推导

**Research date:** 2026/05/07
**Valid until:** 约30天（phase-executor 扩展机制稳定）