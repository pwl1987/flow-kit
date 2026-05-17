---
title: "装了Superpowers还是不会用？这套完整工作流，让你的AI从\"工具\"变成\"搭档\""
source: "https://mp.weixin.qq.com/s/cs2iFnOI5fIEQQJPFoVQtA"
author:
  - "[[AI智闻说]]"
published:
created: 2026-05-15
description: "90%的人装完Superpowers只用到了10%的能力，问题出在不知道怎么串起来写在前面你可能已经装了Sup"
tags:
  - "clippings"
---
AI智闻说 *2026年5月12日 07:41*

> 90%的人装完Superpowers只用到了10%的能力，问题出在不知道怎么串起来

## 写在前面

你可能已经装了Superpowers。

但说实话，你大概率只触发了其中一两个Skill——写代码时偶尔触发TDD，调试时偶尔触发systematic-debugging，大部分时间还是"直接让AI干活"。

这不是你的问题。Superpowers有14个Skill，每个都写得很详细，但 **没有人告诉你它们怎么串成一条完整的开发流水线** 。

今天这篇文章，我从入门到实战，完整讲清楚一件事： **从你提需求到代码合入主分支，Superpowers的14个Skill怎么一步步接管你的开发流程。**

看完这篇，你会知道为什么有人说"Superpowers让AI自主工作几小时"——不是吹牛，是流程对了。

## 一、先看全貌：14个Skill怎么分工

Superpowers不是14个独立的工具，是一套 **有先后顺序的开发流水线** ：

| 阶段 | Skill | 一句话职责 | 铁律 |
| --- | --- | --- | --- |
| 入口 | using-superpowers | 检查该用哪个Skill | 1%可能就触发 |
| 设计 | brainstorming | 不急着写代码，先问清楚需求 | 没设计不写代码 |
| 规划 | writing-plans | 把需求拆成2-5分钟的小步骤 | 计划写给零上下文的人看 |
| 隔离 | using-git-worktrees | 创建隔离的工作空间 | 不在主分支上开发 |
| 执行 | subagent-driven-development | 每个任务派一个新代理 | 代理不继承历史 |
| 实现 | executing-plans | 无子代理时自己按计划执行 | 不跳过验证步骤 |
| 测试 | test-driven-development | 先写失败测试，再写最小实现 | 没有失败测试不写代码 |
| 调试 | systematic-debugging | 先找根因，再修bug | 没找到根因不提方案 |
| 审查请求 | requesting-code-review | 派独立代理审查代码 | 完成任务必须审查 |
| 审查接收 | receiving-code-review | 验证审查意见再实施 | 不盲从审查意见 |
| 并行 | dispatching-parallel-agents | 独立问题同时派多个代理 | 不让代理改同一文件 |
| 验证 | verification-before-completion | 声称完成前必须跑验证 | 没跑命令不能说"搞定了" |
| 收尾 | finishing-a-development-branch | 验证、合并、清理 | 测试不过不合并 |
| 元技能 | writing-skills | 用TDD方法写新Skill | 没压测不写Skill |

**关键洞察：每个Skill的输出是下一个Skill的输入。** 你不需要记住14个Skill，只需要记住这条流水线。

## 二、完整实战：从需求到上线的7步走

我用一个真实场景走一遍完整流程： **给一个项目添加用户注册功能** 。

### 第1步：brainstorming — 别急着动手

你说"帮我加个用户注册功能"，Superpowers不会直接写代码。它先走brainstorming：

1

**探索项目上下文** — 看你现有代码、文档、最近的提交

2

**逐个提问** — "注册需要邮箱验证吗？""需要第三方登录吗？""密码策略是什么？"

3

**提出2-3个方案** — 比如方案A：邮箱+密码注册；方案B：手机验证码注册；方案C：第三方OAuth

4

**你选方案后，出设计文档** — 保存到 `docs/superpowers/specs/`

**大多数人的错误：** 直接跟AI说"写个注册功能"，AI写完你发现没考虑邮箱验证、没考虑密码强度、没考虑重复注册。brainstorming就是防止这种"做错方向"的问题。

**铁律：** 不管需求多简单，都必须先出设计、你批准后才能写代码。一个5分钟能写完的功能，设计可能只要3句话——但必须有。

### 第2步：writing-plans — 拆到2分钟一个任务

设计批准后，自动进入writing-plans。这一步把设计拆成 **2-5分钟就能完成的小任务** ：

```
## 任务1：创建用户模型
- [ ] 写失败测试：用户创建需要邮箱和密码
- [ ] 运行测试，确认失败
- [ ] 实现User模型最小代码
- [ ] 运行测试，确认通过
- [ ] 提交

## 任务2：添加邮箱唯一性验证
- [ ] 写失败测试：重复邮箱注册返回错误
- [ ] 运行测试，确认失败
- [ ] 添加唯一性约束
- [ ] 运行测试，确认通过
- [ ] 提交

## 任务3：密码加密
...
```

**为什么拆这么细？** 因为每个任务会派给一个独立的AI代理执行。任务越小，代理越不容易出错，审查越容易。

**计划写给谁看的？** 写给"一个技术很强但对项目一无所知的人"——所以必须包含完整代码、精确文件路径、具体命令。不能写"添加验证"，要写"在 `src/models/user.ts` 第15行后添加 `validates :email, uniqueness: true` "。

### 第3步：using-git-worktrees — 隔离工作空间

执行计划前，先创建一个隔离的git工作空间：

```
# 自动创建隔离分支
git worktree add .worktrees/user-registration feature/user-registration
cd .worktrees/user-registration
npm install  # 自动检测并安装依赖
npm test     # 验证基线测试通过
```

**为什么不在主分支上开发？** 因为如果搞砸了，直接删掉worktree就行，主分支完全不受影响。这就像手术前的消毒——不消毒大概率也没事，但出事就是大事故。

### 第4步：subagent-driven-development — 代理流水线

这是Superpowers最核心的执行引擎。每个任务走这个循环：

1

派代理A实现（全新上下文，不继承历史）

2

派代理B审查规格合规性（代码做了该做的事吗？）

3

派代理C审查代码质量（代码写得好吗？）

4

两个审查都通过，任务完成

5

下一个任务，重复1-4

**为什么每个任务派新代理？** 因为AI的上下文窗口是有限的。如果你在一个对话里干10个任务，到第5个任务时AI已经"忘了"前面的细节。新代理 = 干净的上下文 = 更少的错误。

**为什么不并行派实现代理？** 因为多个代理同时改同一个代码库会冲突。实现是串行的，审查可以并行。

**模型选择策略：**

| 角色 | 推荐模型 | 原因 |
| --- | --- | --- |
| 实现代理 | Haiku/Sonnet | 机械性工作，成本优先 |
| 规格审查 | Sonnet | 需要理解需求 |
| 代码质量审查 | Opus | 需要深度判断 |
| 调试代理 | Opus | 需要最强推理 |

### 第5步：test-driven-development — 每个代理内部的铁律

每个实现代理内部，必须遵循TDD循环：

1

RED：写一个失败测试，运行，确认失败

2

GREEN：写最小代码让测试通过，运行，确认通过

3

REFACTOR：重构，保持测试通过，运行，确认通过

4

重复

**Superpowers的TDD比普通TDD更严格：**

•

"这个功能太简单不需要测试" → 不行，简单代码也需要测试

•

"我先写完代码再补测试" → 不行，先写测试和后写测试是两回事

•

"我先写个参考实现" → 不行，删掉重来

•

"我只是想看看API怎么用" → 不行，看文档，不写代码

**为什么这么严？** 因为AI是最容易"先写代码再补测试"的。一旦开了口子，AI会100%走捷径。铁律不是限制你，是限制AI的偷懒倾向。

### 第6步：requesting-code-review + receiving-code-review — 双重审查

代码写完后，走两轮审查：

**第一轮：请求审查（requesting-code-review）**

•

派一个全新的审查代理，给它精确的上下文（不是你的对话历史）

•

审查代理只看代码变更，不看你的思考过程

•

按严重度分级：Critical（必须修）、Important（应该修）、Minor（记下来）

**第二轮：接收审查（receiving-code-review）**

•

这一步最容易被忽视： **不是审查说什么就改什么**

•

Superpowers要求你先验证审查意见是否正确

•

如果审查建议会破坏现有功能，要反驳

•

如果审查建议违反YAGNI原则（你不会需要它），要反驳

•

修复顺序：Critical → Important → Minor，每个修完单独测试

**审查的黄金法则：** 技术正确性 > 社交舒适度。不能因为审查者"说得有道理"就盲从——要自己验证。

### 第7步：verification-before-completion + finishing-a-development-branch — 收尾

**验证铁律：** 没跑过命令，不能说"搞定了"。

**错误示范：** "代码改完了，应该没问题"  
**正确示范：** "运行 `npm test` ，32个测试全部通过，0个失败"

Superpowers要求你提供 **新鲜的证据** ——上一次运行的测试结果不算，必须是当前消息中运行的。

验证通过后，finishing-a-development-branch给你4个选项：

1

本地合并到主分支

2

推送并创建PR

3

保留分支不动

4

丢弃所有更改

每个选项都有对应的安全检查——测试不过不能合并，丢弃更改需要你输入"discard"确认。

## 三、3条铁律，记住就够了

14个Skill太多记不住？记住这3条铁律，覆盖80%的场景：

### 铁律1：没设计不写代码（brainstorming）

不管需求多简单，先出设计再动手。设计可以很短，但必须有。

**违反后果：** 做错方向，返工3次。

**触发时机：** 你说"帮我做XX"的时候，AI应该先问清楚，而不是直接写代码。

### 铁律2：没测试不写代码（TDD）

先写失败测试，再写最小实现。

**违反后果：** 写了一堆代码，不知道对不对，改一处坏三处。

**触发时机：** 任何写代码的时刻——新功能、修bug、重构。

### 铁律3：没验证不说完成（verification）

声称完成之前，必须跑验证命令并给出证据。

**违反后果：** "应该没问题"上线后出bug。

**触发时机：** 你说"搞定了""应该可以了""测试通过了"的时候——AI必须跑一遍验证。

## 四、调试：Superpowers怎么帮你修Bug

调试是独立于开发流水线的流程，任何阶段遇到bug都可以触发：

1

根因调查：读错误信息、复现问题、查最近变更、追踪数据流

2

模式分析：找正常代码、对比差异

3

假设验证：提一个假设、最小改动验证、一次只改一个变量

4

实施修复：先写失败测试、修复根因、验证通过

**最常见的反模式：** "我试试改这个看行不行"——这不是调试，这是猜。

**Superpowers的3次规则：** 如果你连续3次修复都失败，说明问题可能在架构层面。停下来，和人讨论，而不是继续猜。

**什么时候最该用systematic-debugging？** 不是闲的时候，是 **最急的时候** 。因为越急越容易猜，越猜越浪费时间。系统调试15-30分钟搞定的问题，猜着改可能要2-3小时。

## 五、并行：哪些任务可以同时干

dispatching-parallel-agents让多个代理同时处理独立问题：

**适合并行的场景：**

•

3个不相关的bug需要修

•

前端和后端的独立任务

•

多个文件的独立重构

**绝对不能并行的场景：**

•

代理会改同一个文件

•

一个问题的修复可能影响另一个

•

你还不确定问题出在哪（探索阶段）

**关键原则：** 每个代理拿到的是精心构造的上下文，不是你的完整对话历史。你像项目经理一样分配任务、收集结果、处理冲突。

## 六、写自己的Skill：用TDD方法

writing-skills告诉你： **写Skill也要TDD。**

1

**RED：** 先想3个"压力场景"——AI最容易犯错的场景。不带Skill跑一遍，记录AI的"自然表现"和"借口"

2

**GREEN：** 针对那些借口写Skill，再跑一遍，看AI是否遵守

3

**REFACTOR：** 测试中AI又找到新借口？加反借口规则，循环直到"防弹"

**最重要的陷阱：description写成了摘要。**

```
# 致命错误：描述变成了流程摘要
description: 在任务之间做代码审查，确保质量

# 正确：只写触发条件
description: Use when completing a coding task, before marking it done
```

为什么？因为AI读到摘要就可能"自以为懂了"，不去读Skill正文。description只写"什么时候用"，流程写在Skill里面。

## 七、大多数人不知道的5个细节

### 细节1：brainstorming会自动串联writing-plans

设计一旦批准，brainstorming会自动调用writing-plans。你不需要手动切换。这是14个Skill之间最核心的串联关系。

### 细节2：subagent-driven-development的代理不继承历史

每个代理拿到的上下文是你精心构造的，不是你的完整对话。这意味着：

•

代理不会"记住"你之前说的偏题的话

•

但也意味着你必须给代理足够的上下文

•

计划写得越详细，代理执行得越好

### 细节3：receiving-code-review鼓励你反驳

审查意见不是圣旨。Superpowers明确列出了哪些情况该反驳：

•

建议会破坏现有功能

•

审查者不了解完整上下文

•

建议违反YAGNI原则

•

建议在技术上不正确

### 细节4：verification-before-completion的"新鲜证据"要求

"我上次跑了测试通过了"不算。必须是 **当前消息中** 运行的验证结果。因为代码可能在你上次验证后又改了。

### 细节5：writing-plans的计划是给"陌生人"看的

计划必须包含完整代码、精确文件路径、具体命令。不能写"添加验证"，要写"在 `src/models/user.ts` 第15行后添加 `validates :email, uniqueness: true` "。因为执行计划的代理对你的项目一无所知。

## 八、从零开始：5分钟配置Superpowers

```
# Claude Code安装
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace

# 验证安装成功
# 重启后说"帮我规划一个功能"
# 如果AI开始问问题而不是直接写代码，说明brainstorming生效了
```

**自定义Skill放哪里：**

```
# 个人级（所有项目可用）
~/.claude/skills/my-skill/SKILL.md

# 项目级（团队共享，提交到git）
.claude/skills/my-skill/SKILL.md
```

**验证Skill是否生效的3个测试：**

1

说"帮我规划一个功能"，AI应该先问问题，不是直接写代码

2

说"加个登录功能"，AI应该先写失败测试，不是直接写实现

3

说"这个bug帮我修一下"，AI应该先问根因，不是直接改代码

如果3个都没按预期触发，检查Skill的description是否写好了触发短语。

## 九、Superpowers不适合什么场景

任何工具都有边界，诚实地说：

**不适合的场景：**

•

一次性脚本（写完就扔的那种，TDD反而浪费时间）

•

探索性原型（你还不确定要做什么，brainstorming会卡住）

•

紧急hotfix（先止血再补流程）

•

一个人维护的小项目（流程开销可能大于收益）

**最适合的场景：**

•

团队协作的项目（流程保证一致性）

•

长期维护的项目（测试和审查的投资回报高）

•

复杂功能开发（设计阶段防止走错方向）

•

AI辅助编程（流程弥补AI的偷懒倾向）

**核心判断标准：** 代码要活多长时间？活1天的脚本不需要Superpowers，活1年的项目很需要。

## 十、一张图总结

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**简单需求：** 直接做，但verification（验证）还是要有

**正式需求，走流水线：**

1

brainstorming：问清楚需求，出设计，你批准

2

writing-plans：拆成2-5分钟任务

3

using-git-worktrees：创建隔离空间

4

每个任务循环：subagent-driven-development（派代理实现，代理内部走TDD：RED→GREEN→REFACTOR）→ requesting-code-review（独立审查）→ receiving-code-review（验证后实施）

5

verification-before-completion：跑验证，给证据

6

finishing-a-development-branch：合并或PR

**Superpowers的本质不是14个独立工具，是一条防止AI偷懒的流水线。** 每个环节都在防止AI走捷径：brainstorming防止做错方向，TDD防止跳过测试，code-review防止自说自话，verification防止假完成。

你不需要一次用上所有Skill。从3条铁律开始：没设计不写代码，没测试不写代码，没验证不说完成。等这3条变成习惯，再加其他Skill。

扫码关注「AI智闻说」，每天3分钟掌握AI新知识

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

继续滑动看下一个

AI智闻说

向上滑动看下一个