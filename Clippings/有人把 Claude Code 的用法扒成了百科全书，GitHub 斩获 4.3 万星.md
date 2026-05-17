---
title: "有人把 Claude Code 的用法扒成了百科全书，GitHub 斩获 4.3 万星"
source: "https://mp.weixin.qq.com/s/Dh5VJKfQ_tKV6EbSpRmSIg"
author:
  - "[[开源项目精选集]]"
published:
created: 2026-05-15
description: "claude-code-best-practice：GitHub 热榜最佳实践百科全书，从 vibe coding 到 agentic engineering的完整指南，持续更新，涵盖 Subagents、Skills、Hooks、MCP"
tags:
  - "clippings"
---
## 43.1K+ star | 有人把 Claude Code 的用法扒成了百科全书，GitHub 斩获 4.3 万星

开源项目精选集 *2026年4月19日 15:00*

Subagents、Commands、Skills、Hooks、MCP Servers、Routines、Channels、Memory、Checkpointing……

当你第一次打开 Claude Code 的官方文档，看到这一整套概念时，是不是有一种「走进了一个新世界」的感觉？

每概念背后都是一套完整的用法，但官方文档是字典式的——查得到定义，却不知道怎么把它们 **组合在一起解决实际问题** 。

GitHub 上有人把这件事做了一一这个人花了大量时间研究 Claude Code 的每一个功能，整理成了一份 **持续更新的最佳实践百科全书** ，目前已经斩获 **4.3 万颗星** ，今天又涨了 **2,569 颗** ，高居 GitHub Trending 第四名。

这份仓库的副标题就是它的核心价值主张： **from vibe coding to agentic engineering — practice makes claude perfect。**

![[_resources/有人把 Claude Code 的用法扒成了百科全书，GitHub 斩获 4.3 万星/401bcb21227c73d297378a1a23bcfc2e_MD5.webp]]

---

## 01 它是什么？

`claude-code-best-practice` 是一份 **关于 Claude Code 的最佳实践指南** ，由开发者 shanraisshan 维护。

它不是官方文档的翻译，而是一份 **实战型的知识库** ——每个功能都标注了：

- **Best Practice**
	（最佳实践建议）
- **Implemented**
	（作者自己已经落地使用）
- **Orchestration Workflow**
	（编排工作流）

涵盖了从基础概念到高级用法的完整链路，并且随着 Claude Code 版本更新持续迭代（badge 显示最新更新于 2026 年 4 月 15 日）。

---

## 02 核心原理/亮点

### 概念全景图

这份仓库把 Claude Code 的核心概念整理成了一张清晰的地图：

| 概念 | 文件位置 | 是什么 |
| --- | --- | --- |
| **Subagents** | `.claude/agents/<name>.md` | 在独立上下文中运行的自主执行者，有自己的工具、权限、模型和记忆 |
| **Commands** | `.claude/commands/<name>.md` | 用户调用的提示模板，注入到现有上下文里，用于编排工作流 |
| **Skills** | `.claude/skills/<name>/SKILL.md` | 可配置、可预加载的技能，支持上下文分叉和渐进式披露 |
| **Hooks** | `.claude/hooks/` | 在特定事件触发时运行的用户定义处理器（脚本、HTTP、提示、Agent） |
| **MCP Servers** | `.mcp.json` | Model Context Protocol 连接器，连接外部工具、数据库和 API |
| **Memory** | `CLAUDE.md`  、`.claude/rules/` | 通过 CLAUDE.md 文件和 `@path` 导入实现的持久上下文 |
| **Routines** | `claude.ai/code/routines` | 云端自动化——定时任务、API 触发、GitHub 事件驱动，关机也能跑 |
| **Channels** | `--channels` | 把 Telegram、Discord 或 Webhook 的事件推入运行中的会话 |
| **Checkpointing** | 自动（基于 git） | 自动追踪文件编辑，支持 `/rewind` 回滚和定向总结 |

### 亮点：Hot 特性

作者还专门标注了 **最热门的特性** ，这些都是近期 Claude Code 的新能力：

- **Routines：**
	云端自动化任务，关机也能跑
- **Devcontainers：**
	预配置的开发容器，安全隔离
- **Channels：**
	远程事件驱动会话，Claude 在 Telegram/Discord 里响应你
- **Ultraplan：**
	更强的规划能力

### vs 官方文档

|  | 官方文档 | 这份指南 |
| --- | --- | --- |
| 形式 | API 字典 | 实战手册 |
| 内容 | 功能定义 | 最佳实践 + 落地案例 |
| 组织 | 按功能分页 | 按场景组织，附编排逻辑 |
| 更新 | 跟随版本 | 持续迭代（前日刚更新） |

---

## 03 应用场景

### 谁应该看？

- **刚入门 Claude Code：**
	看完官方文档后，想知道「怎么把这些功能组合起来」
- **用了一段时间但感觉没发挥全部潜力：**
	想系统化提升 AI 编程效率
- **团队 Lead：**
	想规范 Claude Code 在团队中的使用方式

### 最佳阅读路径

**路径 1：从概念到实践** 按 Concepts 部分的顺序通读，理解每个功能是什么、怎么用。

**路径 2：从场景出发** 直接找跟自己场景最接近的部分，比如：

- 「想给 Claude 分配长期任务让它自己跑」→ Routines
- 「想在特定事件发生时自动触发 Claude」→ Hooks
- 「想让 Claude 记住项目上下文」→ Memory / CLAUDE.md
- 「想把 Claude 接入 Telegram/Discord」→ Channels

---

## 04 快速上手

**第一步：把这个仓库 clone 下来**

```
git clone https://github.com/shanraisshan/claude-code-best-practice.git
cd claude-code-best-practice
```

**第二步：从 Readme 开始**

仓库的 Readme 就是一份 **完整的概念地图** ，建议先通读一遍，搞清楚每个模块负责什么。

**第三步：按需深入**

点击 README 里每个概念对应的 badge（Best Practice / Implemented / Orchestration Workflow），跳转到详细的实践文档。

**第四步：学以致用**

每学一个功能，就在自己的项目里用起来：

```
#创建你的第一个 Subagent
mkdir-p .claude/agents
#参考仓库里的 best-practice/claude-subagents.md
```

---

## 写在最后

这份仓库最打动人的地方，不是某个具体功能讲得多好，而是 **系统性** 。

Claude Code 的每一个功能，官方文档都讲得很清楚——但把它们怎么组合起来，怎么在实际项目中落地，怎么避免常见陷阱，这些都需要大量试错才能总结出来。

shanraisshan 把这些试错总结成了可操作的指南，而且更新速度几乎跟 Claude Code 版本同步。

**如果你已经用 Claude Code 一段时间了，但感觉还是在「 vibe coding」而不是真正的「agentic engineering」——这份指南能帮你完成那个跨越。**

---

![Star History](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**相关链接：**

- GitHub：https://github.com/shanraisshan/claude-code-best-practice
- Claude Code 官方文档：https://code.claude.com/docs
- Claude Code 官方最佳实践：https://code.claude.com/docs/en/best-practices
- 官方 Skills 市场：https://github.com/anthropics/skills/tree/main/skills

**微信扫一扫赞赏作者**

继续滑动看下一个

开源项目精选集

向上滑动看下一个