---
title: "深度拆解 Superpowers 和 gstack：AI 编程真正的差距，不在模型"
source: "https://mp.weixin.qq.com/s/M3kjvObjgvBINvV68XX-ig"
author:
  - "[[JackGan]]"
published:
created: 2026-05-15
description: "它们都在重塑 AI 编程，但走的是两条完全不同的路。核心结论先说：gstack 和 Superpowers 都不是在让 AI 更聪明，而是在让 AI 编程更工程化。 这个判断，值不值得你继续读，看完你就知道了。"
tags:
  - "clippings"
---
JackGan *2026年5月8日 09:08*

它们都在重塑 AI 编程，但走的是两条完全不同的路。 **核心结论先说：gstack 和 Superpowers 都不是在让 AI 更聪明，而是在让 AI 编程更工程化。** 这个判断，值不值得你继续读，看完你就知道了。

---

📌 本文目录

▷ 一、AI 编程的"野路子"困境  
▷ 二、gstack：YC 总裁的虚拟工程团队  
▷ 三、Superpowers：85k stars 的 7 大命令体系  
▷ 四、两种路线的本质对比  
▷ 最终判断

---

## 一、AI 编程的"野路子"困境

先说清楚一件事： **为什么 AI 编程现在还是"野路子"？**

你的日常是不是这样的——

你写一个 prompt，Claude 生成代码。你复制粘贴，运行，有时候能用，有时候不能用。发现 bug，你再问 Claude，改一下，再运行，再问，再改……

循环 3-5 次，最后代码能跑了，但你心里清楚： **你不知道为什么它能跑，也不知道下次会不会崩。**

这就是问题所在。

![[_resources/深度拆解 Superpowers 和 gstack：AI 编程真正的差距，不在模型/0d2eccd67bb43fedfb47f5a0d3b96e11_MD5.webp]]

传统 AI 编程有 4 个致命缺陷：

**第一，没有上下文管理。** 每次问 Claude，它都是"无状态"的。你需要重复解释：项目背景是什么、已有代码怎么写的、约束条件是什么。说多了烦，说少了 Claude 瞎猜。

**第二，没有质量保证。** Claude 生成的代码可能有 bug，但没有自动化测试来发现。你只能靠手动跑、靠人眼review。bug 漏过去了，就带进生产了。

**第三，没有工程规范。** 代码风格不一致，这个文件缩进是 2，那个是 4；变量命名有时用 camelCase，有时用 snake\_case。没人管，没人知道该听谁的。

**第四，没有反馈循环。** 每个错误都是孤立的。这次踩了个坑，下次 Claude 大概率还会犯同样的错。你们俩在重复踩坑，谁也没学到谁。

**所以 AI 编程一直停留在"玩具"阶段——能跑，但不可靠；有意思，但不能当生产力。**

---

## 二、gstack：YC 总裁的虚拟工程团队

Garry Tan 的 gstack 出来的时候，我看了一圈，心想： **这哥们想清楚了。**

gstack 的核心理念是： **不要让 Claude 单独工作，给它一个虚拟团队。**

这个团队有 6 个角色：

| 角色 | 职责 | 示例 |
| --- | --- | --- |
| **Architect** | 系统设计 | 定义架构、API 设计 |
| **Developer** | 代码实现 | 编写功能代码 |
| **Reviewer** | 代码审查 | 检查质量、安全性 |
| **Tester** | 测试 | 编写测试用例 |
| **DevOps** | 部署 | CI/CD、配置管理 |
| **PM** | 项目管理 | 需求分析、优先级 |

当你需要某个功能时，你不是问"Claude"，你是问 **"Architect"** 或 **"Developer"** 。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

这就是关键。 **把 AI 从一个应答机器，变成了一个角色体系里的执行者。**

每个角色有明确的职责边界，角色之间可以互相审查和反馈。Developer 写完代码，Reviewer 来检查；Reviewer 觉得有问题，打回去重写；Tester 跑测试用例，发现 bug，Developer 接着修。

Claude 不再单打独斗，而是在一个结构化的虚拟工程团队里工作。

**这就像从"游击队"变成了"正规军"——不是人变多了，而是组织方式变了。**

---

## 三、Superpowers：85k stars 的 7 大命令体系

如果说 gstack 是 **组织结构** ，那 Superpowers 就是 **工作流** 。

Superpowers 是 Claude Code 的一个插件，GitHub 上 85k+ stars。它定义了 7 个核心命令，覆盖整个开发周期：

| # | 命令 | 触发时机 | 核心作用 |
| --- | --- | --- | --- |
| 1 | `brainstorming` | 需求探索 | 9 步流程，HARD-GATE 铁律 |
| 2 | `writing-plans` | 设计完成 | 任务拆解，2-5 分钟块 |
| 3 | `test-driven-development` | 开发阶段 | RED-GREEN-REFACTOR 循环 |
| 4 | `systematic-debugging` | 遇到 bug | 四阶段调试，先找根因 |
| 5 | `subagent-driven-development` | 复杂任务 | 独立会话并行 |
| 6 | `requesting-code-review` | 代码完成 | 子代理审查，三级处理 |
| 7 | `finishing-a-development-branch` | 准备合并 | 测试验证 + 四种合并方案 |

这 7 个命令厉害的地方在于：

**它们不是 7 个功能，而是 7 个有输入有输出的工作流程。**

拿 `brainstorming` 来说，它不是问"你觉得这个需求怎么样"，而是执行 9 步结构化流程，从需求澄清到约束确认到方案评估，每一步都有明确的产出。

再比如 `test-driven-development` ，它不是"顺便写点测试"，而是严格执行 RED-GREEN-REFACTOR 循环： **先写一个跑不通的测试（RED），再写刚好能让测试通过的代码（GREEN），最后重构优化（REFACTOR）** 。这套循环是 TDD 的精髓，但以前靠人记，现在靠命令驱动。

开发者可以按需调用，而不是"自由发挥"。想清楚了吗？调用 `writing-plans` 。代码写完了？调用 `requesting-code-review` 。准备合并了？调用 `finishing-a-development-branch` 。

**Superpowers 把 AI 编程从" freestyle" 变成了"剧本式开发"。**

---

## 四、两种路线的本质对比

gstack 和 Superpowers，长得很像，但基因不同。

**gstack = 组织结构。** 它解决的是"谁来做什么"的问题。你有一个虚拟团队，6 个角色各司其职，通过角色分配来管理 AI 的行为。

**Superpowers = 工作流。** 它解决的是"这件事怎么做"的问题。你有一个剧本，7 个命令按顺序执行，通过流程来保证质量。

**但它们的共同点，本质上只有一个：把 AI 编程从"聊天模式"转变为"工程模式"。**

对比一下：

**聊天模式：**

> 用户：帮我写个登录功能  
> Claude：好的，这是代码...  
> 用户：有 bug  
> Claude：改一下...  
> （无限循环）

**工程模式：**

> 用户：Architect，我需要一个登录功能  
> Architect：分析需求，设计 API，输出设计文档  
> Developer：按设计实现代码  
> Tester：编写测试用例  
> Reviewer：审查代码质量  
> DevOps：配置部署流程

区别在哪里？

- • 有明确的流程
- • 有质量保证
- • 有反馈循环
- • 有文档和规范

**不是 AI 更强了，是工程化把 AI 的不稳定因素约束住了。**

---

## 最终判断

**✅ 做得好的**

- • 把 AI 从"聊天机器人"变成"工程参与者"，真正解决了可靠性问题
- • 两种路线各有千秋：gstack 适合团队协作，Superpowers 适合个人快速迭代
- • 覆盖完整开发周期，从需求到合并，有体系感

**❌ 还不够的**

- • 学习成本不低，6 个角色或 7 个命令都需要时间消化
- • gstack 的角色切换需要工具支持，配置起来有门槛
- • Superpowers 对 Claude Code 有依赖，不是全平台通用

**适合谁？**

- • **gstack** ：工程化需求强的团队，有明确的代码规范和流程意识
- • **Superpowers** ：个人开发者或小团队，想快速迭代但需要质量兜底

---

## 最后说几句

说了这么多 AI 编程有多厉害、有多工程化。

但我最后想说的是： **工具能做到的，终究是工具的边界。**

gstack 和 Superpowers 再强，解决的是"AI 怎么更好地干活"这个问题。但"干什么活"、"为什么干"、"干完之后往哪走"——这些，始终是你的问题。

AI 可以帮你写代码，但它不能帮你决定代码要解决什么问题。  
AI 可以帮你 review 代码，但它不能替你做产品决策。  
AI 可以帮你跑测试，但它不能替你理解用户。

**那些它做不到的，才是你真正的价值所在。**

所以，用好这些工具，但别把判断权一并交出去。

**微信扫一扫赞赏作者**

继续滑动看下一个

2077硅基趣谈

向上滑动看下一个