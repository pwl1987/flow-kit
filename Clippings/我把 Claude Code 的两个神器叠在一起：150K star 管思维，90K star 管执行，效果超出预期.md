---
title: "我把 Claude Code 的两个神器叠在一起：150K star 管思维，90K star 管执行，效果超出预期"
source: "https://mp.weixin.qq.com/s/DiZHXuJRND3LhDx2fSwPlw"
author:
  - "[[莲花明]]"
published:
created: 2026-05-15
description: "一个负责方法论，一个负责执行。两个插件叠在一起，才是完整的AI工程师配置。"
tags:
  - "clippings"
---
莲花明 *2026年5月14日 09:36*

上周一个读者给我发消息：

> 装了 gstack，感觉命令很多，但不知道什么时候该用哪个。

这个反馈让我想了很久。

gstack 的问题不是功能不够——它有 23 个 AI 角色、8 个执行工具，从需求评审到安全审计全覆盖。问题是：没有一套约束告诉 Claude Code，什么时候该停下来想，什么时候才能开始干。

这就是 **Superpowers** 存在的原因。

一个管怎么想，一个管怎么干。两个插件叠一起，才是完整的配置。

![[_resources/我把 Claude Code 的两个神器叠在一起：150K star 管思维，90K star 管执行，效果超出预期/c4064c7ee7abacba8bbc10d7ff102ea4_MD5.webp]]

装与不装，差别有多大？看这张图就够：

---

## Superpowers：给 Claude Code 装一套工程方法论

Superpowers 是 obra（Jesse Vincent）开源的 Claude Code 插件，150K GitHub Star，上线 6 个月。

它解决的不是"Claude 写代码的质量"，而是更上游的问题：

> Claude Code 默认行为是接到指令就开始写代码。Superpowers 强制它先走完"想清楚"的步骤，再动手。

核心是一套五步强制流程：

| 步骤 | 做什么 | 为什么不能跳 |
| --- | --- | --- |
| ① 厘清需求 | 反问 2-3 个关键问题 | 需求模糊是一切返工的根源 |
| ② 设计方案 | 给出架构、数据流、状态机 | 改架构的代价远高于改代码 |
| ③ 拆解计划 | 细拆任务，估工期 | 防止上来就啃最难的 |
| ④ 写代码 | 严格 TDD，先写测试 | 没有测试的代码=定时炸弹 |
| ⑤ 验证结果 | 核对需求，跑完整流程 | 做完了不等于做对了 |

关键机制是 **SessionStart Hook** ：每次开新对话，Superpowers 自动把这套方法论注入上下文。不需要每次手动提醒 Claude，它从第一句话开始就按这个框架运作。

装了 Superpowers 的 Claude Code，遇到新需求不再直接开写，而是先问你几个问题。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

---

## gstack：把执行工具配齐

gstack 是 Y Combinator CEO Garry Tan 的个人工具包，今年 3 月开源，16 天 90K Star。

Tan 本人用它 60 天写了 60 万行代码、6000 个 PR。

它的思路很简单： **把工程团队每个岗位都变成一个 slash 命令** 。

| 命令 | 对应岗位 | 干什么 |
| --- | --- | --- |
| /plan-ceo-review | 创始人 / CEO | 从商业价值和用户视角重新审需求，砍不必要的功能 |
| /plan-eng-review | 技术负责人 | 锁定架构、数据表、API 设计，出结构图 |
| /review | 资深工程师 | 找 N+1 查询、竞争条件、SQL 注入，能修的自动修 |
| /browse | QA 工程师 | 真的打开 Chromium 浏览器，截图给你看页面 |
| /qa | QA 主管 | 系统测试 + 自动修复 + 健康评分 0-100 |
| /cso | 首席安全官 | OWASP Top 10 + STRIDE 威胁建模 |
| /ship | 发版工程师 | 一键同步、测试、push、开 PR |
| /retro | 工程主管 | 每周回顾 commit 速度、测试比率、贡献者数据 |

⚡ 注意 /browse 这个命令——它启动的是真实 Chromium 进程，用无障碍树定位元素，响应时间 100-200ms。不是模拟，是真浏览器。这一条解决了"AI 说测试通过但浏览器一打开白屏"的经典问题。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

---

## 两个插件的区别，一句话说清

|  | Superpowers | gstack |
| --- | --- | --- |
| 核心隐喻 | 大脑——工程方法论 | 手脚——执行工具集 |
| 管的是什么 | 什么时候该想、该停、该动手 | 动手时每个节点怎么做 |
| 触发方式 | SessionStart 自动注入，全程生效 | 手动 slash 命令，按需调用 |
| 能力范围 | 5步流程 + 14个技能 | 23个角色 + 8个工具 |
| 单独使用的问题 | 流程对了，但执行工具不够专业 | 工具齐了，但没有约束容易跳步骤 |

> 单用 Superpowers：Claude 知道该先想清楚，但 code review 和 QA 只靠对话，没有专业工具加持。  
> 单用 gstack：命令很多，但 Claude 还是可能直接跳到写代码，绕过需求和架构。  
>   
> 两个叠一起：Superpowers 保证流程不跳步骤，gstack 保证每个步骤用正确的工具做。

---

## 安装：两条命令，5 分钟搞定

`# 第一步：安装 Superpowers   claude mcp install superpowers      # 第二步：安装 gstack（需要先装 Bun）   curl -fsSL https://bun.sh/install | bash  # 装 Bun   git clone https://github.com/garrytan/gstack ~/.claude/skills/gstack   cd ~/.claude/skills/gstack && bun install      # 重启 Claude Code，slash 命令全部生效`

装完之后，Claude Code 的 slash 命令列表里会出现 /review、/qa、/ship 等所有 gstack 命令，同时每次对话开始 Superpowers 自动生效。

---

## 组合工作流：从需求到上线的标准闭环

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

用一个虚构场景走一遍：你要给一个内部系统加"审批流程"功能。

### 第一步：理清需求（Superpowers 自动触发）

你说"加个审批功能"。Claude 不直接写代码，先问：

审批几级？审批人固定还是动态分配？审批拒绝后可以修改重提吗？超时自动通过还是自动拒绝？

你花 1 分钟回答，Claude 输出"我理解的需求是……"确认一遍。

### 第二步：锁架构（/plan-eng-review）

跑 /plan-eng-review。Claude 输出：审批表结构、状态流转图、API 端点列表、需要哪些索引。你看一眼说 OK，才开始写代码。

### 第三步：写代码，然后 /review

代码写完，跑 /review。这次 Claude 以"资深工程师"视角挑刺：状态更新没加事务、通知接口没做幂等、审批记录表缺了 operator\_id 字段。自动修复三个问题。

### 第四步：/browse 验证前端

跑 /browse。真实浏览器打开，截图给你看：审批列表页正常，审批详情页正常，手机端显示正常，console 零报错。

### 第五步：/ship 发版

跑 /ship。自动 push 代码、创建 PR、写 PR 描述（含本次改动说明和测试覆盖情况）。

你全程做了什么： **确认需求 1 分钟，看架构 1 分钟，看 review 结果 1 分钟，批 PR 10 秒。**

Claude 做了什么：其他所有事。

---

## 谁适合这套配置

**最适合** ：一个人负责多个项目、需要把关每个技术节点的人。用这套配置的收益在于——不是让你写代码更快，是让你不漏掉该做的关键步骤。

**不太适合** ：偶尔写写小脚本的人，或者在有完整工程团队的公司工作（你们已经有真人 QA、真人 reviewer 了）。

**可以只装一个** ：如果你已经有很强的工程纪律，只是需要更好的执行工具，装 gstack 就够。如果你只是想让 Claude Code 写代码更严谨、不乱跳步骤，装 Superpowers 就够。

---

## 两个数字

Superpowers：150K GitHub Star，上线 6 个月。

gstack：90K GitHub Star，上线 2 个月。

两个插件都爆了。说明大家发现了同一个问题：Claude Code 单独用，能力够，但少了约束和工具。

一个装方法论，一个装执行工具。这套组合是目前我见过对 Claude Code 改造最完整的方案。

Repo 地址： *github.com/obra/superpowers* 和 *github.com/garrytan/gstack*

**微信扫一扫赞赏作者**

继续滑动看下一个

AI落地手记

向上滑动看下一个