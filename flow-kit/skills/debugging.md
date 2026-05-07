--- BEGIN flow-kit/skills/debugging.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为调试技能包 (SKILL-34)，用于 Bug 诊断与修复。
> 遵循 WHEN_TO_USE / HOW_TO_USE / EXAMPLE / NOTES 四段式结构。

# Skill: Debugging (SKILL-34)

## WHEN_TO_USE

- **Phase**: Any Phase（调试不限于特定阶段）
- **Trigger**: 出现错误、异常或未预期行为时
- **场景**:
  - 程序崩溃或抛出异常
  - 功能行为与预期不符
  - 性能问题（延迟、卡顿）
  - 资源泄漏（内存、连接）
  - 难以复现的间歇性问题

## HOW_TO_USE

### Diagnostic Subagent Format

使用独立诊断子代理，系统化定位问题。

```javascript
DiagnosticAgent({
  problem: "描述问题现象",
  hypothesis: [
    // 假设列表（从最简单到最复杂排序）
  ],
  testPlan: {
    // 每个假设的验证计划
  },
  evidence: {
    // 收集的证据
  },
  conclusion: {
    // 最终结论
  }
})
```

### Hypothesis-Testing-Verification Cycle

#### 步骤 1: 收集证据

```markdown
## 证据收集

### 环境信息
- OS: [OS version]
- Runtime: [Node/Python/etc version]
- 代码版本: [git commit]

### 错误信息
- Error type: [Type]
- Stack trace: [trace]
- 发生时间: [timestamp]

### 复现步骤
1. [具体步骤]
2. [具体步骤]
3. 错误发生

### 期望行为
[应该发生什么]

### 实际行为
[实际发生什么]
```

#### 步骤 2: 生成假设

| 假设类型 | 示例 | 优先级 |
|----------|------|--------|
| **简单错误** | 变量未定义、拼写错误 | 高（先检查） |
| **边界条件** | 空输入、极端值 | 高 |
| **逻辑错误** | 条件判断错误、循环问题 | 中 |
| **并发问题** | 竞态条件、死锁 | 中 |
| **系统问题** | 内存泄漏、资源耗尽 | 低（最后检查） |

#### 步骤 3: 验证假设

```javascript
// 验证方法优先级
const verificationMethods = [
  "simple-check",    // 1. 简单检查（最快）
  "log-analysis",    // 2. 日志分析
  "unit-test",       // 3. 单元测试验证
  "integration-test", // 4. 集成测试
  "debugger",        // 5. 调试器
  "profiler",        // 6. 性能分析工具
  "heap-dump"        // 7. 堆转储分析（最慢）
];
```

#### 步骤 4: 定位根因

使用消除法：
1. 排除不可能的假设
2. 确认最可能的假设
3. 验证并修复
4. 测试确认修复

## EXAMPLE

**问题**：API 请求延迟从 50ms 增长到 2000ms

### Diagnostic 执行

```markdown
## Diagnostic: API Latency Spike

### Problem
API response time degraded from 50ms to 2000ms over past 2 days.

### Evidence
- Error logs: None
- DB query logs: 150+ queries per request (正常应该是 5-10)
- Memory: stable
- Request pattern: increased traffic but not by 40x

### Hypothesis (ordered by likelihood)
1. [HIGH] N+1 query problem - 循环中查询 DB
2. [MEDIUM] Missing database index on frequently queried column
3. [LOW] Connection pool exhaustion

### Test Plan

#### Hypothesis 1: N+1 Query
```
验证方法: 添加查询计数日志
预期: 每个请求触发 150+ 次查询
结果: ✓ 确认 - 发现 loop 中调用 repo.findById()
```

#### Hypothesis 2: Missing Index
```
验证方法: EXPLAIN ANALYZE 查询计划
预期: Sequential scan on large table
结果: ○ 排除 - 已有索引
```

### Conclusion
**Root Cause**: N+1 query in OrderRepository loop

**Fix**:
```javascript
// Before (N+1)
for (const item of items) {
  const product = await repo.findProductById(item.productId);
  // 每项都执行一次查询
}

// After (Eager loading)
const products = await repo.findProductsByIds(items.map(i => i.productId));
const productMap = new Map(products.map(p => [p.id, p]));
for (const item of items) {
  const product = productMap.get(item.productId);
  // 无额外查询
}
```

**Verification**: Latency back to 50ms
```

## NOTES

### 错误分类

| Category | 特征 | Debug 方法 |
|----------|------|-----------|
| **Logic** | 特定输入触发 | 单元测试 + 边界分析 |
| **Concurrency** | 间歇性、随机失败 | 日志 + 时间戳分析 |
| **Memory** | 逐渐恶化、最终崩溃 | Heap profiler |
| **Network** | 偶发超时、连接失败 | 抓包 + 日志 |
| **Resource** | 高负载时出现 | 监控 + profiling |

### 开始前检查清单

- [ ] 问题可复现？
- [ ] 最近有什么变更？
- [ ] 影响范围有多大？
- [ ] 是否有相关错误日志？
- [ ] 是否在其他环境复现？

### 常见陷阱

| 陷阱 | 描述 | 避免方法 |
|------|------|----------|
| **确认偏误** | 只看支持假设的证据 | 使用消除法 |
| **过度工程** | 为小问题复杂化修复 | 保持最小修改 |
| **治标不治本** | 绕过问题而非修复 | 确认根因再修复 |
| **忽略复现** | 不验证就关闭 ticket | 必须复现后关闭 |

### 验证检查

- [ ] 问题已复现
- [ ] 根因已确认
- [ ] 修复已测试
- [ ] 无副作用（无回归）
- [ ] 添加了预防测试

---
**关联技能**: code-review.md (SKILL-33) — 修复后审查
**应用场景**: 任何阶段出现 bug 时

## D-19 增强：错误模式库

### 常见错误模式
| 错误类型 | 症状 | 联动命令 |
|----------|------|----------|
| Phase 文件格式错误 | 解析失败、占位符未替换 | `/flow-kit:validate-phase` |
| Checkpoint 残留 | 断点续跑提示旧状态 | `/flow-kit:reset-checkpoint` |
| Context 过期 | 上下文丢失、重复加载 | `/flow-kit:check-expiry` |
| Token 预算耗尽 | 执行中断、压缩提示 | `/flow-kit:estimate-tokens` |
| 棕地检测失败 | 错误的护栏激活 | `/flow-kit:project-type detect` |

### /flow-kit:validate-phase 命令
验证 phase 文件格式：
- 检查占位符是否已替换
- 检查必需章节是否存在
- 检查 YAML frontmatter 格式

### /flow-kit:reset-checkpoint 命令
强制清理 checkpoint 状态：
- 删除 `.flow-kit/checkpoint-state.json`
- 提示用户重新开始或指定起始点

## D-20 增强：debug-snapshot

### /flow-kit:debug-snapshot 命令
调试前自动保存现场：

```markdown
# Debug Snapshot Report
Generated: {timestamp}

## 环境信息
- OS: {os}
- Working Directory: {cwd}
- Git Branch: {branch}

## 项目状态
- Project Type: {from .flow-kit/project-type}
- Context Age: {N} days
- Token Budget: {pct}%

## 最近变更
{git log -3 --oneline}

## Phase 状态
{list of phase directories and their states}

## 建议
基于以上信息，推荐以下调试步骤：
1. ...
2. ...
```

### 棕地项目适配
- 自动关联数据库状态快照
- 提示最近的数据库迁移
- 提供 rollback 建议
--- END flow-kit/skills/debugging.md ---