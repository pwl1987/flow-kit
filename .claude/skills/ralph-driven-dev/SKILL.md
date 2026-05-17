---
name: ralph-driven-dev
description: Ralph Loop 循环驱动开发 - 小步快跑、持续验证、自动推进完成复杂任务。当用户提到"循环开发"、"自动化任务"、"Ralph"、"ralph-loop"、或需要执行多步骤开发任务时使用。
---

# Ralph-Driven Dev（循环驱动开发）

## 前置依赖

本技能依赖以下 Superpowers-ZH 技能（位于 `.claude/skills/`）。若缺失，使用括号内替代方案：

| 依赖技能 | 缺失时替代 |
|----------|-----------|
| `/test-driven-development` | 遵循"先写测试→确认失败→写实现→确认通过" |
| `/verification-before-completion` | 运行项目测试命令确认通过 |
| `/smart-commit` | 使用 `git commit -m "feat: {描述}"` |
| `/systematic-debugging` | 手动分析错误日志，定位根因 |
| `/writing-plans` | 在 tasks/ 文件中详细列出实现步骤 |
| `/dispatching-parallel-agents` | 按顺序逐个执行任务 |

可选依赖（不影响核心循环）：
- `/finishing-a-development-branch` — 发布流程
- `/requesting-code-review` — 代码审查

## 概述

Ralph Loop 是一种结构化的增量开发方法论，通过小步快跑、持续验证、自动推进的方式完成复杂任务。

**核心原则**：
- 每次只做一个任务，不多做
- 产出物写文件，不依赖对话记忆
- 进度唯一来源是 TODO 索引
- 循环终止条件：全部 `[x]` 后输出 `<promise>__DONE__</promise>`。无论多少 Wave，严格顺序执行，中间失败自动重试或跳过，直到最后一个任务成功。全程无人工介入。

## 快速开始

### 激活 Ralph Loop

```
0. 前置检查：
   - ralph/TODO.md 存在且至少有一个 [ ] 任务
   - ralph/PROMPT.md 中的测试命令已配置（非占位符）
   - 若未配置，提示用户先完成初始化
1. 读 ralph/TODO.md → 找第一个 [ ]
2. 读 ralph/tasks/X.Y-name.md → 执行（按循环协议步骤 4~10）
3. 循环直到全部 [x] → 输出 <promise>__DONE__</promise>
```

### 初始化新项目

```bash
# 从模板创建（模板位于技能目录下）
cp -r .claude/skills/ralph-driven-dev/template/ralph {project}/

# 或手动创建
mkdir -p {project}/ralph/tasks

# 然后编辑 PRD.md、TODO.md、tasks/
```

模板默认包含 Wave 0（项目骨架）示例，可根据项目需要增删 Wave。

### 智能初始化（从 PRD 自动生成）

如果已有一份 PRD（由其他 AI 或手动编写），可直接用它自动生成 Ralph 项目骨架：

**触发方式**：将 PRD 放入项目，说"根据 PRD.md 创建 Ralph 项目"或直接粘贴 PRD 内容。

**自动生成过程**：
1. 读取 PRD → 提取项目名称、目标、模块、技术栈、验收标准
2. 自动生成 `ralph/TODO.md`（按目标拆 Wave，每个模块一个任务，自动推断依赖）
3. 自动生成 `ralph/tasks/X.Y-*.md`（填充依赖、目标、RED/GREEN 占位引导）
4. 自动生成 `ralph/PROMPT.md`（根据 PRD 技术栈填充测试命令、构建命令）
5. 生成完成后直接进入循环，执行第一个任务

**拆分原则**：
- Wave 0 始终为"项目骨架"（目录、配置）
- 每个独立模块一个任务，小模块合并
- 依赖：先基础 → 后业务 → 最后集成
- 技术栈命令从 PRD 技术栈节直接提取

## 循环协议

### 单次迭代流程

```
1. 读 ralph/TODO.md → 找第一个 [ ]（未完成任务）
2. 读 ralph/tasks/X.Y-name.md → 获取任务详情
3. [依赖检查] 若依赖列非 "—"，检查依赖任务是否已 [x]
   → 未完成：跳到依赖任务先执行
   → 循环依赖（A→B→A）：拆分其中一个任务打破循环
4. RED: 写测试 → 运行 → 确认失败（看到红色）
5. GREEN: 写最小实现 → 运行 → 确认通过（看到绿色）
6. REFACTOR: lint 清理，保持绿色
7. 质量内循环（最多 3 轮）：
   a. REVIEW: 自查代码正确性（或调用 /requesting-code-review）
   b. 若发现需修改的问题：
      - FIX: 修正问题
      - TEST: 重新运行相关测试，确认绿色
      - 回到步骤 a 再次 REVIEW
   c. 回到步骤 a，直到 REVIEW 无新问题（最多 3 轮）
8. VERIFY: 运行全量项目测试命令 + 项目构建命令（若有），全部通过
9. COMMIT: `git add` + `git commit -m "feat: 任务 X.Y 描述"`
10. TODO: 在 ralph/TODO.md 将 [ ] 改为 [x]
11. 追加日志 → 在 ralph/tasks/X.Y-name.md 底部追加本次迭代结构化日志
12. 输出迭代摘要

熔断与自动恢复（全程无人工介入）：
- 同一任务连续失败 ≥ 5 次，触发熔断
- 自动诊断：检查环境/配置问题，尝试自动修复（如安装缺失依赖）
- 若修复成功 → 重置失败计数，重新执行当前任务
- 若修复失败 → 自动重新分析任务需求，更新 tasks/ 文件中的 GREEN 步骤，重置计数重试
- 若重新设计后仍熔断（再 5 次失败）→ 自动拆分为 2~3 个子任务，更新 TODO.md 和 tasks/
- 若拆分后仍熔断 → 检查下游任务依赖：
  * 下游不依赖当前任务 → 标记为 [B]，继续下一个 [ ] 任务
  * 下游依赖当前任务 → 标记为 [B]，暂停循环并说明阻塞原因（无法自动解除）
- 所有非阻塞任务完成后，自动回头尝试修复 [B] 任务
- 全程所有动作记录在 ralph/EXPERIENCE.md 中
```

### 日志格式（每步必须输出）

```
## [迭代 N] 任务 X.Y: {任务名}
**[RED]** 写测试 → 运行 → {通过/失败: 原因}
**[GREEN]** 最小实现 → 运行 → {通过/失败}
**[REFACTOR]** {清理内容/无需}
**[REVIEW#1]** {自查结果}
  **[FIX]** {修正内容/无需}
  **[TEST]** {重新运行测试结果}
**[REVIEW#2]** {二次评审，如无需则省略}
**[VERIFY]** 全量测试 + 构建 → {结果}
**[COMMIT]** {commit hash 前7位}
**[TODO]** 打钩 X.Y → {剩余未完成数}
```

关键决策日志：
```
**[SKILL]** 调用 /{技能名} → {调用原因} → {输出摘要}
**[DEBUG]** 测试失败 2 次 → {根因分析}
**[DECISION]** {非显而易见的设计选择} → {原因}
```

## 项目延续（项目完成后执行）

当全部任务完成后，按以下步骤操作：

### 步骤 1：检测完成

```bash
unchecked=$(grep -c '\[ \]' ralph/TODO.md || echo "0")
# 若 unchecked === 0 → 项目完成
```

### 步骤 2：询问用户

向用户展示选项：
1. **创建新版本项目** — 基于当前项目的 Wave 结构生成新 TODO
2. **结束发布** — 运行项目构建命令 + 更新 VERSION + CHANGELOG
3. **继续当前项目** — 手动添加新任务到 TODO.md

### 步骤 3：若选择创建新版本

```
1. 将当前 ralph/ 归档为 ralph-${version}-archive/
2. 展示归档版本的任务列表摘要（Wave 数、任务数）
3. 询问用户新版本需新增/删除/修改哪些任务
4. 根据用户反馈，结合归档版本的 Wave 结构，生成新 TODO.md 和 tasks/ 占位文件
5. 用户确认后，进入新版本迭代
```

### 步骤 4：输出完成

```
**[DONE]** 项目 {name} 完成
- 任务数：{total}
- 测试：{pass_count} passed
- 版本：{version}
- 下一步：{用户选择的操作}

<promise>__DONE__</promise>
```

## 检查点与恢复

### 自动检查点

每完成一个 Wave（一组相关任务）后执行：

```bash
# 从刚完成的任务编号提取 Wave 序号（如 1.3 → wave 1）
wave_num=$(echo "$task_id" | cut -d'.' -f1)

git add .
git commit -m "feat: wave ${wave_num} 完成"
git tag "ralph-wave${wave_num}-$(date +%Y%m%d)"
```

判定 Wave 完成：当前 Wave 的所有任务均已 `[x]`。

### Context 接近满时

当对话变得很长时：
1. `git add . && git commit -m "wip: ralph checkpoint"` 保存当前进度
2. 继续执行下一个任务（Ralph Loop 会自动从 TODO.md 恢复进度）

### 测试连续失败 2 次

1. 暂存当前变更：`git stash`
2. 单独复现问题，定位根因
3. 修复后恢复：`git stash pop`
4. 重新运行测试

### 严重错误

若错误无法快速修复：
1. 回滚到最近检查点：`git reset --hard ralph-waveN-{date}`
2. 重新执行失败的任务

## 依赖管理

任务依赖在 TODO.md 的"依赖"列声明：

```markdown
| 1.2 | 任务 B | tasks/1.2-b.md | 1.1 | [ ] |
```

执行规则：
- 依赖任务必须先完成（标记 [x]）
- 若依赖未完成，跳过当前任务，先执行依赖任务
- 若检测到循环依赖（A→B→A），拆分其中一个任务打破循环

## 项目模板

### 目录结构

```
{project}/
├── ralph/               # Ralph Loop 根目录
│   ├── PRD.md           # 项目需求文档
│   ├── PROMPT.md        # 执行规则
│   ├── TODO.md          # 任务索引
│   └── tasks/           # 任务详情
├── src/                 # 源码
├── tests/               # 测试
└── dist/                # 产物
```

### TODO.md 格式

```markdown
# {项目名} 任务索引（{N} 原子任务）

## Wave 1: {名称}
| # | 任务 | 详情文件 | 依赖 | 状态 |
|---|------|----------|------|------|
| 1.1 | {任务} | tasks/1.1-name.md | — | [ ] |

## 完成标准
- 全部 [x]
- 项目测试命令通过
```

### task 格式

```markdown
# 任务 {X.Y}: {任务名}

## 依赖
{前置任务编号，如 1.1}

## 目标
{一句话描述}

## 实现步骤

### RED（测试先行）
1. 写测试验证 {具体行为}
2. 运行测试确认失败

### GREEN（最小实现）
1. 实现 {最小代码}
2. 运行测试确认通过

### REFACTOR
1. {清理项或"无需"}

## 验证
- 项目测试命令通过

## 涉及文件
- src/file.ext（新建/修改）
```

## 质量门禁

### 每任务门禁

- 测试写且通过（RED → GREEN）
- 无未用 import / 调试代码
- 产出物与 tasks/ 描述一致
- 代码评审通过（REVIEW → FIX）
- git commit 已完成

### 全部完成门禁

- 项目测试命令通过（见 ralph/PROMPT.md 技术栈配置）
- 项目构建命令成功（若有构建步骤）
- 所有验收标准满足

## 技能路由

执行时遵循 `ralph/PROMPT.md` 中的"技能路由"表及降级规则。PROMPT.md 是技能路由的唯一权威来源。

## 最佳实践

1. **任务拆分**：每个任务 5-15 分钟
2. **测试先行**：必须先看到测试失败
3. **最小实现**：只写让测试通过的代码
4. **及时 commit**：每任务完成后立即
5. **进度透明**：TODO.md 是唯一进度来源
6. **检查点备份**：每 Wave 完成后 git tag

## 故障排除

| 问题 | 解决 |
|------|------|
| 测试一直失败 | 暂存变更→单独复现→定位根因→修复→恢复（运行项目测试命令） |
| 任务太复杂 | 拆分为多个子任务（每个 < 15 分钟）|
| 循环无法终止 | `grep '\[ \]' ralph/TODO.md` 检查 |
| 依赖循环 | 拆分其中一个任务打破循环 |
| context 满 | git commit 保存进度，继续下一任务 |
| 技能不存在 | 使用"缺失时替代"列中的方案 |
| 需完全重置 | `sed -i 's/\[x\]/\[ \]/g' ralph/TODO.md`（保留任务定义，清除进度） |
| 需暂停循环 | 在对话中输入 "暂停 ralph"，当前任务 commit 后安全停止 |
| 任务反复熔断 | 自动诊断环境→自动修复→重设计→拆分→标记 [B] 继续后续任务 |

## 经验管理

每完成一个 Wave，在 `ralph/EXPERIENCE.md` 追加本 Wave 的经验总结：

```markdown
## Wave {N}: {名称}
- **完成任务**: {X.Y 列表}
- **关键决策**: {决策及原因}
- **遇到的问题**: {问题及解决方案}
- **给下个 Wave 的建议**: {提示}
```

EXPERIENCE.md 是跨版本升级时的核心参考，确保经验不丢失。

## 参见

- `ralph/PROMPT.md` — 执行规则（循环行为、日志格式、技术栈约束、禁令）
- `ralph/PRD.md` — 项目需求文档
- [reference.md](reference.md) — 完整参考指南（快速开始、故障排除、术语表）
- `/smart-commit` — 规范 commit
- `/test-driven-development` — TDD 循环
- `/verification-before-completion` — 完成前验证