---
title: "忘掉 brainstorming：grill-me + trellis 的极简 vibe coding 工作流"
source: "https://mp.weixin.qq.com/s/YzI83k56nW7IE-YMKltRyg"
author:
  - "[[朗朗晴空]]"
published:
created: 2026-05-15
description: "几句话的skill问清需求，分阶段执行框架一气呵成——比superpowers的plan环节更清晰。"
tags:
  - "clippings"
---
朗朗晴空 *2026年5月2日 15:12*

工具研究 · 2026.05.02

KEY TAKEAWAY

Matt Pocock 的 grill-me skill 只有几句话，却能在写代码前把需求问得事无巨细。问清楚之后交给 Trellis 做任务拆解和计划管理，配合 dangerously-skip-permissions 模式，整个开发过程可以无人干预跑几十分钟。这套组合比 superpowers 的 brainstorming 环节更简洁、侵入性更低。

5行

grill-me 代码量

13k+

Reddit 讨论热度

2

工具组合

这套工作流解决什么问题

vibe coding 的核心痛点不是"写不出代码"，而是"写出来的不是我想要的"。原因很简单：你在脑子里有一个模糊的愿景，但你给代理的指令不够具体，代理就按自己的理解去做了。做出来你才发现"不对，我要的不是这个"。

传统的解决方案是 brainstorming 或 plan 环节——让代理先出一个方案，你审，改，再审，再改。问题是这些环节太重了：输出长、慢、经常跑偏，你还得花精力去判断代理的方案对不对。

grill-me 的思路完全反过来：不是代理给你出方案，而是代理问你问题。一个一个问，每个问题附带推荐答案。你只需要回答"对"或"不对，应该是这样"。问完之后，代理对你的需求的理解比你自己还清楚。

grill-me：几句话的神级 skill

grill-me 是 Matt Pocock 创建的 Claude Code skill，完整代码只有几句话。它的作用是：在你提出需求时，代理不断追问你，沿着设计决策树的每个分支走下去，直到你们达成完全的共识。

**grill-me 的核心指令** 　"Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer. Ask the questions one at a time. If a question can be answered by exploring the codebase, explore the codebase instead."

▸　 **一次只问一个问题** — 不会信息过载，你只需要做一个个小决策

▸　 **附带推荐答案** — 不是开放式问题让你自己想，而是"我建议这样做，你觉得呢"

▸　 **能自己查代码就查** — 如果答案在代码库里，代理自己去找，不浪费你的时间

▸　 **极简无侵入** — 只有几行指令，不改变你现有的任何工作流，可以嵌入任何代理系统

在 Reddit 的 r/vibecoding 社区，grill-me 的讨论帖获得了 13k+ 的热度。用户反馈的核心共识是：它比 brainstorming 更高效，因为 brainstorming 是代理在猜你要什么，grill-me 是代理在确认你要什么。

Trellis：项目计划与任务治理框架

需求问清楚了，下一步是执行。Trellis 是 Mindfold 出品的项目计划和任务治理框架，它不是替代 Claude Code，而是给 Claude Code 增加一套"先规划、再执行"的结构。把大想法拆成任务树，明确目标、约束、验收标准，然后让代理按计划推进。

▸　 **任务树拆解** — 把大方向拆成可执行的任务树，每条任务有明确目标和验收标准

▸　 **上下文管理** — 让代理按计划推进，避免长对话中上下文腐烂和方向漂移

▸　 **多平台支持** — 一次 init 同时支持 Claude Code、Codex、Cursor 等多个代理

▸　 **先规划再执行** — 先用 Trellis 搭计划骨架，再用 grill-me 拷问，最后让代理实现

完整工作流：从需求到交付

**第一步：grill-me 问清需求**  
对代理说"使用 grill-me 拷问这个方案"，它开始逐个追问设计决策。你回答每个问题，直到双方对每个关键决策都理解一致。这一步通常需要 5-15 分钟。

**第二步：Trellis 搭计划骨架**  
在项目目录里运行 trellis init 初始化，然后用 Trellis 把需求共识拆成任务树。每个任务有明确目标和验收标准。

**第三步：代理按计划执行**  
让 Claude Code 或 Codex 按 Trellis 生成的计划推进。配合 dangerously-skip-permissions 模式可以全程无人干预，一次跑几十分钟。

**第四步：交付验收**  
所有阶段跑完，得到一个符合需求的完整交付。因为需求在第一步已经问清楚了，交付和预期的偏差会很小。

为什么比 superpowers 的 brainstorming 更好

SUPERPOWINGS BRAINSTORMING

代理出方案，你审

输出长、慢、容易跑偏

需要你判断方案对不对

侵入性强，改变工作流

GRILL-ME + TRELLIS

代理问问题，你答

每个问题附推荐答案

你只需要确认或纠正

极简无侵入，嵌入任何系统

核心区别在于认知负荷的方向：brainstorming 是代理输出、你审核；grill-me 是代理提问、你决策。后者的认知负荷更低，因为你只需要做二元判断（对/不对），不需要从零评估一个完整方案。

如何安装

**grill-me（Claude Code skill）**  
如果你用的是 Claude Code + superpowers，已有 skill 管理器，直接添加：

```
npx skills@latest add mattpocock/skills --yes
```

注意： `npx skills@latest add mattpocock/skills/grill-me` （子路径方式）安装器无法识别，必须用整仓库安装。安装器会自动写入 Claude Code、Codex、Cursor、Gemini CLI 等多个平台。

**Trellis（Mindfold）**  
需要 Node.js 环境。全局安装后在项目里 init：

```
npm install -g @mindfoldhq/trellis@beta
cd your-project
trellis init --claude --codex
```

适合谁，不适合谁

●　 **适合 vibe coder** — 你想快速把想法变成可工作的代码，但不想花时间写详细 spec

●　 **适合多代理用户** — 用 Claude Code、Codex、Hermes Agent 等工具的人，grill-me 可以嵌入任何系统

●　 **适合长任务开发者** — Trellis 的任务拆解和上下文管理解决了长任务中的方向漂移问题

●　 **不适合** — 不用编码代理的人（grill-me 是 skill 不是独立产品）、需要 GUI 的非技术用户

关于 dangerously-skip-permissions

NOTE安全提醒

**dangerously-skip-permissions** 会跳过所有权限确认，代理可以直接读写文件、执行命令。好处是流程丝滑不中断；风险是代理可能做出你预期之外的操作。

建议：先用 grill-me 把需求问透，再用 Trellis 的先规划再执行模式——需求越明确，跳过权限的风险越小。在不熟悉的项目上不要用这个模式。

项目状态

GRILL-ME

作者：Matt Pocock

仓库：mattpocock/skills

状态：成熟，社区广泛使用

适配：Claude Code / Hermes Agent

TRELLIS

作者：Mindfold

仓库：mindfold-ai/Trellis

npm：@mindfoldhq/trellis@beta

适配：Claude Code / Codex / Cursor

grill-me 已经是社区验证过的成熟工具，Matt Pocock 本人有视频教程和详细文档。Trellis 仍处于 beta 阶段，但其设计理念（任务拆解 + 上下文管理 + 多平台支持）是目前代理工作流框架中最扎实的之一。如果你不想用 Trellis，也可以只用 grill-me 做需求澄清，执行阶段仍用你熟悉的工具。

SOURCES

grill-me SKILL.md — github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md

Trellis — github.com/mindfold-ai/Trellis（npm: @mindfoldhq/trellis@beta）

Reddit r/vibecoding 讨论 — reddit.com/r/vibecoding/comments/1swyadr

Matt Pocock 教程 — aihero.dev/use-the-grill-me-skill-k029d

linux.do 原帖 — linux.do/t/topic/2070891

ai 工作流 · 目录

作者提示: 内容由AI生成

继续滑动看下一个

极客BIM设计工坊

向上滑动看下一个