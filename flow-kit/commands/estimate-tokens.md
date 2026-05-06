> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件实现基于代码行数的 Token 估算逻辑。
> D4-2: LOC-based Token Estimation

# Token Estimation Module

## 核心公式

```
estimated_tokens = total_LOC * 1.5
```

## 行为定义

### 统计范围

- 扫描 `.planning/phases/*/` 下所有 `.md` 文件
- **排除**包含 `template` 或 `TEMPLATE` 的文件名

### Budget 定义

| Budget 级别 | 阈值 | 行为 |
|-------------|------|------|
| 健康 | < 80% | 正常执行，无提示 |
| 警告 | >= 80% | 输出 `[WARNING] Approaching token budget ({pct}%)` |
| 阻止 | >= 100% | 输出 `[BLOCK] Token budget exhausted` 并阻止继续 |

**默认 Budget**: 100,000 tokens（可配置）

## 输出格式

```
Token Estimation Report
=======================
Phase 01: {LOC1} lines
Phase 02: {LOC2} lines
Phase 03: {LOC3} lines
Phase 04: {LOC4} lines
...
Total LOC: {total_LOC}
Estimated Tokens: {estimated_tokens}
Budget: {budget} ({budget_pct}% used)
Status: [HEALTHY/WARNING/BLOCK]
```

## 命令

| 命令 | 行为 |
|------|------|
| `/flow-kit:estimate-tokens` | 输出完整 Token 估算报告 |
| `/flow-kit:tokens` | 同上，简写 |

## 实现逻辑

### LOC 统计流程

```
1. glob('.planning/phases/*/*.md') -> files
2. filter files where !filename.includes('template') && !filename.includes('TEMPLATE')
3. for each file: count lines using wc -l
4. group by phase directory
5. sum all lines -> total_LOC
6. estimated = total_LOC * 1.5
7. pct = (estimated / budget) * 100
```

### 集成点

- GO.md 启动时自动调用（静默模式，警告才输出）
- `/flow-kit:estimate-tokens` 命令触发（完整输出）

## 边界情况

### 空目录
- 无 .md 文件：输出 `Total LOC: 0, Estimated Tokens: 0`

### 单文件过大
- 单一文件超过 10,000 行：标记为异常，给出警告

---

**关联文件**：
- `@flow-kit/GO.md` (启动时调用)
- `.planning/phases/*/` (扫描目标)