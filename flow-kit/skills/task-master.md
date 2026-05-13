--- BEGIN flow-kit/skills/task-master.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为任务拆解技能包 (SKILL-31)，用于 Phase 2 任务分解与规划。
> 遵循 WHEN_TO_USE / HOW_TO_USE / EXAMPLE / NOTES 四段式结构。

# Skill: Task Mastery (SKILL-31)

## WHEN_TO_USE

- **Phase**: Phase 2 — Task Breakdown
- **Trigger**: 需求已澄清，需要拆解为可执行任务时
- **场景**:
  - PRDs 或需求文档需要转化为具体开发任务
  - 任务列表过于粗糙（超过 2 小时的工作项）
  - 需要并行分配任务给多个 subagent
  - 项目复杂度高，需要依赖关系管理

## HOW_TO_USE

### D-23 任务依赖关系图

#### 自动识别依赖
```javascript
// 从 task 输入输出自动推断依赖
function inferDependencies(tasks) {
  const graph = new DirectedGraph();
  for (const task of tasks) {
    for (const dep of task.dependencies) {
      graph.addEdge(dep, task.id);
    }
  }
  return graph;
}
```

#### 依赖图输出格式
```markdown
## Task Dependency Graph

```
[T1.1] ──→ [T2.1] ──→ [T3.1]
  │            │
  ↓            ↓
[T1.2]      [T2.2] ──→ [T3.2]
                │
                ↓
             [T3.3] (blocked: waiting T2.2)
```
```

#### 用户手动调整
- 命令：`/flow-kit:scan adjust [task-id] --after [dep-id]`
- 调整后自动验证无循环依赖

#### 与 subagent-execution 联动
依赖图生成后，自动调用 `flow-kit/skills/subagent-execution.md` 进行调度。
```

### 两步法：parse_prd → expand_task

#### Step 1: parse_prd（解析需求文档）

**目标**：从需求中提取实体、动作、约束

```
输入：澄清后的需求描述
输出：
  - entities[]: 数据实体（User, Order, Payment...）
  - actions[]: 业务动作（create, update, delete, search...）
  - constraints[]: 约束条件（权限、性能、依赖...）
```

**执行**：
1. 识别所有名词 → 实体
2. 识别所有动词 → 动作
3. 识别约束词（必须、只能、不超过）→ 约束

#### Step 2: expand_task（展开为原子任务）

**目标**：将实体+动作拆解为 5-15 分钟的原子单元

**原则**：
- 每个任务独立可执行
- 任务不跨 phase 边界
- 输入输出明确
- 可独立测试

**输出格式**：
```markdown
### [TASK-ID] Task Name
- **Phase**: X
- **Status**: todo | in-progress | done | blocked
- **Entities**: entity1, entity2
- **Actions**: action1, action2
- **Input**: source file or entity
- **Output**: target file or state
- **Dependencies**: [TASK-ID], [TASK-ID]
- **Verification**: how to verify completion

## Dependency Graph
```{mermaid}
graph LR
  T1.1 --> T2.1
  T2.1 --> T3.1
```
```

**D-25 checkpoint 同步**：
- 任务状态变更自动同步到 `.flow-kit/checkpoint-state.json`
- blocked 状态触发断点续跑提示
- 命令：`内部功能（自动管理） status` 查看当前任务状态

## EXAMPLE

**输入需求**：
> "用户可以创建订单，订单包含多个商品，总价自动计算，支持折扣码"

**parse_prd 输出**：
```
entities: User, Order, OrderItem, Product, DiscountCode
actions: create_order, add_item, calculate_total, apply_discount
constraints:
  - user must be authenticated
  - discount code must be valid
  - order total >= 0
```

**expand_task 输出**：
```markdown
### [T2.1] Create Order entity and API
- **Phase**: 3
- **Entities**: Order
- **Actions**: create_order
- **Input**: User authentication token, order data
- **Output**: Order API endpoint, Order model
- **Dependencies**: [T1.1] (auth setup)
- **Verification**: POST /orders returns 201

### [T2.2] Create OrderItem entity
- **Phase**: 3
- **Entities**: OrderItem
- **Actions**: add_item
- **Input**: Order ID, Product ID, quantity
- **Output**: OrderItem model, API endpoint
- **Dependencies**: [T2.1]
- **Verification**: Order has items

### [T2.3] Implement total calculation
- **Phase**: 3
- **Entities**: Order
- **Actions**: calculate_total
- **Input**: Order items
- **Output**: total_amount field
- **Dependencies**: [T2.2]
- **Verification**: total = sum(item.price * item.quantity)

### [T2.4] Implement discount logic
- **Phase**: 4
- **Entities**: DiscountCode
- **Actions**: apply_discount
- **Input**: Order ID, discount code
- **Output**: discounted total
- **Dependencies**: [T2.3]
- **Verification**: valid code reduces total
```

## NOTES

### 任务独立性原则

1. **不跨 phase 边界**：Phase 3 任务不能依赖 Phase 4 的输出
2. **单向依赖**：依赖链只能向前，不能循环
3. **接口先行**：跨任务接口应在依赖任务中定义

### D-24 可选看板视图
不强制默认开启。通过命令启用：
- `内部功能（看板视图） show` — 显示看板
- `内部功能（看板视图） hide` — 隐藏看板

看板格式：
| To Do | In Progress | Done | Blocked |
|-------|-------------|------|---------|
| T1.3 | T2.1 | T1.1 | T3.3 |
| | T2.2 | T1.2 | |

### 常见问题

| 问题 | 原因 | 解决 |
|------|------|------|
| 任务过大 | 拆分粒度不足 | 强制 5-15 分钟原则 |
| 任务过小 | 过度拆分 | 合并相关任务 |
| 依赖混乱 | 未理清实体关系 | 先 parse_prd 再 expand |
| 遗漏边界 | 未考虑异常流程 | 显式列出 edge cases |

### 验证检查

- [ ] 每个任务 5-15 分钟可完成
- [ ] 依赖关系无循环
- [ ] 每个任务有明确输入输出
- [ ] 可独立测试
- [ ] 不跨 phase 边界

---
**关联技能**: requirement-clarify.md (SKILL-30) — 输入来源
**后续技能**: subagent-execution.md (SKILL-32) — 并行分发
--- END flow-kit/skills/task-master.md ---