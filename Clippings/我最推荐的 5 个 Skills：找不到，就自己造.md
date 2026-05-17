---
title: "我最推荐的 5 个 Skills：找不到，就自己造"
source: "https://mp.weixin.qq.com/s/p6z6OeSQVFb2bv5_r5dTTA"
author:
  - "[[悟鸣]]"
published:
created: 2026-05-15
description: "很多朋友问我，有没有“必装”的 Skills。我的答案可能有点扫兴：先别急着看下载量，也别急着囤一堆合集。Skills 真正好不好用，关键要看它能不能贴住你的场景。这篇文章分享 5 个我认为值得先试的通用 Skills，也顺手给几个继续挖宝的入口。"
tags:
  - "clippings"
---
悟鸣 *2026年5月7日 07:46*

这是悟鸣的第 258 篇公众号文章

大家好，我是悟鸣。

最近一段时间，越来越多朋搞 Skills。

我经常被问到一个问题：“有没有什么必装的 Skills？”

大家刚接触一个新东西，第一反应都是想找“最佳清单”“必装合集”。

但我自己用下来，的结论是：最有用的都是我自己原创的这些。

![[_resources/我最推荐的 5 个 Skills：找不到，就自己造/ec7e4ba5956929de49c5a958d78f024e_MD5.webp]]

一个 Skill 再火，如果和你的工作流对不上，它大概率只能“吃灰”。反过来，一个没多少人知道的小 Skill，只要刚好解决你的痛点，可能马上就能省掉一堆重复劳动。

所以这篇文章我不想写成“全网最强合集”，也不想把一些自媒体大 V 的Skills 伪装成“小众好用”的 Skills 合集。

我更想分享一个朴素一点的思路：

先按场景找。找不到，再自己做。用得多了，再慢慢沉淀成自己的 Skills 仓库。

基于这个思路，我今天推荐 5 个我认为比较通用、适合大多数人先装起来试试的 Skills。

---

## 1\. find-skills：先学会“找 Skill”

![[_resources/我最推荐的 5 个 Skills：找不到，就自己造/aa3220634616b56fc67ab3ef571eac7a_MD5.webp]]

第一个我推荐的是 `find-skills` 。

它的价值更偏入口：先帮你找到合适的 Skill，再让后面的工作继续跑起来。

Skills 会一直增长。今天别人发给你的清单，过几天可能就不够新了。更省事的方式，是把自己的需求说清楚，然后让 AI 帮你去找匹配的 Skills。

比如你可以直接说：

> 我想找一个适合整理会议纪要的 Skill。

装好 `find-skills` 之后，你后面想找什么 Skills，就可以直接描述需求，让 AI 帮你检索、筛选，甚至继续安装。

地址：https://skills.sh/vercel-labs/skills/find-skills

安装指令：

```
npx skills add https://github.com/vercel-labs/skills --skill find-skills
```

如果你刚开始接触 Skills，我反而建议先装这种“入口型”的。它不解决某一个固定问题，但能帮你更快找到合适的工具。

---

## 2\. skill-creator：找不到，就自己造

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

第二个我推荐的是 `skill-creator` 。

很多人一开始会把 Skills 理解成“别人写好的工具”。这个理解没错，但只说了一半。

我自己长期用下来，真正能留下来的 Skills，很多都是围绕自己的场景慢慢做出来的。

比如私人助理 Skill，公众号写作、文章解读、资料整理、提示词优化、知识库沉淀等等，这些事情每个人的习惯都不一样。别人写好的 Skill 可以参考，但不一定完全适合你。

这时候 `skill-creator` 就很有用。

它来自 Anthropic Skills 仓库，核心作用是帮你把想法、资料和工作流程整理成一个可复用的 Skill。你不需要一开始就懂完整规范，只要把需求说清楚，把参考材料准备好，它就可以帮你生成初版。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

地址：https://skills.sh/anthropics/skills/skill-creator

安装指令：

```
npx skills add https://github.com/anthropics/skills --skill skill-creator
```

我的建议是，先从一个很小的场景开始。

比如：

- 每次读完一篇文章，自动整理成固定格式的读书笔记。
- 每次写公众号草稿，自动检查标题、开头、AI 味和事实核查点。
- 每次处理会议录音，自动输出纪要、待办和可转发摘要。

不要一上来就做“全能助手”。Skills 最适合从真实、重复、边界清楚的小任务开始。小任务跑顺了，再慢慢往外扩。

## 3\. skill-vetter：Skill 安全性审查

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

skill-vetter 是一个“安装前安全审查”Skill，主要用来在安装 OpenClaw/ClawHub/GitHub 上来的 skill 前做人工审计。

它会检查几类风险：元数据是否可疑、权限是否过大、是否同时要 network + shell、是否引用 ~/.ssh /.env / 云密钥、是否有 curl/wget/nc、Base64 混淆、prompt injection、typosquatting 等，最后输出 SAFE / WARNING / DANGER / BLOCK 这类安装建议。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

地址：https://skills.sh/useai-pro/openclaw-skills-security/skill-vetter

指令： `npx skills add https://github.com/useai-pro/openclaw-skills-security --skill skill-vetter`

## 4\. dokobot：网页资料读取的好帮手

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

第四个我推荐的是 `dokobot` 。

很多 AI 工作流都会卡在第一步：资料怎么进来？

比如你想让 AI 总结一篇网页、拆解一个产品、整理一份资料，前提是 AI 得先读到内容。可现实里，经常会遇到各种麻烦：网页需要登录，内容结构复杂，平台不方便复制，或者普通抓取方式直接失败。

`dokobot` 解决的就是这类问题。

你给它一个网页，它可以帮你把网页内容提取出来，再交给 AI 做总结、翻译、改写或资料整理。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

Skill 合集：https://dokobot.ai/skill

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

如果安装 Dokobot 浏览器插件，它还可以复用浏览器登录态，读取一些普通方式不好抓取的网页内容。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

我比较看重它的几个场景：

- 读取网页文章，再让 AI 帮我总结和改写。
- 把网页上的文档一起抓下来，后续做资料整理。
- 辅助读取 Twitter、YouTube、微信公众号、微博、知乎、小红书、B 站等平台内容。
- 调用常见搜索引擎做检索，比如 Google、Bing、DuckDuckGo、X、百度、搜狗等。
![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

我的很多文章、论文解读时抓取原文，如果常规的 curl 指令和搜索获取不到原文时，会主动使用 dokobot 获取。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

我的 AI 资讯都是通过 dobobot 抓取后汇总得来的。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

不过，不同网站的反爬策略、登录权限、内容格式都会影响读取效果。我的用法通常是：先让它抓，抓得完整就继续用；如果抓得不完整，再换 MarkSnip 浏览器插件兜底。

---

## 5\. superpowers：更适合程序员的 Coding Skills 套件

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

第五个推荐给程序员朋友： `superpowers` 。

如果你平时主要用 Claude Code、Codex、Cursor、Qoder 这类 AI Coding 工具，单个 Skill 有时候不够。你真正需要的，可能是一整套围绕研发流程设计的协作方式。

`superpowers` 更像一个面向编码场景的 Skills 套件，覆盖头脑风暴、开发计划、执行计划、代码审查、问题排查、并行开发等环节。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

GitHub 地址：https://github.com/obra/superpowers

它比较适合这几类人：

- 经常用 AI Coding 工具写代码的程序员。
- 希望 AI 先帮你拆任务、再逐步执行的人。
- 想让 AI 不只是“补全代码”，而是参与完整研发流程的人。
- 已经开始尝试多 Agent 并行工作，但还缺少方法论的人。

不过我也建议大家理性看待。

这类 Coding Skills 会改变你和 AI 协作的节奏。刚开始用的时候，不一定马上变快，因为你需要适应“先规划、再执行、再 review”的方式。

但如果你经常处理复杂需求，这种投入是值得的。它的价值不只是让 AI 多写几行代码，而是让 AI 更稳定地参与完整研发过程。

---

## 推荐几个继续挖宝的平台

上面这 5 个，是我认为可以先装起来试试的通用 Skills。

如果你想继续自己找，可以看看下面几个平台。

### skills.sh

`skills.sh` 是我比较推荐的新手入口之一。里面有不少 Skills，查看和安装都比较方便。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

地址：https://skills.sh/

### skillsmp

`skillsmp` 更适合做搜索、分类和趋势观察。你可以看看最近有哪些 Skills 增长比较快，也可以按分类慢慢翻。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

地址：https://skillsmp.com/

### 我的公开 Skills 仓库

我自己也沉淀了一些公开 Skills，主要围绕 Skill 优化、Agent 设计、CLAUDE.md 优化、源码解读、论文解读、OpenClaw、Hermes 运维等场景。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

我的公开 Skills 仓库：https://github.com/chujianyun/skills 未来还会把更多适合公开的好用的 Skills 发布到这里。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

还有一个好消息，我的这个公开 Skills 仓库也被美团的一个龙虾聚合网站：xia345.com 收录啦！xia345 上可以看到很多龙虾产品，相关知识库和好用的 Skills 仓库等，感兴趣的朋友也可以去了解一下。

---

## 写在最后

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

最后再回到开头那个问题：到底哪些 Skills 最有用？

我的答案还是那句话：能贴合你实际场景的 Skills，才是真的有用。

AI 工具本身会一直变，模型也会一直变。今天流行的 Skill，过一阵子可能就会被新的工具替代。但你的场景、经验、资料和工作习惯，如果能被持续沉淀下来，才会真正变成自己的生产力。

先选一个真实的小场景，装一个能解决问题的 Skill，用起来。如果找不到合适的，就试着自己做一个。这样慢慢积累下来，才能真正实现“越用越好用，越用越有用”。

如果文章对你有帮助，可以给我三连击：点赞、喜欢，并转发给身边需要的朋友。

AI 工具 · 目录

继续滑动看下一个

悟鸣AI

向上滑动看下一个