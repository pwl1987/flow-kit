---
title: "OpenSpec + Superpowers + gstack：一套让 AI 从「写代码」到「做项目」的组合拳"
source: "https://mp.weixin.qq.com/s/xjYmBrAR1Jxi0fMd_818Bg"
author:
  - "[[祥子]]"
published:
created: 2026-05-15
description: "OpenSpec + Superpowers + gstack：一套让 AI 从「写代码」"
tags:
  - "clippings"
---
祥子 *2026年4月26日 08:15*

## OpenSpec + Superpowers + gstack：一套让 AI 从「写代码」到「做项目」的组合拳

> OpenSpec 负责「想清楚再动手」，Superpowers 负责「测试驱动、子代理驱动开发」，gstack 负责「虚拟工程团队全流程覆盖」。初步尝试下来，这套组合拳确实能让 AI 从「写代码的助手」变成「做项目的团队」。

---

## 你是不是也这样？

用 AI 写代码久了，总有一些痛点：

- 让 AI 改个功能，结果跑偏了，写了半天不是你想要的
- 没有需求文档，聊完就忘，下次又得重新对齐
- AI 写的代码看着能用，但没有测试，心里没底
- 一个人 review 代码容易漏掉边界情况
- 写完代码不知道要不要测试、要不要部署

我以前也经常这样。直到最近尝试了三个开源项目的组合，才意识到原来「AI 做项目」这件事可以有完整的方法论。

---

## 一、三件套分别是什么？

### OpenSpec：需求先行，想清楚再动手

**GitHub** ：Fission-AI/OpenSpec（4.2 万+ Star，MIT 协议）

**核心定位** ：Spec-driven development（规格驱动开发），在 AI 写代码之前，先对齐「要做什么」。

```
1234567891011
        /opsx:propose add-dark-mode
  → 创建 proposal.md（为什么要做）
  → 创建 specs/（需求场景）
  → 创建 design.md（技术方案）
  → 创建 tasks.md（实施清单）
 
/opsx:apply
  → 按 tasks.md 逐项执行
 
/opsx:archive
  → 归档到历史，更新规格库
```

**适合谁** ：需要 AI 在动手前先对齐需求的任何人。

### Superpowers：测试驱动、子代理驱动开发

**GitHub** ：obra/superpowers（16.6 万+ Star，MIT 协议）

**核心定位** ：一套完整的 AI 编程方法论，从头脑风暴到测试到部署的全流程。

**核心工作流** ：

| 阶段 | 技能 | 做什么 |
| --- | --- | --- |
| 设计 | brainstorming | 苏格拉底式提问，把模糊想法变成清晰规格 |
| 分支 | using-git-worktrees | 创建工作树，隔离开发 |
| 规划 | writing-plans | 拆成 2-5 分钟的小任务，每个都有明确验收标准 |
| 开发 | subagent-driven-development | 子代理驱动，每个任务独立执行、独立审查 |
| 测试 | test-driven-development | 红绿重构循环，先写测试再写代码 |
| 审查 | requesting-code-review | 代码审查清单 |
| 完成 | finishing-a-development-branch | 合并/PR 决策 |

**适合谁** ：希望 AI 能自主工作几小时不跑偏的团队。

### gstack：虚拟工程团队全流程

**GitHub** ：garrytan/gstack（8.2 万+ Star，MIT 协议）

**核心定位** ：Y Combinator CEO Garry Tan 的 Claude Code 完整配置，把 Claude Code 变成一个 23 人的虚拟工程团队。

| 命令 | 角色 | 做什么 |
| --- | --- | --- |
| `/office-hours` | YC 导师 | 6 个灵魂拷问，重新定义你的产品方向 |
| `/plan-ceo-review` | CEO | 重新思考问题，找到 10 分产品 |
| `/plan-eng-review` | 工程经理 | 锁死架构、数据流、边界情况、测试 |
| `/plan-design-review` | 高级设计师 | 设计维度打分 0-10，AI Slop 检测 |
| `/review` | 代码审查员 | 自动修复问题，阻塞严重 bug |
| `/qa` | QA 工程师 | 真实浏览器测试，点击流程 |
| `/ship` | 发布工程师 | 跑测试、开 PR、自动部署 |
| `/retro` | 复盘教练 | 每周工程复盘 |

Garry Tan 自己的数据： **2026 年代码产出是 2013 年的 240 倍** （按逻辑变更计算，不是原始行数）。

---

## 二、三件套怎么组合？

### 核心理念：各司其职，流水线作业

| 阶段 | 工具 | 职责 |
| --- | --- | --- |
| **想清楚** | OpenSpec | 规格定义、需求对齐、技术方案 |
| **拆清楚** | Superpowers | 头脑风暴、任务拆解、测试驱动 |
| **做清楚** | gstack | 虚拟团队全流程 review、QA、部署 |

### 完整工作流：从想法到上线

```
123
    想法 → /opsx:propose → /opsx:apply → /review → /qa → /ship
   ↑               ↑              ↑          ↑       ↑
OpenSpec      OpenSpec+Super  gstack     gstack   gstack
```

---

## 三、实战：从零开始做一个功能

### 第 1 步：定义规格（OpenSpec）

```
12345
        # 初始化 OpenSpec
openspec init
 
# 提出变更提案
/opsx:propose add-user-notifications
```

AI 会自动生成：

- proposal.md — 为什么要做这个功能
- specs/ — 需求和场景
- design.md — 技术方案
- tasks.md — 实施清单

**输出示例** ：

```
1234567891011121314151617181920
        # Proposal: add-user-notifications
 
## Why
用户在消息中心找不到新消息提醒，导致错过重要更新。
 
## What changes
- 新增邮件通知
- 新增应用内通知
- 新增推送通知（可选）
 
## Specs
### Spec: 邮件通知
- 用户收到评论时应收到邮件
- 邮件包含评论摘要和跳转链接
- 用户可在设置中关闭邮件通知
 
### Spec: 应用内通知
- 导航栏显示未读数量
- 点击打开通知列表
- 标记已读/全部已读
```

### 第 2 步：头脑风暴 + 任务拆解（Superpowers）

OpenSpec 生成的规格，直接作为 Superpowers 的输入：

```
12345
        # 头脑风暴，把规格变成可执行的计划
/brainstorming
 
# 生成实施计划
/writing-plans
```

AI 会把 tasks.md 拆成 2-5 分钟的小任务，每个任务包含：

- 具体文件路径
- 完整代码
- 验收步骤

### 第 3 步：子代理驱动开发（Superpowers）

```
12
        # 子代理驱动开发
/subagent-driven-development
```

每个任务会启动一个独立的子代理，完成后进行两阶段审查：

1. 规格符合性检查
2. 代码质量检查

这个阶段 AI 可以自主工作几小时不跑偏。

### 第 4 步：代码审查（gstack）

```
12345678
        # CEO 视角的战略审查
/plan-ceo-review
 
# 工程经理视角的技术审查
/plan-eng-review
 
# 自动代码审查
/review
```

gstack 的审查会自动修复一些问题，严重问题会阻塞合并。

### 第 5 步：QA 测试（gstack）

```
12
        # 真实浏览器测试
/qa https://staging.myapp.com
```

gstack 会打开真实浏览器，点击完整流程，发现 bug 自动修复。

### 第 6 步：部署上线（gstack）

```
12
        # 自动开 PR、跑测试、部署
/ship
```

输出：

```
12
        Tests: 42 → 51 (+9 new). 
PR: github.com/you/app/pull/42
```

### 第 7 步：归档（OpenSpec）

```
12
        # 归档本次变更
/opsx:archive
```

规格更新到历史库，下次类似需求可以直接参考。

---

## 四、安装指南

### OpenSpec

```
123456
        # 全局安装
npm install -g @fission-ai/openspec@latest
 
# 项目初始化
cd your-project
openspec init
```

### Superpowers

在 Claude Code 中：

```
12
        # 官方市场安装
/plugin install superpowers@claude-plugins-official
```

或在 Codex CLI 中：

```
12
        /plugins
# 搜索 superpowers，安装
```

### gstack

在 Claude Code 中粘贴：

```
1
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack && cd ~/.claude/skills/gstack && ./setup
```

安装完成后，输入 `/office-hours` 开始使用。

---

## 五、效果对比

| 维度 | 纯 AI 写代码 | OpenSpec | OpenSpec + Superpowers | 三件套组合 |
| --- | --- | --- | --- | --- |
| 需求对齐 | ❌ 容易跑偏 | ✅ 规格先行 | ✅ 规格+头脑风暴 | ✅ 规格+头脑风暴+CEO 审查 |
| 代码质量 | ⚠️ 取决于 prompt | ⚠️ 取决于 prompt | ✅ TDD 保证质量 | ✅ TDD + 代码审查 + QA |
| 测试覆盖 | ❌ 通常没有 | ❌ 通常没有 | ✅ 红绿重构循环 | ✅ 红绿重构 + 真实浏览器 QA |
| 审查机制 | ❌ 没有 | ❌ 没有 | ✅ 子代理互审 | ✅ 多级审查（CEO/工程/QA/安全） |
| 可追溯性 | ❌ 聊天历史 | ✅ 每个变更有完整记录 | ✅ 计划+执行记录 | ✅ 完整工程流程记录 |
| 适合场景 | 小改小修 | 需要明确需求的项目 | 中大型功能开发 | 企业级项目全流程 |

初步尝试下来，对于「中大型功能开发」场景，三件套组合确实能大幅提升 AI 的可控性和交付质量。

---

## 六、适合谁用？

| 人群 | 推荐理由 |
| --- | --- |
| **技术管理者** | 用 AI 带虚拟团队，全流程可控 |
| **独立开发者** | 一个人当一支团队，从需求到部署 |
| **Tech Lead** | 标准化开发流程，降低沟通成本 |
| **全栈工程师** | 需求对齐→开发→审查→测试→部署全覆盖 |

---

## 七、注意事项

### 限制 1：学习曲线不低

**说明** ：三个工具各有自己的概念和工作流，上手需要时间。

**建议** ：先用 OpenSpec 跑通规格驱动开发，再加 Superpowers 的 TDD，最后上 gstack 的全流程。

### 限制 2：对模型能力要求高

**说明** ：规格生成、子代理驱动、代码审查都需要强推理能力的模型。

**建议** ：OpenSpec 推荐 Opus 4.5 和 GPT 5.2。Superpowers 推荐 Claude Sonnet 4.5。gstack 在 Claude Code 上效果最好。

### 限制 3：不适合小改小修

**说明** ：如果只是改个 type 或者调个样式，直接让 AI 改就行，不需要走完整流程。

**建议** ：简单变更直接用 AI，中大型功能才走三件套。

---

## 八、总结

**核心要点** ：

1. OpenSpec 想清楚： 规格先行，每个变更有完整的 proposal/specs/design/tasks
2. Superpowers 拆清楚： 头脑风暴→任务拆解→TDD→子代理驱动开发
3. gstack 做清楚： 23 个虚拟角色覆盖 CEO/设计/工程/QA/安全/部署全流程
4. 组合效果 > 单个工具： 三件套各司其职，流水线作业

**立即行动** ：

1. 安装 OpenSpec： `npm install -g @fission-ai/openspec@latest`
2. 安装 Superpowers：在 Claude Code 中 `/plugin install superpowers`
3. 安装 gstack： `git clone` + `./setup`
4. 从一个小功能开始： `/opsx:propose` → `/opsx:apply` → `/review` → `/ship`

仓库链接：

- Fission-AI/OpenSpec（4.2 万 Star）
- obra/superpowers（16.6 万 Star）
- garrytan/gstack（8.2 万 Star）

这是我目前的学习笔记，还在持续探索中。如果你也有 AI 工程化的好方法，欢迎在评论区交流。

---

> **免责声明** ：本文内容仅为个人学习分享，提及的三个项目均为 MIT 开源协议，遵守对应许可条款即可使用，如有侵权请联系删除。

---

**感谢你的阅读。**

如果这篇文章对你有帮助，欢迎：

- 点赞支持
- 分享给朋友
- 在评论区分享你的想法

关注「AI 工程化实战派」，不空谈虚概念，只输出务实干货。

期待和你的交流！

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

企业 AI 工程化实践笔记 · 目录

作者提示: 个人观点，仅供参考

继续滑动看下一个

AI工程化实战派

向上滑动看下一个