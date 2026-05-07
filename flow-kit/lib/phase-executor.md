> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件实现阶段执行器，协调各阶段的执行流程。
> 集成 Offline Mode 和 Minimal Mode 支持

# Phase Executor

## 概述

Phase Executor 负责协调 flow-kit 8阶段工作流的执行，处理模式切换和阶段调度。

## 阶段执行流程

```
┌─────────────────────────────────────────────────────────┐
│                    Constitution Check                   │
│              (SEC/DATA/DEPLOY/GIT rules)               │
└────────────────────────┬────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         ▼                               ▼
   [Offline Mode?]                 [Minimal Mode?]
         │                               │
         ▼                               ▼
   Built-in Lint                  Skip Phase 5/6
   (offline-mode.md)              (minimal-mode.md)
         │                               │
         └───────────────┬───────────────┘
                         ▼
    ┌────────────────────────────────────┐
    │         8 Phase Execution          │
    │  0-Change -> 1-Plan -> ... -> 8   │
    └────────────────────────────────────┘
```

## 集成点

### 1. Offline Mode 检测 (offline-mode.md)

**执行前检查**：
```
Before running external lint tools:
  1. Check isOffline flag (from offline-mode.md)
  2. If isOffline == true:
     - Invoke built-in lint adapter
     - Log: "Running in offline mode (built-in lint)"
  3. Else:
     - Run external linters as normal
```

**自动故障转移**：
```
On external tool failure:
  1. Set isOffline = true
  2. Set offlineReason = "auto-failover"
  3. Retry with built-in lint
```

### 2. Minimal Mode 检测 (minimal-mode.md)

**Phase 5 跳过检查**：
```
Before Phase 5 (Test):
  1. Check isMinimal flag (from minimal-mode.md)
  2. If isMinimal == true:
     - Log: "Skipping Phase 5 (Test) - minimal mode"
     - Skip to Phase 6 check
  3. Else:
     - Execute Phase 5 normally
```

**Phase 6 跳过检查**：
```
Before Phase 6 (Review):
  1. Check isMinimal flag (from minimal-mode.md)
  2. If isMinimal == true:
     - Log: "Skipping Phase 6 (Review) - minimal mode"
     - Skip to Phase 7
  3. Else:
     - Execute Phase 6 normally
```

### 3. P0 Approval 检测 (p0-approval.md)

**Phase 7 执行前检查**：
```
Before Phase 7 (Integration):
  1. Check if P0 flag is set (auto-detected or manual)
  2. If P0 == true:
     - Call p0-approval.md for approval workflow
     - Block until Admin or Reviewer approves
     - Log approval decision
  3. Else:
     - Continue to Phase 7
```

**P0 触发条件**：
- `BREAKING-CHANGE.md` 文件存在
- `*.sql` 文件（DDL/DML）存在
- `migration/` 目录存在
- 手动触发：`/flow-kit:p0`

**Minimal Mode 保证**：P0 审批不能被 Minimal Mode 跳过

### 4. PR Description 生成 (pr-description.md)

**Phase 7 完成后**：
```
After Phase 7 (Integration) complete:
  1. Call pr-description.md
  2. Generate PR body from git log
  3. Output PR description for review
```

### 5. Context Expiry Detection (check-expiry.md)

**启动时检查**：
```
On phase-executor load:
  1. Call check-expiry.md logic silently (non-blocking)
  2. If warning condition (15-30 days): display warning non-blocking
  3. If archive condition (30+ days): prompt user before auto-archiving
```

**check-expiry 行为**：
- 扫描 `.planning/phases/` 下 .md 文件的最后修改时间
- 15 天警告：输出 `[WARNING] Context will expire in {N} days`
- 30 天阻止：输出 `[BLOCK] Context expired, run recovery or archive`

### 6. Token Estimation (estimate-tokens.md)

**Phase 加载时执行**：
```
On each phase load:
  1. Call estimate-tokens.md to count LOC in .planning/phases/*/
  2. Calculate: estimated_tokens = total_LOC * 1.5
  3. Compare against budget (default 100,000 tokens)
  4. Output warnings at threshold
```

**Budget 阈值处理**：
| 状态 | 阈值 | 行为 |
|------|------|------|
| HEALTHY | < 80% | 静默，继续执行 |
| WARNING | >= 80% | 输出 `[WARNING] Approaching token budget ({pct}%)` |
| BLOCK | >= 100% | 输出 `[BLOCK] Token budget exhausted` 并阻止继续 |

**集成点**：
- Phase executor 加载时：静默检查，仅警告时输出
- Phase 切换时：完整报告输出
- 命令触发：`/flow-kit:estimate-tokens` 完整输出

### 7. Checkpoint Resume Detection

**Execution on phase load:**
```
On phase-executor start:
  1. Call shouldResume(cwd) from checkpoint.js
  2. If shouldResume.should == true:
     - Display: message from checkpoint.message
     - Prompt user: "输入 'resume' 恢复，或 'new' 覆盖"
  3. If user chooses 'resume':
     - Load checkpoint.checkpoint
     - Set current phase/plan/task to resumed position
     - Log: "Resuming from Phase {phase}, Plan {plan}, Task {task_index}"
  4. If user chooses 'new' or no checkpoint exists:
     - Proceed with normal execution
     - If checkpoint existed, call clearCheckpoint(cwd) first
```

**Resume entry point:**
- Command: `/gsd-execute-phase 5 --resume`
- Auto-detect on phase start if .flow-kit/checkpoint-state.json exists

**Cleanup triggers (D-05):**
- Phase complete (all plans done)
- New phase start (auto-clear previous phase checkpoint)
- User reset: `/gsd-reset-phase 5` (explicit)

### 8. Auto Cleanup（自动清窗机制）

**D-09 渐进式压缩**：
| Token 预算 | 行为 | 输出 |
|------------|------|------|
| >= 80% | WARNING | `[WARNING] Approaching token budget ({pct}%)` |
| >= 90% | HINT | `[HINT] Consider running cleanup: /flow-kit:cleanup` |
| >= 100% | BLOCK + 强制压缩 | `[BLOCK] Token budget exhausted, running cleanup` |

**D-10 清理粒度**：
- 清理目标：已完成 phase 的 checkpoint 文件和 logs
- 保留文件：CONTEXT.md, PLAN.md, SUMMARY.md（核心文档）
- 清理操作：归档到 `.planning/archive/` 而非删除
- 归档文件名格式：`.planning/archive/{phase}-{timestamp}.json`

**Cleanup 执行逻辑**：
```
On cleanup trigger (100% budget):
  1. Scan .planning/phases/*/ for completed phases
  2. For each completed phase:
     - Archive checkpoint files to .planning/archive/
     - Archive log files to .planning/archive/
  3. Preserve: CONTEXT.md, PLAN.md, SUMMARY.md
  4. Log: "Archived {N} files, preserved {M} documents"
  5. Display: "Cleanup complete. Run /flow-kit:estimate-tokens to verify"
```

**Cleanup 命令**：
- `/flow-kit:cleanup` — 手动触发清理
- `/flow-kit:cleanup --force` — 强制清理（包括未完成 phase）

### 9. Rollback Trigger（回滚触发）

**Phase 执行完成时触发**：
1. 调用 `markStablePoint(phase, "auto")`
2. 创建 `.planning/checkpoints/{phase}-stable.json`
3. 标记文件包含：
   - phase 名
   - 标记时间
   - commit hash
   - 生成文件列表
   - canRollback: true

**手动调整命令**：
- `/flow-kit:rollback --promote {phase}` — 提升 phase 到稳定点
- `/flow-kit:rollback --demote {phase}` — 降级 phase（禁用回滚）
- `/flow-kit:rollback --remove {phase}` — 移除稳定点标记

**`markStablePoint()` 函数实现**：
```javascript
function markStablePoint(phase, reason = "auto") {
  const checkpointDir = '.planning/checkpoints';
  const markerPath = `${checkpointDir}/${phase}-stable.json`;

  // 确保目录存在
  if (!fs.existsSync(checkpointDir)) {
    fs.mkdirSync(checkpointDir, { recursive: true });
  }

  fs.writeFileSync(markerPath, JSON.stringify({
    phase,
    markedAt: new Date().toISOString(),
    reason,  // "auto" or "manual"
    canRollback: true,
    commit: getCurrentCommitHash(),
    files: getGeneratedFiles(phase)
  }, null, 2));
}
```

**`adjustStablePoint(phase, level)` 函数实现**：
```javascript
function adjustStablePoint(phase, level) {
  // level: "promote" | "demote" | "remove"
  const checkpointDir = '.planning/checkpoints';
  const markerPath = `${checkpointDir}/${phase}-stable.json`;

  if (level === "remove") {
    if (fs.existsSync(markerPath)) {
      fs.unlinkSync(markerPath);
      console.log(`[StablePoint] Phase ${phase} stable point removed`);
    }
    return;
  }

  if (!fs.existsSync(markerPath)) {
    if (level === "promote") {
      markStablePoint(phase, "manual");
      console.log(`[StablePoint] Phase ${phase} promoted to stable point`);
    }
    return;
  }

  const marker = JSON.parse(fs.readFileSync(markerPath, 'utf-8'));

  if (level === "demote") {
    marker.canRollback = false;
    marker.demotedAt = new Date().toISOString();
    marker.demotedReason = "manual";
    console.log(`[StablePoint] Phase ${phase} demoted (rollback disabled)`);
  } else if (level === "promote") {
    marker.canRollback = true;
    marker.promotedAt = new Date().toISOString();
    marker.promotedReason = "manual";
    console.log(`[StablePoint] Phase ${phase} promoted to stable point`);
  }

  fs.writeFileSync(markerPath, JSON.stringify(marker, null, 2));
}
```

## Constitution 安全墙

**所有阶段前必须通过**：

```javascript
function checkConstitutionSafety(change) {
  const rules = loadConstitutionRules();
  for (const rule of rules) {
    if (!rule.check(change)) {
      throw new Error(`Constitution violation: ${rule.name}`);
    }
  }
}
```

安全规则类型：
- **SEC**: 安全相关检查（不允许的危险操作）
- **DATA**: 数据保护检查（敏感信息处理）
- **DEPLOY**: 部署安全检查
- **GIT**: git操作安全检查

## 正常执行路径

| 阶段 | 说明 | 检查 |
|------|------|------|
| Phase 0 | Change Detection | Constitution + Offline check |
| Phase 1 | Planning | Constitution + Offline check |
| Phase 2 | Planning | Constitution + Offline check |
| Phase 3 | Planning | Constitution + Offline check |
| Phase 4 | Development | Constitution + Offline check |
| Phase 5 | Test | **Skip if Minimal** + Constitution |
| Phase 6 | Review | **Skip if Minimal** + Constitution |
| Phase 7 | Integration | **P0 Gate** + Constitution + All checks |
| Phase 8 | Rollback | Constitution only |

## 日志输出

```
[Phase Executor] Starting Phase {N}
[Phase Executor] Offline mode: {isOffline} ({offlineReason})
[Phase Executor] Minimal mode: {isMinimal} ({minimalReason})
[Phase Executor] Constitution checks: PASSED
[Phase Executor] Phase {N} complete
```

## 错误处理

| 错误类型 | 处理方式 |
|----------|----------|
| Constitution violation | Block execution, throw error |
| External lint timeout | Auto-switch to offline mode |
| Phase skip | Log and continue to next phase |

---

**关联文件**：
- `@flow-kit/commands/offline-mode.md` (离线模式)
- `@flow-kit/commands/minimal-mode.md` (最小模式)
- `@flow-kit/commands/p0-approval.md` (P0 审批)
- `@flow-kit/commands/check-expiry.md` (上下文过期检测)
- `@flow-kit/commands/estimate-tokens.md` (Token 估算)
- `@flow-kit/config/constitution.md` (安全规则)