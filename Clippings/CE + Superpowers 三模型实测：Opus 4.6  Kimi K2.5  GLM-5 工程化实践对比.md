---
title: "CE + Superpowers 三模型实测：Opus 4.6 / Kimi K2.5 / GLM-5 工程化实践对比"
source: "https://mp.weixin.qq.com/s/jMMMNz0tccjMIzNaww1xiQ"
author:
  - "[[Lex 陆徐洲]]"
published:
created: 2026-05-15
description: "CE的知识沉淀是团队复利的一种手段。"
tags:
  - "clippings"
---
Lex 陆徐洲 *2026年4月2日 07:50*

大家好，我是陆徐洲。

上篇 Superpowers 实战里我提过一个问题：TDD 阶段尽管严格按照约束做了E2E的测试，但是实际上还会存在代码跑不通的情况。

当时的结论是需要引入外部手段做 code review。

最近看到一个框架，叫 Compound Engineering（下面简称 CE）。核心理念是"每次开发都让下一次更容易"， review 阶段能同时启动 12 个子代理从安全、性能、架构等维度并行审查代码，另外还有一个知识沉淀机制，把踩过的坑结构化地存下来，下次 plan 时自动引用。

恰好补上了 Superpowers 的短板。这篇记录的是我把两者组合起来，用三个模型跑同一个全栈项目的完整过程。

![[_resources/CE + Superpowers 三模型实测：Opus 4.6  Kimi K2.5  GLM-5 工程化实践对比/bcd1c08a8209f10b96df5036abc770a8_MD5.webp]]

先说清楚两者的关系。很多人在 X 上讨论"CE 能不能替代 Superpowers"，superpowers 的 GitHub 上甚至有个 Issue #230 专门讨论这个，16 个 upvote。

我的结论是： **层次不同，不构成替代。**

简单说就是：Superpowers 管纪律，CE 管能力。

Superpowers 是 Harness 层，通过 hooks 和技能约束强制 AI 遵守工程纪律。CE 是 Skill Pack 层，提供多代理 review 和知识沉淀的能力，所有约束是 prompt 级别的建议，模型理论上可以不听。

所以我设计的组合方式是各取所长：需求探索用 Superpowers 的 brainstorming，技术计划用 CE 的 plan，代码实现用 Superpowers 的 TDD，代码审查用 CE 的 review，知识沉淀用 CE 的 compound，用claude.md做流程约束。

说回模型选择。过年的时候我写过一篇测评，对比了国内主流模型在相同编码任务上的表现。当时有读者反馈说 GLM 没有在 Claude Code 环境下测试不公平。

[Opus4.6 6分钟一次成功，国产模型最慢30分钟：四大模型Claude Code编程实测](https://mp.weixin.qq.com/s?__biz=MzU0MDcyMDQ0Nw==&mid=2247483878&idx=1&sn=55bf8b365c34f546c39e58ff0731f040&scene=21#wechat_redirect)

本来我是想等到deepseekv4出了再把glm5、kimik2.5和deepseekv4比较一遍，毕竟kimik2.5和ds是个人认为比较强的模型，可惜迟迟等不到v4发布。

这次我找到了一个统一方案。七牛云的 MaaS 平台同时支持海内外 130+ 大模型，包括 Claude Opus 4.6、GLM-5、Kimi K2.5。更关键的是，配置方式完全一样，三个模型只需要改一个字段。

```json
// Claude Opus 4.6{  "env": {    "ANTHROPIC_API_KEY": "你的七牛云 API Key",    "ANTHROPIC_BASE_URL": "https://api.qnaigc.com",    "ANTHROPIC_MODEL": "claude-4.6-opus"  }}
```

一个平台、一个 Key、改一行配置就能切换模型。GLM-5 的模型 ID 是 `z-ai/glm-5` ，Kimi K2.5 是 `moonshotai/kimi-k2.5` ，注意带命名空间前缀。

任务是从零构建一个 AI 知识库问答系统：FastAPI 后端，ChromaDB 向量存储，支持文本上传、切分、embedding、多轮对话，有简单的 Web 界面。三个模型跑完全相同的需求描述，走完全相同的 CE + Superpowers 全流程。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

先说结论。 **在计划阶段，Kimi 略优于 GLM-5，但两者跟 Opus 4.6 的差距仍然明显。**

Opus 的 brainstorming 阶段提问方式是从全局到局部。它先问你系统的核心目标和用户群体是什么，然后逐步深入到技术选型、性能要求、安全边界。每个追问都在收窄范围，最终落到可执行的边界条件上。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

plan 阶段的产出也明显不同。Opus 的方案有明确的风险分析、分阶段实施路径和回退策略。

反观 Kimi 这边。brainstorming 阶段的提问模式跟 Opus 比较像，也是从全局切入，会主动问"你要不要支持多租户""安全等级要到什么程度"。

架构设计质量也不错。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

坑在后面。CE 的 plan review 和 code review 两个阶段，Kimi 都跳过了。不是失败，是它直接无视了外部 skill 的指令，自己往下走了。我当时还以为是配置有问题，排查了半天才确认是它自己跳过的。需要手动喊停，明确告诉它"现在执行 /ce:review"，它才会去做。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

再看 GLM-5。区别最先体现在 brainstorming 阶段，它的提问方式是从局部到整体，先问你用什么数据库、用什么框架，再往上问业务逻辑。跟 Opus 和 Kimi 的思路方向相反。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

优点是 GLM-5 的外部指令遵循明显比 Kimi 好。CE 的 plan review 和 code review 阶段都按照 skill 要求执行了，没有自行跳过。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

就是吧，设计方案的深度和 Opus 差距比较大，架构图的层次感和风险分析的细致程度都弱一截。

简单总结一下三个模型在计划阶段的表现：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

我跑完的体感是，GLM-5 针对 Claude 的优化可能主要在基础对话层面，复杂的多步规划差距还在。Kimi K2.5 的推理模式跟 Opus 接近，架构设计也不错，卡就卡在指令遵循上。

话说回来，Kimi 和 GLM-5 有一个 Opus 给不了的优势： **便宜** 。国内用户直接用，延迟低，适合日常开发中不那么关键的阶段。

接下来重点说 Opus 4.6 的完整流程，这是理想状态下 CE 和 Superpowers 结合使用的样子。brainstorming 和 plan 阶段前面已经说过，直接跳到 TDD。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

Superpowers 的 TDD 严格执行红绿重构循环。先写测试让它失败（红灯），再写最小实现让测试通过（绿灯），最后重构。这个纪律在 Opus 上执行得很完整。

TDD 完成后进入 CE 的多代理并行 review。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

12 个子代理同时启动，从安全、性能、架构、可维护性等维度审查代码。

然后是 CE 最独特的阶段：知识沉淀。

review 完成后执行 `/ce:compound` ，它会启动 5 个子代理，自动提取本轮踩过的坑、用到的模式、review 的关键发现，结构化地存到 `docs/solutions/` 目录下。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

比如这次产出了一个 `fastapi-chromadb-production-patterns.md` ，里面记录了 ChromaDB 非单例的问题、文件名 path traversal 的安全风险、重复上传的竞态条件等。

这些不是 AI 凭空生成的最佳实践，是从这次实际开发中提炼出来的一手经验。

关键是，这些经验存下来不是摆设。

知识沉淀的价值要在第二轮才能验证。我在第一轮代码的基础上增加一个新需求：给知识库加 PDF 上传支持，包括扫描版 PDF 的 OCR。

进入 plan 阶段时，CE 的 learnings-researcher 子代理自动搜索了 `docs/solutions/` 目录，找到了第一轮留下的文件。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

plan 文档里直接引用了上轮的已知问题："ChromaDB 非单例、filename 未做 path traversal 清理、重复上传有竞态。"

更关键的是设计层面的影响。新增的 OCR 模块主动采用了单例模式，因为上一轮 compound 记录了 ChromaDB 非单例是个问题。它还在"不在范围内"部分明确标注了"ChromaDB 单例化是已知技术债，不在此次范围"。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

这不是 AI 读代码就能推断出来的。这是上一轮记录下来的经验在影响设计决策。

跑完两轮，这里面最让我印象深刻的不是某个阶段跑得多漂亮，是第二轮 plan 阶段那一刻。它自动引用了第一轮的经验，设计方案里主动避开了已知的坑，review 发现数也明显下降。

不是"AI 变聪明了"，是知识沉淀机制在工作。

说下费用。跑完整个实验，Opus 4.6 的 token 消耗确实猛，尤其是 CE review 阶段 12 个代理并行，单次 review 就烧掉大量 token。钱包肉疼。

这就是为什么我还是会用 Kimi 和 GLM-5。brainstorming、TDD 这些不需要多代理并行的阶段，国产模型完全够用，费用低一个数量级。

我试了下七牛云上其他模型也能用，DeepSeek、Qwen、Gemini 都在上面，配置方式一样。完整模型列表：https://s.qiniu.com/iAviMv

需要配置国外模型的也可以在这个页面上找到对应的model\_id: https://sufy.com/zh-CN/services/ai-inference/models

对于想自己搭 Agent 工作流的读者，七牛云还有 66 元/年的轻量服务器，配合 OpenClaw 可以跑自己的编排系统。这是活动专题页 https://s.qiniu.com/vy2Q32

CE 插件原生支持转换到 OpenClaw 平台：

```nginx
bunx @every-env/compound-plugin install compound-engineering --to openclaw
```

CE + Superpowers 的组合也有缺陷。CE 光是装上不用就吃 36k token，多代理并行的费用也是实打实的。小任务、改 bug，完全不需要走全流程。

关键是用对场景。正经的功能开发，尤其是需要多轮迭代的项目，知识沉淀带来的加速效果是真实的。第一轮踩过的坑，第二轮 plan 时自动被引用，不需要你记，也不需要你翻记录。

国产模型在设计阶段跟 Opus 4.6 确实有差距，好在它们便宜、延迟低、国内直连，日常开发中混着用是最务实的选择。

很多时候，不是 AI 能力不够，是我们没给它搭好记忆和约束的架子。

最后放一下七牛云的注册链接：https://s.qiniu.com/URV3qe

新用户送 1000 万 token，参与活动可以免费拿最多百亿Token，跑完这篇文章里的整个实验绰绰有余

我是陆徐洲，一家 LIMS 公司的 AI 算法负责人。关注我，让我们一起在 AI 落地实践的路上，走得更远。

感谢您阅读我的文章。有任何关于AI提效或者工程落地实践方面的问题都可以加我微信，交个朋友，一起探讨，共同进步。

AI工程化实践 · 目录

作者提示: 个人观点，仅供参考

继续滑动看下一个

硅基鹿鸣

向上滑动看下一个