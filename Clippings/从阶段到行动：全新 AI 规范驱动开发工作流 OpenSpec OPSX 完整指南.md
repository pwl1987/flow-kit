---
title: "从阶段到行动：全新 AI 规范驱动开发工作流 OpenSpec OPSX 完整指南"
source: "https://mp.weixin.qq.com/s/qE5suQ3JKbQTL-cwJcAjUQ"
author:
  - "[[兔兔AGI]]"
published:
created: 2026-05-15
description: "OPSX 是 OpenSpec 重构的全新工作流，为 AI 编程提供了一种迭代式的开发方式。它不再把流程拆成固定阶段，而是通过一组可以随时执行的行动来组织开发。"
tags:
  - "clippings"
---
兔兔AGI *2026年3月16日 11:23*

在 AI 时代，最直观的变化之一就是：工具迭代得非常快。过去，一种开发方式往往几年才会演进一次，而在 AI 生态里，几个月就可能出现一轮新的工具升级。

去年在学习 **规范驱动开发（Spec-Driven Development）** 的过程中，我写过一篇 [从规范到代码：OpenSpec驱动的可迭代AI开发实践](https://mp.weixin.qq.com/s?__biz=MjM5NzA1NzMyOQ==&mid=2247486315&idx=1&sn=a3f4887b6992e7649a10e31915a0c859&scene=21#wechat_redirect) ，介绍了 OpenSpec 如何以规范（Spec）为核心，在需求、设计和代码之间建立一个 **可迭代的开发流程** 。

几个月后，OpenSpec 迎来了重大更新，推出了新的 **OPSX 工作流** 。相比之前以阶段为核心的模式，OPSX 对整个开发流程进行了进一步抽象：把需求、规范、任务拆分和实现整合为一套更灵活的工作流体系。这样一来，AI 不再只是生成代码，而是可以参与从问题建模到任务执行的完整开发流程。规范也不再只是文档，而是驱动开发过程的一部分。

在这篇文章中，我会结合 OpenSpec 的最新演进，对 **OPSX 工作流** 做一次系统介绍：它解决了什么问题、相比旧流程有哪些关键变化，以及在实际的 AI 开发中应该如何使用。

## 什么是 OPSX

OPSX 是 OpenSpec 重构的 **全新工作流** ，为 AI 编程提供了一种迭代式的开发方式。它不再把流程拆成固定阶段，而是通过一组 **可以随时执行的行动** 来组织开发。

### 传统阶段式流程的困境

我们先看看传统线性阶段式工作流的问题：

```
传统（阶段锁定）：

PLANNING ────────► IMPLEMENTING ────────► DONE
      │                    │
      └────────────────────┘
      无法回头
```

在实现阶段，你可能会：

- • 发现设计其实不太合理
- • 找到更好的实现方式
- • 遇到新的需求变化
- • 受到技术细节的限制

但在这种流程下，一旦进入实现阶段，回到设计阶段往往并不容易。

旧版的 OpenSpec 工作流在一定程度上也延续了这种线性思路。它通过单个命令一次性生成所有规划 Artifact。当 AI 输出不理想，或者在实现过程中需要调整设计，回头修改就会比较麻烦。开发者通常只能手动编辑文件（这往往会破坏原有上下文）、放弃当前流程重新开始，或者先继续往下做，等以后再修。

### OPSX 的解决思路

OPSX 换了一种思路来组织开发流程，把整个开发过程拆分为一组可以随时调用的行动：

```
OPSX（行动驱动）：

  proposal ──► specs ──► design ──► tasks ──► implement
   ▲           ▲          ▲                    │
   └───────────┴──────────┴────────────────────┘
            随时更新，持续迭代
```

**核心理念** ：

- • **行动优先，而不是阶段优先**
- • **依赖关系用于连接信息，而不是限制流程**

这种从「阶段锁定」到「行动驱动」的变化，也让整个开发过程变得更加灵活：

- • **渐进式生成** ：你可以一次只生成一个 Artifact，先查看结果，再决定下一步要做什么，而不是一次性跑完整个流程
- • **更容易迭代** ：如果在实现（ `apply` ）过程中发现设计不合理，可以直接修改 `design.md` ，然后继续执行 `apply` 。OPSX 会从中断的位置继续，而不需要重新开始。
- • **高度可定制** ：工作流不再写死在工具里，而是通过 YAML（ `schema.yaml` ）和 Markdown 模板（ `templates/*.md` ）定义。这意味着团队可以根据自己的习惯调整 Artifact 类型、依赖关系以及提示词。
- • **过程更加透明** ：当 AI 生成的内容不理想时，你可以直接修改模板中的提示指令，然后重新生成，而不是面对一个无法调整的黑盒。

从这个角度看，OPSX 更像是一种 **可以不断调整的开发工作流** 。它让规范不再只是一次性写好的文档，而是可以随着开发过程不断更新。

### 两种工作模式

OPSX 提供两种工作模式，用来适应不同复杂度的开发场景。

#### 默认快速路径（core profile）

新安装的 OPSX 默认使用 `core` 配置，只提供四个核心命令：

| 命令 | 功能 |
| --- | --- |
| `/opsx:explore` | 探索式调研，不确定需求时使用 |
| `/opsx:propose` | 一键创建提案+规范+设计+任务 |
| `/opsx:apply` | 按任务清单执行开发 |
| `/opsx:archive` | 归档完成，合并规范 |

典型工作流：

```
/opsx:propose ──► /opsx:apply ──► /opsx:archive
```

这种模式流程简单、步骤清晰，适合大多数日常开发场景，比如需求明确、需要快速迭代的小功能。

#### 扩展路径（自定义 workflow）

如果你想要更细粒度的控制，可以启用扩展模式：

```
openspec config profile
openspec update
```

扩展模式提供了额外命令：

| 命令 | 功能 | 使用场景 |
| --- | --- | --- |
| `/opsx:new` | 创建变更脚手架 | 想要逐步创建文档 |
| `/opsx:continue` | 创建下一个 `Artifact` | 逐步推进，每步审核 |
| `/opsx:ff` | 创建所有规划文档 | 需求明确，快速推进 |
| `/opsx:verify` | 验证实现完整性 | 归档前检查 |
| `/opsx:sync` | 手动合并规范 | 可选的同步操作 |
| `/opsx:bulk-archive` | 批量归档变更 | 多任务并行后统一归档 |
| `/opsx:onboard` | 团队成员上手指南 | 新人加入项目 |

典型工作流：

```
/opsx:new ──► /opsx:ff 或 /opsx:continue ──► /opsx:apply ──► /opsx:verify ──► /opsx:archive
```

这种模式更适合复杂功能开发、需要精细控制流程的项目，或者团队协作的场景。

#### 如何选择？

可以用下面这个简单的决策思路来判断：

```
需要细粒度控制？
│
├─ 是 → 启用扩展路径（Expanded Path）
│       │
│       需求是否明确？
│       │
│       ├─ 明确 → /opsx:new + /opsx:ff
│       └─ 不明确 → /opsx:new + /opsx:continue
│
└─ 否 → 使用默认快速路径（Default Quick Path）
        │
        是否需要先探索问题？
        │
        ├─ 是 → /opsx:explore → /opsx:propose
        └─ 否 → /opsx:propose
```

**简单建议** ：

如果你刚开始使用 OPSX，建议先从默认快速路径开始。等熟悉流程后，如果发现需要更细粒度的控制，再切换到扩展路径。

## 深入理解：工作流模式

OPSX 的设计非常灵活，可以适应不同的开发场景。下面介绍三种典型的工作流模式。

### 探索式开发

当需求还不明确，或者需要先调研技术方案时，可以从 `/opsx:explore` 开始。

```
/opsx:explore ──► /opsx:new ──► /opsx:continue ──► ... ──► /opsx:apply
```

**示例对话：**

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

探索阶段的价值在于：在真正开始实现之前，先对问题空间有一个更清晰的认识。  
在这个过程中得到的分析和结论，也会自然地进入后续的提案和设计中。

**适合场景** ：

- • 性能优化
- • Bug 调试、
- • 技术选型或架构决策、
- • 需求还不够清晰的功能。

### 快速功能开发

当需求已经比较明确、希望尽快实现时，可以使用 `/opsx:ff` （fast forward）一次性生成所有规划文档。

```
/opsx:new ──► /opsx:ff ──► /opsx:apply ──► /opsx:verify ──► /opsx:archive
```

**示例对话：**

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

这种模式的特点是： **先快速生成完整规划，再集中实现功能** 。当需求已经比较清晰时，可以显著减少来回迭代的时间。

**适合场景** ：

- • 小到中等规模的功能开发、
- • Bug 修复
- • 需求已经非常明确的变更。

### 并行变更管理

在真实开发中，你经常需要同时处理多个任务。OPSX 对这种并行工作流提供了很好的支持。

```
变更A: /opsx:new ──► /opsx:ff ──► /opsx:apply (进行中)
                                   │
                               上下文切换
                                   │
变更B: /opsx:new ──► /opsx:ff ──────► /opsx:apply
```

**示例对话：**

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

这种模式让你可以在不同任务之间灵活切换，而不需要重新组织上下文或流程。

**适合场景：**

- • 多任务并行开发
- • 紧急 bug 修复打断当前任务
- • 团队协作中的多个变更同时推进。

当有多个变更已经完成时，还可以使用 **批量归档** ：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

批量归档会自动检查多个变更是否修改了相同的规范，并结合实际实现情况来处理可能的冲突。

## 快速上手指南

### 第一步：安装与初始化

OpenSpec 的安装非常简单，只需要一个命令：

```
# 全局安装 OpenSpec
npm install -g @fission-ai/openspec@latest

# 验证安装
openspec --version
```

安装完成后，在你的项目目录中进行初始化：

```
# 进入项目目录
cd your-project

# 初始化 OpenSpec
openspec init
```

在初始化过程中，OpenSpec 会询问你正在使用的 AI 工具

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

并根据选择自动生成相应的配置文件和技能。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

如果你想要更细粒度的控制，可以启用扩展模式。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### 第二步：配置项目上下文（可选）

`openspec/config.yaml` 是一个项目级配置文件，用于设置默认行为，并向 OpenSpec 注入项目特定的上下文信息。

这个文件通常会在初始化时自动创建，但你也可以手动添加：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**这个配置文件主要包含三个部分：**

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `schema` | string | 新变更默认使用的 schema（例如 `spec-driven` ） |
| `context` | string | 注入到所有 Artifact 指令中的项目上下文 |
| `rules` | object | 各类 Artifact 的生成规则 |

简单来说， `context` 用来告诉 AI 项目的技术背景和约定，而 `rules` 用来约束生成的文档结构。

#### 多语言支持

如果你希望 OpenSpec 生成 **中文文档** ，可以直接在 `context` 中说明：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

#### 初始化后的项目结构

完成初始化后，项目中会生成类似下面的目录结构：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### 第三步：实战演示

下面用一个简单的例子—— **为应用添加深色模式（Dark Mode）** ，完整演示 OpenSpec 的工作流程。

#### 创建提案

首先创建一个变更提案：

```
/opsx:propose add-dark-mode
```

执行后，OpenSpec 会为这个变更创建一组基础文件，包括 `proposal.md` 、规范差异（spec delta）以及任务清单。

**proposal.md** — 说明为什么要做这个功能：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**specs/ui/spec.md** — 描述新增的行为规范：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**tasks.md** — 将实现工作拆分为可执行任务：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

#### 实施开发

接下来开始实现：

```
/opsx:apply
```

OpenSpec 会按照 `tasks.md` 中的任务顺序逐步完成实现，例如：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

如果在实现过程中发现设计需要调整，也可以直接修改 `design.md` 或 `tasks.md` ，然后继续执行。

#### 验证实现

在归档之前，可以运行一次验证：

```
/opsx:verify
```

验证会检查实现是否与规范保持一致，例如：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**验证检查什么？**

| 维度 | 检查内容 |
| --- | --- |
| **完整性** | 所有任务是否完成，需求是否全部实现，关键场景是否覆盖 |
| **正确性** | 实现是否符合规范意图，边界情况是否得到处理 |
| **一致性** | 设计中的关键决策是否体现在代码结构中，整体实现模式是否一致 |

验证不会强制阻止归档，但可以帮助你提前发现一些容易遗漏的问题。

#### 归档变更

当功能完成并通过验证后，就可以归档这次变更：

```
/opsx:archive
```

归档时，OpenSpec 会自动完成几件事情：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

此时，这个功能的提案、设计、任务和规范差异都会被完整保存，而最终的规范也会合并到 `specs/` 中，成为系统当前状态的一部分。

#### 验证与审核

完成变更后，可以通过 OpenSpec 提供的工具检查和审核你的工作：

```
# 查看当前活跃的变更列表
openspec list

# 查看某个变更的详细信息
openspec show add-dark-mode

# 验证规范（Spec）格式是否正确
openspec validate add-dark-mode

# 打开交互式仪表板，浏览和管理所有变更
openspec view
```

## 进阶能力：自定义 Schema

当默认工作流无法满足团队需求时，OpenSpec 允许你创建完全自定义的 Schema。通过 Schema，你可以定义自己的 Artifact、生成模板以及它们之间的依赖关系。

### 为什么需要自定义

不同团队的开发节奏并不相同。例如：

- • **研究驱动型团队** ：需要先探索问题，再设计方案，最后实施
- • **快速迭代型团队** ：希望减少设计文档，直接从任务清单开始
- • **合规严格型团队** ：必须包含风险评估和审计记录

通过自定义 Schema，可以让 **工作流适应团队，而不是让团队适应工具** 。

### 最快方式：Fork 现有 Schema

从一个内置 Schema 开始是最快的：

```
# Fork spec-driven schema
openspec schema fork spec-driven my-workflow
```

执行后，会在项目中生成：

```
openspec/schemas/my-workflow/
├── schema.yaml
└── templates/
    ├── proposal.md
    ├── spec.md
    ├── design.md
    └── tasks.md
```

现在你可以修改 `schema.yaml` 调整工作流结构，或者编辑模板来调整 AI 生成内容。

### 从零创建 Schema

如果需要完全自定义，也可以直接创建一个新的 Schema。

交互式创建：

```
openspec schema init research-first
```

或者使用命令行参数：

```
openspec schema init rapid \
  --description "快速迭代工作流" \
  --artifacts "proposal,tasks" \
  --default
```

### Schema 结构解析

Schema 的核心是定义 **Artifact 以及它们之间的依赖关系** 。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**关键字段说明：**

| 字段 | 用途 |
| --- | --- |
| `id` | Artifact 的唯一标识 |
| `generates` | 生成的文件名（支持通配符如 `specs/**/*.md` ） |
| `template` | 使用的模板文件 |
| `instruction` | AI 生成内容时的提示 |
| `requires` | 依赖的 Artifact，决定创建顺序 |

### 验证你的 Schema

在正式使用之前，可以先验证 Schema：

```
openspec schema validate my-workflow
```

OpenSpec 会检查：

- • `schema.yaml` 是否合法
- • 引用的模板是否存在
- • 是否存在循环依赖
- • Artifact ID 是否有效

### 使用自定义 Schema

创建完成后，可以在创建变更时指定 Schema：

```
openspec new change feature --schema my-workflow
```

或者在 `config.yaml` 中设置为默认：

```
schema: my-workflow
```

### 调试 Schema 解析

如果不确定当前使用的是哪个 Schema，可以运行：

```
openspec schema which my-workflow
```

或者查看所有可用 Schema：

```
openspec schema which --all
```

输出类似：

```
Schema: my-workflow
Source: project
Path: /path/to/project/openspec/schemas/my-workflow
```

这可以帮助你确认 Schema 是来自：当前项目、用户目录还是 OpenSpec 内置。

> **注意** ：OpenSpec 也支持用户级 Schema（ `~/.local/share/openspec/schemas/` ）用于跨项目共享。但在团队开发中，更推荐使用项目级 Schema，因为它可以和代码一起进行版本控制。

## 最佳实践

### 何时更新 vs 新建变更

在使用 OpenSpec 时，一个常见问题是：

当需求发生变化时，应该 **继续更新当前变更** ，还是 **创建一个新的变更** ？

**可以用一个简单的判断思路：**

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**四个判断维度：**

| 维度 | 问题 | 适合更新 | 适合新建 |
| --- | --- | --- | --- |
| **意图** | 是否在解决同一个问题 | 目标没变，只是调整实现方式 | 目标已经改变 |
| **重叠度** | 代码或规范是否高度重叠 | 大部分实现仍然相同 | 涉及不同模块或功能 |
| **范围** | 工作范围是否明显变化 | 小幅扩展或收缩 | 已经变成另一项工作 |
| **独立性** | 原变更是否可以单独完成 | 原计划已经无法独立完成 | 原变更可以单独发布 |

**实际案例分析：**

**案例一：添加深色模式**

```
原始变更：add-dark-mode
- 添加浅色/深色主题切换

需求变化：“还要支持自定义主题颜色”
→ 判断：功能范围明显扩大
→ 决策：新建变更 add-custom-themes
```

**案例二：优化 API 性能**

```
原始变更：optimize-api-performance
- 添加数据库索引
- 优化查询语句

发现：“某些查询优化比预期复杂”
→ 判断：意图相同，只是实现方式调整
→ 决策：更新当前变更
```

**案例三：用户认证系统**

```
原始变更：add-user-auth
- 实现基础登录

产品调整：“OAuth 留到下一阶段”
→ 判断：原变更可以独立完成
→ 决策：归档 add-user-auth，再创建 add-oauth-auth
```

这个判断模型背后的原则其实很简单：

- • **更新变更** ：是为了保留已有的设计上下文
- • **新建变更** ：是为了保持变更边界清晰

从某种程度上说，这和我们在使用 **Git 分支** 时的思路是类似的。

### 团队采用指南

#### 1\. 先建立基本共识

让团队成员大致理解 SDD 和 OPSX 的思路。可以从一两个小项目或内部实践开始，先跑一遍完整流程，看看实际效果。

#### 2\. 一起整理项目配置

可以组织一次简单的讨论，把项目的技术栈、代码规范和开发约定写进 `config.yaml` 。这个过程本身也是一次对团队工程规范的梳理。

#### 3\. 先使用默认 Schema

刚开始不必急着自定义工作流，先用默认的 `spec-driven` 跑顺流程，熟悉基本的使用方式。

#### 4\. 再逐步沉淀自己的 Schema

当团队发现默认流程无法很好覆盖某些场景时（例如需要增加 `安全评审` 或 `数据模型设计` 等步骤），再基于现有 Schema 进行调整，逐步形成适合团队的工作流。

#### 5\. 把 Artifact 审查纳入开发流程

在进入代码实现之前，可以先对 `proposal` 和 `specs` 做一次简单评审，确保需求和设计已经基本明确，再开始编码。

### 常见误区

#### 1\. 流程过度复杂

OPSX 支持高度定制，但如果团队设计出过于繁琐的 Schema，让每个小改动都要经过大量 Artifact 和审批，就会失去它原本强调的轻量和灵活，最终又回到流程过重的问题。

#### 2\. 上下文配置不合理

`config.yaml` 里的 `context` 会直接影响 AI 的输出。如果里面包含大量无关、过时或互相矛盾的信息，反而会干扰生成结果。一般来说， `context` 应该尽量保持简洁和准确。

#### 3\. 忽视 Artifact 审查

如果完全依赖 AI 生成的 Artifact，不经过检查就直接进入 `apply` 阶段，风险会比较大。AI 可能误解需求，也可能漏掉边界情况。和代码一样， `proposal` 、 `specs` 等 Artifact 也需要经过人工审查。

#### 4\. 仓库管理混乱

随着开发推进， `changes/` 目录里可能会积累大量进行中的或已经废弃的变更。如果不定期整理，很容易变得混乱。比较好的做法是定期归档或清理，保持仓库结构清晰。

## 迁移指南

如果你之前使用的是旧版 OpenSpec 工作流，可以比较平滑地迁移到 OPSX。迁移过程不会影响已有的变更和规范，只是对工具结构进行更新，让工作流更加灵活。

### 如何开始迁移

运行 `openspec init` 或 `openspec update` 时，OpenSpec 会自动检测旧版本文件，并引导你完成清理和升级。

默认情况下：

- • 新安装会使用 `core` profile（ `propose` 、 `explore` 、 `apply` 、 `archive` ）
- • 旧项目迁移时，会根据现有配置生成 `custom` profile，尽量保留原来的工作方式

### 使用 openspec init

如果你希望重新初始化配置，或者添加新的 AI 工具，可以运行：

```
openspec init
```

`init` 命令会自动检测旧版本文件，并引导完成以下步骤：

1. 1\. 删除旧版斜杠命令目录
2. 2\. 从 `CLAUDE.md` 、 `AGENTS.md` 等文件中移除 OpenSpec 标记（保留你的原始内容）
3. 3\. 删除旧的 `openspec/AGENTS.md`
4. 4\. 在 `.claude/skills/` 中安装新的技能
5. 5\. 使用默认 schema 创建 `openspec/config.yaml`

### 使用 openspec update

如果只是想升级工具，而不重新初始化配置，可以运行：

```
openspec update
```

`update` 命令会：

- • 检测并清理旧版本遗留文件
- • 更新生成的命令和技能
- • 根据当前 profile 刷新相关配置

### 在脚本或 CI 中迁移

如果需要在自动化脚本或 CI 环境中执行迁移，可以使用：

```
openspec init --force --tools claude
```

`--force` 参数会跳过交互提示，自动执行清理和初始化步骤，适合批量或自动化迁移场景。

### 常见问题

#### Q1：在非交互环境中检测到旧版文件

这通常说明你是在 CI 或脚本环境中运行 OpenSpec。可以使用命令 `openspec init --force` 跳过交互提示。

#### Q2：迁移后命令没有出现

尝试重启你的 IDE。大多数工具只会在启动时扫描并加载 Skills。

#### Q3：规则中出现未知的 Artifact ID

通常是 `rules` 中的键名与当前 Schema 的 Artifact ID 不匹配。

可以检查：

- • `rules`: 中的名称是否与 Schema 定义一致
- • 使用 `openspec schemas --json` 命令查看 Schema 中定义的 Artifact。

#### Q4：配置没有生效

可以检查以下几点：

1. 1\. 配置文件路径是否为 `openspec/config.yaml` （不是 `.yml` ）
2. 2\. YAML 语法是否正确

配置修改后会立即生效，一般不需要重启工具。

#### Q5：上下文（Context）过大

`context` 的大小限制为 **50KB** 。

如果超出限制，可以：

- • 对内容进行摘要
- • 将详细文档放到外部文档中，然后在 `context` 中引用

#### Q6：project.md 没有被迁移

这是有意保留的，因为文件中可能包含用户自定义内容。建议手动检查其中有用的信息，并迁移到 `config.yaml` 中，然后再删除该文件。

### 写在最后

**OpenSpec** 不是要替你拿主意，而是为了帮你理清思路。它把开发中那些零散的直觉变成清晰、有据可查的逻辑。

软件开发说白了就是不断尝试。 **OpenSpec OPSX** 把流程拆解成一个个灵活的「小步快跑」，让你既能享受规范带来的安稳，又能随时根据新想法调头迭代，不用被死板的流程绑架。

如果你也想在下一个项目里让 AI 协作开发更高效、更可靠，不妨试试 **OpenSpec OPSX** 。

**Github 地址** ：https://github.com/Fission-AI/OpenSpec

**既然看到这里了，如果觉得有启发，随手点个赞、推荐、转发三连吧，你的支持是我持续分享干货的动力。**

推荐阅读： [规范驱动 AI 编程实战指南：OpenSpec vs Spec-Kit vs BMAD](https://mp.weixin.qq.com/s?__biz=MjM5NzA1NzMyOQ==&mid=2247486432&idx=1&sn=55741c3aac6a6f793e6d644aafabe467&scene=21#wechat_redirect)

**微信扫一扫赞赏作者**

AI编程 · 目录

继续滑动看下一个

技术极简主义

向上滑动看下一个