---
title: "Superpowers + GSD：Claude Code 的双模式工作流实战"
source: "https://mp.weixin.qq.com/s/osgThwPHOyTqZ_YVh-Gz8w"
author:
  - "[[月影]]"
published:
created: 2026-05-15
description: "Superpowers 技能系统和 GSD 项目管理如何在 Claude Code 中协同工作。本文介绍从创意到落地的完整路径：brainstorming 探索方向、PLAN.md 规划实现、execute-plan 执行交付，以及如..."
tags:
  - "clippings"
---
月影 *2026年4月15日 06:00*

![[_resources/Superpowers + GSD：Claude Code 的双模式工作流实战/59127a81aa05cfe99251ad87e642384f_MD5.webp]]

**📄 核心要点**

- Superpowers 和 GSD 是互补的两层抽象
- brainstorming → writing-plans → execute-plan 覆盖从想法到交付的完整路径
- 两者结合让 Claude Code 的行为更可预测

---

## 痛点：单独用哪一种都不够

用 Claude Code 一段时间后，你可能会遇到两类困境。

**只用 Superpowers 技能** ：brainstorming 很爽，但想法落地没有节奏感。plan 写出来了，实际执行时还是东一榔头西一棒槌，commit 历史混乱，中途想回归原始计划更是无从下手。

**只用 GSD 工作流** ：PLAN.md 写得详细，但 plan 本身是从哪里来的？光有一个框架，没有前期探索和后期审查，容易在错误的方向上走很远。

我自己的实践是把两者组合起来：Superpowers 负责"做什么"的探索和判断，GSD 负责"怎么做"的节奏和追踪。两条线并行，互补而不干扰。

本文介绍这个组合的协作机制和实操流程。

![[_resources/Superpowers + GSD：Claude Code 的双模式工作流实战/584cfcf4d6ba3f7fbd033e5de885f176_MD5.webp]]

---

## 前置准备：安装两个系统

在开始之前，需要先把两个系统装进 Claude Code。

### 安装 Superpowers

Superpowers 由 obra/superpowers 提供，安装方式如下：

**方式一：官方插件市场（推荐）**

bash

```
/plugin install superpowers@claude-plugins-official
```

**方式二：通过插件市场注册**

bash

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

安装完成后，开启一个新对话，说一句"帮我规划一下这个功能"——Agent 会自动触发 brainstorming 技能，说明安装成功。

### 安装 GSD

GSD 由 gsd-build/get-shit-done 提供，一行命令即可：

bash

```
npx get-shit-done-cc@latest
```

交互式安装程序会提示你选择目标平台（Claude Code、OpenCode、Gemini CLI 等）和安装范围（全局 / 当前项目）。非交互式安装：

bash

```
# 全局安装（所有项目可用）
npx get-shit-done-cc --claude --global

# 本地安装（仅当前项目）
npx get-shit-done-cc --claude --local
```

### 验证安装成功

两个系统都装好后，输入以下命令确认：

bash

```
/gsd-help
```

看到 GSD 命令列表（/gsd-new-project、/gsd-plan-phase、/gsd-execute-phase 等）即安装成功。Superpowers 无需单独验证——它会在你开始描述需求时自动触发。

---

## 第一层抽象：Superpowers 技能系统

Superpowers 是一套 \[Claude Code 技能集合\](https://github.com/anthropics/claude-code skills)，覆盖开发全生命周期的关键节点。每个技能都是一个独立的 `/slash` 命令，调用时有明确的进入条件和退出契约。

### 核心技能一览

| 技能 | 触发命令 | 输入 | 输出 |
| --- | --- | --- | --- |
| brainstorming | `/superpowers:brainstorming` | 问题描述 | 探索结论、方向建议 |
| writing-plans | `/superpowers:writing-plans` | SPEC/需求 | 可执行的 PLAN.md |
| executing-plans | `/superpowers:executing-plans` | PLAN.md | 代码交付物 |
| code-review | `/superpowers:requesting-code-review` | 代码变更 | review 报告 |

这些技能的核心价值是 **强制结构化** 。你在 brainstorming 里输出的内容，会直接成为 writing-plans 的输入；writing-plans 产生的 PLAN.md，是 executing-plans 的执行蓝图。每个环节有明确的输入输出，不允许跳步。

### 执行一次完整的 brainstorming

bash

```
# 在 Claude Code 里直接调用
/superpowers:brainstorming
```

交互式提问会引导你描述问题背景、约束条件、期望结果。brainstorming 的输出不是直接给 execute 用的——它是一份结构化的探索笔记，包含：方向选项、风险评估、推荐路径。

我自己在用的时候，通常在 brainstorming 结尾追问一句："如果按推荐路径做，第一步是什么？"——这个问题能把探索结论直接转化为 plan 的起始点。

---

## 第二层抽象：GSD 工作流

GSD（Getting Stuff Done）是一套轻量的项目阶段管理框架。它的核心思想是： **把所有工作拆成 phase（阶段），每个 phase 有明确的 goal（目标）和结束条件** 。

### GSD 的核心命令

bash

```
# 查看当前工作区状态
/gsd-progress

# 创建新 phase 并开始规划
/gsd-plan-phase

# 执行当前 phase 的所有 plan
/gsd-execute-phase

# 验证当前 phase 的交付物
/gsd-verify-work
```

GSD 的 phase 不是狭义的"开发阶段"——它可以是"需求确认"、"技术调研"、"MVP 实现"、"Beta 测试"。phase 的边界由你定义，GSD 只负责追踪状态和依赖。

### phase 之间的关系

相邻 phase 之间有明确的依赖声明：

markdown

```
## Phase 3: MVP 实现

Depends on: Phase 2 (技术调研)

Goal: 完成核心功能可运行的最小版本

Success criteria:
- 用户可以完成一次完整操作流程
- 单元测试覆盖率达到 70%
```

这种 `Depends on` 声明是 GSD 的精髓之一。它让"做完了吗"变成一个有据可查的事实，而不是凭感觉判断。

---

## 两者如何协同：双模式工作流

Superpowers 技能和 GSD 工作流的结合点，在于 **它们作用于不同的抽象层次** 。

![Superpowers 探索层与 GSD 执行层协作示意图](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**层间传递的载体是 PLAN.md** 。Superpowers 的 writing-plans 输出标准的 PLAN.md；GSD 的 execute-phase 读取 PLAN.md 并按 wave 执行。

### 具体流程演示

**第一步：brainstorming 探索方向**

code

```
/superpowers:brainstorming
> 我们的内部工具需要从单体拆成微服务，怎么拆？什么时候拆？
```

brainstorming 输出包含：当前架构痛点、拆分方案选项（渐进式 vs 重写式）、推荐路径（渐进式）、风险点。

**第二步：writing-plans 生成 PLAN.md**

code

```
/superpowers:writing-plans
> 基于上一步的 brainstorming 结果，生成 Phase 1 的实现计划
```

输出： `PLAN.md` ，包含 phase goal、task breakdown（带依赖图）、verification criteria。

**第三步：GSD 接管执行节奏**

bash

```
/gsd-plan-phase
# 创建 Phase 1: 微服务拆分第一阶段

/gsd-execute-phase
# 按 wave-1 / wave-2 / wave-3 顺序执行
```

GSD 的 execute-phase 会自动解析 PLAN.md 中的 task 依赖，按拓扑顺序分 wave 执行。每个 wave 完成后提示验证结果，不通过则停在当前 wave。

**第四步：Superpowers code-review 把关质量**

bash

```
/superpowers:requesting-code-review
```

在每个 wave 结束或 phase 收尾时调用。review 报告会列出代码质量问题、安全风险和可改进点——这是 Superpowers 技能系统里最后一层防护网。

---

## 为什么这个组合值得用

**Superpowers 解决了"想清楚"的问题。** brainstorming 的强制提问让你在动手之前先审视方向，writing-plans 把模糊的想法翻译成可执行的任务列表。没有这一步，执行时很容易走偏。

**GSD 解决了"做完整"的问题。** phase 的边界和依赖声明让进度可见，execute-phase 的 wave 机制让大任务可以被分批交付和验证。没有这一层，plan 很容易变成"写了没人看的文档"。

**两者叠加后，Claude Code 的行为变得更可预测。** 因为每个阶段有明确的进入条件和退出标准，AI 在每个节点都知道自己该做什么、不该做什么。

下面这张对比说明了两种模式的差异：

| 维度 | 单独用 Superpowers | 单独用 GSD | Superpowers + GSD |
| --- | --- | --- | --- |
| 方向探索 | brainstorming ✅ | 无 | brainstorming ✅ |
| 任务拆解 | writing-plans ✅ | PLAN.md 手动写 | writing-plans ✅ |
| 执行节奏 | 无 | phase + wave ✅ | phase + wave ✅ |
| 进度可见性 | 低 | 中 | 高 |
| 代码质量把关 | code-review ✅ | 无 | code-review ✅ |

我自己在迁移一个旧 Python 项目时用过这个组合：brainstorming 确定技术选型（渐进式迁移而非重写），writing-plans 拆出 3 个 phase，每个 phase 用 GSD 的 wave 机制分批交付。结果是整个迁移过程有清晰的节奏感，每个周末的 MR 都能在周一顺利 review 通过。

来看一个具体 phase 的 PLAN.md 结构，体会 Superpowers 和 GSD 是如何在这里汇合的：

markdown

```
## Phase 1: 数据库访问层重构

Depends on: (none — 首个 phase)

Goal: 将所有直接 SQL 拼接替换为 ORM 查询，统一错误处理。

Tasks:
- [ ] 识别项目中所有直接使用 \`cursor.execute()\` 的位置
- [ ] 引入 SQLAlchemy session 管理
- [ ] 替换旧查询（wave-1: 只读查询）
- [ ] 替换旧查询（wave-2: 写操作）
- [ ] 添加集成测试覆盖

Success criteria:
- 无直接 cursor.execute() 调用残留
- 集成测试覆盖率 > 80%
```

GSD 执行时会按 wave 顺序推送这些任务，遇到 `[ ]` 标记会停在当前 wave 等你确认后才继续：

bash

```
$ /gsd-execute-phase
Wave 1: 识别 + 引入 SQLAlchemy + 替换只读查询
  → 3 tasks completed
  → Wave 1 verification: PASS

Wave 2: 替换写操作 + 添加集成测试
  → 2 tasks completed
  → Wave 2 verification: PASS

Phase 1: COMPLETE ✅
```

---

## 快速上手：第一次组合调用

bash

```
# 1. 启动 brainstorming
/superpowers:brainstorming

# 2. 生成第一个 phase plan
/superpowers:writing-plans

# 3. 创建 GSD phase 并开始执行
/gsd-plan-phase
/gsd-execute-phase

# 4. 每批任务完成后做一次 review
/superpowers:requesting-code-review

# 5. 验证通过后进入下一个 phase
/gsd-next
```

如果你现在有一个具体的项目在推进，试着用这个流程走一遍第一个 phase。第一轮可能会有点慢（brainstorming 和 writing-plans 都要求你思考清楚再动手），但从第二个 phase 开始，你会明显感受到积累的效果——之前的 brainstorming 结论和 PLAN.md 都可以复用。

---

**💡 延伸阅读**

如果你想深入了解 GSD 的 phase 依赖分析和 wave 执行机制，可以查看 `/gsd-plan-phase` 的详细文档。Superpowers 技能系统的完整列表在 CLAUDE.md 中。

ai · 目录

继续滑动看下一个

CostaLong

向上滑动看下一个