# 【CLAUDE CODE INSTRUCTION 强制约束】
> 本命令在进入 1-requirement 之前可选激活，生成 STRATEGY.md 作为策略锚点。

## 执行 /flow-kit:strategy

### 何时使用

在用户提出变更需求后，进入 Phase 1 之前激活：
- 复杂功能（涉及多个模块/系统）
- 高风险变更（涉及数据库/安全/公共 API）
- 战略级功能（影响产品方向）

### 输出 STRATEGY.md

```markdown
# 策略文档 - {变更名称}

## 目标问题
这个变更解决什么？描述要解决的问题。

## 方法
为什么是这个方案？对比备选方案，说明选择理由。

## 用户画像
谁会用到这个功能？描述目标用户和使用场景。

## 关键指标
怎么衡量成功？定义可测量的指标。
- 指标 1：
- 指标 2：

## 非目标
明确不做的事，避免范围蔓延。
- 不做：xxx
- 不做：yyy

## 风险
可能的风险和缓解措施。
```

### 使用流程

1. 用户调用 `/flow-kit:strategy` 或 AI 自动检测到复杂变更
2. AI 生成 STRATEGY.md 草稿
3. AI 反问用户确认：
   - 目标问题是否准确？
   - 方法选择是否合理？
   - 用户画像是否正确？
   - 关键指标是否可测量？
   - 非目标是否清晰？
4. 用户确认后，STRATEGY.md 成为后续阶段的锚点
5. `1-requirement` 和 `2-design` 自动读取 STRATEGY.md

### Token 预算对比（每次路由后必输出）

> v1.7 新增：三路线成本对比

```
### Token 预算对比

✅ 本次 change 规模：（预估代码行数/任务数/是否前端）
✅ 默认模式预估：~XXk - YYk tokens

1. 完整模式（推荐 500+ 行/团队项目/长期维护）
   - 优点：全流程覆盖，Phase 2-6 完整执行
   - 预估：~150k-200k tokens

2. 极简模式（推荐 100~500 行，跳 2a/跳第四轮/跳跨模型）
   - 优点：省 ~20% token
   - 跳过：Phase 2a-ui-design、第四轮 verify、跨模型交叉审查

3. 单点调用（你只想跑某一阶段，告诉我哪一个）
   - 优点：最小消耗
   - 用法：直接说 /flow-kit:phase-N

是否继续当前挡位？或换挡位？
```

### 跳过

若用户选择跳过，直接进入标准 `1-requirement` 流程。

---

## 参考来源

- [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) — /ce-strategy 策略锚定机制
- [garrytan/gstack](https://github.com/garrytan/gstack) — 策略先行理念（80% 时间在规划与审查）