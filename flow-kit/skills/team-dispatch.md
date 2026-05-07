> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本技能将 3-task.md 生成的 DAG 结果按角色路由到 team-roles.md 对应角色执行。

## 概述

Team Dispatch 将 DAG 解析结果转换为角色-任务分配表，每个角色仅加载其职责范围内的护栏规则。

## 核心功能

### 1. DAG 任务解析

读取 `3-task.md` 生成的依赖图：

```yaml
## 依赖图

### 执行序列
- task-1 → task-2 → task-3
- task-4 (并行组 A)

### 并行组
- 组 A: [task-4, task-5]
- 组 B: [task-7]
```

### 2. 角色路由

| 任务类型   | 路由角色    |
| ---------- | ----------- |
| 设计类任务 | Architect   |
| 实现类任务 | Dev         |
| 审查类任务 | Reviewer    |
| 测试类任务 | QA          |
| 安全相关   | Security    |
| 架构决策   | Eng-Manager |

### 3. 角色-任务分配表

输出格式：

```yaml
## 角色-任务分配表

### CEO
- task-0: 需求挑战（是否需要这个功能？）

### Designer
- task-3a: UI 评审（视觉一致性）

### Eng-Manager
- task-1: 架构设计评审

### Dev
- task-2: 实现 task-2
- task-4: 实现 task-4（并行）

### Reviewer
- task-5: 代码审查

### QA
- task-6: 测试验证

### Security
- task-7: 安全审计（高风险）
```

### 4. 上下文隔离

每个角色仅加载其职责范围内的护栏规则：

- Dev: 只加载 Dev 相关的 R3/R4 规则
- Reviewer: 只加载 Reviewer 相关的 R2/R4 规则
- 减少上下文占用，提高效率

### 6. 并行执行协调协议

> 来源：garrytan/gstack 并行 session 聚合

当多个子代理并行执行时：

#### 聚合规则

- **结果收集**：并行任务完成后，结果汇总到 CEO
- **冲突检测**：若两个子代理对同一文件有修改，以最后一个完成的为准
- **依赖验证**：所有并行任务的输出必须满足串行任务的输入要求

#### 冲突检测算法

```
对于每个并行组：
1. 记录每个子代理修改的文件列表
2. 若同一文件被多个子代理修改：
   - 标记为"冲突文件"
   - 等待所有相关子代理完成后
   - 由 CEO 根据 timestamp 裁定最终版本
3. 若无冲突，合并所有输出
```

#### 并行组执行顺序

```
Group A (并行) → Group B (并行) → 汇总 → CEO 审查
                ↑                   ↑
                └───────────────────┘ (依赖反馈)
```

---

### 7. 执行顺序

1. 读取 DAG 依赖图
2. 分析任务类型
3. 路由到对应角色
4. 生成角色-任务分配表
5. 按顺序执行（遵循依赖关系）
6. 并行组内并发执行
7. 汇总结果并检测冲突

---

### 8. 一键启动（借鉴 OMC 极简入口）

> v1.9 新增：极简配置模式

用户只需指定 executor 数量 + 一句话任务即可启动 agent 流水线：

```bash
/flow-kit:dispatch 3:"实现用户认证模块"
```

格式：`/flow-kit:dispatch <executor数量>:"<一句话任务描述>"`

系统自动：

1. 解析任务描述 → 生成 DAG
2. 按 executor 数量分配并行任务
3. 启动 subagent 执行
4. 汇总结果并检测冲突

---

## 参考来源

- [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — Team 模式任务分发
- [jnMetaCode/agency-orchestrator](https://github.com/jnMetaCode/agency-orchestrator) — DAG 并行检测
- [garrytan/gstack](https://github.com/garrytan/gstack) — 并行 session 聚合
