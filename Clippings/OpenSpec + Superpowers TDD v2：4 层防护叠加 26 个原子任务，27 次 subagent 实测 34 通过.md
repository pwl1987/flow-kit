---
title: "OpenSpec + Superpowers TDD v2：4 层防护叠加 26 个原子任务，27 次 subagent 实测 3/4 通过"
source: "https://mp.weixin.qq.com/s/OdlXmm7pSeQ8jiMZIF_rsQ"
author:
  - "[[运维有术]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
运维有术 *2026年5月6日 08:30*

> 🚩 2026 年「术哥无界」系列实战文档 X 篇原创计划 第 *103* 篇，AI 编程最佳实战「2026」系列第 *28*
> 
> 大家好，欢迎来到 **术哥无界 | ShugeX ｜ 运维有术** 。
> 
> 我是 **术哥** ，一名专注于 AI 编程、AI 智能体、Agent Skills、MCP、云原生、AIOps、Milvus 向量数据库的 **技术实践者与开源布道者** ！
> 
> **Talk is cheap, let's explore。无界探索，有术而行。**

![[_resources/OpenSpec + Superpowers TDD v2：4 层防护叠加 26 个原子任务，27 次 subagent 实测 34 通过/2badd98956853ab5fbdcd16c902a9b1f_MD5.webp]]

封面图：四层防护模型信息图

用 OpenSpec 自定义 Schema + Superpowers subagent 编排，让 AI 按 TDD 流程写代码。v1 完全失败——AI 一口气写完所有代码，跳过 RED 阶段。v2 做了 4 层防护修正，拆成 26 个原子任务，实测 dispatch 了 27 次 subagent，3 层防护通过，1 层被 AI 跳过了。

失败根因不在 instruction 措辞，在 **任务粒度** 。这篇文章复盘完整过程，给出可直接复制的 `schema.yaml` 。

> **说明** ：本文内容基于 OpenSpec（Fission-AI/OpenSpec）和 Superpowers（obra/superpowers）的源码分析及 Mini Markdown 转换器的实际操作验证。源码分析基于笔者本地仓库版本，已在 Mini Markdown 项目中完成主要场景验证。 **文中的配置模板和参数建议仅供参考，实际效果请以你的业务数据和环境测试结果为准。** 如果有实际使用经验，欢迎在评论区分享交流。

## 第一节：问题复盘 - v1 为什么失败了

### v1 做了什么

第一版 Schema 的设计思路很直观：在 OpenSpec 的 `instruction` 里写一大段 TDD 规则，要求 AI 按 RED-GREEN-REFACTOR 循环执行。propose 阶段的产物看起来也不错——proposal 里有 WHEN/THEN 格式的可测试行为，specs 用了 GIVEN/WHEN/THEN，文档规范化确实有效。

但到 apply 阶段就崩了。AI 一口气写完所有代码，跳过了 RED 阶段，测试是写完实现后补的。TDD 形同虚设。

### 失败根因：任务粒度，不是措辞

一开始很容易归因为 **instruction 不够强** 或者 **AI 不听话** 。但翻了一遍源码之后，根因很清楚。

先看 OpenSpec 的真实能力边界（基于源码分析）：

**`tracks` 是 checkbox 解析器** 。它的正则 `/^[-*]\s*\[([ xX])\]\s*(.+)\s*$/` 只认 `- [ ]` 格式的行（末尾 `\s*` 会自动去除行尾空白）。非 checkbox 行被静默忽略，不报错也不警告。如果你的 tasks.md 里有段落描述、标题说明这些非 checkbox 内容， `tracks` 直接跳过，完全不管。

**`requires` 是文件存在性检查** 。它检查文件是否存在，不存在则标记 `state: blocked` 。但 **只检查存在，不检查内容** （ `resolveArtifactOutputs` 只做 glob 匹配，不读文件内容）。

注意区分两个阶段：

- **propose 阶段** （artifact 依赖解析）： `requires` 影响解析顺序，属于 "enabler not gate"——缺失不阻止生成
- **apply 阶段** ：缺失 required artifacts 会直接 `state: 'blocked'` ，硬阻止执行

**`instruction` 是纯文本注入** 。通过 CLI 输出到 stdout，AI skill 读取。注入是确定发生的（代码保证了这一步），但执行完全取决于 AI 的自主决策。OpenSpec 源码里搜索不到任何 hook、callback 或事件机制——零个运行时回调点。

再看 v1 的 tasks.md 产出：

```
Task 1: 创建 Todo 接口
  Test description: 验证 POST /todos 返回 201
  Expected behavior: 接受 title 参数并返回 todo 对象
  Implementation notes: 实现 POST /todos 路由
```

这个粒度下，AI 在一个任务内部同时写测试和实现是 **完全合理的** 。因为任务本身就要求它同时做这两件事。这不是 AI 不听话，是我们的指令有歧义——一步做完和分步做都算 **完成任务** 。

### Superpowers 能帮什么忙

Superpowers 仓库（github.com/obra/superpowers）提供了几个关键能力：

**subagent-driven-development 的结构隔离是真实的** 。每个 subagent 是 fresh context，只看到 controller 传入的当前任务文本，看不到其他任务。Claude Code 的 Agent 工具保证了 context 隔离——subagent 确实无法访问其他任务的上下文，跨任务批量执行被阻止。

**两阶段审查可以打回** 。spec reviewer 检查 **是否多做了/少做了** ，code quality reviewer 检查代码质量。审查不通过会打回让 implementer 修复。

**TDD skill 是 371 行的行为塑造文本** 。包含 Iron Law、反合理化表格、Red Flags 列表。但全是 prompt，不是可执行的断言。

但有一个关键事实： **两个仓库的核心代码互不依赖** 。OpenSpec 核心代码（ `src/` ）里 0 个 `superpowers` 引用，Superpowers 源码里 0 个 `openspec` 引用。不过 OpenSpec 的 `docs/customization.md` 提到了 `superpowers-bridge` 社区 schema，说明官方已经注意到了集成方案。集成完全依赖社区 schema 的 `instruction` 文本桥接。

![配图 1：v1 失败路径 vs v2 修正路径对比](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

配图 1：v1 失败路径 vs v2 修正路径对比

*图 1：v1 失败路径 vs v2 修正路径对比*

## 第二节：修正思路 - 四层防护模型

根因分析清楚了，修正方案就自然了。四层防护，每层解决一个具体问题。

### 第一层：原子化任务

**解决的问题** ：任务内部混合 RED + GREEN，AI 可以合理地一步完成。

**机制** ：在 `tasks` artifact 的 `instruction` 里强制要求每个 task 只包含一个 TDD 阶段（RED、GREEN 或 REFACTOR）。用 checkbox 格式 `- [ ]` 书写，确保 OpenSpec 的 `tracks` 能正确解析。

```
- [ ] RED: Write failing test for heading parsing
- [ ] GREEN: Implement heading parser
- [ ] RED: Write failing test for bold parsing
- [ ] GREEN: Implement bold parser
```

而不是：

```
- [ ] Implement Markdown parser — support headings, bold, italic
```

粒度变了，AI 的操作空间就变了。一个 subagent 只做一个原子任务，想一口气写完也没机会。

### 第二层：subagent 隔离

**解决的问题** ：AI 跨任务批量执行，在第一个 subagent 里就把所有功能写完。

**机制** ：在 `apply.instruction` 里强制指定 `superpowers:subagent-driven-development` 。每个 task 分配一个独立 subagent，subagent 之间 context 完全隔离。第一个 subagent 不知道第二个 subagent 要做什么，自然没法提前写。

这一层的关键是：不是 **建议** 用 subagent，是 instruction 里写死 `MANDATORY: Use superpowers:subagent-driven-development skill` 。当然，AI 仍然可能忽略这条指令——这在第五节的诚实评估里会详细说。

### 第三层：两阶段审查

**解决的问题** ：subagent 在单个任务内过度执行——比如 RED 任务里同时写了实现代码。

**机制** ：spec reviewer 检查 subagent 是否 **恰好** 完成了任务要求的内容，不多不少。code quality reviewer 检查代码质量。两轮审查都不通过就打回重做。

这一层特别重要。假设 RED 阶段的 subagent 除了写测试还顺手写了实现，spec reviewer 应该能抓住： **你的任务只要求写测试，为什么多了实现代码？打回。**

### 第四层：验证证据

**解决的问题** ：无法确认 TDD 顺序是否真正执行——RED 必须先失败，GREEN 必须让它通过。

**机制** ：subagent 必须在报告中包含测试运行输出。

- RED 阶段：报告必须显示测试失败。如果 subagent 报告 `all tests passing` ，那就是 RED FLAG，必须重新 dispatch。
- GREEN 阶段：报告必须显示测试通过。如果还是 failing，不标记完成，重新 dispatch。
- REFACTOR 阶段：报告必须包含全量测试输出。任何回归都不放过。

这一层提供了可检查的硬证据。不看 AI 怎么说，看测试输出怎么说。

![配图 2：四层防护模型架构图](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

配图 2：四层防护模型架构图

*图 2：四层防护模型架构图——从内到外：原子化任务、subagent 隔离、两阶段审查、验证证据*

你在项目中用过类似的 TDD 约束方案吗？欢迎在评论区聊聊你的经验。

## 第三节：实战 - 创建修正版 Schema

接下来是全文核心：完整的 `tdd-driven-v2` Schema。你可以直接复制使用。

### 目录结构

```
openspec/
├── schemas/
│   └── tdd-driven-v2/
│       ├── schema.yaml        # 工作流定义
│       └── templates/
│           ├── proposal.md
│           ├── spec.md
│           ├── design.md
│           ├── tasks.md
│           └── plan.md
├── config.yaml                # 项目配置（注意：在 openspec/ 根目录下）
├── changes/                   # 变更记录（openspec init 自动创建）
└── specs/                     # 规范目录（openspec init 自动创建）
```

> **注意** ： `openspec init` 只会自动创建 `openspec/changes/` 、 `openspec/specs/` 和工具适配目录（`.claude/` 、`.cursor/` 等）。\*\* `schemas/` 目录和 `config.yaml` 不会自动创建\*\*，需要手动操作。

### schema.yaml（全文核心）

```
name: tdd-driven-v2
version:2
description:AtomicTDDworkflowwithsubagentisolationandevidenceverification

artifacts:
-id:proposal
    generates:proposal.md
    description:Initialchangeproposalwithtestablebehaviors
    template:proposal.md
    instruction:|
      Create a proposal that explains WHY this change is needed.

      MANDATORY FORMAT for testable behaviors:
      ListeverytestablebehaviorusingWHEN/THENformat.

      Example:
      -WHENmarkdownToHtml("#Hello")iscalled
        THENresultis"<h1>Hello</h1>"
      -WHENmarkdownToHtml("**bold**")iscalled
        THENresultis"<strong>bold</strong>"
      -WHENmarkdownToHtml("Hello\n\nWorld")iscalled
        THENresultis"<p>Hello</p>\n<p>World</p>"

      DoNOTdescribeimplementationdetails.
      FocusonWHATshouldhappen,notHOW.
    requires:[]

-id:specs
    generates:specs/**/*.md
    description:Behavioralspecifications
    template:spec.md
    instruction:|
      Write behavioral specs using GIVEN/WHEN/THEN scenarios.

      Rules:
      -Eachscenariomustbeindependentlytestable
      -Cover:happypath,edgecases,errorcases
      -Expressexpectedbehavior,notimplementation
      -Referenceexistingpatternsbeforecreatingnewones
    requires:
      -proposal

-id:design
    generates:design.md
    description:Technicaldesignwithteststrategy
    template:design.md
    instruction:|
      Create a technical design explaining HOW to implement.

      MUST include:
      -Testfilestocreate(withexactpaths)
      -Teststrategyperfile(unit/integration)
      -Filestructureshowingtestfilesalongsidesourcefiles
      -Testrunnercommand(e.g.,npmtest)
    requires:
      -proposal

-id:tasks
    generates:tasks.md
    description:AtomicTDDtasklist
    template:tasks.md
    instruction:|
      CRITICAL: Break work into ATOMIC TDD tasks.
      Each task is EXACTLY ONE TDD phase (RED, GREEN, or REFACTOR).

      MANDATORYFORMAT—use checkbox syntax for every task:

      ### Feature: [feature name]

      -[]RED:Writefailingtest—[具体测试什么行为]
      -[]GREEN:Implement—[最小实现描述，引用对应的RED任务]
      -[]REFACTOR:Cleanup—[清理描述]（可选，不是每个GREEN都需要）

      Rules:
      1.NEVERcombineREDandGREENinonetask
      2.EveryGREENtaskmustreferenceitscorrespondingREDtest
      3.EverytaskMUSTuse"- [ ]"checkboxformat—nootherformatallowed
      4. Tasks alternate:RED→GREEN→(REFACTOR)→RED→GREEN→...
      5.Notaskshouldtakemorethan2-5minutes
      6.DoNOTgroupbyfeature—groupbyTDDphaseorder

      Example of correct output:

      -[]RED:Writefailingtestforheadingparsing—createmarkdown.test.ts,testthatmarkdownToHtml("#Hello")returns"<h1>Hello</h1>"
      -[]GREEN:Implementheadingparser—minimalregextoconvert"# text"to"<h1>text</h1>"
      -[]RED:Writefailingtestforboldparsing—testthatmarkdownToHtml("**bold**")returns"<strong>bold</strong>"
      -[]GREEN:Implementboldparser—minimalregextoconvert"**text**"to"<strong>text</strong>"
      -[]REFACTOR:Extractinlineparsingmodule—movebold/italicparsingtosharedinline-parser.ts

      ExampleofWRONGoutput(doNOTdothis):

      -[]ImplementMarkdownparser—supportheadings,bold,italic,linkswithtests←WRONG:combineseverything
    requires:
      -specs
      -design

-id:plans
    generates:plan.md
    description:Executionplanwithper-phaseevidencerequirements
    template:plan.md
    instruction:|
      PRECHECK: Verify superpowers:writing-plans skill is available.
      If not available, STOP and report the missing skill.

      Createadetailedexecutionplan.EachplanstepmapstoEXACTLYONEtaskfromtasks.md.

      ForREDtasks,specify:
      -Filetocreate/modify(exactpath)
      -Testassertiontowrite
      -Expectedfailurereason
      -Verify command:npmtest--[test-file]
      -Evidence:"Test MUST fail with [expected reason]"

      ForGREENtasks,specify:
      -Whichfailingtesttopass(referencetheREDtaskbydescription)
      -Minimalcodetowrite
      -Verify command:npmtest--[test-file]
      -Evidence:"Test MUST pass"

      ForREFACTORtasks,specify:
      -Whattocleanup
      -Verify command:npmtest
      -Evidence:"ALL tests MUST still pass"

      Afterplaniscreated,append this section:

      ---
      ## Execution Mode Selection

      REQUIRED:Usesuperpowers:subagent-driven-developmentskillforexecution.

      DONOTuseexecuting-plansorinlineexecution.
      Reason:AtomicTDDtasksrequiresubagentisolation.
      EachtaskisasingleTDDphase—onesubagentperphase.
    requires:
      -tasks

apply:
requires:[plans]
tracks:tasks.md
instruction:|
    MANDATORY: Use superpowers:subagent-driven-development skill.
    DO NOT use executing-plans or inline execution.

    Execution rules:
    1.EachtaskisanatomicTDDphase—dispatchONEsubagentpertask
    2.NEVERdispatchmultipleimplementationsubagentsinparallel
    3.TasksMUSTbeexecutedinorder—donotskiporreorder

    Evidence requirements per subagent:
    -RED tasks:SubagentMUSTincludetestfailureoutputinreport
      Ifsubagentreports"all tests passing"onaREDtask→REDFLAG→re-dispatch
    -GREEN tasks:SubagentMUSTincludetestpassoutputinreport
      Ifsubagentreports"tests still failing"onaGREENtask→doNOTmarkcomplete→re-dispatchwithfix
    -REFACTOR tasks:SubagentMUSTincludefulltestsuiteoutput
      Ifanytestfailsafterrefactor→doNOTmarkcomplete→re-dispatchwithfix

    After each task:
    1. Spec reviewer checks:Didsubagentbuildexactlywhatwasrequested?Nothingmore,nothingless?
    2. Code quality reviewer checks:Iscodeclean,tested,maintainable?
    3.OnlyafterBOTHreviewersapprove→marktaskcompleteintasks.md(-[]→-[x])
    4.Proceedtonexttask

    After all tasks complete:
    1.Runfulltestsuite
    2.Verifyallspecsaresatisfied
    3.CheckforTODOmarkers
```

### 模板文件

**templates/proposal.md**

```
# Proposal: {{change_name}}

## Problem
<!-- 描述要解决的问题 -->

## Testable Behaviors
<!-- WHEN/THEN 格式列出每一个可测试行为 -->

## Acceptance Criteria
<!-- 验收标准 -->
```

**templates/spec.md**

```
# Spec: {{change_name}}

## Scenarios

### Scenario 1: [name]
- GIVEN: [前置条件]
- WHEN: [操作]
- THEN: [期望结果]

<!-- Repeat for each scenario -->
```

**templates/design.md**

```
# Design: {{change_name}}

## File Structure
<!-- 列出要创建的文件，包括测试文件 -->

## Test Strategy
<!-- 每个 test 文件的测试策略 -->

## Implementation Notes
<!-- 实现要点 -->
```

**templates/tasks.md**

```
# Tasks: {{change_name}}

## Atomic TDD Task List

<!-- 每个 task 只能是一个 TDD 阶段 -->
<!-- 必须使用 checkbox 格式 -->

### [AI fills feature name]

- [ ] RED: ...
- [ ] GREEN: ...
- [ ] REFACTOR: ...
```

**templates/plan.md**

```
# Execution Plan: {{change_name}}

## Micro-tasks

### Step 1: RED — [description]
- Test file: [path]
- Assertion: [what to test]
- Expected failure: [reason]
- Verify: \`npm test -- [test-file]\`

### Step 2: GREEN — [description]
- Pass test from: Step 1
- Minimal code: [what to implement]
- Verify: \`npm test -- [test-file]\`

<!-- Repeat for each task -->
```

### 项目配置 config.yaml

```
schema: tdd-driven-v2

context:|
  Tech stack: TypeScript, Node.js, Jest
  Testing framework: Jest
  Test runner: npm test
  Project: Pure function library — no framework, no database, no HTTP
  Core function signature: markdownToHtml(input: string): string
  All production code must have corresponding tests.

rules:
proposal:
    -ListeverytestablebehaviorinWHEN/THENformat
    -Donotdescribeimplementation
specs:
    -UseGIVEN/WHEN/THENformatforeveryscenario
    -Eachscenariomustbeindependentlytestable
design:
    -Mustspecifyexacttestfilepaths
    -Mustspecifyteststrategyperfile
tasks:
    -MUSTusecheckboxformat"- [ ]"foreverytask
    -EachtaskisexactlyONETDDphase(RED,GREEN,orREFACTOR)
    -TasksmustalternateRED→GREEN→(optionalREFACTOR)
    -GREENtasksmustreferencetheircorrespondingREDtask
plans:
    -Eachplanstepmapstoexactlyonetask
    -Mustspecifyverifycommandandexpectedevidence
```
![配图 3：Schema 四层防护映射图](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

配图 3：Schema 四层防护映射图

*图 3：Schema 配置如何对应四层防护——左：Schema 工作流，右：四层防护映射*

## 第四节：实战验证 - 用 Mini Markdown 转换器跑一遍

Schema 写好了，接下来用一个真实用例跑一遍验证。

### 为什么选 Mini Markdown 转换器

三个原因：

1. **零依赖** ：纯 Node.js + Jest，不需要 Express/数据库/HTTP
2. **纯函数** ： `markdownToHtml(input: string): string` ，输入输出完全确定
3. **天然适合原子化 TDD** ：每个 Markdown 语法元素（heading/bold/italic/link）= 一个独立的 RED-GREEN 循环

### 环境准备

```
# 0. 初始化 git（后续验证需要 git log）
git init

# 1. 初始化项目
mkdir mini-markdown && cd mini-markdown
npm init -y
npm install --save-dev jest ts-jest @types/jest typescript

# 2. 初始化 OpenSpec（生成 openspec/changes/、openspec/specs/ 和工具适配目录）
# 初学者建议用 --tools claude，只安装 Claude Code 适配，避免生成 29 个不需要的工具目录
openspec init --tools claude

# 3. 手动创建 Schema 目录和配置文件
mkdir -p openspec/schemas/tdd-driven-v2/templates
# 将 schema.yaml 放到 openspec/schemas/tdd-driven-v2/
# 将 config.yaml 放到 openspec/（注意：在 openspec/ 根目录下，不在 schemas/ 里）
# 将模板文件放到 openspec/schemas/tdd-driven-v2/templates/
```

### 验证步骤

**步骤 1：验证 Schema 语法**

```
openspec schema validate tdd-driven-v2
# 注意：会先显示 "Note: Schema commands are experimental and may change."
# 这是 CLI 的常规提示，不影响验证结果
```

✅ 检查：无报错，YAML 语法通过

**步骤 2：创建变更提案**

```
# 在 Claude Code 中执行
/opsx:propose mini-markdown
```

执行后，AI 会依次调用 `openspec instructions <artifact> --change mini-markdown --json` 获取 instruction 文本，按依赖顺序生成：proposal → design + specs（并行）→ tasks → plans。

**如果 `config.yaml` 的 `context` 字段写得充分（如本项目的 TypeScript + Jest 纯函数配置），整个 propose 过程不需要任何人工输入。** AI 直接从 context 推断需求，整个过程大约 2-3 分钟。

重点检查以下验证点：

✅ proposal.md 包含 WHEN/THEN 格式的可测试行为（实测 15 条） ✅ specs 使用 GIVEN/WHEN/THEN（实测 16 个场景，含 edge cases） ✅ design.md 包含测试文件路径和测试策略 ✅ **tasks.md 每个 task 只有一个 TDD 阶段** （实测 26 个 task：13 RED + 13 GREEN） ← 核心验证点 ✅ **tasks.md 使用了 checkbox 格式** ← 核心验证点 ⚠️ tasks.md 无 REFACTOR 任务——AI 认为 REFACTOR 是可选的，选择了跳过 ✅ plans 指定了验证命令和期望证据，末尾包含 "Execution Mode Selection" 指定 subagent-driven-development

如果 tasks.md 的产出类似下面这样，说明第一层防护生效了：

```
### Headings
- [ ] RED: Write failing test for heading parsing — create tests/markdown.test.ts, test that markdownToHtml("# Hello") returns "<h1>Hello</h1>"
- [ ] GREEN: Implement heading parser — add regex in src/parser.ts to convert "^# (.+)" to "<h1>$1</h1>", export from src/index.ts

### Bold
- [ ] RED: Write failing test for bold parsing — test that markdownToHtml("**bold**") returns "<strong>bold</strong>"
- [ ] GREEN: Implement bold parser — minimal regex to convert "**text**" to "<strong>text</strong>"
```

❌ 如果产出是 `- [ ] Implement heading and bold parser` ，说明原子化没有生效。

**步骤 3：确认 instruction 注入**

```
openspec instructions tasks --change mini-markdown --json
```

✅ 检查：输出中包含原子化任务的 instruction 文本

**步骤 4：执行变更**

```
# 在 Claude Code 中执行
/opsx:apply mini-markdown
```

这一步是全文最关键的验证环节。 **以下是 Mini Markdown 验证的实测结果** ，不再是预期分析。

AI 执行了 `openspec instructions apply --change "mini-markdown" --json` 获取 apply instruction，然后使用 Agent 工具 dispatch 了 **27 次 subagent** ：

- 24 个实现 subagent（每个 task 一个）
- 1 个 spec 审查 subagent
- 2 个代码质量审查 subagent

**四层防护实测结果** ：

✅ **第一层生效** ：tasks.md 的 26 个 task 每个只包含一个 TDD 阶段（RED 或 GREEN）。任务的原子化粒度是物理约束，不依赖 AI 的自主决策。

✅ **第二层生效** ：AI dispatch 了 24 个实现 subagent，每个 task 确实由独立 subagent 完成。instruction 中的 `MANDATORY: Use superpowers:subagent-driven-development skill` 被 AI 遵守了。subagent 之间 context 隔离，第一个 subagent 不知道第二个 subagent 要做什么。

⚠️ **第三层部分生效** ：前 2 个 task（Task 1 RED + Task 2 GREEN）有完整的审查流程——spec reviewer 检查交付物范围，code quality reviewer 检查代码质量。但 AI 在验证完前几个 task 后，认为审查流程太耗时，跳过了后续 24 个 task 的审查。subagent 调用详情：

```
Agent #1:  Implement Task 1 RED: heading test
Agent #2:  Review spec compliance Task 1 RED        ← spec reviewer
Agent #3:  Review code quality Task 1 RED            ← code quality reviewer
Agent #4:  Implement Task 2 GREEN: heading parser
Agent #5:  Review code quality Task 2 GREEN          ← code quality reviewer
Agent #6:  Implement Task 3 RED: bold test
Agent #7:  Implement Task 4 GREEN: bold parser
...（后续 task 只有实现 subagent，无审查）
Agent #27: Implement Task 26 GREEN: image parser
```

✅ **第四层生效** ：npm test 的执行历史（15 次）清楚显示了真实的 RED → GREEN 过渡：

```
#4  Tests: 2 failed, 11 passed — RED（bold test 失败）
#5  Tests: 5 failed, 8 passed  — RED（多个新 test 失败）
#14 Tests: 1 failed, 10 passed — 最后一个 RED
#15 Tests: 10 passed           — 最终 GREEN
```

这些失败是 **真实发生** 的，不是 AI 编造的——它们来自 npm test 的真实输出。

执行完成后检查最终产物：

```
# 检查 tasks.md 的 checkbox 是否被逐步勾选
cat openspec/changes/mini-markdown/tasks.md

# 检查 git log 是否有交替的 test/feat 提交
git log --oneline

# 运行全量测试
npm test
```

✅ tasks.md 的 26 个 checkbox 全部被勾选 ⚠️ git log 无 RED-only 提交——RED 和 GREEN 在同一次提交中完成，且 commit message 格式不统一 ✅ npm test 通过（10/10 tests passed） ⚠️ 测试覆盖率 10/15 行为（缺失 h2/h3 多级标题、horizontal rule、mixed inline formatting、code blocks） ⚠️ 源码结构偏离 design.md 规划（AI 选择了单文件 `src/markdown.ts` 71 行，而非 design.md 的双文件方案）

最终产物： `src/markdown.ts` （71 行）、 `tests/markdown.test.ts` （43 行、10 个 test case），npm test 10/10 passed。

![配图 4：验证执行时间线](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

配图 4：验证执行时间线

*图 4：Mini Markdown 验证执行时间线——双轨展示 27 次 subagent dispatch 和 15 次 npm test 的 RED→GREEN 过渡*

### 如果验证不通过

几个常见的失败场景和排查方向：

**场景 1：AI 没有使用 subagent 模式**

如果 `apply` 阶段直接 inline 执行而不是 dispatch subagent，说明 `instruction` 里的 `MANDATORY` 被忽略了。排查方向：检查 Superpowers 的 `subagent-driven-development` skill 是否正确安装。如果 skill 不存在，instruction 就是一纸空文。

**场景 2：RED 任务里同时写了实现**

如果 spec reviewer 没有抓住这个问题，说明审查层失效。排查方向：检查 spec reviewer 的 prompt 是否明确要求 **只检查任务规格内的交付物** 。

**场景 3：测试输出不真实**

如果 subagent 报告的测试输出是编造的（比如报了 pass 但实际没运行），目前没有代码层面的防伪机制。这是第四层的已知局限，第五节会详细讨论。

## 第五节：诚实评估

四层防护模型听起来很完善，但必须坦诚： **它不能 100% 保证 TDD 执行** 。以下用 Mini Markdown 的实测数据，逐一说明每层的实际效果和已知局限。

### 每层的实测效果

**第一层（原子化任务）** ：实测有效。当 tasks.md 的每个 task 只有一个 TDD 阶段时，即使 AI 想一步完成，task 的描述本身就限制了它的操作范围。实测中 tasks.md 生成了 26 个原子 task（13 RED + 13 GREEN），AI 没有合并任何任务。这是四层里最可靠的一层——任务粒度是物理约束，不依赖 AI 的自主决策。

**第二层（subagent 隔离）** ：实测有效。Mini Markdown 验证中，AI dispatch 了 24 个实现 subagent，每个 task 确实由独立 subagent 完成。instruction 中的 `MANDATORY: Use superpowers:subagent-driven-development skill` 被 AI 遵守了。subagent 之间 context 隔离，第一个 subagent 不知道第二个 subagent 要做什么。

注意：有效不代表 100% 可靠。其他项目、其他 AI 模型、其他 instruction 上下文中，AI 仍然可能选择忽略 MANDATORY 选择 inline 执行。但在本验证场景中，第二层确实生效了。

**第三层（两阶段审查）** ：实测部分有效。前 2 个 task（Task 1 RED + Task 2 GREEN）有完整的审查流程——spec reviewer 检查交付物范围，code quality reviewer 检查代码质量。但 AI 在验证完前几个 task 后，认为审查流程太耗时，跳过了后续 24 个 task 的审查。

这个结果揭示了一个微妙的问题：审查机制 **存在且能正确工作** （前 2 个 task 的审查是真实的），但 AI 有 **自主跳过审查** 的裁量权。instruction 里没有说"每个 task 都必须审查"，AI 合理地认为前几个验证过了就够了。

改进方向：在 apply.instruction 中明确写 "Review EVERY task, not just the first few"。但这也只是 prompt 级别的约束——AI 仍然可以选择忽略。

**第四层（验证证据）** ：实测有效。npm test 的执行历史（15 次）清楚显示了 RED → GREEN 的过渡：

- 第 4 次运行：2 failed, 11 passed（bold test 失败）
- 第 5 次运行：5 failed, 8 passed（多个新 test 失败）
- 第 14 次运行：1 failed, 10 passed（最后一个 RED）
- 第 15 次运行：10 passed（最终全部通过）

这些失败是 **真实发生** 的，不是 AI 编造的——它们来自 npm test 的真实输出。第四层提供了可靠的 TDD 顺序证据。

但有一个已知局限：git log 中没有 RED-only 提交。AI 在 RED 阶段写了测试但没有单独提交，而是和 GREEN 一起提交。这意味着从 git 历史看不到"先写测试、测试失败、再写实现"的交替模式。测试覆盖率也只有 10/15 行为。

### 实测中发现的问题

- **审查覆盖不完整** ：AI 跳过了 24/26 个 task 的审查（第三层）
- **测试覆盖率不足** ：10/15 行为有测试，缺失 5 个可测试行为（h2/h3、horizontal rule、mixed inline、code blocks）
- **架构决策偏离** ：AI 自行从双文件方案调整为单文件方案，没有打回
- **git log 无 RED-only 提交** ：无法从版本历史看到 TDD 交替模式
- **REFACTOR 被跳过** ：AI 将 REFACTOR 视为"可选"而跳过，26 个 task 全是 RED + GREEN

说到底，这些问题是第三层审查被跳过的直接后果。如果有 spec reviewer 检查 Task 3-26，AI 自行调整文件结构（从双文件变单文件）和跳过 5 个行为的测试覆盖应该被打回。

### 如果需要更高保证

如果对 TDD 执行纪律有硬性要求（比如团队规范或合规需要），可以在四层防护之外加两道硬约束：

- **pre-commit hook** ：检查测试覆盖率，拒绝覆盖率低于阈值的提交
- **CI pipeline** ：拒绝没有对应测试变更的 feature 提交

这两道约束是代码层面的，不依赖 AI 的自主决策，可靠性远高于 prompt 级别的防护。

### 与 v1 的对比

| 维度 | v1（失败） | v2（设计） | v2（实测） |
| --- | --- | --- | --- |
| 任务粒度 | 一个 task = 完整功能 | 一个 task = 一个原子 TDD 阶段 | ✅ 生效，26 个原子 task |
| 执行路径 | AI 自选（选了 inline） | 强制 subagent-driven-development | ✅ 生效，24 个 subagent |
| 进度追踪 | 无 checkbox， `tracks` 解析失败 | 强制 checkbox 格式， `tracks` 可追踪 | ✅ 生效，tracks 正确解析 |
| 审查机制 | 无 | spec + quality reviewer | ⚠️ 部分生效，仅前 2/26 task |
| 验证证据 | 无 | subagent 报告测试输出 | ✅ 生效，RED 失败证据真实 |

v1 在 propose 阶段的文档规范化是有效的——WHEN/THEN、GIVEN/WHEN/THEN 这些格式约束确实让产物更规范。但 apply 阶段的执行纪律完全失败。v2 通过原子化任务 + subagent 隔离 + 两阶段审查 + 验证证据，在 apply 阶段实现了可预期的 TDD 执行。

四层防护模型的实测结果：三层有效，一层部分有效。第一层（原子化任务）和第二层（subagent 隔离）是最可靠的——任务粒度是物理约束，subagent 隔离是工具机制保证。第三层（审查）机制本身正确，但 AI 选择了加速执行跳过审查，暴露了 prompt 级约束的天花板。第四层（验证证据）提供了真实的 RED 失败记录，是最硬的客观证据。

核心洞察不变： **缩小 AI 的合理操作空间** 比 **让 AI 变得更听话** 更可靠。当每个任务只允许做一件事，subagent 之间互相看不见，做完还有人审查——即使审查被跳过了，前两层已经把 AI 的操作空间压缩到了原子级别。

当然，这个判断需要更多场景验证。如果你也试了这个 Schema，欢迎把验证结果反馈给我——成功了值得记录，失败了更有分析价值。

![配图 5：实测对比评估图](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

配图 5：实测对比评估图

*图 5：v1/v2 设计/v2 实测三方对比评估——5 个维度的演进与实测效果*

**好啦，谢谢你观看我的文章，如果喜欢可以点赞转发给需要的朋友，我们下一期再见！敬请期待！**

**扫码关注，获取更多 AI 工具的实战经验和最佳实践。不错过每一篇干货！**

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**微信扫一扫赞赏作者**

AI编程最佳实战「2026」 · 目录

继续滑动看下一个

术哥无界

向上滑动看下一个