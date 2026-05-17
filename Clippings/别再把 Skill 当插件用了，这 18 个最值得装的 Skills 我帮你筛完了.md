---
title: "别再把 Skill 当插件用了，这 18 个最值得装的 Skills 我帮你筛完了"
source: "https://mp.weixin.qq.com/s/doDjAosWnh55gyTfS9pDIg"
author:
  - "[[丶单向箔]]"
published:
created: 2026-05-15
description: "大家好，这里是单向箔。一个用 Claude Code 用上瘾、结果被 Skills 搞废了的人。"
tags:
  - "clippings"
---
丶单向箔 *2026年3月21日 20:09*

大家好，这里是单向箔。一个用 Claude Code 用上瘾、结果被 Skills 搞废了的人。

用了一段时间之后，我有一个越来越强烈的判断：

**不会用 Skill 的人，正在用一个被截肢了的 AI。**

无论你是 Claude、Codex 党，还是 OpenClaude 主力军，亦或是其它小众 AI 工具使用者，Skills 都是极为重要的。

毕竟像联网搜索、操作浏览器、理解视频、写入文档、管理 GitHub——这些都不是 AI 生来就有的，而是后天靠 Skills 加装进去的（就像手机出厂只有系统自带 App，功能全靠后面装）。

但市面上 Skills 太多，很多人总是在犹犹豫豫力不从心，不知道装哪个。最后结果可能是装了一堆乱七八糟没用的 Skills，而且还一个也没用起来。

所以我花了几天时间，把最热门的 Skills 过了一遍。选出了最实用的 18 个。每个都装了、测了、用了，实话实说——有的确实牛，有的只能说「还行」，有一两个我觉得可以看情况再装。

废话不多，直接上。

## 先说什么是 Skill

[Skill](https://mp.weixin.qq.com/s?__biz=Mzg4MDY0Mzg3OQ==&mid=2247483665&idx=1&sn=5f344ad50c7f459459353b7ac96ab05f&scene=21#wechat_redirect) 就是给 AI 装的「外挂」（正式说法是「扩展能力包」，但说外挂更直观）。

本质上是一个放了 `SKILL.md` 文件的文件夹，里面写着指令或脚本。AI 读到它，就能多干一件事。

安装也简单，一行命令搞定：

```
npx skills add <skill 地址>
```

ClawHub 上的 Skill 可以直接下载 zip，GitHub 上的用上面的命令拉。当然你也可以使用我之前推荐过的 [CC Switch](https://mp.weixin.qq.com/s?__biz=Mzg4MDY0Mzg3OQ==&mid=2247483680&idx=1&sn=b11b26f8cc653f4ec2d087109f4127a3&scene=21#wechat_redirect) ，安装更加方便。

装完就静待在工作区里，需要的时候自动被用上（不需要你手动喊它，挺聪明的）。

## 搜索增强

![[_resources/别再把 Skill 当插件用了，这 18 个最值得装的 Skills 我帮你筛完了/4c7f4d219d25a38df48b4015a8d7b0ae_MD5.webp]]

**Multi Search Engine** ⭐️⭐️⭐️⭐️⭐️

> 推荐指数：必装 · 适合所有人 · 零门槛

这是搜索类 Skills 里集成度最高的一个，一次塞进了 17 个引擎：国内 8 个（百度、必应、搜狗、360、微信文章、头条、集思录……），国际 9 个（Google、DuckDuckGo、Brave、WolframAlpha……）。

支持高级搜索语法、时间过滤、站内搜索、隐私引擎切换，甚至还有 WolframAlpha 知识查询。不需要任何 API Key，装上就能用（终于不用配一堆环境变量了）。

有个细节我特别喜欢：它同时保留了国内和国际入口，可以让 AI 根据问题类型自动选引擎。查技术文档用 Google，查微信生态用搜狗，查金融数据用集思录。一个 Skill 顶多套工具。

AI 不联网，就是个复读机。这是整个 Skills 知识库里优先级最高的一个，没有之一。

👉 clawhub.ai/gpyAngyoujun/multi-search-engine

---

**Summarize** ⭐️⭐️⭐️⭐️

> 推荐指数：高频必备 · 适合内容消费者、研究者 · 需要配置 API Key

丢进去一个 URL、PDF、图片、音频或者 YouTube 链接，几秒出总结（就像把一本书喂给 AI，它帮你提炼读书笔记）。

支持 OpenAI / Anthropic / Google 多家模型，可以指定总结长度（short 到 xxl，想要多详细就要多详细），还能输出 JSON 方便自动化。遇到被屏蔽的网页，有 Firecrawl 兜底。

以前我看一篇英文研究报告要花半小时，现在 AI 3 分钟给我提炼一遍，我再决定值不值得继续深读。效率直接翻倍（而且不用再假装自己看完了）。

需要配 API Key，这是它唯一的门槛。

👉 clawhub.ai/steipete/summarize

---

**Agent Browser** ⭐️⭐️⭐️⭐️

> 推荐指数：自动化利器 · 适合开发者、数据采集需求者 · 上手需要一点时间

这个 Skill 有点不一样，它不是知识库，是工具（就像给 Claude 装了个机械臂）。

基于 Rust 构建的无头浏览器 CLI，专为 AI Agent 设计。装上之后，AI 可以真的「动手」操作浏览器——导航、点击、输入、截图、录制视频、处理表单、保存登录状态……结果结构化，AI 能直接解析。

我测了一下，让 AI 登录三个不同平台把数据收集回来，基本都跑通了（遇到验证码会卡住，AI 再聪明也过不了「你是人类吗」这关）。

普通 Skill 让 AI「知道」网上有什么，Agent Browser 让 AI「动手去拿」。如果你有重复性的网页操作需求，这个 Skill 能帮你把它变成全自动工作流（上手成本比其他 Skill 略高，但值）。

👉 clawhub.ai/TheSethRose/agent-browser

## AI 能力增强

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**Self-Improving + Proactive Agent** ⭐️⭐️⭐️⭐️⭐️

> 推荐指数：长期价值极高 · 适合重度 AI 用户 · 效果随使用时间递增

这个 Skill 的核心设计是一套分层记忆系统，放在 `~/self-improving/` 目录下：

- `memory.md` ：热记忆，每次启动都加载（不超过 100 行，精简）
- `corrections.md` ：最近 50 次纠错历史
- `projects/` 和 `domains/` ：按项目和领域分类学习内容

运行逻辑是这样的：你每次纠正 AI，说「不对，应该是这样」，它就把这条记下来。同一个经验触发 3 次，自动升级为核心记忆，永久生效（就像刷题刷到肌肉记忆）。

大多数人用 AI 是在「消耗它」。这个 Skill 让你和 AI 的每次对话都变成一次投资，用得越久，它就越懂你，错得越少。

用一周可能感受不深。用三个月，你会发现它越来越像一个专门给你调训过的助理，而不是那个所有人都共用的通用 Claude。

唯一的前提：你得愿意在出问题时主动纠正它，而不是沉默地将就（将就的代价是它永远学不会）。

👉 clawhub.ai/ivangdavila/self-improving

---

**humanizer-zh** ⭐️⭐️⭐️⭐️

> 推荐指数：内容写作必备 · 适合用 AI 写中文内容的人 · 效果当场可见

用 AI 写过中文内容的人应该都懂那种感觉：内容没问题，但就是读起来「很 AI」——「总的来说」「值得注意的是」「不仅如此，而且」……一股子机械腔（就像在跟一个刚学会普通话的外星人对话）。

这个 Skill 专门针对中文，能识别并修复 24 种 AI 写作特征：

- 夸张的意义感（动不动就「划时代」「颠覆性」）
- 过度使用破折号和三段式结构
- 否定式排比、模糊归因、谄媚语气
- 表情符号滥用、弯引号、内联标题垂直列表……

它有一套基于维基百科「AI 写作特征」的分析框架，不是模糊地「改得自然一点」，而是逐条对照 24 条规则有依据地改（比你的语文老师还严格）。

如果你平时用 AI 起稿、再人工润色，装了这个之后润色成本能直接砍一半。

👉 clawhub.ai/liuxy951129-cpu/humanizer-zh

## 开发工具

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**taste-skill** ⭐️⭐️⭐️⭐️⭐️（个人推荐）

> 推荐指数：前端颜值救星 · 适合所有做前端的人 · 这篇文章里效果最立竿见影的一个

有没有遇到过这种情况：让 AI 做一个页面，出来的东西功能没问题，但看着很难受——配色像 PPT 模板，布局像 Excel 表格，交互全是白底黑字蓝链接（一股 2009 年的气息）。

taste-skill 的目标只有一个： **让 AI 生成的前端界面不再是「千篇一律的垃圾」。**

它有三个可调参数，像游戏里的难度调节器（1-10 分）：

- `DESIGN_VARIANCE` ——布局实验性（1-3: 简洁居中 / 8-10: 非对称现代）
- `MOTION_INTENSITY` ——动效强度（1-3: 简单悬停 / 8-10: 磁性 + 滚动触发）
- `VISUAL_DENSITY` ——视觉密度（1-3: 宽松奢华 / 8-10: 信息密集仪表板）

这个设计很聪明。同一个 Skill，做博客主页把 `DESIGN_VARIANCE` 调到 3，做 SaaS 仪表板把 `VISUAL_DENSITY` 调到 8，出来的风格完全不同（终于不用每次都手动给 AI 描述「我想要现代感的设计」了）。

支持 Claude Code、Cursor、Antigravity、Windsurf、Copilot……装一次全平台用：

```
npx skills add https://github.com/Leonxlnx/taste-skill
```

觉得 AI 生成的页面太丑？就装这个，别犹豫。

👉 github.com/Leonxlnx/taste-skill

---

**Frontend Design** ⭐️⭐️⭐️⭐️

> 推荐指数：前端开发者必备 · @steipete 出品 · 和 taste-skill 一起装效果更佳

steipete 出品的前端设计规范 Skill（这个作者在 ClawHub 上出了好几个好用的 Skill，基本都值得装）。

它不帮你生成代码，而是让 AI 在生成前端代码时内化一套设计原则——排版对齐、间距逻辑、组件一致性、响应式优先。

很多时候 AI 写的前端功能完全没问题，但视觉乱。根源不是模型能力不够，是它没有被约束在一套设计语言里（就像让一个厨艺不错的人在没有任何食谱约束的情况下做菜，出来的东西能吃，但味道飘）。

装了 Frontend Design 再配合 taste-skill，等于同时给 AI 配了「开发工程师 + 设计师」的双重约束，出来的代码会明显不一样。

👉 clawhub.ai/steipete/frontend-design

---

**UI/UX Pro Max** ⭐️⭐️⭐️⭐️

> 推荐指数：产品设计利器 · 适合做产品和前端的人 · 内置资源丰富

这个 Skill 名字起得很唬人，功能倒也配得上（不是那种光有名字没实质的）。

覆盖从需求理解到代码落地的完整 UI/UX 流程：先确认技术栈（React/Vue/Next.js/Tailwind），再产出 UI 概念和用户流程，然后给出设计系统 Token，最后直接落回代码改动。全程不用你在中间反复翻译意图。

内置设计数据库（配色方案、UI 启发式规则），还捆了一个 `design_system.py` 脚本，可以直接生成 Token 文件。

最让我觉得值的地方是：它覆盖了空态、加载态、错误态、键盘导航、焦点状态这些细节（这些地方是绝大多数 AI 工具的盲区，出来的页面往往「没有异常就没有任何提示」，这是很差的体验）。

做需要认真打磨 UI 的项目，这个 Skill 值得装。

👉 clawhub.ai/xobi667/ui-ux-pro-max

## 外部工具联动

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

这类 Skill 干的事只有一件：打破 AI 和你日常工具之间的那堵墙，让它能直接进去操作。这堵墙一旦打穿，AI 就不只是个聊天窗口了。

这里只介绍了部分人会用到的，更多的还是需要根据你们自己的需求装。

**GitHub** ⭐️⭐️⭐️⭐️⭐️

> 推荐指数：开发者必装 · 用 GitHub 就要装 · 零额外配置

用 `gh` CLI 让 AI 直接操作 GitHub——查 PR、看 CI 跑了几条、看哪个 Step 挂了、用 API 拿到你想要的数据、翻 issue 列表……全在对话窗口里完成，不用切浏览器。

以前我让 AI 帮我看代码，看完了它也没法告诉我「这个 PR 的 CI 跑通没有」，因为它根本进不去。装了这个之后，你可以直接说「帮我看一下 PR #55 为什么 CI 失败了」，它自己去拉日志、定位问题（终于不用自己盯着 Actions 页面刷新了）。

👉 clawhub.ai/steipete/github

---

**Nano Banana Pro** ⭐️⭐️⭐️⭐️

> 推荐指数：图片生成刚需 · 适合需要在对话中生成配图的人 · 依赖 Gemini API

名字离谱，功能实在（名字是谁起的我不知道，但用起来挺好用的）。

基于 Gemini 3 Pro 的图片生成和编辑 Skill，支持文字生图、图片修改、1K/2K/4K 分辨率。内置「起草 → 迭代 → 最终稿」三步工作流，第一张不满意就继续改，而不是将就用（这个工作流设计挺重要的，很多人用 AI 生图都是一次性的，导致效果不稳定）。

解决了一个真实问题：在对话里直接生成配图，而不是另开 Midjourney / Firefly 再切回来。做文案、做演示、做产品说明，图文一起在一个对话里完成。

需要 Gemini API Key，离线场景不适用。

👉 clawhub.ai/steipete/nano-banana-pro

---

**Openai Whisper** ⭐️⭐️⭐️⭐️

> 推荐指数：语音转文字刚需 · 隐私友好 · 本地运行零费用

本地语音转文字，不需要 API Key，不联网，所有处理在你自己的机器上完成（你的会议录音不会上传到任何地方，这件事很重要）。

丢进去录音文件，出来 txt 或 srt 字幕，支持翻译模式（把录音直接翻成另一种语言输出）。

它的核心优势不是「快」，是「在本地」。

会议录音、采访录音、个人语音备忘——如果你对这类内容上云有顾虑，Whisper 是唯一真正合理的选择。模型越大准确率越高，速度越慢，按需权衡就好。

👉 clawhub.ai/steipete/openai-whisper

---

**Obsidian** ⭐️⭐️⭐️⭐️⭐️

> 推荐指数：Obsidian 用户必装 · 让 AI 真正进入你的知识库 · 依赖 obsidian-cli

如果你用 Obsidian，这个 Skill 是必装的（不用思考，直接装）。

它让 AI 可以直接操作你的 vault：搜索笔记全文、创建新笔记、移动和重命名、删除。所有操作通过 `obsidian-cli` 完成，Obsidian 实时同步变化。

有个细节值得单独说： **移动和重命名会自动更新所有双链** 。

用过 Obsidian 的人都体验过这种痛苦：改一个笔记名字，然后手动去找所有引用了它的地方、一条一条修复。这个 Skill 把这件事变成了一步操作（就像 IDE 里的重命名，引用全部一起改了）。

装上之后，AI 就从「外部工具」变成了「和你共享知识库的搭档」——你说「帮我在 Obsidian 里搜一下上周关于 XX 的那篇笔记」，它直接找到给你。

👉 clawhub.ai/steipete/obsidian

---

**Video Frames** ⭐️⭐️⭐️

> 推荐指数：专项工具 · 有视频分析需求时才装 · 其他人先不用管

基于 ffmpeg 的视频帧提取 Skill，让 AI 可以从视频里截取指定时间点的帧：

```
frame.sh video.mp4 --time 00:01:30 --out /tmp/frame.jpg
```

用途比较垂直：视频质检（抽帧看内容对不对）、生成缩略图、视觉调试（某个时间点画面到底什么情况）。

如果你平时不处理视频，这个先不用装（占着也没用）。如果你的工作流里有视频相关步骤，它能帮你省掉手动截图这件事。

👉 clawhub.ai/steipete/video-frames

---

**Nano Pdf** ⭐️⭐️⭐️⭐️

> 推荐指数：PDF 刚需小工具 · 适合频繁需要改 PDF 的场景 · 自然语言操作

用自然语言指令编辑 PDF，一行命令搞定：

```
nano-pdf edit deck.pdf 1 "将标题改为"第三季度业绩"并修正拼写错误"
```

不开 Acrobat，不找在线 PDF 编辑器，不「转 Word 改完再转回来」（这套流程做过的人应该深有体会，麻烦程度堪比拆房装修）。

对频繁需要小改 PDF 的人来说（改合同、改演示稿、批量修改页眉页脚），这个 Skill 的实际价值远超它看起来的体积。

👉 clawhub.ai/steipete/nano-pdf

## 管理你的 Skills

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

最后这四个，是「管理 Skills 的 Skills」（有点套娃，但不装，你的 Skills 就是一堆没人关心的孤儿文件）。

**Skill Vetter** ⭐️⭐️⭐️⭐️⭐️

> 推荐指数：安全底线 · 所有人装 Skill 前都应该先装这个 · 无依赖

装任何 Skill 之前，先用这个过一遍安全审查。

它会检查来源可信度、代码里有没有可疑模式（有没有不必要的网络请求？有没有读了不该读的本地文件？），然后给出 TRUST / CAUTION / REJECT 三级评级。

有必要提一下：Skills 本质上是你允许 AI 执行的代码片段。ClawHub 是开放平台，任何人都可以上传（就像应用商店，里面不全是好东西）。你需要一道过滤机制。

先装 Skill Vetter，再装其他一切。这不是偏执，是好习惯（就像装软件之前先看评论区有没有人报木马）。

👉 clawhub.ai/spclaudehome/skill-vetter

---

> 推荐指数：发现工具 · 入门选手友好 · 解决「不知道装什么」的困境

不知道有没有能做 XX 的 Skill？直接告诉 AI「帮我找一下有没有能做 XX 的 Skill」，它会去搜 ClawHub、筛选匹配选项、提供对比说明，还能直接帮你装。

Skills 生态更新很快，靠手动逛 ClawHub 跟进太低效（而且太伤眼睛，那个列表真的很长）。有了 Find Skills，你只需要描述需求，剩下的让 AI 找。

不过它依赖 ClawHub 的索引，偶尔会漏掉一些冷门但好用的 Skill（已知缺陷，不影响日常使用）。

👉 clawhub.ai/JimLiuxinghai/find-skills

---

**Skill Creator** ⭐️⭐️⭐️⭐️

> 推荐指数：进阶必备 · 想自己做 Skill 的人 · 流程清晰，不用摸黑

想自己写一个 Skill？

这个 Skill 手把手带你过六步：理解需求 → 用具体例子验证 → 规划结构 → 初始化文件 → 逐步完善 → 打包分享。核心原则：每个 Skill 只解决一件事，保持 SKILL.md 简洁、指令精确。

为什么值得学着自己写？

因为你的工作流里一定有那些「AI 做不好，但只需要一段正确指令就能做好」的任务（就像你总在重复说「帮我用某某风格」「不要用这种排版」——把这些话写进 Skill，以后就不用再说了）。那段话，就是你的私有 Skill。

👉 clawhub.ai/chindden/skill-creator

---

**Auto-Updater Skill** ⭐️⭐️⭐️⭐️

> 推荐指数：运维省心利器 · 装了 5 个以上 Skill 就需要它 · 配好之后不用再管

每天自动检查 Clawdbot 和所有已安装 Skills 有没有更新，有就应用，完成后发一条变更摘要。配好 cron，之后就完全不用管了。

Skills 生态迭代很快。你今天装的版本，下个月可能已经更新了几个重要特性。手动跟进更新是件很费神的事（总会忘）。这个 Skill 就是帮你解决这件事的——它在后台跑，你只看每天的一句总结。

👉 clawhub.ai/maximeprades/auto-updater

## 写在最后

整理完这些 Skills，我有一个感受：

Skill 生态正在成为 AI 编程工具的「护城河」。不是谁的模型更聪明，是谁的扩展能力更丰富、更会用。会用 Skills 的人，已经在悄悄拉开差距了（这件事没什么好说的，就是在发生）。

如果你刚开始，从这四个装起：

- **Skill Vetter** ：装任何 Skill 之前先扫一遍，安全第一
- **Multi Search Engine** ：联网搜索是基础，别让你的 AI 只会在本地跑
- **Self-Improving** ：长期投资，越用越懂你
- **taste-skill** ：做前端的，装了立刻有感

实践是检验真理的唯一标准，别光看，亲自动手去装一两个试试，用过才知道好不好使（就像买衣服，不穿怎么知道合不合适）。

> 感谢读到文末。
> 
> 觉得内容有用，欢迎点赞、在看、转发三连支持。
> 
> 点击星标⭐，即可第一时间锁定后续更新。
> 
> 我们下次再见。

**微信扫一扫赞赏作者**

工具分享 · 目录

继续滑动看下一个

单向箔

向上滑动看下一个