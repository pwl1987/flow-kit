> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件实现 PR 描述自动生成功能。
> D4-6: PR Description Generation

# PR Description Generation

## 功能概述

从 git 提交历史中提取信息，自动填充 PR 描述模板，并使用 AI 补充动机和技术细节。

## 命令

```
`bash flow-kit/scripts/pr-description.sh`
```

## 执行流程

### 1. Git Log 提取

```bash
git log --oneline -20
git diff --stat HEAD~5..HEAD
```

获取：
- 最近 20 条提交消息
- 变更的文件列表
- 变更行数统计

### 2. PR Body 模板 (自动填充字段)

```markdown
## Summary
{change_title}
Change ID: {change_id}

## What Changed
{affected_files}

## Test Results
{phase_5_verification_summary}

## Rollback Plan
{rollback_command_or_reference}
```

### 3. AI 补充内容

**Motivation（动机）**：
- 从提交消息上下文推断变更原因
- 说明解决了什么问题

**Technical Details（技术细节）**：
- 关键实现决策
- 技术权衡考量
- 重要的架构变化

### 4. 输出格式

GitHub PR body 兼容的 Markdown：

```markdown
## Summary
{Fill from template}

## What Changed
{Files list from git diff}

## Motivation
{AI-generated: Why this change was needed}

## Technical Details
{AI-generated: Key decisions and trade-offs}

## Test Results
{Phase 5 verification summary}

## Rollback Plan
{Command or reference}
```

## 集成点

### Phase Executor 集成

在 `flow-kit/lib/phase-executor.sh` 中：
- Phase 7 (Integration) 完成后自动调用
- 生成 PR 描述用于提交审查

### 独立命令调用

```bash
`bash flow-kit/scripts/pr-description.sh`
```

直接生成 PR 描述输出

## 边界情况

### 无 Git 历史

当 change 未提交时：
- 输出：`[INFO] No git history available. PR description requires committed changes.`

### 单文件变更

当变更 < 3 个文件：
- 简化为简短描述
- 跳过 AI 补充（optional）

### 大规模变更

当变更 > 20 个文件：
- 截断文件列表
- 标注 "and X more files"

---

**关联文件**：
- `@flow-kit/lib/phase-executor.sh` (阶段执行器)
- `@flow-kit/commands/estimate-tokens.md` (Token 估算)