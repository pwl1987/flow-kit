---
title: "Claude 插件新组合：Superpowers + Ralph-Loop，效果大幅提升，让 AI 编程直接起飞"
source: "https://mp.weixin.qq.com/s/5Dngyi2AtTp6fFop853wSw"
author:
  - "[[知识姬 Mina]]"
published:
created: 2026-05-15
description: "这款 Superpowers + Ralph-Loop 插件组合为 Claude 带来了自动化的“超级循环”能力。它通过 Agent Team 机制让多个 AI 协作拆解任务、编写测试并循环优化，支持 BDD 流程。开发者只需输入目标，AI 即可在后台自主推进复杂工程，是大幅提升编程效率的开源利器"
tags:
  - "clippings"
---
知识姬 Mina *2026年3月18日 17:00*

**作者最新实验：效果大幅提升，结合 Agent Team 已接近成品**

技术大神FradSer 发的一条帖子：“superpowers + ralph-loop = superpowers@frad-dotclaude 👀”

然后补充说，最近实验发现这个组合让原本的 superpowers 效果变得更好了。加上之前 agent team 的支持，现在已经接近完成品。

它就是让 Claude 自己组建 agent 团队，自动拆任务、写测试、后台循环优化的超级工具。以前手动敲半天，现在 AI 自己干活，你只需要看结果。

![[_resources/Claude 插件新组合：Superpowers + Ralph-Loop，效果大幅提升，让 AI 编程直接起飞/afa324f68b10e08157bdae541aed8a53_MD5.webp]]

---

**Superpowers 插件到底是什么**

Superpowers 是 Claude 的一个插件，基于开源版本修改而来。核心改动是完全重写流程，引入 agent team 和 BDD（行为驱动开发）。

执行计划时，它会自动编排批次任务。如果适合，就创建 agent team 或者 subagent，让多个 AI 互相沟通协作。

之前 FradSer 还用它给 openclaw 项目提交 PR，20K+ 行代码大部分都是插件生成的。可见实力不一般。

现在加上 ralph-loop，循环更稳了。原本的 superpowers 已经很强，但这个组合让它真正接近“成品”。

---

**安装方法，两行命令搞定**

安装超级简单，不用折腾环境。

第一步，添加作者的插件市场：

`claude plugin marketplace add FradSer/dotclaude`

第二步，直接安装：

`claude plugin install superpowers@frad-dotclaude`

装完重启 Claude 或者刷新会话，就能用了。

如果你之前用过类似插件，这步熟悉得不能再熟悉。很多人反馈，装上后立刻就能进入超级循环模式。

---

**实战截图：Superpower Loop 真实运行**

来看 FradSer 分享的那张截图，超级直观。

终端里先跑了一个 Bash 脚本：

`set-up-superpower-loop.sh`

它启动 Red agent（红色代理）在后台写领域模型的失败测试。提示说：“I’ll wait for it to complete before starting the Green agent.”

紧接着大字显示：

**Superpower loop activated in this session!**

状态文件自动生成：`.claude/superpower-loop-task-1.local.md` ，里面已经有 39 行内容。

然后 Claude 开始读文件，检查进度。任务列表一目了然：

- • Testing domain models...（用了 3 分 9 秒，6.3k tokens）

下面是一长串子任务：

- • Implement Domain Models (Problem, Solution, Outcome) → blocked by #1
- • Test Repository Protocols (V2) → blocked by #2
- • Implement Repository Protocols + In-Memory → blocked by #3
- • Test Confidence Scoring → blocked by #4  
	... 还有 22 个 pending 任务

这套机制太聪明了：任务有依赖关系，前一个没完，后面的就等着。Red agent 写测试，Green agent 后面跟进实现，整个过程后台运行，你可以干别的。

---

**Agent Team + BDD 为啥这么强**

FradSer 之前就实现了接近 Claude Code 的 agent team。agent 之间能创建、认领任务，还能互相沟通，不是简单的 subagent。

他还提交了 PR，目前在 draft 阶段。superpowers 提供了大部分代码支持。

BDD 流程是另一个亮点：先基于 Cucumber 设计行为，再写测试用例。作者说，这比传统 TDD 更适合 AI 的 vibe coding。

加上 ralph-loop，循环激活后，长时间任务也不卡。截图里明明在跑复杂领域模型开发，却一切井井有条。

---

**实践操作步骤**

想自己试试？按下面顺序来：

1. 1\. 执行上面两行安装命令，确保插件加载成功。
2. 2\. 新开一个 Claude 会话，输入你的任务描述，比如“实现 Domain Models 并写测试”。
3. 3\. 插件自动创建小颗粒度 plan，并生成文档。
4. 4\. 执行 plan 时，superpower loop 立刻激活，agent 开始后台工作。
5. 5\. 用 ctrl+o 展开状态文件，随时查看进度。
6. 6\. 等 Red/Green agent 完成，review 输出代码和测试结果。
7. 7\. 如果有 blocked 任务，耐心等前置解锁就行。

整个过程非阻塞，codex 那种慢吞吞的 review 问题也解决了。作者的实验截图就是最好的案例——领域模型测试全自动推进。

---

**总结**

Superpowers + ralph-loop 这个组合，把 Claude 的 agent 能力推上新高度。安装简单，效果看得见，离真正好用的 AI 编程助手只差一步。

开发者朋友们，不妨现在就试试。装完后跑个小项目，你会发现编程方式彻底变了。

未来这样的 loop 和 team 只会越来越成熟，你准备好迎接了吗？

AI技术 · 目录

继续滑动看下一个

知识发电机

向上滑动看下一个