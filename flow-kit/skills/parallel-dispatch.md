--- BEGIN flow-kit/skills/parallel-dispatch.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为并行分发技能包 (SKILL-35)，用于多任务并行执行调度。
> 遵循 WHEN_TO_USE / HOW_TO_USE / EXAMPLE / NOTES 四段式结构。

# Skill: Parallel Dispatch (SKILL-35)

## WHEN_TO_USE

- **Phase**: Phase 3+ — Development Execution
- **Trigger**: 需要同时执行多个独立任务时
- **场景**:
  - 多个独立任务需要同时执行
  - Subagent 并行分发前需要冲突检测
  - 资源有限需要调度优化
  - 避免多个任务同时修改同一文件

## HOW_TO_USE

### Conflict Detection Algorithm

**输入**: 任务列表（每个任务有 target files）

**输出**: 冲突报告 + 安全分发计划

#### 算法步骤

```
Step 1: Build File Ownership Map
  - 遍历所有任务
  - 创建 file → task[] 映射

Step 2: Detect Ownership Conflicts
  - 如果 file 被多个任务写入 → CONFLICT
  - 如果 file 被一个任务写入、多个任务读取 → OK

Step 3: Check Dependency Graph
  - 如果 Task A 依赖 Task B 输出 → 串行
  - 如果无依赖 → 可并行

Step 4: Generate Dispatch Plan
  - 分组：无冲突任务 → 并行
  - 单独：冲突任务 → 串行
```

### 冲突类型

| 类型 | 描述 | 处理 |
|------|------|------|
| **Write-Write** | 多任务写入同一文件 | 序列化，指定顺序 |
| **Write-Read** | 一写多读 | 可并行（写后读需同步） |
| **Resource Lock** | 共享资源（DB connection） | 连接池管理 |
| **Circular Dependency** | A→B→C→A | 报错，拒绝分发 |

## EXAMPLE

### 场景：4 个任务并行分发

**Tasks**:
```
Task A: 修改 src/api/user.ts, src/models/user.ts
Task B: 修改 src/api/user.ts, src/utils/auth.ts
Task C: 读取 src/api/user.ts, 写入 src/api/order.ts
Task D: 写入 src/utils/logger.ts, src/utils/auth.ts
```

**Step 1: File Ownership Map**
```
src/api/user.ts     → [Task A, Task B, Task C(read)]
src/models/user.ts  → [Task A]
src/utils/auth.ts   → [Task B, Task D]
src/api/order.ts    → [Task C]
src/utils/logger.ts → [Task D]
```

**Step 2: Conflict Detection**
```
Task A & Task B: CONFLICT (both write user.ts)
Task A & Task C: CONFLICT (A writes, C reads after write)
Task B & Task D: CONFLICT (both write auth.ts)
```

**Step 3: Dispatch Plan**
```
Wave 1 (并行):
  - Task C: 无冲突（read user.ts, write order.ts）
  
Wave 2 (串行):
  - Task A: 先执行，写入 user.ts, user.ts
  - Task B: 后执行，写入 auth.ts
  - Task D: 后执行，写入 logger.ts, auth.ts
  * 注意：Task B 和 Task D 都写 auth.ts，需要序列化
```

### Worktree 创建

```javascript
// 为每个并行任务创建独立 worktree
const worktreeOps = [
  { task: "Task A", branch: "worktree-agent-A", base: "main" },
  { task: "Task C", branch: "worktree-agent-C", base: "main" }
];

// 执行
for (const op of worktreeOps) {
  await git.worktree({
    create: true,
    branch: op.branch,
    detach: true,
    path: `./.git/worktrees/${op.branch}`
  });
}
```

## NOTES

### 并行限制

| 场景 | Max Parallel | 原因 |
|------|-------------|------|
| **一般任务** | 4 | 系统资源限制 |
| **Heavy I/O** | 8 | I/O bound 可更宽松 |
| **Heavy CPU** | 2 | 避免 CPU 争抢 |
| **DB 写入** | 1 | 避免连接池耗尽 |

### 资源争抢处理

```javascript
// 连接池管理
const resourceManager = {
  dbConnections: { max: 10, current: 0 },
  fileLocks: new Map(),

  async acquire(type) {
    if (type === 'db') {
      if (this.dbConnections.current >= this.dbConnections.max) {
        await this.waitForRelease();
      }
      this.dbConnections.current++;
    }
  },

  release(type) {
    if (type === 'db') {
      this.dbConnections.current--;
    }
  }
};
```

### 常见问题

| 问题 | 解决 |
|------|------|
| 文件冲突 | 拆分任务使文件归属单一任务 |
| 循环依赖 | 重新设计任务边界 |
| 资源耗尽 | 限制并行数 + 连接池管理 |
| 结果不一致 | 使用分布式锁或序列化写入 |

### 验证检查

- [ ] 无 Write-Write 冲突
- [ ] 无循环依赖
- [ ] 并行数 <= 4
- [ ] 串行任务有明确顺序
- [ ] 资源争抢已处理

---
**关联技能**: subagent-execution.md (SKILL-32) — 具体执行
**前置条件**: 任务列表已生成（来自 task-master.md）
**注意**: 冲突检测应在 dispatch 前执行
--- END flow-kit/skills/parallel-dispatch.md ---