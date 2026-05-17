---
title: "Superpowers 实战指南：7 步流程 + 14 个技能 + 3 条铁律，搭建让 AI 编程更稳、更守规矩的工作流"
source: "https://mp.weixin.qq.com/s/JAt_Y8XFJoF5wi7LL_mAPg"
author:
  - "[[运维有术]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
运维有术 *2026年4月9日 08:31*

> 🚩 2026 年「术哥无界」系列实战文档 X 篇原创计划 第 *77* 篇，AI 编程最佳实战「2026」系列第 *12* 篇
> 
> 大家好，欢迎来到 **术哥无界 | ShugeX ｜ 运维有术** 。
> 
> 我是 **术哥** ，一名专注于 AI 编程、AI 智能体、Agent Skills、MCP、云原生、AIOps、Milvus 向量数据库的 **技术实践者与开源布道者** ！

> **Talk is cheap, let's explore。无界探索，有术而行。**

用 AI 写代码，爽吗？爽。翻车吗？也翻。

翻一圈技术社区的反馈，吐槽出奇一致：AI 太急了。你刚说完需求，它就开始输出代码；代码跑起来了，测试没写；bug 修了，根因没找 - 下次遇到同类问题，该错还是错。

![[_resources/Superpowers 实战指南：7 步流程 + 14 个技能 + 3 条铁律，搭建让 AI 编程更稳、更守规矩的工作流/7acc81ae0c501f7f808482aa173ab9b6_MD5.webp]]

Superpowers 信息图封面

Superpowers 就是冲着这个问题来的。GitHub 36.6K Star，MIT 协议，一套完整的 AI 编程 Agent 工作流系统。核心理念八个字： **不是更强，而是更稳** 。

今天这篇文章，我把 Superpowers 的官方文档和源码翻了个底朝天： **14 个 Skills、7 步工作流、3 条铁律** ，结合三个真实开发场景（新项目、加功能、修 bug），说清楚怎么用它把 AI 编程从野蛮生长拉回到按流程办事。

## 1\. Superpowers 是什么

一句话：Superpowers 是一套给 AI 编程 Agent 用的标准化开发流程。

它由 Jesse Vincent（GitHub: obra）创建，当前版本 v5.0.7（2026-03-31），支持六个平台：Claude Code、Cursor、Codex、OpenCode、Gemini CLI、GitHub Copilot CLI。

注意它的定位 - 不是让 AI 更聪明，而是让 AI 守规矩。传统 AI 辅助开发的通病：AI 急于写代码、缺乏系统化流程、不做测试不写文档。Superpowers 用 14 个可组合的 Skills 加上强制触发机制，把软件工程的标准流程焊在 AI Agent 上。

它的工作原理和大多数人的 AI 编程习惯不一样：

1. Agent 看到引导指令后， **不会直接写代码**
2. 先退后一步，询问你真正想做什么
3. 通过对话提炼需求规格，分段展示供你审阅
4. 你审批设计后，生成实施计划
5. 启动子代理逐任务开发，自动代码审查

这个过程比直接让 AI 写代码要长。但拉长是有原因的 - 翻完文档后的一个直观感受： **前期多花的时间，会从后期的返工里省回来** 。

## 2\. 核心工作流全景图

Superpowers 的基础工作流是一个 7 步流程：

```
brainstorming → using-git-worktrees → writing-plans → subagent-driven-development → test-driven-development → requesting-code-review → finishing-a-development-branch
```

翻译成大白话：

1. **头脑风暴** - 先聊清楚要做什么
2. **Git Worktree 隔离** - 创建独立工作空间
3. **编写计划** - 拆成 2-5 分钟的小任务
4. **子代理开发** - 每个任务派一个独立子代理
5. **测试驱动** - 先写失败测试，再写生产代码
6. **代码审查** - 自动审查代码质量
7. **完成分支** - 验证通过后收尾
![工作流全景结构图](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

工作流全景结构图

*图 1：7 步工作流与 14 个 Skills 的映射关系*

### 14 个 Skills 四大分类

**协作类（9 个）** ：brainstorming、writing-plans、executing-plans、subagent-driven-development、dispatching-parallel-agents、requesting-code-review、receiving-code-review、using-git-worktrees、finishing-a-development-branch

**测试类（1 个）** ：test-driven-development

**调试类（2 个）** ：systematic-debugging、verification-before-completion

**元类（2 个）** ：writing-skills、using-superpowers

### 强制触发机制

这套流程能跑起来的关键在于一个设计： **强制触发** 。如果存在适用的技能，Agent 必须使用，没有选择的余地。

官方文档里坦率地承认，这靠的是 Robert Cialdini 的说服学原理 - 权威性（提示词里写 `技能是强制性的` ）、承诺（让 Agent 主动宣布使用技能）、社会证明（描述 `始终` 会发生什么）。说白了，就是在提示词里用心理学技巧让 LLM 乖乖按流程走。

### 三个场景，三套流程

不是每个场景都需要走完 7 步。Superpowers 的设计是按场景裁剪工作流：

| 场景 | 工作流 | 步骤数 |
| --- | --- | --- |
| 从零开始新项目 | 完整 7 步流程 | 7 步 |
| 老项目加新功能 | 完整流程（brainstorming 侧重已有代码） | 7 步 |
| 修复 bug | 精简流程 | 3 步 |

下面逐个展开。

## 3\. 场景 1：从零开始新项目

这是 Superpowers 能完整发挥的舞台 - 没有历史包袱，可以走完整个 7 步工作流。

### 为什么新项目更需要完整流程

新项目的风险不在 **写不出来** ，而在 **写偏了** 。让 AI 从零搭一个项目，写完发现架构不对、技术栈选错了、需求理解有偏差 - 这种事太常见了。返工成本远高于前期设计成本。

Superpowers 的 brainstorming 技能有一条硬性门槛： **不展示设计并获得用户批准前，绝不启动任何实现** 。这等于强制你在写代码前先把需求想清楚。

![新项目 7 步工作流示意图](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

新项目 7 步工作流示意图

*图 2：新项目从零开始的完整 7 步工作流*

### 7 步流程走一遍

**第 1 步：brainstorming（头脑风暴）**

Agent 会做这些事：探索项目上下文、逐个提问澄清需求、提出 2-3 个方案、分段展示设计文档。

有个细节值得注意：Agent 是逐个提问，不是一股脑把所有问题甩给你。这是刻意设计的 - 一次性问太多问题，用户容易随便应付。

你的角色是审阅设计文档，满意了再批准进入下一步。这个过程可能会来回好几轮，但比写完代码再改架构划算得多。

**第 2 步：using-git-worktrees（创建隔离空间）**

用 Git Worktree 创建一个独立的工作目录，和主分支隔离。流程是：选择目录 → 验证.gitignore → 创建 worktree → 运行项目配置 → 验证测试基线。

为什么要隔离？因为新项目探索性强，改着改着发现方向不对是常有的事。有 worktree 隔离，改坏了直接删掉重来，主分支干干净净。

**第 3 步：writing-plans（拆任务）**

把设计文档拆成 2-5 分钟的小任务。每个任务包含三样东西：精确的文件路径、完整的代码（注意：禁止 TBD、TODO 这类占位符）、验证步骤。

这一步产出的计划文件是后续子代理执行的依据。任务粒度很关键 - 太大了子代理容易跑偏，太小了上下文切换成本高。2-5 分钟这个区间是官方推荐的经验值。

**第 4 步：subagent-driven-development（子代理开发）**

这是整个工作流中技术含量很高的一步。为每个任务派发一个独立的子代理。核心思想是上下文隔离 - 每个子代理只看到当前任务所需的信息，不会被之前任务的上下文污染。

子代理完成后要过两道审查：规范合规审查（有没有违反设计文档）和代码质量审查（代码风格、性能、安全）。审查不通过就打回去重做。

**第 5 步：test-driven-development（TDD）**

标准的 RED → GREEN → REFACTOR 循环：

- **RED** - 先写一个会失败的测试
- **GREEN** - 写能跑通的代码，越简单越好
- **REFACTOR** - 清理代码，保持测试通过

这个循环对 AI 编程的价值特别大。没有 TDD 约束，AI 容易过度设计 - 加一堆 **以后可能用到** 的功能。TDD 迫使每一步都只做够用的事。

**第 6 步：requesting-code-review（代码审查）**

自动获取 git SHA，派发审查子代理，根据反馈修复问题。审查维度包括代码质量、规范合规、潜在风险。

**第 7 步：finishing-a-development-branch（收尾）**

验证所有测试通过后，提供四个选项：合并到基础分支、创建 PR、保留分支、丢弃分支。最后清理 worktree。

### 避坑要点

- brainstorming 阶段别急，多花点时间在需求澄清上，后面省的时间远比这里多
- writing-plans 阶段重点检查任务粒度，太大或太小都影响子代理效率
- worktree 创建后先跑一遍测试基线，确认环境没问题再开始开发

## 4\. 场景 2：老项目加新功能

和场景 1 相比，工作流步骤一样，但每一步的重点截然不同。

### 关键差异点

老项目有历史包袱。现有的代码模式、架构风格、依赖版本都是约束条件。Superpowers 在 brainstorming 技能中有一个专门的指导： **Working in existing codebases** 。

核心原则三条：

- 遵循现有代码模式和架构
- 不提议无关的重构
- 新代码要和项目风格一致

说白了就是 **入乡随俗** 。AI 看到项目用 Vue 2 + Options API，就不要建议迁移到 Vue 3 Composition API。看到项目用 Jest 做测试，就不要换成 Vitest - 除非新功能确实需要。

### 实战示例

假设你有一个 Node.js 后端项目，需要加一个导出 PDF 的功能。

**brainstorming 阶段** ，Agent 会先摸底项目结构 - 用了什么框架、什么模板引擎、现有的导出功能怎么实现的。然后才针对 PDF 导出提方案。这一步在新项目里是梳理需求，在老项目里变成了 **理解现状 + 评估影响范围** 。

**writing-plans 阶段** ，拆任务时会特别关注和现有代码的集成点。比如：在哪个路由文件里添加导出接口、怎么复用现有的权限校验中间件、导出格式要不要和已有的 Excel 导出保持一致。

**subagent-driven-development 阶段** ，每个子代理完成任务后，除了常规的代码审查，还要确认没有破坏已有功能。这靠的是 TDD 的测试保护网 - 先写测试确保现有行为不变，再写新功能的测试。

**requesting-code-review 阶段** ，审查重点偏向 **新代码是否和项目风格一致** 和 **有没有引入不必要的依赖** 这两个维度。

### 一个容易忽略的步骤

在老项目里用 Superpowers，别跳过 using-git-worktrees。

有些人觉得 **加个小功能而已，不用隔离** 。但 worktree 的价值不仅是隔离代码，更关键的是给你一个 **可以随时丢弃的沙箱** - 改坏了直接删 worktree，主分支毫发无损。在老项目里，这种安全网比新项目更重要，因为你改的代码可能影响到已有的业务逻辑。

你在老项目里用 AI 编程时，通常怎么控制代码质量？欢迎在评论区聊聊你的做法。

## 5\. 场景 3：发现并修复 BUG

这个场景和前两个有本质区别 - **不需要完整工作流，只需要精准打击** 。

推荐工作流精简到 3 步：

```
systematic-debugging → test-driven-development → verification-before-completion
```

为什么精简？因为修 bug 的目标明确、范围可控，不需要 brainstorming 来梳理需求，也不需要 worktree 来隔离（通常在现有分支上直接修）。

### 系统化调试四阶段

systematic-debugging 是这个场景的核心技能，严格分四个阶段：

![BUG 修复工作流示意图](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

BUG 修复工作流示意图

*图 3：BUG 修复 3 步工作流，核心在于系统化调试四阶段*

**阶段一：根因调查**

不做任何修改，只做信息收集。检查日志、复现 bug、查看相关代码。目标是找到 bug 的真正原因，而不是表象。

举个例子：用户反馈 **点击导出按钮没反应** 。表象是按钮失效，但根因可能是 API 返回了 500 错误，而前端没有处理错误状态。如果你只修前端按钮的样式，问题还在。

**阶段二：模式分析**

分析 bug 的模式 - 偶发的还是必现的？和特定输入相关还是和环境相关？特定用户才遇到还是所有用户都有？

这个分析会直接影响修复策略。必现的 bug 好修，偶发的需要更多环境信息。和特定输入相关的可能需要加边界检查，和环境相关的可能需要改配置。

**阶段三：假设与测试**

基于前两个阶段的发现，形成修复假设，用测试验证。注意：这里的 `测试` 不是随便跑一下看看，而是写一个能复现 bug 的自动化测试。

**阶段四：实施修复**

确认假设正确后，才真正动手改代码。而且改完要跑一遍完整的测试套件，确保没有引入新的问题。

### 为什么要先写失败测试

这是 Superpowers 的铁律： **没有失败测试就不写生产代码** 。

很多人修 bug 的习惯是直接改代码、跑一遍、不报错了就收工。Superpowers 要求你先写一个能复现 bug 的失败测试，然后再修。两个好处：

1. 确认你真的找到了 bug 的根因，而不是碰巧改对了地方
2. 这个测试会留在测试套件里，防止同一个 bug 再次出现

说白了，失败测试是一个 **诊断证明** - 证明 bug 确实存在，也证明修复确实有效。

### 修复后的验证

verification-before-completion 技能要求在声明完成之前，必须提供 **新鲜的验证证据** 。不是 **我觉得修好了** ，而是：

- 所有测试通过（包括新写的和原有的）
- 手动验证 bug 已经修复
- 相关功能没有回归

`新鲜` 这个词很关键。不是 **昨天跑过了** ，不是 **之前没问题** ，是 **刚刚验证过** 。这个约束防止的是一种常见情况：改了 A 功能，B 功能悄悄坏了，但你没测 B。

## 6\. 三条铁律：为什么管得这么严

翻完 Superpowers 的 14 个 Skills 文档，一个很强烈的感受是：这东西管得真多。

但每条规则背后都有明确的工程逻辑。Superpowers 把它们叫做 **Iron Laws（铁律）** ，不是建议，是硬性约束。

### 铁律一：没有失败测试就不写生产代码

test-driven-development 技能的硬性约束。

逻辑链是这样的：如果你写不出一个能失败的测试，说明你还没想清楚要实现什么。连行为都定义不了，写出来的代码大概率是瞎猜的。

TDD 的好处不是笼统的 **代码质量更好** ，而是非常具体的三个点：

- 迫使你在写代码前思考接口设计
- 提供即时反馈，写完马上就能验证
- 形成安全网，后续改动不怕引入回归

### 铁律二：不做根因调查就不修 bug

systematic-debugging 技能的核心约束。

没有根因分析的修复，本质上是在碰运气。改了一行代码，bug 消失了，但不确定为什么。万一根因在别处，这个 `修复` 只是掩盖了症状。等到后面爆出更大的问题，排查成本翻倍。

社区里有人吐槽这条铁律 **太慢了** 。说实话，确实慢。但根因调查慢在前面，修一次就彻底解决。不查根因快在前面，同一个 bug 反复出现，总时间反而更多。

### 铁律三：没有新鲜验证证据就不做完成声明

verification-before-completion 技能的要求。

这条铁律对抗的是一种心理倾向 - 改完代码后急着宣布 **搞定了** 。尤其是用 AI 编程的时候，AI 说 **修复已完成** ，你就信了。但 AI 说的 `已完成` 可能只是 **代码改完了** ，不代表 **验证过了** 。

Superpowers 要求的验证证据包括：测试全部通过、手动验证确认、相关功能无回归。三条都满足才算完成。

三条铁律合在一起看，本质上是在对抗软件开发中三种典型的偷懒行为：不写测试、不查根因、不验证就收工。Superpowers 不是在教你怎么做事，而是在阻止你偷懒。

## 7\. 实战心得与建议

### 怎么选工作流

三个场景对应三套流程，选择逻辑很简单：

- 做新东西（新项目或新功能）→ 走完整 7 步
- 修 bug → 走 3 步精简版（调试 → TDD → 验证）
- 有多个不相关的独立任务 → 考虑 dispatching-parallel-agents 并行处理

### 安装方式

Claude Code 用户一行命令搞定：

```
/plugin install superpowers@claude-plugins-official
```

Cursor 用户：

```
/add-plugin superpowers
```

其他平台（Codex、OpenCode、Gemini CLI、GitHub Copilot CLI）的安装方式可以在项目 README 里找到。六个平台全部支持，这是 Superpowers 相比同类项目的一个优势 - 不绑定单一工具。

### 什么时候用，什么时候不必

Superpowers 适合有一定复杂度的开发任务。改个配置文件、写个简单脚本，用它反而重了。

但涉及多文件改动、需要测试保护、需要代码审查的场景，Superpowers 的价值就出来了。尤其是子代理驱动开发这个机制 - 让每个任务独立执行、独立审查，对复杂项目帮助很大。

### 几个常见问题

**Superpowers 会拖慢开发速度吗？**

前期确实会慢。brainstorming 的反复确认、TDD 的测试先行，都比直接让 AI 输出代码多花时间。但这个时间花在设计阶段，能减少后期的返工。用官方文档的话说： **流程优于猜测（Systematic over ad-hoc）** 。

**可以只用部分 Skills 吗？**

Skills 是可组合的，不需要每次走完整流程。修 bug 就是个例子 - 只用 3 个 Skills。但要注意强制触发机制： **如果存在适用的技能，Agent 会自动使用。想精细控制的话，可以在配置里调整。**

**对什么编程语言有效？**

Superpowers 约束的是开发流程，不是代码实现，理论上不限语言。不过 TDD 在不同语言中的体验差异比较大： **Python、JavaScript 这类动态语言写测试比较轻快，C++、Java 这类编译型语言测试周期会长一些。**

## 总结

Superpowers 解决的不是 **AI 不会写代码** 的问题，而是 **AI 写代码不够靠谱** 的问题。

14 个 Skills 覆盖从需求梳理到代码审查的完整流程。3 条铁律对抗的是开发中三种典型的偷懒行为。子代理驱动开发解决了多任务场景下的上下文污染问题。

说实话，这套流程上手会有不习惯 - 毕竟大多数人用 AI 编程图的就是快。但如果你正在用 AI 做正经的项目开发，建议收藏这篇文章。下次遇到复杂任务时翻出来对照一下，看看 Superpowers 的三条铁律能帮你避开哪些坑。

如果你的同事也在用 AI 编程，转发给他们看看：尤其是那些抱怨 **AI 写的代码老出 bug** 的人，Superpowers 的 3 条铁律可能正是他们需要的。

**好啦，谢谢你观看我的文章，如果喜欢可以点赞转发给需要的朋友，我们下一期再见！敬请期待！**

**扫码关注，获取更多 AI 工具的实战经验和最佳实践。不错过每一篇干货！**

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**微信扫一扫赞赏作者**

AI编程最佳实战「2026」 · 目录

继续滑动看下一个

术哥无界

向上滑动看下一个