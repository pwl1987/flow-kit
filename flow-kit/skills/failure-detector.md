# 【CLAUDE CODE INSTRUCTION 强制约束】

> 本技能在检测到 AI 懈怠信号时自动激活。

---

## 5 大懈怠模式（出现任意一项即自动触发）

### 1. 蛮力重试 (Brute Force Retry)

Same command/method fails ≥2x in a row, no strategy change

### 2. 推卸责任 (Blame Shifting)

Output contains any of:
- "可能是环境问题"
- "建议手动处理"
- "需要更多上下文"
- "这不是代码问题"

### 3. 工具闲置 (Tool Idle)

Has search capability but doesn't search, has read capability but doesn't read, has execution capability but doesn't execute

### 4. 假忙 (Fake Busy)

Repeatedly micro-adjusting same line/code or parameters, core problem not advancing

### 5. 被动等待 (Passive Waiting)

Fix surface problem then stop, no verification, no extension, waiting for next user instruction

---

## 7 点强制清单（必须逐项执行并记录，不得跳过）

- [ ] **1. Read error message verbatim** (word by word, don't summarize)
- [ ] **2. Search project for similar patterns** (grep error keywords)
- [ ] **3. Check recent git diff** (any unrelated changes introduced problem)
- [ ] **4. List attempted approaches and failure reasons** (write to PROGRESS.md "excluded approaches" section)
- [ ] **5. List approaches not yet tried** (at least 3)
- [ ] **6. Select one untried approach, explain selection reason**
- [ ] **7. Execute selected approach, record results**

---

## 退出条件

- All 7-point checklist executed and recorded
- OR found new valid approach and executed successfully
- **Cannot** output "I cannot solve" / "suggest manual handling" before completing half the checklist

---

## L0-L4 压力升级（配合 4-dev 使用）

| 级别 | 触发条件 | 执行策略 |
|------|---------|---------|
| **L0 冷静提示** | 第 1 次 verify 失败 | 输出错误日志，要求 AI 自行分析原因并修复 |
| **L1 结构化引导** | 第 2 次同类型失败 | 提供结构化调试清单（检查依赖、检查类型、检查边界条件） |
| **L2 外部知识注入** | 第 3 次失败或 AI 跳过 verify | 搜索 LESSONS.md 中相似问题的修复方案，强制 AI 阅读后重试 |
| **L3 人机协同** | 第 4 次失败或 2 次跳过 verify | 暂停流程，向用户报告"AI 在任务 X 上反复失败"，等待人工介入 |
| **L4 放弃后果蒙太奇** | AI 主动放弃或提议"换个方案" | 输出"你确定要放弃吗？放弃意味着以下功能将缺失：... 你有能力解决这个问题，让我们重新分析根本原因。" |

---

## 质量评分机制（PASSING_SCORE）

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 每个任务完成后自动评分，基于 verify 通过数、覆盖率、lint 通过数。

### 评分公式

```
PASSING_SCORE = (verify_pass_rate * 0.5) + (coverage_rate * 0.3) + (lint_pass_rate * 0.2)
```

- **verify_pass_rate**: verify 命令通过比例（0-100%）
- **coverage_rate**: 测试覆盖率（0-100%）
- **lint_pass_rate**: lint 通过比例（0-100%）

### 默认阈值

- **PASSING_SCORE 默认值**: 80 分
- 用户可在 `config/user-config.md` 中设置 `passing_score: {n}`

### 自动迭代

若分数 < PASSING_SCORE（默认 80）：
- 自动触发 L1 结构化引导
- 提供调试清单（检查依赖/类型/边界条件）
- 修复后重新评分
- 若连续 2 次 < 80，触发 L3 人机协同

### 输出格式

```markdown
## 质量评分

| 指标 | 值 | 权重 | 加权分 |
|------|------|------|--------|
| verify | 3/4 = 75% | 0.5 | 37.5 |
| coverage | 85% | 0.3 | 25.5 |
| lint | 100% | 0.2 | 20 |
| **总分** | **83** | — | **83** |

结论：✅ 通过（83 >= 80）
```

### 参考来源

- [smallnest/autoresearch](https://github.com/smallnest/autoresearch) — PASSING_SCORE 评分驱动自动迭代

---

## 参考来源

- [tanweai/pua](https://github.com/tanweai/pua) — AI 五大懒惰模式识别 + 7 点强制排查清单 + L0-L4 五级压力升级机制
