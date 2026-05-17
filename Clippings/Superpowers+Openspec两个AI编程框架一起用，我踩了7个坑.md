---
title: "Superpowers+Openspec两个AI编程框架一起用，我踩了7个坑"
source: "https://mp.weixin.qq.com/s/aw8x5JSG2lZKUvDsS7kPRw"
author:
  - "[[AI智闻说]]"
published:
created: 2026-05-15
description: "OpenSpec管\x26quot;做什么\x26quot;，Superpowers管\x26quot;怎么做\x26quot;。装了不会配合？"
tags:
  - "clippings"
---
AI智闻说 *2026年5月14日 21:22*

> OpenSpec管"做什么"，Superpowers管"怎么做"。装了不会配合？我用一个真实项目走完流程，踩过的坑你不用再踩

## 写在前面

你可能已经读过这两篇文章：

一篇讲Superpowers——14个工作流Skill让AI编程助手守规矩。

一篇讲OpenSpec——规范驱动开发，让AI不再凭感觉写代码。

但你装了两个框架之后，大概率会遇到这些问题：

OpenSpec生成了规范文档，Superpowers的brainstorming又开始问需求，两个在重复劳动。

Superpowers的TDD说"先写测试"，OpenSpec的tasks.md里已经列好了实现步骤，AI该听谁的。

用了一段时间发现：OpenSpec管好了"做什么"，但AI实现的时候还是乱写代码；Superpowers管好了"怎么做"，但做出来的东西和需求对不上。

**这两个框架不是替代关系，是互补关系。** OpenSpec解决"做什么"，Superpowers解决"怎么做"。但它们不会自动配合——你需要一个衔接层。

OpenSpec是Fission-AI开发的开源SDD框架，核心理念是"规范是source of truth，代码是规范的派生产物"——在AI写代码之前，先对齐"做什么"和"技术方案选型"。它专门为已有代码库的项目设计，通过增量规范（delta spec）描述变更而非重写整个规范。Superpowers是Jesse Vincent开发的工作流框架，140,000+ GitHub星标，核心理念是"给AI可组合的Skill工作流，而不是模糊的建议"。一个管方向，一个管执行。

这篇文章，我用一个真实项目走一遍完整流程： **给一个已有的Go微服务添加JWT认证** 。不是从零开始，而是在已有的代码和规范上叠加新功能——这是最常见的开发场景。我会把每一步的输入输出、踩坑和调整都写出来。

## 一、先搞清楚分工：谁管什么

很多人把OpenSpec和Superpowers搞混，以为它们是竞争关系。实际上它们解决的是完全不同的问题：

| 维度 | OpenSpec | Superpowers |
| --- | --- | --- |
| 回答的问题 | 做什么、为什么做 | 怎么做、按什么标准做 |
| 核心产物 | proposal.md、specs、design.md、tasks.md | 代码、测试、审查报告 |
| 控制的对象 | 需求和规范 | 行为和纪律 |
| 失败模式 | 做了不需要的东西 | 需要的东西做错了 |
| 类比 | 建筑蓝图 | 施工规范 |

**一句话总结：OpenSpec确保方向对，Superpowers确保执行对。**

缺少任何一个会怎样？

•

只有OpenSpec：规范写得好好的，AI实现时跳测试、不做审查、一次性提交500行——规范对了但代码质量烂

•

只有Superpowers：TDD做得好、审查做得好，但做出来的东西和需求对不上——代码质量好了但方向错了

•

两个都没有：方向错+代码烂，最差组合

## 二、完整实战：给Go微服务添加JWT认证

### 场景设定

项目背景：

•

一个Go微服务，已有session认证

•

需要添加JWT认证，支持移动端

•

现有代码有基本测试，但覆盖率不高

### 第1步：OpenSpec explore — 先搞清楚方向

不要上来就propose。先explore，和AI讨论技术方案。

```
/opsx:explore
```

你和AI的对话：

> **你** ：我们需要给移动端加JWT认证
> 
> **AI** ：让我看看现有的认证方案……你目前用的是session认证，存在服务端内存里。JWT认证有三种方案：
> 
> 1
> 
> 纯JWT（无状态，支持离线验证）
> 
> 2
> 
> JWT + 黑名单（支持主动失效）
> 
> 3
> 
> 扩展现有session（改最小，但移动端体验差）
> 
> **你** ：用JWT + 黑名单吧，需要能主动踢人
> 
> **AI** ：好。另外几个问题：token过期时间？刷新token要不要？黑名单存哪？
> 
> **你** ：30分钟过期，要刷新token，黑名单用Redis
> 
> **AI** ：明确了。运行 /opsx:propose add-jwt-auth 开始

**踩坑1：直接propose不explore。** 我第一次用时跳过了explore，结果AI生成的proposal选了纯JWT方案，没有黑名单，和需求对不上。来回改了3次。explore花5分钟，省了30分钟的返工。（explore的详细用法和适用场景，之前讲OpenSpec的文章已经展开过，这里不重复。）

### 第2步：OpenSpec propose — 生成规范文档

```
/opsx:propose add-jwt-auth
```

AI生成4个文档：

**proposal.md** — 为什么要做，范围是什么：

```
# 提案：添加JWT认证

## 动机
移动端无法使用session认证，需要无状态token方案。

## 范围
- 添加JWT签发和验证
- 添加刷新token机制
- 添加token黑名单（Redis）
- 修改登录接口返回token

## 排除范围
- 不修改现有session认证逻辑
- 不修改前端Web端代码
- 不添加OAuth2第三方登录
- 不修改数据库用户表结构
```

**踩坑2：proposal的"排除范围"写得不够细。** 我第一次写的时候没写"不修改前端Web端代码"，AI在实现的时候顺手把Web端的登录也改了。加上排除范围后，AI就像有了围栏，不会"好心"帮你多做。（"不做什么比做什么更重要"这个原则之前讲OpenSpec时详细说过，这里强调的是：和Superpowers组合使用时，排除范围还会被spec-compliance-check Skill引用，写不写直接影响审查能不能抓到违规。）

**specs/** — 增量规范：

```
# 新增需求

## 需求：JWT签发

系统MUST在用户登录成功后签发access token和refresh token。

### 场景：有效凭证登录

- 假设 用户持有有效的用户名和密码
- 当 用户提交登录请求
- 则 返回access token（30分钟过期）和refresh token（7天过期）
- 且 返回格式包含三个字段：
  - access_token：访问令牌
  - refresh_token：刷新令牌
  - expires_in：过期时间（秒）

### 场景：无效凭证登录

- 假设 用户持有无效凭证
- 当 用户提交登录请求
- 则 返回401状态码
- 且 不签发任何token

## 修改需求

## 删除需求
```

**design.md** — 技术方案：

```
# 设计方案：添加JWT认证

## 技术方案

使用golang-jwt库签发和验证token。中间件模式拦截请求，
验证Authorization头。黑名单使用Redis SET存储已失效的token。

## 架构决策

- access token 30分钟过期，refresh token 7天过期
- 黑名单用Redis SET，key为jti（JWT ID），TTL等于token剩余有效期
- 中间件模式，不修改现有路由注册逻辑
- 刷新token时轮换（refresh token用一次就失效，签发新的）
```

**tasks.md** — 实现步骤：

```
# 任务清单

- [ ] 1.1 添加JWT依赖（golang-jwt）
- [ ] 1.2 定义token结构和常量
- [ ] 2.1 实现JWT签发函数
- [ ] 2.2 实现JWT验证函数
- [ ] 3.1 实现Redis黑名单
- [ ] 3.2 实现token失效逻辑
- [ ] 4.1 实现认证中间件
- [ ] 4.2 修改登录接口返回token
- [ ] 5.1 实现刷新token接口
- [ ] 5.2 实现刷新token轮换
```

**踩坑3：tasks.md的粒度和Superpowers的plan不匹配。** OpenSpec的tasks是需求视角的拆分，Superpowers的plan是实现视角的拆分：

1

OpenSpec的task: "实现JWT签发函数"——说什么

2

Superpowers的plan: "1.写失败测试 2.运行测试 3.写最小实现 4.运行测试 5.提交"——怎么做

这两个不矛盾，但需要正确衔接——后面第4步会讲。

### 第3步：审核规范文档

这一步没有框架帮你，必须你自己做。

审核清单：

1

proposal的范围和排除范围是否完整

2

specs的场景是否覆盖了边界情况（token过期、token被黑名单、并发刷新）

3

design.md的技术决策是否合理

4

tasks.md是否遗漏了步骤（安全测试、性能测试）

**我发现的问题：** specs里没有覆盖"并发刷新同一个refresh token"的场景。这是一个安全漏洞——如果攻击者拿到refresh token，可以在原用户刷新的同时也刷新，获得多个有效token。我补充了这个场景：

```
### 场景：并发刷新

- 假设 同一个refresh token被同时使用两次
- 当 第二次使用该refresh token
- 则 返回401状态码
- 且 原refresh token被加入黑名单
```

### 第4步：关键衔接——让两个框架听同一个指挥

这是整篇文章最关键的一步，也是两个框架的"断层"所在。

**问题在哪？** OpenSpec的tasks.md告诉你"做什么"，但不说"怎么做"。Superpowers的writing-plans告诉你"怎么做"，但不知道"做什么"。两个框架各管一段，中间缺了衔接。

**还有一个容易忽略的问题：OpenSpec的apply去哪了？** OpenSpec自己的流程是explore、propose、apply、sync、archive，apply是让AI按照tasks.md实现代码。但如果你用Superpowers来执行，apply这一步就被Superpowers的TDD流程替代了——Superpowers做得更好，因为它有测试纪律、代码审查、验证机制。

**所以联合工作流中，跳过OpenSpec的apply，用Superpowers的执行流程替代。** 跳过apply后，tasks.md中的勾选状态需要手动更新（每完成一个task，在tasks.md中把 `- [ ]` 改为 `- [x]` ），或者通过openspec-superpowers-bridge Skill自动更新。

**怎么衔接？** 把OpenSpec的产物喂给Superpowers：

1

把OpenSpec生成的design.md和specs/作为上下文

2

告诉AI："基于OpenSpec的tasks.md，用Superpowers的planning流程拆成可执行的计划"

3

Superpowers会把每个task拆成TDD步骤

**具体操作：** 如果你用Claude Code，在对话中输入：

```
请阅读以下OpenSpec规范文档，然后基于这些规范使用Superpowers的
writing-plans流程拆分实现计划：

1. 读取 openspec/changes/add-jwt-auth/design.md 作为技术方案
2. 读取 openspec/changes/add-jwt-auth/specs/ 下的所有场景作为测试依据
3. 读取 openspec/changes/add-jwt-auth/tasks.md 作为任务列表
4. 读取 openspec/changes/add-jwt-auth/proposal.md 的排除范围作为审查依据

每个task拆成Superpowers plan的粒度：
1. 写失败测试
2. 运行测试
3. 写最小实现
4. 运行测试
5. 重构
6. 提交
```

如果你用Cursor或其他工具，打开这些文件让AI读取后，再执行 `/superpowers:writing-plans` 。

**粒度转换示例：** AI会把OpenSpec的task 2.1"实现JWT签发函数"拆成：

1

写失败测试： `TestJWTSign_ValidCredentials_ReturnsToken`

2

运行测试，确认失败（ `undefined: SignToken` ）

3

写最小实现： `func SignToken(userID string, expiry time.Duration) (string, error)`

4

运行测试，确认通过

5

重构：提取常量、改进命名

6

提交

**踩坑4：直接让Superpowers开始实现，不喂OpenSpec的规范。** 如果不把specs和design.md给Superpowers，AI会按自己的理解实现，可能和OpenSpec对齐的方案不一致。比如design.md决定用Redis SET存黑名单，AI可能自己选了内存map。 **衔接的关键：把OpenSpec的design.md作为Superpowers brainstorming的输入。**

**另一个容易踩的坑：brainstorming和explore重复劳动。** OpenSpec的explore已经讨论过需求和技术方案了，Superpowers的brainstorming又会重新问一遍。 **解法：如果OpenSpec的explore和propose已经完成，跳过Superpowers的brainstorming阶段，直接进入planning阶段。把proposal.md和design.md作为brainstorming的等效输出。**

**如果你已经跑了apply怎么办？** apply会让AI直接按tasks.md实现代码，但实现过程没有TDD、没有代码审查、没有验证机制。两种处理方式：

1

如果apply生成的代码可以用，保留代码，但后续每个task补上Superpowers的代码审查和verify

2

如果apply生成的代码质量不行，用 `git reset` 回退，重新用Superpowers的TDD流程实现

### 第5步：Superpowers执行 — TDD实现每个task

这一步完全交给Superpowers的纪律流程。每个task走：

1

派新代理实现（subagent-driven-development）

2

代理内部走TDD（test-driven-development）

3

独立代理审查规格合规性

4

独立代理审查代码质量

**踩坑5：审查代理没有OpenSpec的规范上下文。** Superpowers的代码审查默认只看代码质量（由requesting-code-review Skill触发，自动派一个全新代理审查），不检查实现是否和OpenSpec的规范一致。我写了一个自定义Skill来解决这个问题：

```
---
name: spec-compliance-check
description: Use when 完成代码实现后，在代码审查之前，检查实现是否符合OpenSpec规范
---

# 规范合规审查

## 铁律
任何实现必须与openspec/specs/中的规范一致。不一致就是bug。

## 审查步骤

1. 读取 openspec/specs/ 下的主规范（检查本次实现是否违反了已有需求）
2. 读取本次变更对应的openspec/changes/下的delta规范
3. 逐条检查每个"假设/当/则"场景是否有对应实现
4. 检查design.md中提到的架构决策是否被遵守
5. 检查proposal.md的排除范围是否被违反

## 常见问题

- "AI顺手多改了代码"：检查排除范围
- "实现方式和design.md不一致"：这是bug，不是优化
- "场景没有覆盖"：测试不完整
```

这个Skill的关键在于： **它把OpenSpec的规范文档变成了Superpowers审查流程的一部分。** 没有这个Skill，审查代理只看代码质量，不看规范合规。

### 第6步：OpenSpec verify — 验证实现和规范的一致性

每个task完成后，Superpowers会做代码审查。但代码审查通过不等于规范合规。

```
/opsx:verify
```

（注：verify属于OpenSpec的扩展工作流，需要通过 `openspec config profile` 切换到扩展配置才能使用。）

verify从三个维度检查：

| 维度 | 检查什么 | 和Superpowers审查的区别 |
| --- | --- | --- |
| 完整性 | 每个需求是否有对应实现 | Superpowers审查看代码，verify看规范 |
| 正确性 | 实现是否符合规范意图 | Superpowers审查看质量，verify看语义 |
| 一致性 | 实现是否和design.md一致 | Superpowers审查不读design.md |

**实测发现的问题：** verify发现task 4.1"实现认证中间件"的实现用了内存map存黑名单，和design.md的Redis方案不一致。代码审查没发现这个问题，因为代码本身质量没问题——只是和规范不一致。spec-compliance-check Skill也没抓到，因为这个task是在安装Skill之前实现的。

**踩坑6：verify和代码审查二选一。** 两个都要做。代码审查看质量，verify看合规。它们检查的东西不一样，互补不替代。代码审查关注"代码写得好不好"（命名、结构、错误处理），verify关注"代码做了该做的事吗"（规范合规、场景覆盖、架构一致）。一个代码质量满分但和规范不一致的实现，代码审查会通过，verify不会。 **正确顺序：**

1

代码质量审查（Superpowers的requesting-code-review Skill自动派一个全新代理审查）

2

规范合规审查（spec-compliance-check Skill）

3

OpenSpec verify（从规范维度全面验证）

先确保代码写得对，再确保代码和规范一致，最后从规范维度全面验证。

### 第7步：OpenSpec archive — 归档并更新主规范

所有task完成，verify通过后：

```
/opsx:archive
```

两件事：

1

把delta specs合并到主规范（ `openspec/specs/auth/spec.md` 更新了JWT认证的需求）

2

把变更文件夹移到archive/

**归档的意义：** 下次加功能时，AI读到的主规范已经包含了JWT认证的信息。不会出现"AI不知道项目已经有JWT认证，又实现了一套session认证"的问题。

**踩坑7：归档前没跑全量测试。** 我有一次在verify通过后直接archive，结果后来发现verify只检查了规范合规，没跑测试套件。Superpowers的verification-before-completion要求"跑过命令才能说搞定了"，但OpenSpec的archive没有这个检查。 **我的做法：在archive之前，加一步Superpowers的verification。** 具体来说，按项目类型跑全量测试：Go项目用 `go test ./...`，Node.js项目用 `npm test` ，Python项目用 `pytest` 。或者直接触发Superpowers的verification-before-completion Skill，它会要求你提供当前对话中运行的测试结果。

### 第8步：Superpowers收尾

验证通过后，finishing-a-development-branch给你4个选项：

1

本地合并到主分支

2

推送并创建PR

3

保留分支

4

丢弃更改

测试不过不能合并——这条铁律保底。

## 三、完整流程一览

把8步串起来，完整的联合工作流：

**需求阶段（OpenSpec主导）：**

1

explore — 和AI讨论技术方案（5-10分钟）

2

propose — 生成proposal、specs、design、tasks（10-15分钟）

3

人工审核 — 检查规范文档的完整性（5-10分钟）

**衔接阶段（你主导）：**

1

喂上下文 — 把OpenSpec的design.md和specs给Superpowers，让planning基于规范拆分（跳过OpenSpec的apply，用Superpowers替代）

**实现阶段（Superpowers主导）：**

1

TDD实现 — 每个task走RED-GREEN-REFACTOR循环

2

双重审查 — 代码质量审查 + 规范合规审查

**验证阶段（两者配合）：**

1

OpenSpec verify + Superpowers verification — 先跑测试确保代码能工作，再跑verify确保实现和规范一致

2

OpenSpec archive + Superpowers收尾 — 归档更新主规范，合并或创建PR

**核心原则：OpenSpec的产物是Superpowers的输入，Superpowers的输出是OpenSpec验证的对象。**

**当流程出问题时怎么办？**

1

**verify不通过** — 回到对应的task，用Superpowers的systematic-debugging找根因，修复后重新跑verify

2

**spec-compliance-check发现不合规** — 先判断是代码错了还是规范过时了：代码错了就修代码，规范过时了就修改design.md并重新跑propose

3

**design.md的决策不合理** — 回到第3步人工审核，修改design.md，然后重新走衔接层让Superpowers基于新方案规划

4

**tasks.md粒度太粗或太细** — 粗粒度task会被Superpowers的planning自动拆细，细粒度task可以在衔接时合并（相邻的task 1.1和1.2合并为一个plan task）

5

**实现过程中需要修改规范** — 先暂停Superpowers的执行，回到OpenSpec修改design.md（必要时重跑propose），修改后的delta specs需要重新审核，然后重新走衔接层让Superpowers基于新方案规划。已完成的task如果不受影响则保留，受影响的task需要用Superpowers的systematic-debugging评估影响范围并修改。如果只是微调而不需要重新propose，可以用 `/opsx:sync` 把变更中的delta specs同步到主规范，无需归档

6

**多个变更并行推进** — 每个变更用独立的git worktree开发，每个worktree里只有一个OpenSpec变更在推进。Superpowers的dispatching-parallel-agents可以在不同worktree上并行工作，但不要在同一个worktree上同时推进多个OpenSpec变更，否则spec-compliance-check会混淆不同变更的规范边界

## 四、7个坑的完整清单

| 坑 | 现象 | 根因 | 解法 |
| --- | --- | --- | --- |
| 1 | propose生成的方案和需求对不上 | 跳过了explore | 先explore再propose |
| 2 | AI多做了你没要求的功能 | proposal的排除范围没写 | 写清楚"不做什么" |
| 3 | tasks和plan粒度不匹配 | OpenSpec说"做什么"，Superpowers说"怎么做" | 衔接层转换粒度 |
| 4 | 实现方式和design.md不一致 | Superpowers没有规范上下文 | 把design.md喂给brainstorming |
| 5 | 代码审查不检查规范合规 | 审查代理只看代码质量 | 自定义spec-compliance-check Skill |
| 6 | 只做verify或只做代码审查 | 以为两者等价 | 两个都做，互补不替代 |
| 7 | archive前没跑全量测试 | verify不跑测试 | archive前加Superpowers的verification |

## 五、自定义Skill：让两个框架自动配合

上面7个坑，有5个可以通过自定义Skill自动解决。我写了一个衔接Skill：

把这两个Skill放在Claude Code的Skills目录下：

•

`~/.claude/skills/spec-compliance-check/SKILL.md`

•

`~/.claude/skills/openspec-superpowers-bridge/SKILL.md`

如果你用Cursor，放在`.cursor/rules/` 目录下。

```
---
name: openspec-superpowers-bridge
description: Use when 开始实现OpenSpec的tasks，在brainstorming和planning之前自动加载。当用户说"开始实现"、"apply tasks"或提到OpenSpec变更时触发
---

# OpenSpec-Superpowers衔接规范

## 铁律
实现任何OpenSpec task之前，必须先加载对应的规范文档。没有规范上下文的实现就是盲写代码。

## 执行步骤

1. 读取 openspec/specs/ 下的主规范（了解已有约束）和 openspec/changes/ 下最新的未归档变更目录中的所有文档（如果不确定当前变更目录，运行 \`ls openspec/changes/\` 查看未归档的变更文件夹。如果只有一个，那就是当前变更。如果有多个，询问用户确认）
2. 如果OpenSpec的explore和propose已经完成，跳过Superpowers的brainstorming阶段，直接进入planning阶段
3. 把 design.md 作为 Superpowers planning 的输入
4. 把 specs/ 中的场景转换为 TDD 测试用例
5. 把 tasks.md 中的每个任务拆成 Superpowers plan 的粒度
6. 每个任务完成后，用 spec-compliance-check 审查规范合规
7. 全部任务完成后，运行 /opsx:verify
8. verify 通过后，运行 Superpowers verification（跑测试命令）
9. 两个验证都通过，才能 /opsx:archive

## 场景到测试的转换规则

OpenSpec的"假设/当/则"场景映射为测试用例，每个场景至少需要两个测试：

1. 正常路径测试：假设对应setup，当对应action，则对应assertion
2. 错误路径测试：假设对应异常条件，当对应action，则对应错误assertion
3. 边界值测试：如果场景涉及数值、时间等边界，额外添加

## 审查的双重检查

每次代码审查必须包含两个维度：
1. 代码质量（Superpowers默认审查）
2. 规范合规（spec-compliance-check Skill）

## 常见问题

- "AI没读design.md就实现了"：检查衔接Skill是否触发
- "tasks粒度太粗"：自动拆成TDD步骤
- "verify通过了但测试没跑"：archive前强制跑测试
```

**这个Skill直接解决了7个坑中的5个：**

1

**自动加载规范上下文** — 解决坑4（实现方式和design.md不一致）

2

**跳过brainstorming避免重复** — 解决explore和brainstorming重复劳动的问题

3

**场景转测试用例** — 解决坑3（tasks和plan粒度不匹配），让OpenSpec的规范直接变成Superpowers TDD的输入

4

**双重验证** — 解决坑6（verify和代码审查二选一）和坑7（archive前没跑测试）

5

**spec-compliance-check** — 解决坑5（审查不检查规范合规）

未自动解决的：坑1（需要人先explore）和坑2（需要人写排除范围），这两个需要人在流程中主动把关。

## 六、什么时候该用哪个

不是所有项目都需要两个框架一起上。

**只用OpenSpec就够了：**

•

改按钮颜色、修typo等小改动

•

需求很明确，AI不会做多余的事

•

你只需要对齐"做什么"，实现质量你自己把控

**只用Superpowers就够了：**

•

一次性脚本（写完就扔）

•

需求明确但不需要长期规范的小功能（比如写个数据迁移脚本）

•

你自己很清楚需求，不需要规范对齐

**两个都用：**

•

团队协作的项目（规范保证方向一致，纪律保证质量一致）

•

长期维护的项目（规范随项目增长，纪律保证代码质量不退化）

•

复杂功能开发（设计阶段防止方向错，TDD防止实现错）

•

已有代码库的项目（现有代码+新功能，规范防止AI"好心"多改，纪律防止AI偷懒跳步）

**判断标准：代码要活多久 + 有多少人碰代码。** 活1天1个人碰，两个都不用。活1个月3个人碰，两个都用。

**从单框架过渡到双框架：**

•

如果你已经在用OpenSpec：在下一个新功能中加入Superpowers的TDD和代码审查，不需要一次用上全部14个Skill，先加3条铁律（没设计不写代码、没测试不写代码、没验证不说完成）

•

如果你已经在用Superpowers：在下一个复杂功能前先用OpenSpec的explore和propose生成规范文档，不需要一次用上完整流程，先加规范对齐这一步

## 七、效果对比：4种组合的数据一览

用同一个项目（Go微服务添加JWT认证）做对比（以下数据来自作者个人经验，仅供参考）：

| 维度 | 只用OpenSpec | 只Superpowers | 两个都用 |
| --- | --- | --- | --- |
| 需求对齐 | proposal+specs确认 | 口头说了算 | proposal+specs确认 |
| AI多做功能 | 排除范围控制 | 偶尔（1-2次） | 排除范围控制（0次） |
| 测试覆盖 | 0个测试 | 10个测试 | 10个测试 |
| 提交粒度 | 1次大提交 | 8次小提交 | 8次小提交 |
| 规范合规 | verify检查 | 无法验证 | verify+合规审查 |
| 长期维护 | 主规范累积 | 新对话忘光 | 主规范累积+纪律一致 |
| 返工次数 | 1-2次 | 2-3次 | 0-1次 |

**两个框架组合的最大价值不是各自的价值相加，是消除"方向对了但做错了"和"做对了但方向错了"这两个最常见的失败模式。**

**数据说明：** "AI多做功能"这行，Superpowers比"两个都不用"好，是因为brainstorming阶段会问清楚需求边界；但Superpowers没有排除范围机制，所以AI还是可能"好心"多做。加了OpenSpec的排除范围后，spec-compliance-check能自动检测违规，所以能到0次。返工次数指因方向错误或质量不达标需要返工的次数，不含正常的小调整。

## 写在最后

OpenSpec和Superpowers的组合，本质上是给AI编程加了两个维度的约束：

1

**横向约束** （OpenSpec）：AI做的事情和你的需求一致

2

**纵向约束** （Superpowers）：AI做事情的方式符合工程标准

没有横向约束，AI可能做出一个完美但不需要的功能。没有纵向约束，AI可能做出一个需要但质量不合格的功能。

**两个约束都有，才是真正的"对的事情，用对的方式做出来"。**

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

3条起步规则：

1

先explore再propose——别让AI猜需求

2

把design.md喂给Superpowers——别让AI猜方案

3

双审查——别让AI自己给自己打分

## 3分钟上手

两个框架都装好后，按这个顺序走你的第一个联合任务：

1

`/opsx:explore` 讨论方案

2

`/opsx:propose 功能名` 生成规范

3

审核四份文档（proposal、specs、design、tasks）

4

对AI说："读取 openspec/changes/ 目录下的规范，用Superpowers的writing-plans拆计划"

5

Superpowers逐个task走TDD

6

每个task完成后：代码审查、spec-compliance-check、 `/opsx:verify`

7

跑全量测试（ `go test ./...` 或项目对应命令）

8

`/opsx:archive` Superpowers收尾合并

第4步是关键——如果你只记住一件事，记住这个： **把OpenSpec的规范文档喂给Superpowers，不要让Superpowers空手上阵。**

扫码关注「AI智闻说」，每天3分钟掌握AI新知识

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

继续滑动看下一个

AI智闻说

向上滑动看下一个