---
title: "Claude Code 进阶指南：为什么高手都在同时用这两套 CLAUDE.md？"
source: "https://mp.weixin.qq.com/s/XIq8_MdcNRDCdIjMa7-KPw"
author:
  - "[[Albert347]]"
published:
created: 2026-05-15
description: "在 AI Coding 这波浪潮里，很多人已经开始用 Claude Code 写项目。"
tags:
  - "clippings"
---
Albert347 *2026年4月21日 23:31*

在 AI Coding 这波浪潮里，很多人已经开始用 Claude Code 写项目。但很快你会发现一个问题：

> ❗为什么同样是 Claude，有的人像“高级工程师”，有的人却像“实习生”？

答案很简单—— **你怎么“驯化”它。今天我们拆解两个非常火的 CLAUDE.md 配置思路：**

- oh-my-claudecode（https://github.com/Yeachan-Heo/oh-my-claudecode）
- andrej-karpathy-skills（https://github.com/forrestchang/andrej-karpathy-skills/tree/main）

它们代表了两条完全不同的进化路线。

![[_resources/Claude Code 进阶指南：为什么高手都在同时用这两套 CLAUDE.md？/45195be1f52e7f8a48a0f5771ae90bb4_MD5.webp]]

---

## 一、两种思路，本质完全不同

### OMC：把 AI 变成“团队”，OMC 做的事情非常激进：

- 多 Agent 分工（规划 / 编码 / 验证）
- 自动 pipeline（plan → execute → verify）
- 工具链（AST / LSP / Python REPL）
- 状态管理 + workflow

👉 本质是一个：AI 工程操作系统（Agent OS）,一句话总结：不相信模型能力，用系统兜底

---

### Karpathy Skills：把 AI 变成“高级工程师”

它只有 4 条规则：

- Think before coding
- Simplicity first
- Surgical changes
- Goal-driven

没有 agent、没有工具、没有流程。它做的是，修正 AI 的“思维方式”，不改变系统，只优化模型行为

---

## 二、硬控制 vs 软约束

这两者最大的差异在“控制力”：

| 维度 | OMC | Karpathy |
| --- | --- | --- |
| 控制方式 | 系统流程 | Prompt规则 |
| 控制强度 | 极强（不可绕） | 较弱（可能失效） |
| 作用层 | 执行层 | 思考层 |

结论很直接：

- OMC = **强工程控制（deterministic）**
- Karpathy = **弱行为引导（probabilistic）**

---

## 三、怎么用

很多人踩过这两个坑，只用 OMC，一旦思考路线错了，AI 会“高效地产生垃圾代码”，而只用 Karpathy的话，没有 workflow和自动验证以及任务拆解，效率很低，OMC 决定效率上限，Karpathy 决定质量下限。最优解不是二选一，而是 **融合，下面是推荐结构：**

```
CLAUDE.md =  🧠 Karpathy（行为层）  + 📏 项目规范（约束层）  + ⚙️ OMC（执行层）对应关系：
```

| 层级 | 作用 |
| --- | --- |
| Karpathy | 控制“怎么思考” |
| 项目规则 | 控制“不能做什么” |
| OMC | 控制“怎么执行” |

这其实就是，目前所谓的 Harness Engineering，未来 AI 工程的核心竞争力，不再是模型：而是“控制系统”，让agent可以稳定高效输出才是构建真正“能用”的 AI 系统的关键。

大模型 · 目录

内容含AI生成图片

继续滑动看下一个

半路IT南

向上滑动看下一个