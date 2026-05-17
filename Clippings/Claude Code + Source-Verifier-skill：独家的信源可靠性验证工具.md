---
title: "Claude Code + Source-Verifier-skill：独家的信源可靠性验证工具"
source: "https://mp.weixin.qq.com/s/UWt_xQlAdso_sIcaIh8Y_Q"
author:
  - "[[Lex 陆徐洲]]"
published:
created: 2026-05-15
description: "信息的质量比数量更重要。"
tags:
  - "clippings"
---
Lex 陆徐洲 *2026年3月30日 23:14*

之前我写了一篇文章，主题是分享Auto Research如何优化skill的，顺手造了一个平时比较用的到的skill。

最近有不少读者问我，之前提到的那个信源可靠性研判工具能不能分享出来。

![[_resources/Claude Code + Source-Verifier-skill：独家的信源可靠性验证工具/b23893b7bb0c0f6510fe02cdb860bfba_MD5.webp]]

说实话有点受宠若惊。熟悉我的粉丝都知道我向来是有求必应的，今天这篇就把它开源了，文末有安装方式。

不过在讲这个工具之前，我想先聊聊一个更前置的问题： **信息从哪来** 。信源验证的前提是你得先有信息可验。昨天刷 X 的时候，我看到一个叫 last30days 的 Claude Code Skill 正在刷屏，66 天攒了 16K Stars，作者是 Lyft 联合创始人 Matt Van Horn。

大家好，我是陆徐洲。今天这篇是一次完整的实践记录：用 last30days 采集热点信息，再用信源验证工具判断这些信息该信几分。

先简单介绍一下 last30days 在做什么。

它跟普通搜索最大的区别不是"搜得更多"，而是"搜的东西不一样"。Google 搜出来的是媒体文章和官方内容，last30days 搜的是社区真实讨论：Reddit 里的吐槽、X 上的争论、HN 的技术辩论，甚至 Polymarket 上人们拿真金白银在赌什么。

它还有一套三维评分体系。每条结果的最终得分 = 相关度 45% + 时效性 25% + 热度 30%。不同平台的热度指标不一样，Reddit 看 upvotes 和评论数，X 看 likes 和转发，Polymarket 看交易量和流动性。普通网页搜索结果因为没有热度数据，会被扣 15 分惩罚。

设计思路确实不错。关键是实际跑起来怎么样。

安装很简单， `git clone` 到 `~/.claude/skills/last30days` 就行，零配置下有三个免费数据源：Reddit、HN、Polymarket。但我的环境是 Windows 11，这里有个提醒：last30days 是 macOS 优先开发的项目，Windows 上会碰到 `python3` 路径问题和超时机制不兼容，需要手动改几处配置。macOS 用户可以跳过这段，Windows 用户建议用 WSL 跑，能省不少事。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

修完兼容性问题后，我先拿"AI coding assistants"这个话题试了一下，覆盖率只有 60%。脚本只跑通了 HN 和部分 Reddit，X、YouTube 全挂了，最后靠 Claude 自己的 WebSearch 补位。说白了，这个结果跟直接让 Claude 搜差别不大。

后来我换了个思路。既然 HN 和 Reddit 天然适合技术对比类话题，那就拿"Claude Code vs Cursor"来试。

效果立刻不一样了。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

这次脚本成功拉到了 22 条 Reddit 讨论、189 条 X 推文、69 条 HN 帖子，覆盖率接近 80%。报告里的社区情绪分析、优劣势对比、Top voices 排名，确实是普通搜索给不出的东西。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

简单总结一下： **话题选对，数据源才能喂饱** 。拿这些英文社区平台去搜泛泛的概念，数据会很稀疏。但如果是具体的工具对比、技术争议、行业事件这类话题，last30days 拿到的社区讨论数据确实比普通搜索有信息增量。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

说回信源验证。

last30days 帮你把信息聚合起来了，但聚合不等于可信。它的报告里有一条说"Claude Code 在 36 项独立测试中赢了 67%"，还有"Claude Code 完成相同任务的 token 比 Cursor 少 5.5 倍"。这些数据准不准？引用源在哪？有没有被断章取义？

这就是信源可靠性研判引擎要解决的问题。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

我在 Claude Code 里直接输入 `/source-verifier` ，选择对 last30days 的报告做全面深度研判。工具会自动提取报告中的可验证声明，按 NATO Admiralty Code 的双维度评估体系逐条验证。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

举个例子。"Claude Code 完成相同任务的 token 比 Cursor 少 5.5 倍"这条声明，验证结果是 D-4（存疑）。原始数据来源是 Ian Nuttall 的一条 X 帖子，只有 1 个独立信源，而且测试场景是特定的 Next.js 项目，模型配置也不同。这个数据点被广泛引用后就变成了"Claude Code 效率碾压 Cursor"，但本质上只是一次实验的观察。

这就是信源验证的价值。不是告诉你"这条信息是对是错"，而是告诉你"这条信息你该信几分，为什么"。

最后说下结论。

last30days 和 source-verifier 组合起来，解决的是信息处理链路上的两个关键环节： **从哪获取信息** + **信息该信几分** 。前者帮你跳出算法推荐的信息茧房，后者帮你在信息洪流里保持判断力。

last30days 的安装（推荐 macOS/Linux 用户）：

```bash
git clone https://github.com/mvanhorn/last30days-skill.git ~/.claude/skills/last30days
```

信源可靠性研判引擎的安装：

```css
claude plugin marketplace add Luxuzhou/source-verifier-skillclaude plugin install source-verifier
```

这是 Claude Code 原生的插件安装方式，后续 `claude plugin update source-verifier` 一键更新。Gemini CLI 用户可以用 `gemini extensions install` ，习惯 git clone 的也可以直接 clone 到 skills 目录。纯文本 Skill，不依赖任何二进制，macOS、Windows、Linux 都能跑。

装好后输入 `/source-verifier` 就能用，不需要额外的 API key。Skill 内部的检索工具链也可以自行扩充，比如加上 Tavily、Brave Search 等 MCP 服务来增强搜索覆盖。

刚发布的版本，可能还有一些边界情况没覆盖到，使用中碰到问题欢迎在评论区留言或在GitHub 提 issue 反馈。觉得好用的话，也麻烦帮忙点个 star，这对独立开发者真的很重要。

GitHub 地址：https://github.com/Luxuzhou/source-verifier-skill <sup>[1]</sup>

我是陆徐洲，一家 LIMS 公司的 AI 算法负责人。关注我，让我们一起在 AI 落地实践的路上，走得更远。

感谢您阅读我的文章。有任何关于AI提效或者工程落地实践方面的问题都可以加我微信，交个朋友，一起探讨，共同进步。

### References

`[1]`: *https://github.com/Luxuzhou/source-verifier-skill*

AI赋能千行百业 · 目录

作者提示: 个人观点，仅供参考

继续滑动看下一个

硅基鹿鸣

向上滑动看下一个