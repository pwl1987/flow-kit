> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件实现成本报告功能。
> D4-7: Cost Report Metrics

# Cost Report

## 功能概述

生成月度成本报告，包含 Token 消耗、阶段完成率、平均成本和优化建议。

## 命令

```
/flow-kit:cost-report
```

## 报告指标

| 指标 | 计算方式 | 说明 |
|------|----------|------|
| Total Token consumption | LOC × 1.5 | 复用 estimate-tokens.md 算法 |
| Phase completion rate | 完成 Phase N 的变更数 / 总变更数 | 各阶段完成率 |
| Avg cost per change | Total tokens / Change count | 平均每变更 Token 消耗 |
| Change count | 统计周期内变更数 | 活跃度指标 |

## 输出格式

```markdown
# Cost Report — {YYYY-MM}

## Token Consumption
| Phase | LOC | Est. Tokens |
|-------|-----|------------|
| 01    | xxx | xxx        |
| 02    | xxx | xxx        |
| 03    | xxx | xxx        |
| 04    | xxx | xxx        |
| Total | xxx | xxx        |

## Phase Completion
| Phase | Completion Rate | Changes |
|-------|------------------|---------|
| 01    | XX%             | XX     |
| 02    | XX%             | XX     |
| ...   | ...             | ...    |

## Summary
Total changes: {n}
Total tokens: {n}
Avg cost/change: {n}

## Recommendations
- {优化建议1}
- {优化建议2}
```

## 优化建议规则

当 Token 使用率超过 80%：
- 建议归档过期上下文
- 建议精简阶段文档

当阶段完成率低于 60%：
- 建议分析瓶颈阶段
- 建议增加验证密度

## 数据来源

- `.planning/phases/*/` 下的 .md 文件
- 排除 template 文件
- 按月统计（使用文件修改时间）

## 集成点

### 独立命令

```bash
/flow-kit:cost-report
```

### 自动触发

- 每月初自动生成上月报告
- 存储到 `.flow-kit/reports/` 目录

---

**关联文件**：
- `@flow-kit/commands/estimate-tokens.md` (Token 估算逻辑)