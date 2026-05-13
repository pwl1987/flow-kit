> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件实现跨会话搜索命令 `/flow-kit:scan`。
> D-CMD-01: 搜索方式 = 混合模式（关键词优先 + 语义兜底）
> D-CMD-02: 输出格式 = 可切换（默认列表，`--verbose` 摘要模式）
> D-CMD-03: LESSONS.md 读写权限 = 结构化追加（### Entries 用户写，### Extracted 系统只读）

# Cross-Session Search

## 功能概述

搜索跨会话持久化的经验教训，支持关键词快速检索和语义兜底查询。

## 命令

```
/flow-kit:scan <query> [--verbose]
/flow-kit:scan --list [--verbose]
/flow-kit:scan --stats
```

## 搜索方式

### 混合模式（默认）

| 阶段 | 工具 | 触发条件 |
|------|------|----------|
| 1. 关键词检索 | `rg` (ripgrep) | 始终执行，快速返回 |
| 2. 语义兜底 | GLOSSARY See Also / Category 遍历 | 关键词无结果时触发 |

### 语义兜底策略

当 `rg` 无匹配结果时：
1. 遍历 `GLOSSARY.md` 的 See Also 交叉引用
2. 按 Category 分组遍历相关词条
3. 使用模糊匹配返回候选结果

## 输出格式

### 默认列表模式

```
/flow-kit:scan "error handling"
```

输出：
```
[Cross-Session Search Results]

## Matching Entries
| # | Title | Category | Session | Date |
|---|-------|----------|---------|------|
| 1 | Handle null safely | patterns | session-2025-05 | 2025-05-07 |
| 2 | Error recovery patterns | patterns | session-2025-04 | 2025-04-20 |

## Semantics Candidates (fuzzy match)
| Score | Title | Category |
|-------|-------|----------|
| 0.85 | Null pointer safety | safety |
| 0.72 | Exception patterns | patterns |
```

### 摘要模式（--verbose）

```
/flow-kit:scan "error handling" --verbose
```

输出：
```
[Cross-Session Search Results — Verbose]

## Summary
Total entries: 47
Matching: 2 direct, 3 semantic
Last updated: 2025-05-07

## Top Match: Handle null safely
- Category: patterns
- Session: session-2025-05
- Date: 2025-05-07
- Content: Always check null before accessing methods.
  Use optional chaining (?.) for safe navigation.
- Tags: safety, null-check, defensive

## Second Match: Error recovery patterns
- Category: patterns
- Session: session-2025-04
- Date: 2025-04-20
- Content: Implement retry logic with exponential backoff.
  Max retries: 3, base delay: 100ms.
- Tags: retry, backoff, resilience
```

## LESSONS.md 结构

### 读写权限

| Section | 权限 | 说明 |
|---------|------|------|
| `### Entries` | 用户可写 | 用户手动记录的教训和经验 |
| `### Extracted` | 系统只读（锁定标记） | 系统自动提取的会话关键决策 |

### 结构化格式

```markdown
# LESSONS.md

## Entries
<!-- 用户写区域 — 可以自由追加和编辑 -->

### [Category] Entry Title
- Date: YYYY-MM-DD
- Tags: tag1, tag2
- Content: 经验描述

---

## Extracted
<!-- 系统只读区域 — 自动生成，带锁定标记 -->
<!-- ⚠️ LOCKED: Do not edit manually -->

### [Category] Extracted Lesson
- Date: YYYY-MM-DD
- Session: session-id
- Source: [文件路径]:[行号]
- Content: 系统提取的关键决策
```

## 选项

| 选项 | 说明 |
|------|------|
| `<query>` | 搜索关键词 |
| `--list` | 列出所有条目 |
| `--verbose` | 启用摘要模式，显示完整内容 |
| `--stats` | 显示统计信息（条目数、分类分布） |
| `--category <cat>` | 按分类过滤 |
| `--session <id>` | 按会话过滤 |
| `--limit <n>` | 限制结果数量（默认 10） |

## 统计信息

```
/flow-kit:scan --stats
```

输出：
```
[LESSONS.md Statistics]

## Overview
Total entries: 47
- User entries: 32
- System extracted: 15

## By Category
| Category | Count | Percentage |
|----------|-------|------------|
| patterns | 18 | 38% |
| safety   | 12 | 26% |
| workflow | 9  | 19% |
| other    | 8  | 17% |

## Recent Activity
- Entries added this week: 3
- Last update: 2025-05-07
```

## 集成点

### 独立命令

```bash
/flow-kit:scan "pattern"
/flow-kit:scan --list --verbose
/flow-kit:scan --stats --category patterns
```

### 自动触发

- 会话结束时自动提取关键决策到 `### Extracted`（带锁定标记）
- 定期清理过期条目

### 与其他命令集成

```bash
# 与 learn-rule 集成
/flow-kit:scan "same mistake"  # 预防重复错误

# 与 replay-learnings 集成
/flow-kit:scan "database"  # 查找相关经验
```

---

**关联文件**：
- `@flow-kit/commands/replay-learnings.md` (经验回放)
- `@flow-kit/commands/learn-rule.md` (规则学习)
- `@flow-kit/config/GLOSSARY.md` (术语表)
- `.planning/intel/LESSONS.md` (持久化经验库)
