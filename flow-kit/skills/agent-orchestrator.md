# agent-orchestrator.md — 多代理编排技能

> v1.12.4 P0 新增：多代理任务编排决策与上下文管理

## 多代理编排决策树

```
任务输入
    │
    ▼
┌─────────────────┐
│ 任务复杂度评估   │
│ - 改动范围       │
│ - 文件数量       │
│ - 依赖深度       │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
 简单       复杂
 (<3文件)   (≥3文件)
    │         │
    ▼         ▼
 minimal   dispatch
 (L0)      (Team/L2+)
```

### 拆分策略

| 任务类型   | 拆分策略     | 代理角色                          |
| ---------- | ------------ | --------------------------------- |
| 新功能开发 | 按模块拆分   | Executor × N                      |
| Bug 修复   | 按影响范围拆 | Executor + Reviewer               |
| 重构       | 按风险等级拆 | Executor + Reviewer + Test Runner |
| 大型变更   | 按子系统拆   | Executor × N + Coordinator        |

## 判断标准：dispatch vs minimal

### 使用 minimal 的条件

- 改动范围 ≤ 3 个文件
- 单一模块内的简单变更
- 无跨模块依赖
- 不需要并行验证

### 使用 dispatch 的条件

- 改动范围 > 3 个文件
- 多模块协同变更
- 需要 Code Review + Test 多线并行
- 有明确的模块边界可拆分

## 子代理上下文预算管理

### 预算分配策略

| 角色                 | 上下文预算上限 | 说明             |
| -------------------- | -------------- | ---------------- |
| 主会话               | 30-40%         | 协调、聚合、决策 |
| 子代理 (Executor)    | 80%            | 独立执行任务     |
| 子代理 (Reviewer)    | 80%            | 代码审查         |
| 子代理 (Test Runner) | 80%            | 测试执行         |

### 上下文控制原则

1. **80% 上限**：每个子代理最多使用 80% 上下文预算
2. **主会话 30-40%**：主会话保留 60-70% 用于协调和聚合
3. **增量传递**：子代理输出只传递关键摘要，不传递完整上下文
4. **超时回收**：子代理超时后自动回收上下文

### 上下文消耗计算

```bash
# 伪代码：计算子代理上下文消耗
SUBAGENT_CONTEXT_BUDGET = (TOTAL_CONTEXT * 0.8)
REMAINING_FOR_MAIN = TOTAL_CONTEXT * 0.3

if (subagent_consumed > SUBAGENT_CONTEXT_BUDGET):
    warn("子代理上下文超支，触发压缩")
    trigger_context_compress()
```

## 聚合报告模板

```json
{
  "dispatch_summary": {
    "task_id": "multi-agent-20260508",
    "total_agents": 3,
    "successful": 2,
    "failed": 0,
    "partial": 1,
    "duration_seconds": 120
  },
  "files_modified": ["auth/login.ts", "auth/register.ts", "api/user.ts"],
  "context_consumed_pct": "45%",
  "overall_summary": "用户认证模块开发完成，2个executor成功，test runner报告部分测试待补充"
}
```

## 失败处理策略

### 重试规则

| 失败类型      | 重试次数 | 间隔 | 降级策略     |
| ------------- | -------- | ---- | ------------ |
| 子代理超时    | 1        | 30s  | 减少文件范围 |
| 子代理 FAILED | 2        | 60s  | 人工介入     |
| 锁冲突        | 3        | 10s  | 重新分配任务 |

### 降级路径

```
子代理失败
    │
    ▼
┌─────────────────┐
│ 重试 (最多2次)  │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
  成功      仍失败
    │         │
    ▼         ▼
  继续    降级处理
            │
            ▼
    ┌─────────────────┐
    │ 减少文件范围    │
    │ 更换子代理角色  │
    │ 人工介入标记    │
    └─────────────────┘
```

### 人工介入规则

出现以下情况时，标记为 `HUMAN_INTERVENTION_REQUIRED`：

1. 子代理连续失败 2 次
2. 锁冲突超过 3 次无法解决
3. 上下文超支 50% 以上
4. 检测到数据损坏或安全风险

## 快速启动指令

```bash
# Team 模式：3 并行
/flow-kit:dispatch 3:"实现用户认证系统"

# L0 极简模式
/flow-kit:minimal "修复登录 bug"

# 查看 dispatch 状态
/flow-kit:dispatch-status
```

## 参考来源

- [multi-agent-orchestration-patterns](https://github.com/anthropic/multi-agent-patterns) — 多代理编排最佳实践
- [task-executor-agent](https://github.com/anthropic/task-executor-agent) — 任务执行代理模式
