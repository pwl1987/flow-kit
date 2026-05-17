---
title: "5个Claude Code神级Skill：第三个让我每天多睡1小时"
source: "https://mp.weixin.qq.com/s/-BuLSPZbxUwjSevjAYrXsg"
author:
  - "[[智物社TECH]]"
published:
created: 2026-05-15
description: "装了30个Claude Code Skill，删到只剩这5个。说个真实的教训。我之前装Skill跟集邮一样，"
tags:
  - "clippings"
---
智物社TECH *2026年4月17日 08:55*

装了30个Claude Code Skill，删到只剩这5个。

说个真实的教训。我之前装Skill跟集邮一样，看到什么新鲜的都往里塞。结果呢？一半跟自带功能重复，剩下一半用一次就忘了。真正每天在用的，一个都没有。

后来我想通了，真正值得装的Skill只有三种：解决痛点的、每次会话都用的、不需要手动维护的。

这5个Skill有一个共同点，都在解决Claude Code的原生缺陷。废话多、记不住、论文难读、上下文不足、测试遗漏。

---

## Caveman：AI输出砍半，Token费用直接降75%

第一个必须装的是Caveman。

Claude Code有个问题，输出太啰嗦了。问一个技术问题，它给你写一大段解释，200字起步。实际上你只需要那个核心答案，废话全在看。

Caveman就是来解决这个的。同样的技术问题，普通Claude输出69 tokens，Caveman模式输出19 tokens，节省75%。

看个对比。普通Claude说，The reason your React component is re-rendering is likely because you're creating a new object reference on each render cycle. When you pass an inline object as a prop, React's shallow comparison sees it as a different object every time, which triggers a re-render. I'd recommend using useMemo to memoize the object。

Caveman模式说，New object ref each render. Inline object prop = new ref = re-render. Wrap in useMemo。

意思一样，差了50个字。

关键是什么？技术准确性不变。去掉的只是废话，技术内容100%保留。这个有论文背书，不是瞎压缩。

Caveman有4种强度模式。Lite轻度压缩，Full标准模式，Ultra极限压缩，还有一个文言文模式，用中文古文输出。

多Agent通用。Claude Code、Codex、Gemini CLI、Cursor、Windsurf、Copilot、Cline都能用。

安装命令是两个。claude plugin marketplace add JuliusBrussee/caveman，然后claude plugin install caveman@caveman。

Auto-activation，不用每次手动调用，装完自动生效。我装了之后就没管过，每天自动省Token。

---

## Memory Compiler：让Claude记住项目关键决策

第二个必装的是Memory Compiler。

Claude Code最大的问题我之前说过，每次新Session上下文全丢了。你花一周讨论的架构设计，新Session一开Claude什么都不记得。

Memory Compiler解决这个。Hook自动捕获对话，提取知识，存入每日日志，编译成知识库。下次Session直接调取。

知识库结构分三块。concepts放概念，connections放关联，qa放问答。不用向量数据库，Karpathy的LLM Knowledge Base架构改造过来的。

这里有个反直觉的设计。No RAG。个人规模50到500篇文章，不需要向量检索，LLM直接读index.md效果更好。向量数据库是大规模才需要的，小规模反而增加复杂度。

自动触发机制。SessionEnd Hook自动捕获对话，PreCompact Hook是安全网，每天6PM后自动编译。不需要手动操作，装完自动跑。

还有个健康检查。lint.py有7项检查，broken links、orphaned pages、contradictions、staleness等等。定期跑一下保证知识库质量。

这个Skill真的让我每天多睡了一小时。之前每天早上要花半小时重新跟Claude解释项目背景，现在不需要了，它直接记得。

---

## Paper2Code：把AI论文秒变可运行代码

第三个是Paper2Code。

读AI论文最大的痛苦是什么？看懂原理了不知道怎么实现。每个公式都知道，但写成代码不知道从哪下手。

Paper2Code解决这个。arxiv URL进去，citation-anchored implementation出来。

Citation anchoring是它的核心功能。每行代码都标注来自论文第几节、第几个公式。比如注释里写着§3.2 — "We apply layer normalization before each sub-layer"，然后代码就是对应的Transformer实现。每一行都可验证。

Ambiguity auditing是另一个有用的功能。论文里有些地方是模糊的，Paper2Code会把每个实现选择分类。SPECIFIED是明确的，PARTIALLY\_SPECIFIED是部分明确，UNSPECIFIED是论文没说。UNSPECIFIED的地方代码里会标注common defaults，但不擅自填充。

这个很诚实。论文没明确的就不乱猜，标出来让用户决定。

输出结构很完整。README.md是论文总结，REPRODUCTION\_NOTES.md是歧义审计，requirements.txt是依赖，src/是源代码，configs/是配置，notebooks/是教程。支持PyTorch、TensorFlow、JAX可选，还有minimal、full、educational三种模式。

使用方式是跟Claude说/paper2code加上arxiv链接。可以指定框架，/paper2code URL --framework jax。也可以指定模式，--mode full或者--mode educational。

---

## CLAUDE.md Optimizer：自动生成项目上下文

第四个是CLAUDE.md Optimizer。

CLAUDE.md是给Claude注入项目上下文的文件，Claude Code启动时读取，告诉它项目是什么，用什么技术栈、有什么规范。

手写CLAUDE.md有三个问题。费时，要手动梳理项目结构。遗漏，容易忘记重要的技术细节。不同步，代码变了CLAUDE.md还是旧的。

CLAUDE.md Optimizer分析项目结构，扫描package.json、import语句，识别框架和库，然后生成上下文写入CLAUDE.md。

比手写更精准。基于实际代码结构，不是基于记忆。代码用了什么就是什么，不会漏。

自动维护。代码变更后重新运行，自动更新上下文。装完不用管。

---

## TestDrift：AI写完代码自动生成测试用例

第五个是TestDrift。

TDD大家都知道，Red写失败测试，Green写代码通过，Refactor重构。问题是流程容易断。代码写完了，手动切换到测试，想起来才写，想不起来就忘了。

TestDrift无缝嵌入。检测到代码变更，自动生成测试用例，保持测试覆盖。写完业务代码后自动触发，不用手动切换。

测试覆盖追踪。记录哪些函数有测试、哪些没有，避免漏测。

---

## 这5个Skill解决了什么问题

Caveman解决输出冗余，Token节省75%。

Memory Compiler解决上下文丢失，每天省一小时重新解释项目。

Paper2Code解决论文到代码的转化难题。

CLAUDE.md Optimizer解决项目上下文不精准的问题。

TestDrift解决TDD流程断裂的问题。

这5个Skill覆盖了Claude Code的5个核心痛点。不是锦上添花，是实实在在解决每天都会遇到的问题。

---

## 留个问题

你最头疼的Claude Code问题是什么？输出太啰嗦、记不住项目上下文、还是论文不知道怎么实现？

继续滑动看下一个

JingBuoluo

向上滑动看下一个