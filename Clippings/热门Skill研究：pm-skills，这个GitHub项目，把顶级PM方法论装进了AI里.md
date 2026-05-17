---
title: "热门Skill研究：pm-skills，这个GitHub项目，把顶级PM方法论装进了AI里"
source: "https://mp.weixin.qq.com/s/DY6jkOeRNvR7MVLDz02ezg"
author:
  - "[[杜倬]]"
published:
created: 2026-05-15
description: "65个技能、36个工作流，从发现到增长全覆盖。Teresa Torres、Marty Cagan等大师的方法论，一个斜杠命令就能调用。"
tags:
  - "clippings"
---
杜倬 *2026年5月6日 07:00*

> 65个技能、36个工作流，从发现到增长全覆盖。产品经理的AI时代，真的来了。

· · ·

## 一、一个令人惊艳的发现

前几天在GitHub上闲逛，我发现了一个让人眼前一亮的项目—— **pm-skills** 。

它的自我介绍很简洁：「PM Skills Marketplace，100+ agentic skills, commands, and plugins」。但点进去一看，我发现这不仅仅是一个工具集合，而是一个 **把顶级产品管理方法论系统性编码进AI的尝试** 。

项目作者整合了 Teresa Torres（持续发现）、Marty Cagan（赋能团队）、Alberto Savoia（精益创业）等一众产品大师的框架，把它们变成了可以直接在 Claude Code 和 Cowork 中调用的技能和工作流。

换句话说， **以前要读十本书才能建立的产品思维体系，现在一个斜杠命令就能调用。**

· · ·

## 二、它到底能做什么？

整个项目分为8个插件，覆盖了产品经理工作的完整生命周期：

### 1\. 产品发现（pm-product-discovery）

这是我最惊喜的部分。它不只是帮你头脑风暴，而是提供了一套结构化的发现流程：

- ● **`/discover`**
	—— 完整的发现周期：创意发散 → 假设识别 → 优先级排序 → 实验设计
- ● **`/brainstorm`**
	—— 多视角创意生成（PM、设计师、工程师）
- ● **`/interview`**
	—— 客户访谈脚本准备和访谈总结
- ●
	内置 **Opportunity Solution Tree** （机会解决方案树）、 **假设映射** 、 **优先级矩阵** 等框架

举个实际例子：当你有一个"AI会议助手"的创意时，输入 `/discover AI-powered meeting summarizer` ，它会引导你一步步识别风险最高的假设，设计验证实验，而不是直接开始写PRD。

### 2\. 产品策略（pm-product-strategy）

策略制定往往是产品经理最头疼的部分。这个插件提供了：

- ● **`/strategy`**
	—— 9宫格产品策略画布（从愿景到护城河）
- ● **`/business-model`**
	—— 商业模式探索（Lean Canvas、BMC、Startup Canvas）
- ● **`/market-scan`**
	—— 宏观环境分析（SWOT + PESTLE + 波特五力 + 安索夫矩阵）
- ● **`/pricing`**
	—— 定价策略设计

**它把 Roger Martin 的《Playing to Win》和 Strategyzer 的商业模式框架都装了进来。**

### 3\. 产品执行（pm-execution）

日常工作中最实用的部分：

- ● **`/write-prd`**
	—— 从一句话需求生成完整PRD
- ● **`/plan-okrs`**
	—— 对齐公司目标的团队OKR
- ● **`/sprint`**
	—— 冲刺规划、回顾、发布
- ● **`/pre-mortem`**
	—— 预演失败风险分析
- ● **`/stakeholder-map`**
	—— 利益相关者权力-利益矩阵

### 4\. 市场研究（pm-market-research）

- ● **`/research-users`**
	—— 构建用户画像、细分市场、绘制客户旅程
- ● **`/competitive-analysis`**
	—— 竞争格局分析
- ● **`/analyze-feedback`**
	—— 用户反馈的情感分析和主题提取

### 5\. 数据分析（pm-data-analytics）

- ● **`/write-query`**
	—— 自然语言生成SQL（支持BigQuery、PostgreSQL、MySQL）
- ● **`/analyze-cohorts`**
	—— 队列分析
- ● **`/analyze-test`**
	—— A/B测试结果统计分析

### 6\. 市场进入（pm-go-to-market）

- ● **`/plan-launch`**
	—— 从滩头市场到发布计划的完整GTM策略
- ● **`/growth-strategy`**
	—— 增长飞轮设计和GTM模式评估
- ● **`/battlecard`**
	—— 销售用竞争对比卡

### 7\. 营销增长（pm-marketing-growth）

- ● **`/market-product`**
	—— 营销创意、定位、价值主张、产品命名
- ● **`/north-star`**
	—— 定义北极星指标和支撑指标

### 8\. 工具箱（pm-toolkit）

- ● **`/review-resume`**
	—— PM简历评审
- ● **`/draft-nda`**
	—— 起草保密协议
- ● **`/proofread`**
	—— 语法和逻辑检查

· · ·

## 三、为什么这个项目值得关注？

### 理由一：它不是"更快写文档"，而是"更好做决策"

市面上很多AI产品管理工具都在解决"怎么更快写PRD"的问题。但 pm-skills 的核心理念不同—— **它提供的是决策框架，而不是文档模板。**

每个技能都编码了一个经过验证的PM框架，让AI不是替你写，而是 **引导你思考** 。这才是AI在产品管理中应该扮演的角色：不是替代思考，而是 **放大思考质量** 。

### 理由二：方法论不是挂墙上，而是融入工作流

很多产品经理都读过《INSPIRED》《Continuous Discovery Habits》，但读过和用过之间隔着一道鸿沟。pm-skills 把这些方法论变成了 **可执行的命令** ，你可以在几秒钟内调用一个完整的分析框架。

**知识不再是书架上的收藏，而是指尖的工具。**

### 理由三：兼容多种AI工具

虽然主要为 Claude Code 设计，但项目中的 skills 采用通用格式，可以复制到 Gemini CLI、Cursor、OpenCode、Codex CLI、Kiro 等工具中使用。

这意味着 **你不需要切换工具链** ，可以在自己习惯的IDE里获得产品管理能力加成。

· · ·

## 四、安装方法（超简单）

**Claude Code 用户：**

代码bash

```
claude plugin marketplace add phuryn/pm-skills
```

或者手动安装单个插件：

代码bash

```
claude plugin install pm-product-discovery@pm-skills claude plugin install pm-execution@pm-skills
```

**其他工具用户：**

直接把技能文件夹复制到对应目录即可：

代码bash

```
# 例如 Gemini CLI for plugin in pm-*/; do   cp -r "$plugin/skills/"* ~/.gemini/skills/ 2>/dev/null done
```

· · ·

## 五、几个令人心动的使用场景

**场景一：新产品创意验证**

代码

```
/discover AI-powered meeting summarizer for remote teams
```

→ 自动走完创意发散、假设识别、优先级排序、实验设计全流程

**场景二：竞品分析**

代码

```
/competitive-analysis Figma competitors in the design tool space
```

→ 输出结构化的竞品优劣势对比和差异化机会

**场景三：从功能列表到成果路线图**

代码

```
/transform-roadmap
```

→ 把"我们要做A功能、B功能"变成"我们要实现X成果"

**场景四：会议总结**

代码

```
/meeting-notes
```

→ 上传会议录音/文字，自动提取决策点和行动项

· · ·

## 六、写在最后

pm-skills 让我看到了AI赋能产品经理的另一种可能： **不是替代，而是升维。**

当AI掌握了最好的方法论，产品经理可以把更多精力放在"判断"和"洞察"上——那些机器暂时还做不到的部分。

这个项目目前还在快速迭代中，GitHub 地址是：

**https://github.com/phuryn/pm-skills**

如果你也是产品经理，或者对AI如何改变产品工作感兴趣，强烈推荐去star一下，亲自体验几个命令。我试完 `/discover` 和 `/strategy` 后的感受是： **这可能就是产品经理的AI Copilot该有的样子。**

· · ·

**你最想试试哪个命令？** 评论区聊聊 👇

*本文介绍的工具为开源项目，使用请遵循其 LICENSE 协议。*

— 全文完 —

如果对你有帮助，欢迎点个 在看 👀 或 转发 给朋友 🙌

**微信扫一扫赞赏作者**

热门Skill研究 · 目录

继续滑动看下一个

读行万里的AI日记

向上滑动看下一个