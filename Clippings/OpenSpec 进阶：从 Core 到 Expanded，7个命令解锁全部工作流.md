---
title: "OpenSpec 进阶：从 Core 到 Expanded，7个命令解锁全部工作流"
source: "https://mp.weixin.qq.com/s/sQo8AvfxmKpUvWPIGoY66w"
author:
  - "[[运维有术]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
运维有术 *2026年4月27日 08:30*

> 🚩 2026 年「术哥无界」系列实战文档 X 篇原创计划 第 *95* 篇，AI 编程最佳实战「2026」系列第 *24* 篇
> 
> 大家好，欢迎来到 **术哥无界 | ShugeX ｜ 运维有术** 。
> 
> 我是 **术哥** ，一名专注于 AI 编程、AI 智能体、Agent Skills、MCP、云原生、AIOps、Milvus 向量数据库的 **技术实践者与开源布道者** ！
> 
> **Talk is cheap, let's explore。无界探索，有术而行。**

![[_resources/OpenSpec 进阶：从 Core 到 Expanded，7个命令解锁全部工作流/954086a9937951a123d23ad088a373ca_MD5.webp]]

OpenSpec Expanded Workflow 全景概览

*图 1：OpenSpec Expanded Workflow 命令全景概览*

如果你已经用 OpenSpec 跑通了 propose → apply → archive 的基本流程，可能会碰到一些力不从心的场景：想在实现之前逐个审查制品、多个变更同时进行需要并行管理、或者实现完了想检查代码和规格是不是真的对得上。

这些场景，core profile 处理不了。OpenSpec 的 Expanded Workflow 就是为此设计的——它在 core 的基础上新增了 7 个命令，提供更细粒度的制品控制、实现验证和并行变更管理。

翻了一圈官方文档，发现 expanded 模式的设计思路和 core 有本质区别：core 追求 **快** ，expanded 追求 **可控** 。这篇就把这 7 个命令、4 种工作流模式、以及什么时候该用哪个，全部拆开来讲清楚。

## 1\. 从 Core 到 Expanded：为什么需要更多命令？

### Core 做了什么

Core profile 是 OpenSpec 安装后的默认模式，提供 4 个命令：

| 命令 | 用途 |
| --- | --- |
| `/opsx:propose` | 一步创建变更 + 生成全部规划制品 |
| `/opsx:explore` | 开发前梳理思路 |
| `/opsx:apply` | 执行任务、编写代码 |
| `/opsx:archive` | 归档已完成的变更 |

流程很简单： `/opsx:propose` → `/opsx:apply` → `/opsx:archive` ，三步搞定。适合需求明确、范围可控的中小变更。

### Core 做不了什么

根据官方文档和社区反馈（GitHub Issues #1001、#973），core 模式有几个明显的局限：

- **无法逐步审查制品** — `/opsx:propose` 一次性生成 proposal、specs、design、tasks 四个文件，你只能事后修改
- **无法验证实现** — 写完代码后没有办法自动检查代码是否和规格一致
- **无法并行管理变更** — 多个变更同时进行时，归档需要逐个处理
- **无法控制工作流节奏** — 要么全生成，要么不生成

Expanded Workflow 正是为了填补这些缺口。

### 如何启用

根据官方文档（来源：docs/workflows.md），启用 expanded 模式只需要两步：

```
# 第一步：选择 expanded profile
openspec config profile

# 第二步：刷新 AI 助手指令
openspec update
```

运行 `openspec config profile` 后会出现交互式选择，选 expanded 即可。 `openspec update` 会重新生成 `.claude/skills/` （或对应工具的指令目录），让 AI 助手识别新的命令。

![Core vs Expanded 工作流对比](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

Core vs Expanded 工作流对比

*图 2：Core 工作流（4 命令线性）vs Expanded 工作流（11 命令网状）对比*

## 2\. 7 个 Expanded 命令全解析

先看全局命令表，后面逐个展开。

| 命令 | 核心功能 | 一句话总结 |
| --- | --- | --- |
| `/opsx:new` | 创建变更脚手架 | 只建目录，不生成制品 |
| `/opsx:continue` | 逐步创建制品 | 按依赖关系生成下一个制品 |
| `/opsx:ff` | 快速生成所有制品 | 一步到位，类似 core 的 propose |
| `/opsx:verify` | 验证实现 | 检查代码和规格是否一致 |
| `/opsx:sync` | 同步规格 | 把增量规格合并到主规格 |
| `/opsx:bulk-archive` | 批量归档 | 一次归档多个变更 |
| `/opsx:onboard` | 引导式教程 | 用实际代码库学习完整流程 |

### /opsx:new — 变更脚手架

这是 expanded 模式的起点。和 `/opsx:propose` 不同， `/opsx:new` 只做一件事：创建变更目录和元数据文件，不生成任何制品。

```
You: /opsx:new add-dark-mode

AI:  Created openspec/changes/add-dark-mode/
     Schema: spec-driven

     Ready to create: proposal
     Use /opsx:continue to create it, or /opsx:ff to create all artifacts.
```

根据官方文档（来源：docs/commands.md）， `/opsx:new` 的行为：

- 创建 `openspec/changes/<change-name>/` 目录
- 创建 `.openspec.yaml` 元数据文件（记录 schema、创建日期）
- 显示当前可创建的制品模板
- 支持 `--schema <name>` 参数指定工作流 schema

关键点： **脚手架创建后，你可以选择用 `/opsx:continue` 逐步生成，也可以用 `/opsx:ff` 一次性生成** 。这种灵活性是 core 模式没有的。

### /opsx:continue — 逐步创建制品

这是 expanded 模式的核心命令。它按照制品依赖图（DAG），一次只生成一个制品，让你可以在每一步审查和修改。

```
You: /opsx:continue

AI:  Change: add-dark-mode

     Artifact status:
     ✓ proposal    (done)
     ◆ specs       (ready)
     ◆ design      (ready)
     ○ tasks       (blocked - needs: specs)

     Creating specs...

     [Reads proposal.md, creates specs based on requirements]

     ✓ Created openspec/changes/add-dark-mode/specs/ui/spec.md

     Now available: tasks
     Run /opsx:continue to create the next artifact.
```

根据官方文档，这个命令的工作流程是：

1. 查询制品依赖图，判断哪些制品处于 ready 状态（所有前置依赖已完成）
2. 显示当前所有制品的状态（✓ done / ◆ ready / ○ blocked）
3. 创建第一个 ready 状态的制品
4. 创建完成后，显示哪些新制品被解锁

**为什么这个命令重要？** 在复杂变更中，你可以在生成 specs 之后停下来审查，确认需求覆盖到位了再继续。也可以在 design 之后发现方案有问题，回去修改 proposal。这种控制粒度在 core 的 `/opsx:propose` 里是做不到的。

### /opsx:ff — 快速生成所有制品

`ff` 是 fast-forward 的缩写。它的行为和 core 的 `/opsx:propose` 类似——一次性生成所有规划制品。

```
You: /opsx:ff add-dark-mode

AI:  Fast-forwarding add-dark-mode...

     ✓ Creating proposal.md
     ✓ Creating specs/ui/spec.md
     ✓ Creating design.md
     ✓ Creating tasks.md

     All planning artifacts complete!
     Ready for implementation. Run /opsx:apply to begin.
```

根据官方文档（来源：docs/commands.md）， `/opsx:ff` 的特点：

- 按依赖顺序创建所有制品
- 通过 todo 列表跟踪进度
- 每创建一个制品前，先读取其依赖文件获取上下文
- 当所有 `apply-required` 制品完成后停止

**什么时候用 `/opsx:ff` 而不是 `/opsx:continue` ？** 官方给了一个很实用的判断标准：

> 如果你能提前描述完整的范围，用 `/opsx:ff` 。如果你是在过程中逐步理清需求，用 `/opsx:continue` 。

### /opsx:verify — 验证实现与规格的一致性

这是 expanded 模式独有的命令，也是和 core 模式差距明显的一个。根据官方文档（来源：docs/commands.md）， `/opsx:verify` 从三个维度检查实现质量：

| 维度 | 检查内容 |
| --- | --- |
| **Completeness（完整性）** | 所有任务是否完成、需求是否都有对应代码、场景是否覆盖 |
| **Correctness（正确性）** | 实现是否匹配规格意图、边界情况是否处理 |
| **Coherence（一致性）** | 设计决策是否反映在代码结构中、命名是否和 design.md 一致 |

实际输出长这样：

```
You: /opsx:verify

AI:  Verifying add-auth...

     COMPLETENESS
     ✓ All 12 tasks in tasks.md are checked
     ✓ All requirements in specs have corresponding code
     ⚠ Scenario "Session timeout after inactivity" not tested

     CORRECTNESS
     ✓ Implementation matches spec intent
     ✓ Edge cases from scenarios are handled
     ✓ Error states match spec definitions

     COHERENCE
     ✓ Design decisions reflected in code structure
     ✓ Naming conventions consistent with design.md
     ⚠ Design mentions "event-driven" but implementation uses polling

     SUMMARY
     Critical issues: 0
     Warnings: 2
     Ready to archive: Yes (with warnings)

     Recommendations:
     1. Add test for session timeout scenario
     2. Consider refactoring to event-driven as designed, or update design.md
```

说实话，verify 不会阻止归档。它只是把问题暴露出来，让你决定要不要处理。官方的建议是：在 `/opsx:archive` 之前先跑一次 verify，能提前发现规格和实现之间的偏差。

![/opsx:verify 三维度验证示意图](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

/opsx:verify 三维度验证示意图

*图 3：/opsx:verify 三维度验证（完整性/正确性/一致性）检查机制*

### /opsx:sync — 同步增量规格

这个命令的行为比较特殊。根据官方文档（来源：docs/commands.md）， `/opsx:sync` 是 **可选命令** ——归档时会自动提示同步，大多数情况下你不需要手动调用。

```
You: /opsx:sync

AI:  Syncing add-dark-mode delta specs...

     Reading: openspec/changes/add-dark-mode/specs/ui/spec.md
     Target:  openspec/specs/ui/spec.md

     Changes to apply:
     ✓ ADDED: Theme Selection requirement (2 scenarios)
     ✓ ADDED: Accessibility requirement (1 scenario)

     Merging...
     ✓ openspec/specs/ui/spec.md updated

     Change remains active. Run /opsx:archive when ready to complete.
```

手动 sync 适合以下场景（来源：docs/commands.md）：

| 场景 | 是否需要手动 sync |
| --- | --- |
| 长期运行的变更，想在归档前就更新主规格 | 是 |
| 多个并行变更需要共享更新后的基础规格 | 是 |
| 想单独审查合并结果 | 是 |
| 快速变更，直接归档 | 不需要（archive 会处理） |

sync 的一个重要特性： **变更在 sync 后仍然保持活跃状态** ，不会自动归档。这意味着你可以先 sync 让其他变更受益于更新后的规格，再继续完善当前变更。

### /opsx:bulk-archive — 批量归档

当你有多个变更同时进行时，逐个归档效率很低。 `/opsx:bulk-archive` 可以一次处理多个已完成的变更。

```
You: /opsx:bulk-archive

AI:  Found 3 completed changes:
     - add-dark-mode (all tasks done)
     - fix-login-redirect (all tasks done)
     - update-footer (all tasks done)

     Checking for spec conflicts...
     ⚠ add-dark-mode and update-footer both touch specs/ui/

     Inspecting codebase to resolve...
     Both changes are implemented. Will apply in chronological order.

     Archive all 3 changes?

You: Yes

AI:  ✓ Archived add-dark-mode
     ✓ Archived fix-login-redirect
     ✓ Archived update-footer
     Specs merged in order: add-dark-mode → update-footer
```

根据官方文档（来源：docs/workflows.md）， `/opsx:bulk-archive` 的亮点在于 **冲突检测** ：当多个变更修改同一个规格文件时，它会检查实际实现情况，按创建时间顺序合并。这个处理方式比简单的文本合并要靠谱得多。

### /opsx:onboard — 交互式教程

这个命令适合刚接触 expanded 工作流的开发者。根据官方文档（来源：docs/commands.md）， `/opsx:onboard` 会：

1. 扫描你的代码库，找到真实可改进的点
2. 用实际代码走完一个完整的变更流程
3. 在每一步都附上解说

整个过程大约 15-30 分钟，走完你对 expanded 工作流就有了一个直观的感受。比看文档直接上手快多了。

## 3\. 4 种工作流模式详解

官方文档（来源：docs/workflows.md）定义了 4 种典型的工作流模式。不同模式对应不同场景，选对了能少走弯路。

### Quick Feature — 快速功能

```
/opsx:new ──► /opsx:ff ──► /opsx:apply ──► /opsx:verify ──► /opsx:archive
```

**适用场景** ：需求明确、范围可控的中小功能。

这个模式和 core 的 propose → apply → archive 很像，区别在于中间多了一步 verify。如果你对代码质量有要求，verify 能帮你提前发现实现和规格之间的偏差。

完整交互示例（来源：docs/workflows.md）：

```
You: /opsx:new add-logout-button

AI:  Created openspec/changes/add-logout-button/
     Ready to create: proposal

You: /opsx:ff

AI:  Creating all planning artifacts...
     ✓ proposal.md
     ✓ specs/
     ✓ design.md
     ✓ tasks.md
     Ready for implementation!

You: /opsx:apply

AI:  Working through tasks...
     ✓ Added logout button to header
     ✓ Implemented session clearing
     ✓ Added confirmation dialog
     All tasks complete!

You: /opsx:verify

AI:  Verifying add-logout-button...
     ✓ All tasks in tasks.md are checked
     ✓ Requirements in specs have corresponding code
     Ready to archive!

You: /opsx:archive

AI:  ✓ Merged specs
     ✓ Archived change
```

### Exploratory — 探索式开发

```
/opsx:explore ──► /opsx:new ──► /opsx:continue ──► ... ──► /opsx:apply
```

**适用场景** ：需求不明确、需要先调研再动手。

这个模式的特点是 **先探索再动手** 。 `/opsx:explore` 是一个自由对话命令，AI 会分析你的代码库、对比多种方案、甚至画图帮你理清思路。等你想明白了，再通过 `/opsx:new` + `/opsx:continue` 逐步创建制品。

```
You: /opsx:explore

AI:  What would you like to explore?

You: I want to improve page load performance but I'm not sure
     where the bottlenecks are.

AI:  Let me help investigate...
     [Analyzes bundle sizes, identifies slow queries, reviews
     component render patterns]

     I found three main bottlenecks:
     1. Large unoptimized images
     2. Synchronous data fetching in ProductList
     3. Re-renders from context changes

     Which would you like to address first?
```

官方把这个模式定位为 **动手前的思考伙伴** 。说实话，这个功能在性能优化、架构重构这种需求模糊的场景下确实好用，比直接让 AI 写方案要靠谱。

### Parallel Changes — 并行变更

```
Change A: /opsx:new ──► /opsx:ff ──► /opsx:apply (进行中)
                                            │
                                       上下文切换
                                            │
Change B: /opsx:new ──► /opsx:ff ──────► /opsx:apply
```

**适用场景** ：多个变更同时进行、紧急 bug 修复打断正常开发。

并行变更的核心思路是： **每个变更是独立的文件夹** ，互不干扰。你可以随时暂停一个变更去处理另一个，完成后用 `/opsx:apply <change-name>` 切回来。

```
You: I'm working on add-dark-mode but got pulled into a bug fix

You: /opsx:new fix-login-redirect

AI:  Created openspec/changes/fix-login-redirect/

You: /opsx:ff && /opsx:apply

AI:  Working on fix-login-redirect...
     [Implements the fix]
     All tasks complete!

You: /opsx:archive

AI:  ✓ Archived fix-login-redirect

You: Let's get back to dark mode

You: /opsx:apply add-dark-mode

AI:  Resuming add-dark-mode...
     Picking up at task 2.3: Update Header...
```

多个变更完成后，用 `/opsx:bulk-archive` 一次性归档。

### Completing a Change — 完成变更

```
/opsx:apply ──► /opsx:verify ──► /opsx:archive
                    │                 │
              验证实现          提示同步规格
```

这是 expanded 模式推荐的收尾流程。先 apply 实现代码，再 verify 检查一致性，确认没问题后 archive 归档。archive 时如果规格还没同步，会自动提示你。

![4 种工作流模式概览](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

4 种工作流模式概览

*图 4：OpenSpec Expanded Workflow 的 4 种工作流模式及适用场景*

你在项目中更倾向于哪种模式？欢迎在评论区聊聊，说说你的使用场景。

## 4\. ff vs continue：一个实用的决策框架

这两个命令都能创建制品，但使用方式差别很大。官方文档（来源：docs/workflows.md）给了一个清晰的对比：

| 场景 | 选择 | 原因 |
| --- | --- | --- |
| 需求清晰，可以直接开干 | `/opsx:ff` | 一步到位，效率高 |
| 需求模糊，边做边想 | `/opsx:continue` | 可以在每一步停下来审查和修改 |
| 想先改 proposal 再生成 specs | `/opsx:continue` | 逐步控制，灵活调整 |
| 时间紧，快速推进 | `/opsx:ff` | 减少中间交互 |
| 复杂变更，需要精细控制 | `/opsx:continue` | 每个制品都能审查 |

说白了就一句话： **你心里有谱用 ff，心里没谱用 continue** 。

## 5\. 什么时候更新，什么时候从头开始？

在 expanded 模式下，你可以随时修改已创建的制品。但问题是：什么时候该修改现有变更，什么时候该新建一个？

官方文档（来源：docs/workflows.md）给出了明确的原则：

**更新现有变更的情况** ：

- 意图没变，只是执行方式微调
- 范围缩小了（先做 MVP，剩下的后面再说）
- 实现过程中发现代码库和预期不一样，需要调整方案

**新建变更的情况** ：

- 意图发生了根本变化
- 范围膨胀到完全不同的工作
- 原变更可以独立完成并归档

用官方的例子来说：如果变更名是 **添加暗黑模式** ，那 **需要支持自定义主题** 应该新建变更（范围膨胀了），但 **系统偏好检测比预期复杂** 只需要更新现有变更（意图没变）。

这个判断原则很像 Git 分支管理——同一条特性继续 commit，不同的工作开新分支。

## 6\. 制品依赖关系：理解 DAG 的工作原理

expanded 模式的底层是制品依赖图（DAG）。理解这个结构，能帮你更好地使用 `/opsx:continue` 和 `/opsx:ff` 。

根据官方文档（来源：docs/concepts.md），默认的 `spec-driven` schema 定义了这样的依赖关系：

```
proposal
                (根节点)
                    │
      ┌─────────────┴─────────────┐
      │                           │
      ▼                           ▼
   specs                       design
(依赖: proposal)            (依赖: proposal)
      │                           │
      └─────────────┬─────────────┘
                    │
                    ▼
                  tasks
              (依赖: specs, design)
```

每个制品有三个状态：

| 状态 | 含义 |
| --- | --- |
| **BLOCKED** | 前置依赖还没完成 |
| **READY** | 所有依赖已完成，可以创建 |
| **DONE** | 文件已存在 |

关键洞察： **specs 和 design 都只依赖 proposal，所以它们可以并行创建** 。但 tasks 同时依赖 specs 和 design，必须等两者都完成。这就是为什么用 `/opsx:continue` 时，specs 和 design 可能同时显示为 ready 状态。

这个 DAG 是可以定制的——如果你觉得自己的工作流不需要 design，完全可以通过自定义 schema 去掉它。

![制品依赖关系 DAG 可视化](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

制品依赖关系 DAG 可视化

*图 5：spec-driven schema 制品依赖关系（DAG），specs 和 design 可并行创建*

## 7\. 自定义 Schema：定制你的工作流

如果 `spec-driven` 默认的制品链（proposal → specs → design → tasks）不适合你的团队，OpenSpec 支持自定义 schema。

根据官方文档（来源：docs/customization.md），有三种方式：

**从现有 schema 复制修改** ：

```
# 复制 spec-driven schema 作为起点
openspec schema fork spec-driven my-workflow
```

**从零创建** ：

```
# 交互式创建
openspec schema init research-first
```

**自定义示例 — 极简工作流** （来源：docs/customization.md）：

```
# openspec/schemas/rapid/schema.yaml
name:rapid
version:1
description:Fastiterationwithminimaloverhead

artifacts:
-id:proposal
    generates:proposal.md
    description:Quickproposal
    template:proposal.md
    instruction:|
      Create a brief proposal for this change.
      Focus on what and why, skip detailed specs.
    requires:[]

-id:tasks
    generates:tasks.md
    description:Implementationchecklist
    template:tasks.md
    requires:[proposal]

apply:
requires:[tasks]
tracks:tasks.md
```

这个极简 schema 只有两个制品（proposal → tasks），跳过了 specs 和 design。适合快速迭代、不需要详细规格的团队。

验证 schema 是否正确：

```
openspec schema validate my-workflow
```

这个命令会检查语法、模板是否存在、是否有循环依赖。

## 8\. Core vs Expanded 全景对比

把两种模式放在一起看，差异一目了然：

| 维度 | Core | Expanded |
| --- | --- | --- |
| 命令数量 | 4 个 | 11 个（含 core 的 4 个） |
| 制品创建方式 | 一次性全部生成 | 可逐步生成或一次性生成 |
| 实现验证 | 无 | `/opsx:verify`  三维度检查 |
| 并行变更管理 | 逐个归档 | `/opsx:bulk-archive`  批量处理 |
| 规格同步 | 归档时自动处理 | 可手动 `/opsx:sync` 提前同步 |
| 入门教程 | 无 | `/opsx:onboard`  交互式教程 |
| 适用场景 | 中小功能、需求明确 | 复杂变更、并行开发、需要验证 |

**怎么选？** 官方文档（来源：docs/workflows.md）的建议很直接：新项目从 core 开始，当你发现 core 满足不了需求时再切到 expanded。两者在制品结构上完全兼容，切换不需要迁移。

## 最佳实践

根据官方文档和社区反馈，整理了几条实用的建议：

1. **变更粒度要小** — 一个变更只做一件事。 **添加暗黑模式 + 重构认证系统** 应该拆成两个变更。这样归档历史更清晰，出问题也更容易回滚。
2. **命名要有意义** — `add-dark-mode` 比 `feature-1` 好得多。因为 `openspec list` 显示的是变更名，好名字让你一眼就知道每个变更在做什么。
3. **verify 要在 archive 前跑** — 虽然它不会阻止归档，但提前发现问题和上线后发现问题的代价完全不同。
4. **探索阶段用 explore，别直接 propose** — 官方文档明确说了， `/opsx:explore` 不会创建任何制品，纯粹是分析和讨论。等想清楚了再创建变更，比中途改来改去效率高。
5. **并行变更要注意规格冲突** — 如果两个变更修改同一个规格文件， `/opsx:bulk-archive` 能自动检测并解决。但如果条件允许，还是尽量避免两个变更同时改同一个模块。
6. **Context Hygiene（上下文卫生）** — 官方 README 特别提到：在开始实现之前清空上下文窗口，保持良好的上下文卫生。这个建议在 expanded 模式下尤其重要，因为你会频繁切换变更。

## 总结

OpenSpec 的 Expanded Workflow 不是把 core 做的事变得更复杂，而是在需要控制粒度的场景下提供更多选择。7 个新命令各有分工：

- `/opsx:new` + `/opsx:continue` 给你逐步控制制品的能力
- `/opsx:verify` 让你在归档前确认实现和规格对齐
- `/opsx:sync` 提前合并增量规格，支持并行变更
- `/opsx:bulk-archive` 解决多变更归档效率问题
- `/opsx:onboard` 降低学习门槛

如果你正在用 OpenSpec 管理 AI 辅助开发流程，而 core 模式开始显得力不从心，不妨切到 expanded 试试。先跑一遍 `/opsx:onboard` ，用实际代码库走一遍完整流程，比看文档的体感要强得多。

**相关资源**

OpenSpec 官方仓库：https://github.com/Fission-AI/OpenSpec

官方文档 - Workflows：https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md

官方文档 - Commands：https://github.com/Fission-AI/OpenSpec/blob/main/docs/commands.md

官方文档 - Customization：https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md

Discord 社区：https://discord.gg/YctCnvvshC

**好啦，谢谢你观看我的文章，如果喜欢可以点赞转发给需要的朋友，我们下一期再见！敬请期待！**

**扫码关注，获取更多 AI 工具的实战经验和最佳实践。不错过每一篇干货！**

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**加入交流群，共同交流，共同进步！**

![wxq-0426](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**微信扫一扫赞赏作者**

AI编程最佳实战「2026」 · 目录

继续滑动看下一个

术哥无界

向上滑动看下一个