---
title: "谷歌开源一个神级 Skill，斩获 23000+ GitHub Star！"
source: "https://mp.weixin.qq.com/s/DiRKOSV7BPkWaGUxPnLqyQ"
author:
  - "[[小 G]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
小 G *2026年4月26日 17:05*

AI 编程工具的能力进化速度，远超所有人预期，当前已经能快速帮我们完成众多开发任务。

但很快大家便发现一个问题，模型能力越强，AI 走捷径的毛病越明显，拿到任务就一股脑按指令往前冲。

通常不会考虑项目长期的稳定性，也顾不上后续的迭代维护，这恰恰是现实中初级开发者与资深工程师的差距。

为了治好这个毛病，谷歌 Gemini 团队主管 Addy Osmani 开源了 **Agent Skills** 。

开源后不久，便拿下 23000+ GitHub Star，目前还在持续上涨。

![[_resources/谷歌开源一个神级 Skill，斩获 23000+ GitHub Star！/6a681c5fd8c943ebf244fcced94f640a_MD5.webp]]

它把资深工程师的工作流和开发规范，封装成了 Skills 技能包，让 AI 在每个开发阶段都能保持一致的高标准。

这些技能并非凭空编造出来，背后大多源自 《Software Engineering at Google》，这本书主要讲的是 Google 内部做大规模软件工程的那套方法论。

![[_resources/谷歌开源一个神级 Skill，斩获 23000+ GitHub Star！/a6dd3b20c41bb5d2ca28a43451a481a2_MD5.webp]]

Agent Skills 正是围绕软件开发生命周期设计，包含了 20 个 Skill、7 个 Slash 命令，外加 3 个 Agent 人设。

覆盖了定义、规划、构建、验证、评审、发布六个阶段的完整开发链路。

在 Claude Code 里装上后，我们能用

```
/spec
```
做需求梳理，
```
/plan
```

接着

```
/build
```
增量实现、
```
/test
```
跑测试、
```
/review
```
做评审，最后
```
/ship
```
走上线，将整个开发节奏串联起来。

![image-20260422203538059](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

另外三个预设的 Agent 人设也值得一提，分别是 code-reviewer、test-engineer、security-auditor。

```
/ship
```
部署上线时，它们会并行开工，分别出具代码评审、测试、安全三份报告，最后给出是否可以上线的结论。

相当于项目在上线前，对这次版本的修改做一次全面检查，包括代码预览、单元测试、以及安全评估。

![image-20260422203653384](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

看到这里，可能大家开始有疑问，Agent Skills 跟 Spec Kit、Superpowers 区别在哪。

其实三者目标相似，都是给 AI 编程立规矩，但切入角度各有侧重。

Spec Kit 的思路是「先写清楚再动手」，把需求、计划、任务拆解都写成规范文档，让 AI 按文档办事。

Superpowers 更像是一整套开发流水线，把聊需求、写计划、写测试、代码互查这些环节全部自动串起来，让 AI 一接到活就能按部就班走完。

Agent Skills 则把 Google 资深工程师的工作习惯，拆成 20 个可组合的 Skill，约束 AI 每一步都按工程规范干活。

一句话总结，Spec Kit 用文档定 AI，Superpowers 用流程带 AI，Agent Skills 用纪律管 AI。

![image-20260422203743631](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

具体选哪个，就看各自的使用场景。

最后讲下 Agent Skills 上手方式，在 Claude Code 里两行命令即可搞定。

```bash
/plugin marketplace add addyosmani/agent-skills/plugin install agent-skills@addy-agent-skills
```

如果用的是 Cursor，把对应的 SKILL.md 复制到

```
.cursor/rules/
```

另外还支持 Gemini CLI、Windsurf、GitHub Copilot、Codex 等主流 AI 编程工具，项目 docs 目录里都有对应的接入指南。

![image-20260422203806877](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### 写在最后

虽然模型的编程能力在逐渐增强，但 Spec Kit、Superpowers、Agent Skills 这类项目依然接连出现。

说明大家对 AI 写出来的代码到底能不能放心交付到生产环境，心里还是没底。

毕竟对团队来说，一份能稳定交付、可持续迭代的代码，远比一段想都不想就让 AI 生成的代码有价值。

Agent Skills 的意义也正在于此。

它没有试图把 AI 变得更聪明，而是把资深工程师那股「稳、准、狠」的工程习惯沉淀下来，让 AI 在每个开发环节都有规可循。

对每天都在跟 AI 协作写代码的我们来说，这种工具远比模型升级来得更实在。

GitHub 项目地址：https://github.com/addyosmani/agent-skills

今天的分享到此结束，感谢大家抽空阅读，我们下期再见，Respect！

AI · 目录

继续滑动看下一个

GitHubDaily

向上滑动看下一个