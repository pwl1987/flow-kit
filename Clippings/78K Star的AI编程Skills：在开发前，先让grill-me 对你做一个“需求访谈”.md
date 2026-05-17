---
title: "78K Star的AI编程Skills：在开发前，先让grill-me 对你做一个“需求访谈”"
source: "https://mp.weixin.qq.com/s/sSpaBEcClrB04JqDgBu0TQ"
author:
  - "[[H的AI笔记]]"
published:
created: 2026-05-15
description: "TypeScript大师Matt Pocock的14个AI编程Skill，其中/grill-me只有10行Markdown，却解决了AI编程最大的痛点——你说的和AI理解的根本不是一回事。"
tags:
  - "clippings"
---
H的AI笔记 *2026年5月14日 15:23*

我是H，AI狂热爱好者。网上的AI分享看花了眼？我一个个亲手试过，把真实体验告诉你。

用AI写代码的人大概都经历过这个崩溃时刻：你跟AI说"帮我做一个待办清单应用"，它飞速输出完整方案——需求分析、技术选型、系统设计、实现步骤、测试、部署，一应俱全。

但你仔细一看：它不知道你要Web还是App，不知道用户是谁，不知道要不要多人协作，不知道数据存哪。方向全靠猜。

你怪AI写得烂？不，是你没说清楚。

问题是，大多数人根本不知道自己需要什么，直到看到错误答案才知道。《程序员修炼之道》里早就说了："没有人确切知道自己想要什么。"

![[_resources/78K Star的AI编程Skills：在开发前，先让grill-me 对你做一个“需求访谈”/c58c102926817d0f3548b2459b5926db_MD5.webp]]

GitHub上一个78K star的项目，专门解决这个问题。思路和之前爆火的Karpathy CLAUDE.md刚好反过来——不是你教AI怎么做，而是AI教你怎么做。

## ▍先回顾：Karpathy

之前我写过一篇 Andrej Karpathy 的 Skills，一个58行CLAUDE.md文件，给AI定了4条规矩：先想再写、简洁优先、精准修改、目标驱动。同一个需求代码从149行降到42行。

Karpathy的思路是治理AI——约束AI的行为。但Matt Pocock走的是另一条路：治理人。

## ▍Matt Pocock是谁

TypeScript类型系统专家，Total TypeScript作者，TypeScript社区顶级KOL。他整理了一套AI编程Skill集合，叫 mattpocock/skills，78K star。

14个正式Skill，全部是纯Markdown文件，零依赖，零安装。支持Claude Code、Codex、Cursor等多编码Agent。

npx skills@latest add mattpocock/skills

一个命令安装，交互式选择你要的Skill，不到1分钟。

## ▍14个Skill长什么样

分两大类：

**工程类（10个）** ：grill-with-docs（需求对齐+术语管理）、diagnose（系统化调试）、tdd（测试驱动开发）、improve-codebase-architecture（架构深挖）、triage（Issue分拣）、to-prd（生成PRD）、to-issues（PRD拆Issue）、zoom-out（全局视角）、prototype（快速原型）、setup（初始化）

**效率类（4个）** ：grill-me（需求追问）、caveman（省Token模式）、handoff（会话交接）、write-a-skill（写新Skill）

我挑选非常实用的3个讲。

## ▍grill-me：10行Markdown，追问到你想明白为止

这是整个仓库最火的一个Skill。

先看看它到底有多简洁，真正干活的提示词只有这么几句：

Interview me relentlessly about every aspect of this plan  
until we reach a shared understanding. Walk down each branch  
of the design tree, resolving dependencies between decisions  
one-by-one. For each question, provide your recommended answer.  
  
Ask the questions one at a time.

翻译过来：不停地追问你，直到双方理解一致。每次只问一个问题。

其实Claude Code内置了plan mode，在项目之初也会与用户沟通，它的问题是这样的：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

技术栈、数据存储、功能范围——三个选项让你选。对专业程序员来说，他们知道每个选项意味着什么。但对普通人来说，"原生HTML/CSS/JS"和"React"和"Vue"有什么区别？该选哪个？完全懵。而且，他讨论的太粗太粗。

然后我装上grill-me，同一个需求：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

grill-me先看了一眼项目目录是空的，然后推荐："React + Vite + TypeScript"。不是只给选项，而是直接告诉你推荐什么、为什么推荐——"React生态成熟、状态管理灵活；Vite开发体验快；TS减少运行时错误"。

你不懂技术没关系，它帮你做决策并解释理由。你只需要判断"行"或"不行"。

这个区别很关键。Claude Code内置的是选择题，你得自己懂才能选对。grill-me是问答题+推荐，AI帮你分析并给建议，你只需要确认。

详细追问完问题后，"做一个待办清单应用"从一句话变成了完整的PRD。这时候再让AI写代码，就避免当你看到产品时，才想起来跟AI说“我忘记告诉你……”。

这个Skill在LinkedIn和Reddit上疯传，6万Newsletter订阅者验证了需求是真实的。

## ▍grill-with-docs：解决"鸡同鸭讲"

AI编程最怕的不是AI写错代码，是你和AI说的不是同一种话。

你说"任务"，AI理解成Issue；你说"事项"，它又当成Todo。一个概念几个叫法，代码写到后面指代全乱了。

grill-with-docs在追问的基础上，解决了这个"鸡同鸭讲"的问题。它做了三件事：

**统一语言。** 讨论中每确定一个概念，自动写入项目根目录的CONTEXT.md。你一会儿说"任务"，一会儿说"事项"，一会儿说"待办"，AI会停下来："你说的这三个是同一个东西吗？如果是，统一叫一个名字。"后面所有的变量名、函数名、文件名都用这个统一术语。

**交叉验证。** 你说"支持部分退款"，AI去翻代码发现只能整单退款，直接指出来："你说的和代码不一致，哪个是对的？"不是你说啥它就信啥。

**记录重大决策。** 遇到"选了就很难改回来"的架构决策时，AI会建议创建ADR（Architecture Decision Record）。不是每个决定都记，只在三个条件同时满足时才建议：难撤销、不看上下文会困惑、有真实的方案取舍。

grill-with-docs相当于给AI编程加了一个"共识对齐"环节，先统一认知再动笔。

## ▍caveman：让AI闭嘴，只说重点

这个Skill让AI用极简语言回复——砍掉寒暄、解释性文字和模糊措辞，只保留技术要点。

我实测同一个问题"为什么React组件一直重新渲染"：

正常模式，AI先分析原因，再给方案，还附了示例代码，拉拉杂杂一大段。核心信息就那么几句，但被"当然""首先""另外"淹没了。

caveman模式下，AI直接说重点：

> React组件重新渲染可能因多原因。\[组件\] \[重新渲染\] \[原因：状态变更、props变更、生命周期方法调用等\]。\[检查状态或props\]。\[优化渲染性能\]。

同样的信息，干净利落。遇到安全相关和破坏性操作时自动退出caveman模式，不会因为精简漏掉重要警告。

## ▍几个实话

顶级创作者出品。内容本身经得起看——纯Markdown、零依赖、零网络请求、MIT协议，这是我测评过的最干净的工具。

所有Skill都是纯文本提示词，效果取决于你和AI的配合质量。它不是装上就自动生效的魔法，更像是给AI编程加了一套好的工作流程。

这些Skill的核心理念——先想清楚需求再动手、建反馈环、维护架构——不是新东西。来自《程序员修炼之道》《领域驱动设计》《极限编程》这些几十年前的经典。作者把它们浓缩成了AI可执行的格式。

这反而是最大的价值。AI编程的速度在加快，但软件工程的根基没变。越快的工具，越需要好的工程实践来兜底。

*我是H，AI狂热爱好者。AI的世界变化太快，我帮你把真正有用的挑出来。关注「H的AI笔记」，我们下篇见。*

—— 更多热门文章 ——

[DeepSeek-TUI冲上GitHub第一，真比Claude Code强？我帮你把水分挤掉](https://mp.weixin.qq.com/s?__biz=MzAwMDgxMTAyNg==&mid=2247483911&idx=1&sn=5bcff63fc59645099f321d6fc82a3f13&scene=21#wechat_redirect)

[context-mode实测：一个MCP让AI编程Token省了96%](https://mp.weixin.qq.com/s?__biz=MzAwMDgxMTAyNg==&mid=2247483902&idx=1&sn=75d86cd0ede2dca950310c8dd8260374&scene=21#wechat_redirect)

继续滑动看下一个

H的AI笔记

向上滑动看下一个