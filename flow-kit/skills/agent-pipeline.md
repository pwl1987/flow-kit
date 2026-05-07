> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本技能定义 Agent 流水线中的三阶段交接验证门。

## 三阶段 Agent 交接验证门

> v1.10 新增：rihebty 阶段仲裁验证机制

在 explore→plan、plan→execute、execute→verify 三个阶段衔接处，必须输出以下验证段：

### Agent 交接验证

```
### Agent 交接验证

- **上一阶段输出**：{工件链接}
- **计划一致性检查**：verify 计划是否覆盖所有功能点 → 是/否
- **Handler 覆盖矩阵**：

| API Endpoint / UI 交互点 / DB 操作 | Handler 函数路径 | Agent 承诺人 |
|---|---|---|
| POST /api/users/register | src/handlers/auth.ts:register() | Dev |
| GET /api/users/:id | src/handlers/user.ts:getById() | Dev |
```

### 追责链

每个 Task 标注负责 Agent：

```
### 追责链

| Task ID | 负责人 | 承诺时间 | 完成状态 |
|---------|--------|---------|---------|
| T1.1 | Dev | 2026-05-08 | ✅ |
| T1.2 | Dev | 2026-05-08 | 🔄 |
```

---

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit) — 阶段仲裁验证 + R8.2 追责链
- [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) — 三阶段验证门
