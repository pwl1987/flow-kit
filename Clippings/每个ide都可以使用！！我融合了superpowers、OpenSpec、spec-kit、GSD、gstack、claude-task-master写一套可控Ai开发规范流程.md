---
title: "每个ide都可以使用！！我融合了superpowers、OpenSpec、spec-kit、GSD、gstack、claude-task-master写一套可控Ai开发规范流程"
source: "https://mp.weixin.qq.com/s/6NSD1WoKRXTHR0exWBKXtg"
author:
  - "[[rihebty]]"
published:
created: 2026-05-15
description: "先说结论：这东西不是我拍脑袋造的，还有这玩意耗token！！你可以自己改成自己喜欢的流程，因为全是md！"
tags:
  - "clippings"
---
rihebty *2026年5月3日 16:19*

### 先说结论：这东西不是我拍脑袋造的，还有这玩意耗token！！你可以自己改成自己喜欢的流程，因为全是md！内容不难！！相信你自己，我的朋友！！！！

### 那些只会在评论区装的人就不要看了，谢谢

我是用 AI 编程两年多的老用户，各家 IDE / CLI 来回切着用。踩过的坑够我写一本小册子。后来我把市面上几个主流做法混在一起，再加上自己踩坑补的缺口，做成了一套 Markdown 工具包，叫 **flow-kit** 。

这篇聊一聊它怎么来、怎么用、花多少 token、到底值不值。

![[_resources/每个ide都可以使用！！我融合了superpowers、OpenSpec、spec-kit、GSD、gstack、claude-task-master写一套可控Ai开发规范流程/f0a03096de72515d8e4387f095640452_MD5.webp]]

---

## 这东西不是我凭空造的

做之前我把市面上比较硬核的 AI 编程工作流项目都扒了一遍，挑了 7 个重点读。每个项目我都真的跑过的。

下面这 7 个是主要营养来源，每个我只说我学了它什么具体机制、在 flow-kit 里落到了哪。

### spec-kit（GitHub 出的）

规范驱动开发的骨架来自它。 `/speckit.specify` → `/speckit.plan` → `/speckit.tasks` → `/speckit.implement` → `/speckit.analyze` → `/speckit.clarify` 这一串 slash command 的分工非常清楚。

我 flow-kit 的 8 阶段基本是这个骨架的扩展。另外它的 `[P]` 并行任务标记、constitution 作为系统约束这两个细节我也直接搬了。

### OpenSpec

这是我最推崇的一个项目。它把\*\*"CHANGE"\*\*这个概念做成了一等公民——每次变更一个独立目录， `/opsx:propose` 起草 → `/opsx:apply` 实现 → `/opsx:archive` 归档进主 spec。这套三段式 change 流我整个套了过来。

还有它的 `context hygiene` 概念（阶段间清窗、工件驱动）、brownfield 和 greenfield 区分对待，都直接影响了我的设计。我的 `0-change.md` 和 `7-integration.md` 基本是从 `/opsx:propose` 和 `/opsx:archive` 改写来的。

### get-shit-done（GSD）

执行阶段的细节来自它。XML 任务模板 就是它的风格——我看第一眼就知道这比 markdown 列表靠谱多了，AI 解析 XML 比 markdown 稳。

它的另外两个点我也学了：每任务一个 fresh subagent（彻底清窗跑任务）、plan-checker 循环（AI 自检没通过就继续改直到通过）。

### claude-task-master

任务拆解的细节来自它。 `parse_prd` → `expand_task` 两步式 MCP 工具链，每个任务必须有可执行 verify 的硬约束，这套直接搬。

它还有个我特别喜欢的做法： **工具分层加载** （ `TASK_MASTER_TOOLS` 切 `core` 7 件 / `standard` 14 件 / `all` 44+ 件）。不是所有工具一股脑塞进系统 prompt，而是按需加载。我的 `M-health.md` / `I-intel-scan.md` 作为"横向命令"就是受它启发——不属于任何阶段，按需 @ 进来。

### gstack

审查 + 发布这一段从它学的。它的 `/autoplan` 有三连审（CEO / Design / Eng 三个角色接力审）， `/codex` 做跨模型二意见（主模型跑完让另一个模型 spot-check）。

我的 `6-review.md` 三轮审查（意图合规 / 设计合规 / 代码质量）+ 跨模型 spot-check 就是这个路子。另外它的 `/review` + `/qa` + `/ship` + `/land-and-deploy` 整条 ship 链我简化成了 `7-integration.md` 。

### superpowers

这个项目最有价值的是一组 **元技能** （meta-skill），每个 skill 就是一组 prompt 最佳实践。skills 目录下全是干货： `brainstorming` / `writing-plans` / `subagent-driven-development` / `requesting-code-review` / `test-driven-development` / `systematic-debugging` / `dispatching-parallel-agents` / `verification-before-completion` / `executing-plans` 等等。每一个拆开都够写一篇文章。

我从它借了三件事： **2-5 分钟原子任务** 的定义（我放宽到 5-15 分钟更现实）、subagent-driven-development 的执行原则、code review 要分层请求（ `requesting-code-review` skill 的核心观点：不是一次性要求全查一遍）。

### skills（anthropic 社区的 skills 集）

这个贡献了很多细节：

- **SKILL.md 渐进披露**
	—— 我的 prompt 写作风格学了这个
- **`grill-me` + `grill-with-docs`**
	—— 反问式需求澄清（前者抓意图，后者把既有文档当来源抓域语言），我的 `1-requirement.md` 里那套"停下来问"的节奏直接来自它
- **`tdd`**
	—— 红 / 绿 / 重构，我 4-dev 的 TDD 小节几乎是它的改编
- **`diagnose`**
	—— 错误诊断独立子代理，防止主上下文被堆栈污染
- **`caveman` 压缩模式**
	—— 执行阶段输出极简化，我的 SUMMARY.md 模板就是这个风格

### 外加几个外部工具生态（配套 skill 包）

这几个严格说不是 flow-kit 的"方法论来源"，而是 flow-kit 会 **显式调用** 的外部工具，装了就走外部、没装就走内置回退：

- **impeccable**
	—— 前端 / CSS 细节 lint，我 UI 任务会优先调 `npx impeccable detect` 它再做二次判断
- **brooks-lint**
	—— 代码质量 lint，命名来自 Fred Brooks。我的 4-dev 步骤 4 self-review 优先调它
- **ui-ux-pro-max-skill**
	—— UI 质量审，我的 `2a-ui-design.md` 会把它作为外部视觉审专家
- **frontend-design**
	—— 前端设计规范，给前端 change 加视觉评估基线

这几个工具的作者都比我懂得多，我没重复造轮子，而是做了\*\*"检测到就外接、没检测到就内置最小回退"\*\*的设计。

---

这些东西单拿出来都不稀奇。每个项目都很优秀，作者们也都在持续迭代。

但你真用 AI 写老项目会发现—— **每一套单独都不够** 。spec-kit 的阶段骨架有了但没有老项目护栏，OpenSpec 的 change 概念有了但拆任务不够细，GSD 的任务模板有了但没有破坏性变更门槛，task-master 的拆解有了但缺设计阶段，gstack 的审查链有了但门槛对个人项目太重……

所以我做的事情很朴素： **挑每家最好的部分拼起来，按阶段串成一条链，再在几个高频事故点加"护栏"** 。就成了 flow-kit。

说不上原创。顶多算"搬运 + 整合 + 补缺"。

---

## 从零做一个新项目，它长什么样

假设你周末想做一个工具小站。打开 Cursor / Claude Code / 通义灵码 / 随便哪个 IDE，对话里打：

```
@flow-kit/GO.md
我想做一个可以把 markdown 转成海报的小工具
```

**它会带你走 8 步** ：

1. **0-change**
	—— 自动生成一个 change-id（比如 `md-to-poster` ），给你这次需求建个档案目录 `.specs/md-to-poster/`
2. **1-requirement**
	—— 反问你几个关键问题（谁用 / 核心场景 / 验收标准 / 非功能要求），产出一份 `REQUIREMENT.md` ，里面是可打勾的验收标准
3. **2-design**
	—— 先给你 5 张技术栈卡片（Next.js 全栈 / Vite + Express / Astro /...）让你选一个，选完再出 `DESIGN.md` + 必要的 ADR（架构决策记录）
4. **2a-ui-design**
	—— 如果是前端项目，加这一步。先出视觉设计（调性 / 主色 / 字体 / 圆角规范），再写代码
5. **3-task**
	—— 把设计拆成 5-15 分钟能搞完的原子任务，标好哪些能并行，生成 `TASK.md`
6. **4-dev**
	—— **每个任务一个 fresh context 去跑** ，TDD 开头，verify 结尾，跑完写 `SUMMARY.md`
7. **5-test**
	—— 多轮测试（单元 / 集成 / 边界 / 迁移）
8. **6-review → 7-integration**
	—— 三轮 code review + 归档 + 把教训沉淀到 `LESSONS.md`

听起来很长。实际上你作为用户只需要在 3 个地方介入：

- **第 1 步**
	回答几个业务问题
- **第 3 步**
	选技术栈（也可以直接让 AI 推荐，说"你看着办"）
- **第 6 步**
	review 的时候看一下

其余时间它自己跑，你该干嘛干嘛。

---

## 给老项目加个功能，它长什么样

这个场景才是我自己每天用的。分两种情况。

### 第一次在这个老项目用 flow-kit

```
@flow-kit/GO.md
帮我加一个通知中心
```

它会先停下来：

```
🔍 检测到本项目已有以下 AI 上下文文档：
  - AGENTS.md（仓库根，4.2K）
  - .cursor/rules/architecture.md（2.8K）

请选择：
  1. 综合现有文档 + 代码扫描，生成 CONTEXT.md（推荐）
  2. 以现有文档为准，跳过扫描
  3. 跳过 + 不读现有文档（不推荐）
```

选 1 会额外花 15-50k tokens 做一次 **入场扫描** ，把你项目的技术栈、命名风格、既有抽象（HTTP 客户端 / 状态管理 / utils / hooks）、禁动清单全扒一遍，写进 `CONTEXT.md` 。

之后所有 change 都读它。这一步是 **一次性投资** 。

扫完继续正常的 8 步流程。但此时有 6 条专门给老项目的护栏会激活：

- **B1 入场扫描**
	—— 就是刚才说的这一步
- **B2 架构对齐**
	—— 设计阶段强制列清"本次会碰哪些既有模块 / 沿用哪些既有抽象 / 引入哪些新模式"
- **B3 边界约束**
	—— 每个任务声明 `read_files` （允许看）+ `write_files` （允许改）。提交前自动 `git diff` 对比，越界强制回滚
- **B4 破坏性变更门槛**
	—— 删代码 ≥ 5 行 / 改公共接口，必须先 grep 整库引用图，贴给我看，等我确认才动
- **B5 沿用抽象 grep**
	—— 写新代码前，每个能力都要先 grep 一遍项目里有没有，找到就用，找不到才另起
- **B6 视觉语汇对齐**
	（前端 change 才触发）—— 加新页面 / 新组件前先 grep 既有的 token / hover 样式 / 缓动曲线 / elevation / 图标库 / 文案调性，写观察报告给我校准。让新加的 UI 和原有 UI 视觉上无法区分。详见后面 UI 那一节

### 之后再加功能

```
@flow-kit/GO.md
再加一个用户档案页
```

直接读 CONTEXT.md 进 0-change。不再打扰你。

---

## UI 那步我最近重做了一遍

这一节单拎出来说，因为是这周刚改完的。

之前 `2a-ui-design` 这一步质量不稳定。AI 心情好的时候出的视觉很惊艳，心情不好的时候——紫粉渐变 + Inter 字体 + 一堆 emoji 当图标，标准 AI-slop 三件套。我一直没找到办法治。

这周在某音上看到了“code秘密花园”大佬的 garden-skills 里那个 `web-design-engineer` skill，是从 Claude Design 团队的系统提示词提炼出来的。读完发现它治的就是我那块短板。我把里面 4 个最有用的方法论搬进了 flow-kit。

### 改进 1 · v0 草稿先确认（最值钱的一条）

以前是 AI 一口气写完整版 UI-DESIGN.md（带 frontmatter、5 维决策、组件规约、anti-pattern 自检——大几百行），写完给我审。我读 5 分钟发现方向偏了，回炉。

现在多了一步：写完整版 **之前** ，先给我看一份 30 秒能扫完的 v0：

```
📌 v0 草稿（看下对不对，对就 go，不对就指哪个维度偏了）：
- 调性：温暖纸面编辑式
- 主色：oklch(0.55 0.18 25) 磁红
- 字体：display = Fraunces Italic / body = Source Serif
- 缩略布局（hero）：[ASCII 框线]

我正在假设的东西：
- 假设 hero 有背景图（用 16:9 占位符）
- 假设本项目不要 secondary button
- 假设默认不开 dark mode

继续还是调整？
```

方向错了此时换代价最低。我反馈"全推了重来"或"字体偏了"，AI 就只改对应维度，其他保留。

### 改进 2 · 老项目加 UI 必走"视觉语汇对齐"

这个是给老项目用的。老项目护栏之前我写了 B1-B5，全是架构和代码层面的——但 **视觉层面** 完全没护栏。结果就是老项目加新页面，AI 经常画出和原 UI 完全不搭的东西。

现在加了 B6：老项目加 UI 必须先做视觉观察。AI 会去 grep 既有的 token / hover 样式 / 缓动曲线 / elevation 层级 / 图标库 / 文案调性，写一份观察报告给我校准：

```
🔍 视觉语汇观察（你看看对不对）：
- 主色：--color-accent oklch(0.65 0.18 230)，实际只在 primary button 和链接用，约占 3%
- hover：颜色变深 + transform: translateY(-1px)，duration 150ms
- elevation：只有 2 级（shadow-sm / shadow-lg），无多层纵深
- 卡片密度：稀、内边距 24px，rounded-lg，不用渐变
- 图标：lucide-react，stroke-width 1.5
- 文案：工程向，动词为主（"Configure" 而非 "Set it up"）

你确认我看对了吗？
```

目标是让新加的元素和原有 UI 在视觉上 **无法区分** 。我确认观察报告之后，5 维决策的默认势能就调成"沿用观察到的"，AI 不再从空气里现选字体配色。

### 改进 3 · 占位符策略（治 AI 编数据 / 用 emoji 凑图标）

这是 AI 写 UI 最高频的两种作弊：

- 没图标 → 🚀⚡✨ 凑
- 没数据 → 编个 "95% 满意度"、"10000+ 活跃用户"
- 没头像 → 拉张 stock photo
- 没 logo → AI 自绘一个粗糙图形

现在 UI-DESIGN.md 里强制带一段占位符策略表：缺图标用 `[icon]` 方块；缺头像用首字母圆形；缺图用 16:9 aspect-ratio 卡片； **缺数据停下来反问用户** ，不允许编。

占位符传达的信号是"这里需要真材料"，后续好补。伪造物传达的信号是"我偷工了"，后续很难拆。

### 改进 4 · 前端工程硬规则文档

新加了 `reference/frontend-engineer-rules.md` ，专门给 4-dev 阶段的前端任务读。里面是一些极具体的技术雷区，每条都是 AI 实际会踩然后回头 debug 两小时的事故：

- React + Babel CDN 模式下，禁止把 `const styles = {...}` 当全局变量名（多个 script 块会静默互相覆盖）
- 跨文件组件必须 `Object.assign(window, { ComponentName })` 暴露（独立 script 块作用域不共享）
- 禁用 `scrollIntoView` （iframe 预览环境会触发外层 frame 滚动）
- 字体黑名单：Inter / Roboto / Arial / Helvetica / system-ui（典型 AI-slop 视觉指纹）
- 颜色一律 `var(--color-*)` ，组件代码里禁止硬编码 `#fff` / `rgb(...)`
- 动画分层选方案：CSS transition → React state + RAF → useTime → Popmotion， **别一上来就引 Framer Motion / GSAP / Lottie**

还有一份 11 条交付前清单，提交 PR 前逐项过：console 无错误、状态完备（hover / focus / active / disabled / loading / empty / error）、文字无溢出、所有颜色来自 UI-DESIGN.md、没用 `scrollIntoView` 、没 AI-slop ……

### 加起来效果

这套加进去之后，UI 这步从"看心情"变成了"有护栏"。还做不到每次都惊艳，但至少 **不会再出紫粉渐变 + emoji 凑图标 + 编 95% 好评率** 这种典型 AI-slop。

方法论我没原创，是从 garden-skills 那个 skill 搬过来的，按 flow-kit 的 8 阶段结构做了适配。原 skill 是给一次性出 HTML 演示文件的场景设计的，flow-kit 是分阶段的工作流，所以做了拆分：v0 / 占位符 / brownfield 对齐进 `2a-ui-design` ，技术硬规则进 `4-dev` 引用的 reference 文档。

---

## 花多少 token / 多少钱

这个必须说清楚，不然很多人看到数字会劝退。

我按 Claude Sonnet 当前定价估算（ 3 / M i n p u t,3/M input,15/M output），一个 **中等复杂度 change** （2-3 天工作量）的成本大概是：

| 方式 | token 用量 | 成本 |
| --- | --- | --- |
| 裸跑 AI（自己人肉管阶段） | 150-300k | $1.5-4 |
| flow-kit 完整 8 步 | 300-550k | $3-8 |
| flow-kit 极简模式（删 review 和 test） | 200-400k | $2-5 |
| 老项目首次入场扫描 | +20-50k | +$0.3-1（一次性） |

按月算，如果你每天做 2-3 个 change：

- 裸跑： **$60-240 / 月**
- flow-kit 完整： **$120-480 / 月**
- 差 60-240 美金，换两件事：事故率低 + 每个 change 留下完整工件

贵了多少？多 40-80%。

这个钱花不花得值，我下面给判断标准。

---

## 利弊实话

不藏着。下面这些都是亲身体会。

### 它的好处

**事故率真的降低了。** 我那个 8 万行的老项目，之前平均两周炸一次线上，改成 flow-kit 之后两个月没炸过。当然这不是严格实验，就当个参考。主要拦住的是"AI 顺手改坏了" + "AI 重复实现" + "AI 误删"这三类。

**工件可审计。** 每个 change 留下 CHANGE / REQUIREMENT / DESIGN / TASK / SUMMARY × N / TEST / REVIEW 一整套 md。半年后回头看，知道当时为啥这么做、走过什么弯路。对 PR review、交接、复盘都有用。

**单窗口压力小。** 每个任务 fresh context 进去，最多 20-30k token，AI 不会"打转"（用过 AI 的都知道对话长了它会鬼打墙）。

**零依赖。** 纯 Markdown 文件，复制到项目根目录就能用。不需要 npm install，不需要 CLI，不需要后台服务。任何支持 `@` 引用的 IDE 都能跑。

**老项目无缝过渡。** 你已经有的 CLAUDE.md / AGENTS.md / Cursor rules 直接复用，不用重写。

### 它的代价

**Token 费用多花 40-80%。** 上面那张表。小项目 / 原型 / hackathon 场景，这钱不值得花，直接裸跑更划算。

**流程不适合快速原型。** 如果你只是想让 AI 写 50 行代码验证一个想法，走 8 步流程就是过度工程。flow-kit 里专门写了决策表："代码 < 50 行 / 一次性修补 / hackathon 场景 → 不走 flow-kit"。

**学习成本。** 虽然只是读几个 md 文件，但要真的理解每个阶段在干啥、在哪里介入，还是要花两三次上手时间。前两次你会觉得"这流程真啰嗦"，第三次之后才会觉得"离了这个我不敢写了"。

**UI 设计阶段还做不到每次惊艳。** 这周刚重做了一遍（v0 草稿 / 占位符策略 / brownfield 视觉对齐 / 前端工程硬规则，详见上面那一节），AI-slop 出现率明显降了，但要稳定出彩还是看 AI 当时心情 + 装没装 ui-ux-pro-max / impeccable 这种外部审查工具。

**`.specs/` 目录会堆积。** 每个 change 一个目录，做多了你会看到项目里多出几十个目录。flow-kit 有 `archive` 命令归档老 change，但要你自己定期跑。

**反问环节需要你配合。** 老项目护栏触发时（删代码 / schema 变更 / 越界），AI 会停下来等你回复。如果你人不在、AI 自己跑的场景，这反而是阻塞。

**某些语言栈没全验过。** 我主要用 TS / Python / Java，Rust / Ruby / Go / PHP 只是套了模板，verify 命令、schema 工具映射肯定有不对的地方。

### 到底值不值

我的判断标准是这样：

| 场景 | 推荐 |
| --- | --- |
| 一次性脚本 / hackathon / 50 行以内 | 不用 flow-kit，裸跑 |
| 新项目 MVP（周末做完那种） | 极简模式（删 review 和 test） |
| 生产代码 / 老项目加功能 | 完整 flow-kit |
| 团队协作 / 交接频繁 | 完整 flow-kit |
| 金融 / 医疗 / 安全关键 | 完整 flow-kit + 所有护栏 + 外部 lint 工具 |

如果你的事故成本 > 多花的 token 成本，就用。反之就别用。

---

## 怎么用

```
把 flow-kit/ 文件夹复制到项目根目录

在对话里：
  @flow-kit/GO.md
  <你的一句话需求>
```

就这样。GO.md 会帮你路由到合适的阶段 prompt，按项目情况做入场检测、生成 change-id、分波次执行。

---

## 题外话

这套东西是我一个人根据我自己在项目开发上综合的。能用，但肯定有不少地方值得重做。

**如果你是大佬** ，扫一眼觉得"这里、这里、这里设计得不对"，或者你实际用了发现 bug / 缺陷 / 有更好思路 —— 非常欢迎直接砸过来。

我特别想听这几类反馈：

- 某个护栏触发规则太严 / 太松，漏过了什么事故
- 某个阶段在你的语言栈里跑不通
- 某段 prompt 你觉得 AI 会读歪
- 你有更好的既有抽象 grep 模板
- 你项目里有我没覆盖到的事故类型
- 你认为 flow-kit 借鉴错了某个项目的思路

留言、私信、加微信，哪个方便用哪个。

我最怕的不是被说设计不好，最怕没人反馈，然后自己一个人闭门造车越走越偏。但如果你只是想找存在感，来这评论显得你，请退出或者拉黑我，不然我就会拉黑你

---

> 项目地址：先发个预告，五一在外面，还没整理出来哈哈哈哈哈

假期写的，发出来看看有没有人用得上。

继续滑动看下一个

自我学习笔记记录

向上滑动看下一个