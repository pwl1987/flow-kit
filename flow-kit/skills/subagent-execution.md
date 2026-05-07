--- BEGIN flow-kit/skills/subagent-execution.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 Subagent 执行技能包 (SKILL-32)，用于并行任务分发与执行。
> 遵循 WHEN_TO_USE / HOW_TO_USE / EXAMPLE / NOTES 四段式结构。

# Skill: Subagent Execution (SKILL-32)

## WHEN_TO_USE

- **Phase**: Phase 3+ — Development Execution
- **Trigger**: 任务可并行执行，需要拆分到多个 agent 时
- **场景**:
  - 20+ 相似任务（如多个 CRUD endpoints）
  - 独立模块可同时开发
  - 需要隔离执行环境（避免互相干扰）
  - 任务之间有清晰接口定义

## HOW_TO_USE

### Subagent Task Package 格式

```javascript
Task({
  description: "Task description",
  isolation: "worktree",
  workingDirectory: "/path/to/repo",
  concurrency: {
    auto: true,
    maxParallel: 4
  },
  input: { /* 任务输入 */ },
  output: { /* 任务输出 */ },
  onResult: (result) => { /* 结果处理 */ }
})
```

### 执行参数

| 参数 | 值 | 说明 |
|------|-----|------|
| **isolation** | `worktree` | 每个 subagent 独立工作树，安全隔离 |
| **maxParallel** | `4` | 最多同时运行 4 个 subagent |
| **mergeStrategy** | `sequential` | 按顺序合并结果，避免冲突 |
| **contextPass** | `essential-only` | 只传递必要上下文，减少 token |

### D-26 动态并发控制

**预算感知调度**：
| Token 预算 | 并发数 | 说明 |
|------------|--------|------|
| < 80% | maxParallel（默认 4） | 正常并发 |
| >= 80% | 1 | 降级为单并发，避免预算耗尽 |
| >= 90% | 串行 | 强制串行，逐任务完成 |

**配置**：
```javascript
Task({
  // ...
  concurrency: {
    auto: true,  // 启用动态调整
    maxParallel: 4,
    degradeAt: 0.8,   // 80% 降级
    serialAt: 0.9     // 90% 串行
  }
})
```

### D-26 执行日志

**日志格式**：
```json
{
  "timestamp": "2026-05-07T10:30:00Z",
  "taskId": "T2.1",
  "agent": "subagent-1",
  "status": "completed",
  "duration": 120000,
  "tokensUsed": 50000,
  "output": { "files": ["user.ts"], "errors": [] }
}
```

**归档**：
- 执行日志归档到 `.planning/archive/execution-{date}.json`
- 命令：`/flow-kit:cost-report` 导入成本报告

**资源限制**：
- 并发数配置：`maxParallel: N`
- 预算动态调整：自动根据 token 预算调整
```

### 任务拆分策略

1. **按实体拆分**：一个实体相关的操作归为同一任务
2. **按层级拆分**：frontend/backend/db 分开
3. **按复杂度拆分**：简单任务并行，复杂任务单独处理

### 结果合并

```javascript
// 合并策略
const mergeStrategy = {
  type: "sequential",  // 按依赖顺序合并
  conflictResolution: "last-write-wins",
  rollbackOnConflict: true  // 冲突时回滚
};
```

## EXAMPLE

**场景**：创建 20 个 CRUD endpoints

**任务拆分**（4 个 subagent）：
```javascript
// Subagent 1: User-related endpoints
Task({
  description: "Implement User CRUD: create, read, update, delete",
  isolation: "worktree",
  input: {
    entities: ["User"],
    operations: ["create", "read", "update", "delete"],
    outputDir: "src/api/user"
  },
  output: {
    files: ["user.controller.ts", "user.service.ts", "user.routes.ts"]
  }
});

// Subagent 2: Order-related endpoints
Task({
  description: "Implement Order CRUD",
  isolation: "worktree",
  input: {
    entities: ["Order", "OrderItem"],
    operations: ["create", "read", "update", "delete", "list"]
  },
  output: {
    files: ["order.controller.ts", "order.service.ts", "order.routes.ts"]
  }
});

// Subagent 3: Product endpoints
Task({
  description: "Implement Product endpoints",
  isolation: "worktree",
  input: {
    entities: ["Product", "Category"],
    operations: ["create", "read", "update", "delete", "search"]
  },
  output: {
    files: ["product.controller.ts", "product.service.ts", "product.routes.ts"]
  }
});

// Subagent 4: Payment endpoints
Task({
  description: "Implement Payment processing",
  isolation: "worktree",
  input: {
    entities: ["Payment", "Invoice"],
    operations: ["create", "process", "refund", "status"]
  },
  output: {
    files: ["payment.controller.ts", "payment.service.ts", "payment.routes.ts"]
  }
});
```

### 上下文传递

```javascript
// 不传递：完整对话历史（太大）
// 正确传递：
{
  projectContext: "Node.js + Express + Prisma",
  relevantFiles: ["src/schema.prisma"],
  taskInstructions: "...",
  constraints: ["ESLint enabled", "Jest tests required"]
}
```

## NOTES

### 并行限制

| 场景 | Max Parallel |
|------|-------------|
| 普通任务 | 4 |
| 大型重构 | 2 |
| P0 紧急 | 1（串行执行） |

### 共享状态同步

- **禁止**：多个 subagent 同时写入同一文件
- **允许**：读取共享配置文件
- **必须**：写入前检查文件锁状态

### 常见问题

| 问题 | 解决 |
|------|------|
| 上下文丢失 | 使用 task package 的 input 定义明确合约 |
| 结果冲突 | 使用 sequential merge + last-write-wins |
| 资源争抢 | 先执行 parallel-dispatch.md 的冲突检测 |
| 任务失败 | 定义 rollback 策略 |

### 验证检查

- [ ] isolation=worktree 设置
- [ ] 输入输出合约明确
- [ ] 不超过 4 个并行
- [ ] 共享资源无冲突
- [ ] 结果可合并

---
**关联技能**: task-master.md (SKILL-31) — 任务输入
**后续技能**: parallel-dispatch.md (SKILL-35) — 冲突检测
**注意**: context management 参见本文件 EXAMPLE 部分
--- END flow-kit/skills/subagent-execution.md ---