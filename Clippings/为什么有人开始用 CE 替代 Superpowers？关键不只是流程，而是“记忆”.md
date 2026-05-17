---
title: "为什么有人开始用 CE 替代 Superpowers？关键不只是流程，而是“记忆”"
source: "https://mp.weixin.qq.com/s/D_ZXAbL9IhYyhTGBvu6akQ"
author:
  - "[[探索与发现-Ultra]]"
published:
created: 2026-05-15
description: "为什么有人开始用 CE 替代 Superpowers？关键不只是流程，而是“记忆”\x0a如果你最近一直在折腾 C"
tags:
  - "clippings"
---
探索与发现-Ultra *2026年4月2日 16:33*

## 为什么有人开始用 CE 替代 Superpowers？关键不只是流程，而是“记忆”

如果你最近一直在折腾 Claude Code 的各种 skill，大概率已经听过两个名字：

• `gstack`

• `Superpowers`

前者是 `@garrytan` 那套很出名的“一个人模拟整支团队”的工作流，后者则几乎成了很多人装上 Claude Code 后的标配。

但 Jason Zuo 这篇 X 长文给了一个更有意思的判断：

**真正值得认真看的，不只是 `gstack` 和 `Superpowers` ，而是 `Compound Engineering` （CE）为什么开始让一些重度用户愿意替换掉 `Superpowers` 。**

而它最关键的差异，不只是 plan 更深、review 更多，而是多了一层很多 Agent 工作流一直没补上的东西：

**把每次 session 里的经验，变成未来还能被重新搜到、重新利用的项目记忆。**

![[_resources/为什么有人开始用 CE 替代 Superpowers？关键不只是流程，而是“记忆”/723fa39c295a8cf5b8277cd99effe074_MD5.webp]]

## 1\. 先别急着比较 skill，先看 Anthropic 提出的 harness 框架

原文的切入点很好。

作者没有上来就直接说“谁更强”，而是先借 Anthropic 两篇工程博客，给了一个更通用的框架。

在这套 harness 里，至少有四个关键角色：

1 `Planner agent` ：把大任务拆成 feature list

2 `Coding agent` ：一次只做一个 feature

3 `Evaluator agent` ：独立审查，不让 builder 给自己打分

4 `跨 session 桥接` ：把上下文从一个 session 传到下一个 session

原文特别强调的一点是： **generator 和 evaluator 分开，效果会明显提升。**

也就是说，真正成熟的 Agent 工作流，不只是“能不能写代码”，而是有没有把规划、执行、审查和上下文延续分成不同层。

![Anthropic harness 框架相关配图](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

## 2\. 用这个框架回头看，gstack 的强项其实很清楚

作者认为， `gstack` 最值钱的地方，是它在 harness 里补上了两个非常关键的角色：

• `Planner`

• `浏览器端 Evaluator`

像：

• `/plan-ceo-review`

• `/plan-eng-review`

本质上就是从产品和架构两个层面给需求把关。

而 `/qa` 打开浏览器去测 staging URL，这件事更重要，因为它不再是让 Agent 在脑内假想“应该没问题”，而是像真实用户一样去验证。

原文对 gstack 的评价其实很明确：

•planning 很强

•浏览器 QA 很强

•在决策层和测试层依然非常值钱

但它并不打算把自己做成完整全流程。

也就是说，gstack 很强，但它更像一把锋利的刀，不是整套厨房。

## 3\. Superpowers 为什么还不够

原文并没有贬低 `Superpowers` 。

相反，它先承认了这套 workflow 的历史地位：

• `brainstorm -> plan -> execute -> review` 这条线，帮很多人第一次从“跟 AI 瞎聊”升级到“有流程地用 AI”

• `120k stars` 已经足够说明它的质量

•它也已经做了一定程度的 generator-evaluator 分离

但作者之所以开始转向 CE，核心不是因为 Superpowers 不好，而是因为 CE 在三个层面做得更深。

### 第一层：Plan 更深

`Superpowers` 大多还是在当前 context 里写 plan。

而 `CE` 的 `/ce:plan` 会并行派出 research agents，去：

•搜项目历史经验

•扫 codebase pattern

•读 git history

这意味着它写出来的 plan，不只基于“你刚刚说了什么”，还基于“这个项目过去到底发生过什么”。

### 第二层：Review 更细

`Superpowers` 的 reviewer 数量有限。

而 CE 会拉起 6 到 15 个专项 reviewer 并行，从 correctness、security、performance、testing、maintainability 到 adversarial 分别出报告。

这不是 reviewer 数量游戏，而是把“审查”这件事进一步拆成专科。

### 第三层，也是最关键的一层：它能积累知识

原文说得非常直接：

**Superpowers 做完就完了，下一个 session 还是从零开始。**

这才是作者真正决定替换它的原因。

## 4\. CE 最值钱的，不是 /ce:plan，而是 /ce:compound

这是整篇文章最值得看的地方。

原文认为，Anthropic 的 harness 里虽然已经有 `progress file` 这种跨 session 桥接方式，但它本质上还是线性的：

•session A 给 session B 交接

•session B 接着干

这更像备忘录。

而 CE 的 `/ce:compound` 做的是另一件事。

每次你做完一个功能，或者真正解决了一个 bug，它会并行拉起三个 agent：

1 `Context Analyzer`

2 `Solution Extractor`

3 `Related Docs Finder`

最后把这次 session 里真正有价值的东西，写进 `docs/solutions/` 。

而且写进去的不是一堆流水账，而是结构化知识，例如：

•Problem

•What Didn't Work

•Solution

•Prevention

原文对这个设计有一个非常到位的总结：

•Anthropic 的 progress file 解决的是连续性

•CE 的 `docs/solutions/` 解决的是积累性

一个是“上一班交给下一班”。

另一个是“所有未来的班次都能查历史知识库”。

这就是为什么作者会说， `compound` 其实是在把每次工作产出的价值，从“只留下代码”升级到“同时留下未来还能复用的知识”。

## 5\. 这其实是在逼近“永续型 Agent”

原文里有一句判断我很认同。

所谓“永续” Agent，核心并不是 24 小时一直工作，而是：

•持续工作

•持续沉淀

•持续避免重复错误

•持续减少重复浪费

如果一个 Agent 每天帮你写代码、修 bug、跑测试，但做完之后所有经验都散落在 session 里，下次还要重踩一遍，那它顶多只是高效劳动力。

只有当这些经验会被系统化保留下来，并在未来 planning 阶段再次被自动检索出来，它才开始接近“会自我积累”的状态。

这就是原文为什么把 `compound` 看得比很多 flashy 的 workflow 都更重要。

## 6\. 自动化 compound 这件事，作者也没有讲得太理想化

原文还提了一个很实际的问题：

如果 `compound` 这么重要，那是不是应该每个 session 都自动跑？

作者的答案是否定的。

因为不是每个 session 都值得沉淀知识。

比如：

•改一个 typo

•调一处 CSS

•跑一次 migration

这些事情通常不值得写进项目知识库。

如果什么都自动沉淀，最后 `docs/solutions/` 只会被低价值信息淹没，反而让真正有用的经验更难被检索到。

但问题又来了：人会忘记手动 compound。

所以作者提出了一个折中的方向：

做一个 `compound janitor` ，每天回头扫当天的 session 和 git diff，只把真正有价值的那些任务沉淀下来。

这个想法很像人类的复盘机制，也很像知识管理里的定期 review。

## 7\. 最终答案不是“只选一个”，而是 gstack + CE

原文最后的结论，并不是简单说“CE 吊打 Superpowers”。

它更像是把不同工具重新放回 Anthropic 的 harness 框架里，各自归位。

作者给出的组合是：

• `gstack` 负责：

• `/plan-ceo-review`

• `/plan-eng-review`

• `/qa`

• `CE` 负责：

• `/ce:plan`

• `/ce:work`

• `/ce:review`

• `/ce:compound`

一句话总结就是：

**gstack 负责“做不做”和“真实测”，CE 负责“怎么做”“做得好不好”和“记住”。**

这也是为什么作者认为：

• `Superpowers` 依然是很好的入门工作流

•但当你进入更深的项目协作阶段，CE 的架构深度会更占优势

•尤其是 `compound` 这层，是 Superpowers 目前完全没有补上的

![gstack + CE 组合示意配图](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

## 结语

如果把这篇长文压缩成一句话，我觉得它真正讲的是：

**AI Agent 工作流接下来真正拉开差距的，不只是 planning、execution 和 review，而是有没有把“这次做事学到的东西”沉淀成下次还能复用的项目记忆。**

这也是为什么原文会把 CE 看得这么重。

很多 workflow 都在解决“这次怎么做完”，但 `compound` 解决的是“做完之后，这次学到的东西去哪了”。

如果答案还是“散落在历史 session 里”，那 Agent 再勤奋，也还是会重复交学费。

## 来源

来源作者：Jason Zuo  
来源平台：X  
原文链接：https://x.com/xxxjzuo/status/2038086450013495554  
说明：原文为中文，已按公众号阅读习惯整理，保留原文核心结构与关键配图

继续滑动看下一个

探索与发现-Ultra

向上滑动看下一个