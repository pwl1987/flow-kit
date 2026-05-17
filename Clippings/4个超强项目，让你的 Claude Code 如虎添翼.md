---
title: "4个超强项目，让你的 Claude Code 如虎添翼"
source: "https://mp.weixin.qq.com/s/mxkNxjQ7YjuKhHhVOODOFQ"
author:
  - "[[老章很忙]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
老章很忙 *2026年4月17日 20:59*

[Claude Opus 4.7 来了，编程能力又炸了](https://mp.weixin.qq.com/s?__biz=MzA4MjYwMTc5Nw==&mid=2649012519&idx=2&sn=a0fbe4b31a6f3db36b50ba0dcdd87966&token=686239440&lang=zh_CN&scene=21#wechat_redirect)

[Claude Code 100万上下文时代，你的会话管理可能全错了](https://mp.weixin.qq.com/s?__biz=MzA4MjYwMTc5Nw==&mid=2649012538&idx=1&sn=71a297d689f4dd4607d88989411a488c&token=686239440&lang=zh_CN&scene=21#wechat_redirect)

[2026 年，AI 编程 Agent 的真正分水岭——Harness 详解](https://mp.weixin.qq.com/s?__biz=MzA4MjYwMTc5Nw==&mid=2649012185&idx=1&sn=e613849d8e706a95d4a3c292b5881a1e&scene=21#wechat_redirect)

光会用 Claude Code 远远不够，怎么 **把它配到极致** ，才是拉开差距的关键

最近 GitHub 上涌出了一批高质量的 Claude Code 生态项目，我挑了 4 个最值得关注的，每一个都能让你的 Claude Code 直接升级一个段位

### 一、Everything Claude Code——Anthropic 黑客松冠军的全家桶

地址：github.com/affaan-m/everything-claude-code

这个项目的来头很硬—— **Anthropic 黑客松获胜者** 出品，目前 **140K+ Star** ，21K+ Fork，170+ 贡献者

这不是一个"配置模板集合"，这是一整套经过 10 个月高强度日常使用打磨的 **Claude Code 操作系统**

来看下它到底有多猛：

**核心能力：**

- **48 个 Agent** ：不是玩具级别的 demo，是可以直接用于生产环境的智能体
- **183 个 Skill** ：涵盖从代码审查、安全扫描到品牌营销、视频创作的方方面面
- **79 个命令** ：覆盖你能想到的所有开发工作流

最让我眼前一亮的是它的 **六大指南体系** ：

| 主题 | 你将学到什么 |
| --- | --- |
| Token 优化 | 模型选择、系统提示精简、后台进程管理 |
| 内存持久化 | 自动跨会话保存/加载上下文的钩子 |
| 持续学习 | 从会话中自动提取模式到可重用的技能 |
| 验证循环 | 检查点 vs 持续评估、评分器类型 |
| 并行化 | Git worktrees、级联方法、何时扩展实例 |
| 子代理编排 | 上下文管理、迭代检索模式 |

**安装也很简单，两步搞定：**

```
# 第一步：添加市场并安装插件
/plugin marketplace add https://github.com/affaan-m/everything-claude-code
/plugin install everything-claude-code@everything-claude-code

# 第二步：安装规则（必需）
git clone https://github.com/affaan-m/everything-claude-code.git
cd everything-claude-code
npm install
./install.sh --profile full
```

而且这货是 **全平台通吃的** ——Claude Code、Codex、Cursor、OpenCode、Gemini 都能用

最新 v1.10.0 版本还加入了 ECC 2.0 alpha（Rust 控制层）、品牌营销工作流、视频创作等能力

说实话，这个项目的野心已经远超"Claude Code 配置集"的范畴了

**我的评价** ：如果你只打算收藏一个 Claude Code 增强项目，选这个就对了。从新手到高手都能找到价值，尤其是那六份指南，价值千金

### 二、GacUI 的 CLAUDE.md——关键词驱动的工作流引擎

地址：github.com/vczh-libraries/GacUI/blob/master/CLAUDE.md

这个项目的思路完全不同

GacUI 是一个 C++ GUI 框架，但它的 CLAUDE.md 写法堪称 **教科书级别** ——用关键词驱动整个开发工作流

它的核心思想是： **用第一个单词决定 Claude 的行为模式**

```
你输入的第一个词 → Claude 自动加载对应的 prompt 文件 → 按流程执行
```

看看这套关键词体系：

| 关键词 | 对应行为 | 场景 |
| --- | --- | --- |
| `scrum` | 加载敏捷开发流程 | 项目管理、sprint 规划 |
| `design` | 加载设计模式 | 架构设计、接口设计 |
| `plan` | 加载规划流程 | 任务拆解、排期 |
| `execute` | 加载执行流程 | 写代码、实现功能 |
| `verify` | 加载验证流程 | 测试、代码审查 |
| `investigate` | 加载调查流程 | 排查问题、分析日志 |
| `code` | 直接写代码 | 默认模式 |
| `kb` | 知识库查询 | 查文档、找参考 |

最妙的是它支持 **组合输入** ：

- 输入 `scrum learn` → 加载 scrum 流程，主题是 "Learn"
- 输入 `design problem next` → 加载设计流程，主题是 "Problem"，附带 "next"
- 输入 `execute and verify` → 先执行再验证

甚至还考虑了 **语音输入场景** ——如果整段话没有换行和标点，说明是语音转文字输入的，Claude 会自动纠正发音相近词汇的拼写错误

**我的评价** ：这个方案最大的启发在于——你可以把 CLAUDE.md 设计成一个 **命令路由器** 。与其写一堆笼统的规则，不如按场景拆分，让 Claude 在不同场景加载不同的"操作手册"。这个思路适用于任何有复杂工作流的项目

### 三、Waza——Tw93 出品的工程师技能包

地址：https://github.com/tw93/waza

Waza（技，わざ）是日本武术用语，意思是"反复练习直到成为本能的招式"

这个名字起得就很有味道——作者 Tw93（国内知名前端开发者）想表达的是： **好的工程师习惯应该像肌肉记忆一样自然**

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

Waza 提供 8 个精心打磨的 Skill，每一个都对应一个工程师的核心习惯：

| Skill | 触发场景 | 干什么 |
| --- | --- | --- |
| `/think` | 动手写代码之前 | 挑战问题本身，压力测试设计，先验证架构 |
| `/design` | 做前端界面 | 产出有风格的 UI，拒绝千篇一律的默认样式 |
| `/check` | 完成任务、合并之前 | 审查 diff，自动修复安全问题，标记危险命令 |
| `/hunt` | 遇到 bug | 系统性 debug，先确认根因再动手修 |
| `/write` | 写文档/文案 | 重写文字，让中英文都自然流畅 |
| `/learn` | 进入陌生领域 | 六阶段研究流程：收集→消化→大纲→填充→打磨→自审 |
| `/read` | 读任何 URL 或 PDF | 智能路由：GitHub、PDF、微信、飞书都有特殊处理 |
| `/health` | 审计 Claude Code 配置 | 检查 CLAUDE.md、规则、技能、钩子、MCP，按严重级别报告问题 |

它还附带两个实用工具：

**状态栏** ——一行命令搞定 Claude Code 的资源监控：

```
curl -sL https://raw.githubusercontent.com/tw93/Waza/main/scripts/setup-statusline.sh | bash
```

下图是状态栏效果，显示上下文窗口占用、5 小时配额、7 天配额和重置倒计时：

![Waza 状态栏](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

Waza 状态栏

**英语教练** ——让 Claude 在协作时顺带纠正你的英语：

![英语教练效果](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

英语教练效果

安装也极简：

```
# Claude Code
npx skills add tw93/Waza -a claude-code -g -y

# Codex
npx skills add tw93/Waza -a codex -g -y
```

**我的评价** ：Waza 的哲学是"少即是多"——只做 8 件事，但每件都做到位。作者说得好： **每一条规则都是天花板，模型只能做到指令说的那些。Waza 反其道行之，设定目标和约束，然后退后一步。随着模型越来越强，这种克制会产生复利效应。** 30 天、300+ 会话、7 个项目、500 小时打磨出来的东西，确实扎实

### 四、Ars Contexta——给你的 Agent 装一个"第二大脑"

地址：https://github.com/agenticnotetaking/arscontexta

这个项目的定位非常独特——它要解决的问题是： **AI 工具每次开始新会话都是"失忆"的**

Ars Contexta 通过对话生成一整套个人化的知识系统，让你的 Claude Code 拥有持久记忆。

名字来源很浪漫——Ars Combinatoria（组合术）、Ars Memoria（记忆术），到 Ars Contexta（上下文术）。从 Llull 的旋转轮到 Bruno 的记忆轮，它们都是外部思维系统。现在 LLM 可以自己遍历了，轮子又可以转起来了。

**运行 `/arscontexta:setup` 后，你会得到：**

- **一个知识库** ：纯 Markdown + Wiki Link 构成的知识图谱，无数据库，无云端，无锁定
- **处理管道** ：自动提取洞察、发现关联、更新旧笔记
- **自动化钩子** ：写入时校验结构、自动 git commit、会话状态保存
- **导航系统** ：多层级的 Maps of Content（MOC）
- **模板系统** ：带 `_schema` 校验的笔记模板
- **用户手册** ：7 页针对你领域的专属文档

Setup 流程是 6 个阶段的对话：

| 阶段 | 做什么 |
| --- | --- |
| 检测 | 检测 Claude Code 环境和能力 |
| 理解 | 2-4 轮对话，描述你的工作领域 |
| 推导 | 将信号映射到 8 个配置维度 |
| 提案 | 展示将要生成的内容和原因 |
| 生成 | 生成所有文件：上下文、模板、技能、钩子、手册 |
| 验证 | 检查 15 个核心原语，运行管道冒烟测试 |

整套系统基于 **三空间架构** ：

| 空间 | 用途 | 增长速度 |
| --- | --- | --- |
| `self/` | Agent 持久心智——身份、方法论、目标 | 慢（几十个文件） |
| `notes/` | 知识图谱——系统存在的意义 | 稳定（每周 10-50 个） |
| `ops/` | 运营协调——队列状态、会话 | 波动 |

最硬核的是它背后有 **249 条互联的研究论断** （methodology/），涵盖 Zettelkasten、Cornell 笔记法、Evergreen Notes、PARA、GTD、认知科学、网络理论等。每一个配置决策都有学术依据，你可以直接问它为什么这么做：

```
/arscontexta:ask "Why does my system use atomic notes?"
```

安装方式：

```
# 添加市场
/plugin marketplace add agenticnotetaking/arscontexta

# 安装
/plugin install arscontexta@agenticnotetaking

# 重启 Claude Code 后运行
/arscontexta:setup
```

**我的评价** ：这是我见过最有"学术味"的 AI 工具项目，249 条研究论断不是闹着玩的。它真正在尝试回答一个深层问题： **Agent 应该怎么"记住"和"思考"？** 如果你对知识管理（PKM）有兴趣，或者厌倦了每次新会话都要重新交代背景，这个项目值得深度体验。

### 总结

这四个项目代表了 Claude Code 生态的四个方向：

| 项目 | 定位 | 适合谁 |
| --- | --- | --- |
| **Everything Claude Code** | 全家桶，开箱即用 | 想一步到位的人 |
| **GacUI CLAUDE.md** | 工作流路由器 | 有复杂开发流程的团队 |
| **Waza** | 精品技能包 | 追求极简、信奉少即是多的工程师 |
| **Ars Contexta** | 知识管理系统 | 重度知识工作者、PKM 爱好者 |

![ClaudeCode 四大生态项目全景](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

ClaudeCode 四大生态项目全景

我个人的使用建议： **先用 Waza 入门** （8 个 Skill 足够理解 Claude Code 的技能体系）， **再用 Everything Claude Code 全面武装** ，最后按需加入 **Ars Contexta** 做持久化记忆。GacUI 的 CLAUDE.md 模式则适合学习借鉴——哪怕你不用它，关键词路由的思路也值得偷师。

#ClaudeCode #Agent #Skills #Waza #开源

**制作不易，如果这篇文章觉得对你有用，可否点个关注。给我个三连击：点赞、转发和在看。若可以再给我加个🌟，谢谢你看我的文章，我们下篇再见！**

好用的 AI 工具 · 目录

继续滑动看下一个

Ai学习的老章

向上滑动看下一个