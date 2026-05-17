---
title: "如果不开启这个环境变量，你的 Claude Code 可能只发挥了 50% 的功力。"
source: "https://mp.weixin.qq.com/s/7jngdJ3lzPGAy4eNpX_edA"
author:
  - "[[知识姬 Mina]]"
published:
created: 2026-05-15
description: "Claude Code 长会话越聊越“脏”？频繁的工具调用正在吃掉你的 Token。本文深度解析 Subagent 子代理机制：如何通过上下文隔离消除噪音、利用 Fork 模式实现逻辑继承，并配合监控 Hook 实时掌控上下文消耗，让 AI 协作重回清爽高效。"
tags:
  - "clippings"
---
知识姬 Mina *2026年4月27日 17:00*

![[_resources/如果不开启这个环境变量，你的 Claude Code 可能只发挥了 50% 的功力。/42479abffa61f8cec135d655d98ff1af_MD5.webp]]

Claude Code 的长会话，很容易越聊越脏。

你让它帮你查一个实现、复核一段代码、验证一个模式，它就会不断调用 `grep` 、 `find` 、 `ls` 、 `glob` 。问题不在于这些动作没用，而在于这些调用记录会一直留在主上下文里，占掉大量你几乎不会再回头看的空间。

Subagent 的作用，正是把这部分工作隔离出去：它在自己的上下文窗口里完成搜索、分析、归纳，最后只把结论返回给主代理。

这篇文章不绕弯子，直接讲四件事：Subagent 到底是什么、怎么创建、自带哪些常用类型，以及如何通过 `CLAUDE_CODE_FORK_SUBAGENT=1` 把父上下文直接 fork 给它。

## 什么是 Subagent

Subagent 可以理解成一个“专门工种”的小助手。它运行在 **独立的上下文窗口** 里，有自己单独的 system prompt、工具权限和执行边界。主代理把任务交给它，它在隔离环境里完成工作，最后返回一份摘要。

![[_resources/如果不开启这个环境变量，你的 Claude Code 可能只发挥了 50% 的功力。/230b9f8715f79fadf55f802a57e882fa_MD5.webp]]

创建它其实很简单，本质上就是写一个带 frontmatter 的 Markdown 文件：

```
---
name: code-reviewer
description: Reviews code for quality, security, and maintainability. Use after writing or modifying code.
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are a senior code reviewer. When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Start the review immediately
```

Claude Code 会自动识别这类定义；当任务描述和它的 `description` 匹配时，就会优先调用这个 Subagent。

## Subagent 放在哪里

Subagent 文件可以放在不同位置，作用域也不同。如果两个 Subagent 同名，优先级更高的位置会覆盖更低的位置。

![Image](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

大多数情况下，你真正会用到的是这两个目录：

- • `.claude/agents/` ：项目级，适合提交到版本控制里，方便团队共享
- • `~/.claude/agents/` ：个人级，适合全局复用，到处都能用
![Image](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

## 问题所在：所有事情都挤在同一个窗口里

如果没有 Subagent，主代理就得把所有事都塞进同一个上下文里做。

你让它审一个 controller、搜一个模式、验证一段逻辑，它就会开始连环调用： `grep` 、 `find` 、 `ls` 、 `glob` 、 `cd` ，然后继续 `grep` 、继续 `find` 。这些调用本身未必有问题，但它们都会原封不动留在你的上下文里。

![Image](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

半小时之后，你可能已经攒了几万甚至更多 token 的“噪音”，而这些内容你大概率根本不会再看。

更麻烦的是，一旦 Claude 开始压缩上下文，这些信息就会被摊平成摘要。真正关键的细节，反而容易在压缩过程中丢失。

![Image](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

## Claude Code 自带的两个常用 Subagent：Explore 和 Plan

Claude Code 其实已经内置了一些适合高频场景的 Subagent，其中最常用的通常就是下面两个：

**Explore** ：负责搜索代码库，但不会污染主上下文。它可以在自己的窗口里疯狂跑 `grep` 和 `find` ，最后只把真正有价值的发现带回来。

**Plan** ：负责调查、理解架构并产出实现计划。它会去读文件、梳理依赖、组织步骤，最后返回一份可执行的计划文档，而主上下文不需要背负那些中间过程。

![Image](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

这样一来，你的主窗口里不再堆满几十次工具调用，最终只会留下几行真正有用的结论，其余中间噪音都可以被自然丢弃。

> 这里放了一段约 40 秒的演示视频，用来展示 Subagent 如何在独立上下文中工作，并把结果回传给主代理。
> 
> `0:13 / 0:40`

## Fork 上下文：把父上下文直接交给 Subagent

默认情况下，Subagent 启动时拿到的是一个空白上下文。

这对“保持干净”很有帮助，但也会带来另一个问题：如果你已经在主会话里投入了大量 token，建立起对代码库的完整理解，你可能并不想让 Subagent 从零开始。

![Image](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

这时候就可以用 fork。

fork 的含义很直接： **在创建 Subagent 的那一刻，把父代理当前的上下文完整复制一份给它。**

```
export CLAUDE_CODE_FORK_SUBAGENT=1
```

## 它是怎么工作的

一旦设置了 `CLAUDE_CODE_FORK_SUBAGENT=1` ，之后创建的每个 Subagent，默认都会继承父代理当时的完整上下文。

如果你不想全局开启，也可以按需使用 `/fork` 这个 slash command：

![Image](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

要注意的是，fork 过去的是上下文，不是污染。

也就是说，Subagent 虽然继承了父代理已经建立好的理解，但它后续产生的工具调用，依然会留在它自己的隔离窗口里，主会话最终只收到结果摘要。

![Image](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

fork 出来的 Subagent 有几个关键特征：

- • 继承父代理在 fork 那一刻的完整对话上下文
- • 与父代理共享 prompt cache 前缀，因此第 2 个到第 N 个子代理的输入成本会明显更低
- • 仍然在隔离环境中运行，不会把自己的工具调用污染父上下文
- • 最终只把结论性摘要返回主会话

## 实时查看上下文变化：context-timeline Hook

如果你只看控制台，其实很难直观看清楚：主代理当前吃掉了多少上下文、并行跑了几个 Subagent、每个 Subagent 最后又回传了多少信息。

作者为此做了一个 hook，名字叫 `context-timeline` 。

链接：https://www.aitmpl.com/component/hook/monitoring/context-timeline

![Image](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

Image

安装方式如下：

```
npx claude-code-templates@latest --hook monitoring/context-timeline
```

它会在你打开会话后立即开始记录，用时间线的方式展示主代理的上下文窗口，以及每个 Subagent 如何在各自独立的上下文里启动、执行和结束。

当某个 Subagent 完成任务时，它向主代理返回了多少内容，也能被实时看到。

如果你之前还没认真用过 Subagent，我的建议是：先在 `.claude/agents/` 里写一个最简单的。只要经历过一次稍长一点的 Claude Code 会话，你通常很快就能感受到差别。

AI技术 · 目录

继续滑动看下一个

知识发电机

向上滑动看下一个