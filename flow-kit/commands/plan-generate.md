# /flow-kit:plan-generate

基于代码评审结果生成下一版本开发方案。解析 REVIEW.md 发现，按模块分组，生成分里程碑的改进计划。

## 使用场景

- 代码评审后自动生成改进方案
- 版本规划时从评审发现提取开发任务
- Phase 3 任务拆解前的方案准备

## 执行步骤

1. **解析评审** — 读取 REVIEW.md 结构化段落
2. **模块分组** — 按目录前缀归类（scripts/、lib/、hooks/）
3. **生成改进项** — 每项含问题描述、改进目标、实施步骤、工期估算
4. **分里程碑** — P0→M1(本周)、P1→M2(1-2周)、P2→M3(3-4周)、P3→M4(backlog)
5. **输出方案** — 生成 DEV-PLAN.md

## 输出

生成 `DEV-PLAN.md` 包含：

- 按里程碑分组的改进项表格
- 每项改进：模块、问题、目标、步骤、工期
- 总工作量估算

## 流水线

```
/flow-kit:code-review → REVIEW.md → /flow-kit:plan-generate → DEV-PLAN.md
```

---

**版本**: v3.3.0
**脚本**: `flow-kit/scripts/plan-generate.sh`
