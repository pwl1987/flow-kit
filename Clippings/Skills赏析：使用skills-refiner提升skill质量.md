---
title: "Skills赏析：使用skills-refiner提升skill质量"
source: "https://mp.weixin.qq.com/s/681PyfKZjBVNtSjHMGwsfg"
author:
  - "[[TecDeTec]]"
published:
created: 2026-05-15
description: "skills-refiner是一个专门处理skill-creator盲区的Agent Skill评估工具，围绕六个维度展开：skill定位、机制、价值、风险、改进方向、可集成性。当需要把 skill 吸收到另一个 skill/skill仓库 时，哪些可以直接用，哪些需要重新设计，哪些应该放弃。"
tags:
  - "clippings"
---
TecDeTec *2026年4月2日 21:13*

## 导读

![[_resources/Skills赏析：使用skills-refiner提升skill质量/ec5db6dad2fc0a6410af0eedb42fe9d8_MD5.webp]]

Anthropic 在 Claude Agent SDK 中引入 Skill 体系时，做了一个在架构上值得细看的选择：每个 skill 是一个可独立加载的目录，包含 YAML frontmatter、Markdown 指令主体，以及按需加载的 references、scripts 和 templates。这个三层渐进式披露（progressive disclosure）架构，把上下文工程（context engineering）的核心判断落到了工具设计层面。

metadata 层只加载名称和描述，用于 Claude 判断当前请求是否与该 skill 相关；instructions 层在 skill 被激活时载入；resources 层在任务需要时按需调用。逻辑很简单：每个 token 都有成本，多余的加载会挤压对话历史和其他 skill 的空间，降低整体系统的可靠性。OpenAI 在 Custom GPT 和 Agent 体系中有类似的收敛趋势：单个 action 职责专一，接口用 OpenAPI schema 精确约束，而不是给 agent 留太多自由发挥的余地。

两个框架在核心约束上达成了相似的共识：skill 是能力的封装单位，不是 prompt 的堆砌。好的 skill 应该职责单一、边界清晰、可组合、可移植。

这些品质，是目前的测试测不出来的。

### 断言测试的结构性盲区

Anthropic 官方的 skill-creator 提供了创建-测试-迭代的完整循环：with-skill 与 baseline 的 A/B 对比、通过率和 token 消耗测量、基于断言的持续改进。它是功能验证层面设计完善的工具。

但断言测试有结构性盲区。一个 skill 可以通过所有测试用例，同时存在以下问题：

定位偏差：skill 的 description 是 Claude 决定何时激活它的唯一依据。描述过宽导致误触发，描述过窄导致该激活时被忽略。这两种情况在标准测试中通常不会暴露，因为测试预设了 skill 已经被正确激活。

上下文工程浪费：instructions 层包含了不必要的背景，把 Claude 已经内化的通用知识写了进去。Claude 足够聪明，能从冗余信息里提取有用部分，测试依然通过但这个冗余在生产环境里是真实的 context 成本。

低可移植性：skill 的核心逻辑依赖了特定工作流或工具调用链。在设计者自己的 repo 里运行完美，到了另一个人的环境里就失效。本地测试不会发现这个问题。

边界模糊：skill 的职责范围没有清晰界定，与同一 repo 里的其他 skill 存在重叠，或者对某些输入类型默默降级而不通知用户。

断言测试通过，证明 skill 在已知场景下按预期执行。它证明不了 skill 设计是否正确。这两个问题是不同的。

### skills-refiner 是什么

skills-refiner 是一个专门处理上述盲区的 Agent Skill 评估工具，通过 skills CLI 安装，在支持 skills 的 agent 环境（Claude Code、Cursor、Codex、OpenCode 等）中直接调用。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

skills-refiner 并不重复 skill-creator 的测试职责，而是补充测试覆盖不到的那一层：设计判断。

分析框架围绕六个维度展开：

- • 定位：skill 真正解决什么问题，边界在哪
- • 机制：哪些设计选择真正驱动了它的行为
- • 价值：什么是真正强的和可复用的，什么只是表面修饰
- • 风险：什么是脆弱的或难以维护的
- • 改进：具体的提升方向
- • 集成：当需要把 skill 吸收到另一个 skill/skill仓库 时，哪些可以直接用，哪些需要重新设计，哪些应该放弃。（这个隐藏技能相当好用😊）

它的工作分为两个阶段，对应三个核心动作。

第一阶段：诊断与精炼（Diagnose & Refine）

诊断的对象可以是一个 Skill 仓库、单个 skill、工作流框架，或者 eval 集。诊断不是打分，而是定位这个 skill 的真实状态：它真正解决什么问题、边界在哪、哪些设计选择有实质作用、哪些只是表面修饰、哪些是隐患。

精炼是诊断的直接下游。发现之后就要判断：哪些应当保留，哪些应当改进，哪些应当简化或重新划定范围，哪些应当去掉。这不是风格建议，是设计决策。skills-refiner 的名字里强调的是 refine，不是 audit，这两者的区别在于，精炼是目的导向的，refine的是结果，不只是列问题。

第二阶段：提取与整合（Extract & Integrate）

当给出目标 Skills 仓库（target\_repo）时，第二阶段启动。这一步关注的是这个Skill/Skills仓库对目标Skill/Skills仓库有什么价值——哪些部分可以直接采纳，哪些需要重新设计才能使用，哪些应当放弃，以及整合之后目标仓库的哪些部分面临最大的风险。

整合输出的是可操作的计划：最小可行整合路径和高价值增强方向。

### 目的决定标准

这个框架有一个不妥协的核心立场：评估工具应该知道自己在评估什么。

工程和工作流类的 skill 需要被审查结构严谨性、上下文工程质量、可维护性和跨仓可移植性；研究分析类的 skill 需要被审查推理质量和证据纪律；写作或教学类的 skill 需要被审查清晰度和输出质感。用工程标准去诊断一个创意写作 skill，结论通常是错的。目的决定标准，这不是方便的设计，是必要的设计。

同样的原则适用于 eval 集：当诊断对象是一个 eval 集时，skills-refiner 最关注的不是测试通过了多少，而是这个 eval 集有没有测到真正重要的东西——覆盖面是否触及了真实的风险面，断言是否能区分好答案和凑合的答案，边界场景有没有被遗漏。

### 证据优先原则

skills-refiner 的另一个核心原则是证据优先原则（evidence discipline）：分析必须区分三类判断：

- • 直接证据：文件中直接可读的内容
- • 合理推断：基于可见证据的有理由但非确定的判断
- • 未解决的不确定性：证据不足以支撑的问题，应明确标注而不是被自信的措辞掩盖。

这个区分，是针对 LLM 分析输出中一个普遍存在的问题而设计的：用事实的语气表达猜测，让读者无从判断哪些结论可信。在 skill 审计场景下问题更具体，一个 skill 可能只提供了部分文件，审计结论应该诚实地说清楚"我看到了什么，我推断了什么，我还不知道什么"，不能用宏观判断掩盖证据的局限。

### 与 skill-creator 的分工与协作

skill-creator 拥有创建、A/B 测试、断言迭代、description 优化和打包分发的完整循环。skills-refiner 在功能测试之后介入，回答另一类问题：这个 skill 设计是否正确？它的定位是否准确？它到另一个人的 repo 里还能工作吗？上下文工程有没有浪费？

典型路径：用 skill-creator 创建并迭代一个 skill，测试通过后用 skills-refiner 做设计级诊断与精炼，把明确的改进点带回 skill-creator 做下一轮迭代。当需要把一个现有 Skill 仓库的成果整合进另一个项目时，启动整合阶段，得到具体的提取和集成计划。

测试告诉你 skill 做了什么；诊断与精炼告诉你它设计得是否正确；整合告诉你它在新的系统里是否还成立。 三者覆盖了 skill 生命周期里功能测试触不到的全部设计层面。。

### 安装与使用

```
npx skills add yknothing/skills-refiner
```
```
# 诊断与精炼一个 Skill/Skill仓库
> 使用 \`skills-refiner\` 评估此 skill/skill 仓库

# 评估并整合到目标 repo
> 使用 \`skills-refiner\` 评估此 skill/skill仓库，并整合到目标 skill/skill 仓库 [skill/skill仓库名称] 中
```

```
# 用 skill-creator 创建了一个 skill，做设计层的诊断与优化
```

```
> I just finished creating this skill with skill-creator.> Use \`skills-refiner\` to audit the design quality —> focus on what the assertion tests might have missed.
```

### 边界与适用场景

skills-refiner 适合以下场景：

- 用 skill-creator 完成了一个 skill，想在分发前做设计层诊断与精炼
- 想把某个 Skills 仓库吸收进自己的项目，需要判断哪些部分可用、哪些需要改造、哪些应当放弃
- 维护多个 skill 的仓库，需要定期评估整体结构的健康程度
- 想评估一个 eval 集的质量——它有没有真正覆盖 skill 的风险面

它不生成 assertion 测试，不运行 A/B 对比，不优化 description 的触发精度，不负责打包分发。这些边界是刻意的，目的是把判断层的事做好，把执行层的事交给更合适的工具。

Agent Skill 体系走向成熟，需要两类工具：创建工具和评估工具。评估又分两个层次：功能测试和设计判断。skills-refiner 只做后者——诊断设计、精炼方向、规划整合。这是它定位的全部，也是它值得信赖的理由。

参考链接：https://github.com/yknothing/skills-refiner

更多优质信息，请关注！

🔥推荐阅读

#经验&技巧

[Claude Code负责人的干货分享：极简与并行](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247487020&idx=1&sn=c4f1a8075eea6dee6d54c8d1f9bd22d6&scene=21#wechat_redirect)

[如何用好AI大模型：苏格拉底式提问法](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247484418&idx=1&sn=c9a63801c07bc8c8cac23ce84fa608d3&scene=21#wechat_redirect)

[选择大模型的三个最关键因素](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486020&idx=1&sn=9438de82589c6ef09b1b33aaa3d8dede&scene=21#wechat_redirect)

\# Skills

[忘了龙虾🦞吧，skill-creator 2.0更值得关注](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247487152&idx=1&sn=76cae86ecbf7f4c3213492b8200983dc&scene=21#wechat_redirect)

[Claude Skills构建指南：步骤、局限性与实战案例](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486736&idx=1&sn=9afb9380cd4cc184e2aadaa01b7e3d47&scene=21#wechat_redirect)

[如何使用Claude Code快速提升前端设计？](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486705&idx=1&sn=ff01f037f9bfa70d6ec06ccdec6003f4&scene=21#wechat_redirect)

[一文讲透何时使用Claude Skills：与Projects、MCP、subagents的对比](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486656&idx=1&sn=e176ee5e2dc38a0e1238b3f617cfdf23&scene=21#wechat_redirect)

[Claude推出Agent Skills: 上下文工程的优雅实践](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486292&idx=1&sn=71eb78883abf1e2f6da679bc85520094&scene=21#wechat_redirect)

#vibecoding

[2026年，如何终结代码评审？](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247487143&idx=1&sn=a1938585074cce3d8cb051afd539c7da&scene=21#wechat_redirect)

[Andrej Karpathy对于AI编程的最新感悟](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247487094&idx=1&sn=a484423d27dbda68ff680e07cfbea669&scene=21#wechat_redirect)

[SPEC驱动开发真的那么好吗？未必](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247487031&idx=1&sn=9b558a7fc59641b0266f26c4e93faa48&scene=21#wechat_redirect)

[AK的焦虑是Vibe Coding的年度总结](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486995&idx=1&sn=7e71582d71a8cf9c266ab5ff7a790441&scene=21#wechat_redirect)

[一位资深工程师的Vibe之年](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486922&idx=1&sn=591503d1b61a2c941dd3233d443c8e7e&scene=21#wechat_redirect)

[OpenAI如何用Codex在28天内构建Sora Android版？](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486906&idx=1&sn=1882a13503116ba9ac13caceaa92139e&scene=21#wechat_redirect)

[什么编程语言更适合Vibe Coding？](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485517&idx=1&sn=e1ae86693d56834ab41b505c5ccb4fc7&scene=21#wechat_redirect)

[不要刻舟求剑，关于Vibe Coding的几点感想](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485006&idx=1&sn=19ff3c6bd200d6f94a82f695ae93864b&scene=21#wechat_redirect)

[我所了解的优秀系统设计（译）](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485640&idx=1&sn=566b0fbb36676f0811956c1fd5e1aeae&scene=21#wechat_redirect)

[没有银弹：软件工程的本质与偶然](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486030&idx=1&sn=4a0be1382cd23b7e61e244363c3bc41e&scene=21#wechat_redirect)

#Claude

[Claude 4.5 Opus神秘的“灵魂文档”](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486875&idx=1&sn=4d212e3503f9adb25bd9208d5576b796&scene=21#wechat_redirect)

[Claude针对长时运行Agent的高效策略](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486746&idx=1&sn=170841633f714fa17b621781f2aedc8b&scene=21#wechat_redirect)

[用CLAUDE.md文件为代码库定制 Claude Code](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486740&idx=1&sn=e654835126994ca550553edc599611d0&scene=21#wechat_redirect)

[Claude推出高级工具调用，迈向“智能编排”](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486723&idx=1&sn=e6c9725579e218d393deae1c2ebc27a5&scene=21#wechat_redirect)

#AI洞见

[a16z关于2026年AI应用的思考](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247487038&idx=1&sn=6cb36265114692f5935bdec546447b1c&scene=21#wechat_redirect)

[Jim Fan关于机器人领域的三个观点](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247487005&idx=1&sn=e2d7017fec4c05e7cebbab2fc1e6c9f1&scene=21#wechat_redirect)

[AI如何影响科技工作者的生产力](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486955&idx=1&sn=fe698036f28058530e1fdcda14e1ba14&scene=21#wechat_redirect)

[谷歌是否后悔发表了Transformer论文？](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486864&idx=1&sn=3bbc519d4971313f26d1b0f2cd0d4477&scene=21#wechat_redirect)

[OpenAI与谷歌、英伟达的星球大战，广告模式是必然选项？](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486836&idx=1&sn=ab82e4336aca026154490a52b987dcad&scene=21#wechat_redirect)

[Ilya最新访谈：从Scaling Law重回“研究时代”](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486731&idx=1&sn=63f9179a59e612b60d97db18166fe0ae&scene=21#wechat_redirect)

[OpenAI内部拉响“红色警报”](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486809&idx=1&sn=fb6cb20bb3594309a3df9ac98c1384a6&scene=21#wechat_redirect)

[AK最新演讲：我们处于软件3.0时代](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485221&idx=1&sn=c3943017566bc03984351d8578a8bd7f&scene=21#wechat_redirect)

[“AI-Ready”是AI提效和转型的前提](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485178&idx=1&sn=53e69c655d4c587211e69a774ac2c4fd&scene=21#wechat_redirect)

[AI原生时代，GUI转向“文本优先”的技术必然性](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485057&idx=1&sn=0ab49a9bd4f3ffbd7843acd4953a8636&scene=21#wechat_redirect)

[OpenAI关于人机关系的思考与实践](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485050&idx=1&sn=39268c00e593081927fe3ddbc7f39be8&scene=21#wechat_redirect)

[AI的下半场：从解决问题到定义问题](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247484717&idx=1&sn=cadcd05afb486c704963dc4ee95001c6&scene=21#wechat_redirect)

[谷歌：欢迎来到AI的经验时代](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247484692&idx=1&sn=3a05eec5ea6c9af31c3f4b2db0ea7a4a&scene=21#wechat_redirect)

#上下文工程

#模型&Agent

[OpenAI：坦白机制如何使AI保持诚实](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486865&idx=1&sn=38ccd731bafface63c588412e25fdb76&scene=21#wechat_redirect)

[近距离观察：打入Cursor内部的60天](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486564&idx=1&sn=5600505bc773cb8f4688538f280b7330&scene=21#wechat_redirect)

[StackOverflow 2025调查报告关键词：务实](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486717&idx=1&sn=44d0a3203c912836963e8f84e6928692&scene=21#wechat_redirect)

[30多位Founder眼中的Agentic AI落地现状](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486533&idx=1&sn=42b7753501f79d4fbabfa73a42b4e413&scene=21#wechat_redirect)

[创企Every的六位工程师的 AI 工作流程](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486481&idx=1&sn=85ca67791563343c01e9b2bd9b270015&scene=21#wechat_redirect)

[规范驱动开发(SDD)的哲学：代码服务于规范](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486449&idx=1&sn=01c63d079c75771a0552ee6888e7ed99&scene=21#wechat_redirect)

[AI编码悖论：既令人震撼，也同样愚蠢](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486427&idx=1&sn=b60f547fb8de8998b67ce7da0bf86e1e&scene=21#wechat_redirect)

[只有5%的AI Agent生产可用？](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486244&idx=1&sn=7823d2c3ed1f0eb8816766b26a36b3cc&scene=21#wechat_redirect)

[Workflow vs Agent 构建器，LangChain创始人的思考](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486213&idx=1&sn=e3be1a4eb2e251f9bcfc93f4b302a556&scene=21#wechat_redirect)

#产品&思维

[数据模型：产品的基因与格局](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486340&idx=1&sn=aff6602919cef44d29e9ca2e87431025&scene=21#wechat_redirect)

[RL之父萨顿：苦涩的教训](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247486406&idx=1&sn=4e1996d28f5d1caaa8cea390ee7ff6ff&scene=21#wechat_redirect)

[YC创始人：做那些无法规模化的事](https://mp.weixin.qq.com/s?__biz=MzAxNzk3NzM2Ng==&mid=2247485632&idx=1&sn=d42e44f00603841d543a06deceb5f8fc&scene=21#wechat_redirect)

#skills #agent #agentskills #automode #harness #skill-creator

**微信扫一扫赞赏作者**

技能&amp;工具 · 目录

作者提示: 个人观点，仅供参考

继续滑动看下一个

AI咖啡馆

向上滑动看下一个