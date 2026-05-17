---
title: "不可避免的未来：用 Claude Code 设计自己的 Agentic Coding 工作流"
source: "https://mp.weixin.qq.com/s/qFzWHnOQLJzh2GujEVlNCQ"
author:
  - "[[8小时coding]]"
published:
created: 2026-05-15
description: "本文分享如何基于 Claude Code 设计属于自己的 Agentic Coding 工作流。核心不是让 AI 一次性生成 Demo，而是通过 Skill、Checkpoint、Workflow 和自动化验证机制，让 AI 能在真实项目中持续参与需求分析、架构设计、编码实现、部署验证和增量变更。"
tags:
  - "clippings"
---
8小时coding *2026年4月27日 16:01*

## 用 Claude Code 设计属于自己的 Agentic Coding 工作流

今天给大家分享如何使用 Claude Code 来设计属于自己的 Agentic Coding 工作流。

当下各种工具层出不穷，基于 gstack、bmad、spec-kit 等框架，再配合 workflow 编排，很容易实现一套 agentic coding 流程。但是，你需要学习这些工具的使用方式，也需要理解它们背后的设计假设。

本文推荐的是另外一种思维模式： **AI 是思维的拓展，而不是现成框架的替代品** 。

我们可以使用 Claude Code，基于自己的 coding 习惯，设计一套适合日常工作的自动化流程。两者的本质区别是：一个是使用者，另一个是创造者。

要做一个 agentic coding agent，第一步不是写 prompt，而是明确目标。

我的目标不是通过一句话生成一个 demo，也不是让 AI 做一次性的代码补全，而是让 AI 能够在现有项目上，进行长时间、多阶段、可验证的产品功能开发。

换句话说，我希望当我为 agentic coding agent 提供足够的 context 后，Claude Code 可以自动化完成后续的大部分流程：

- • 需求分析
- • 领域建模
- • 架构设计
- • 技术规格
- • 代码实现
- • 测试验证
- • 部署检查
- • 增量变更

下面以我设计的 `Product Design Workflow` 为例，介绍这套工作流的设计思路，希望能给大家一点启发。

## 1\. 先定义工作流，而不是先写 Agent

![[_resources/不可避免的未来：用 Claude Code 设计自己的 Agentic Coding 工作流/5284e1014542103214596fc33a45d940_MD5.webp]]

仓库地址:

https://github.com/infra403/agentic-engineering-lab

Product Design Plugin 是一个 Claude Code 插件，实现了从需求发现到代码部署的完整产品开发流程。

它的核心方法论叫：

```
Spec-Driven Incremental Deploy
设计规格驱动的增量部署
```

这套流程分为三个大阶段：

- • 设计阶段：通过 Generator-Evaluator 收敛循环，产出 5 个 checkpoint YAML 文件
- • 实现阶段：通过 `/implement` 从 checkpoint 自动生成代码，每完成一个功能就部署验证
- • 变更阶段：通过 `/change` 在已有项目上做增量变更，先影响分析，再动手实现

整体流程如下：

```
/product-design
  -> checkpoint-1-discovery.yaml
  -> checkpoint-2-modeling.yaml

/architecture-design
  -> checkpoint-3-architecture.yaml
  -> checkpoint-4-specification.yaml
  -> checkpoint-5-review.yaml

/implement
  -> tech-profile.yaml
  -> deploy-manifest.yaml
  -> RED -> GREEN -> REVIEW -> DEPLOY -> COMMIT

/change
  -> change-request-N.yaml
  -> impact analysis
  -> incremental design
  -> regression verification
```

这里最重要的不是命令本身，而是背后的思想：

**不要让 Agent 直接写代码，而是让 Agent 先建立稳定的规格，再基于规格交付。**

## 2\. Skill 不是 Prompt，而是知识包

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

很多人在做 agentic coding 时，第一反应是写一个很长的 prompt：

> 你是一个资深架构师，你精通 Go、PostgreSQL、Kafka……

这种方式短期有效，但很难长期维护。因为它把知识、流程、角色、输出格式全部混在一起了。

在我的设计里， `Skill` 不是 prompt，而是一个知识包。

一个完整的 skill 通常包含：

```
SKILL.md      定义何时使用、输入输出、工作流
knowledge/    放决策框架，比如 DDD、TOC、QAS、架构风格
roles/        放 Generator / Evaluator 的角色视角
templates/    放 checkpoint、progress、requirements 等模板
references/   放协议、方法论和补充说明
```

比如需求分析阶段会使用 `product-discovery` skill。它不会直接告诉模型“你是产品经理”，而是先加载需求质量框架、TOC 约束理论、QAS 质量属性场景，然后再进入需求收敛。

这就是我非常强调的一点：

```
知识先行，角色后置。
```

角色不是人格扮演，而是视角过滤器。真正重要的是让模型知道：它应该依据什么知识做判断，按什么流程推进，产出什么结构化结果。

## 3\. 为什么引入 TOC：先找约束，而不是先堆功能

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

TOC，全称是 Theory of Constraints，约束理论。

它的核心思想很简单：

```
任何系统的整体产出，都受极少数约束决定。
优化非约束环节，通常不会提升整体产出。
```

举个例子，一个交付流程里，需求写得再快、代码生成得再快，如果测试和部署总是失败，那真正的约束就不是“写代码速度”，而是“验证和集成能力”。

TOC 有五个经典步骤：

```
1. Identify     识别约束
2. Exploit      不加资源，先充分利用约束
3. Subordinate  其他环节服从约束
4. Elevate      必要时投入资源提升约束
5. Repeat       约束转移后重新识别
```

我把它映射到了 agentic coding 里。

### 需求阶段怎么用 TOC

需求分析时，Agent 不应该把用户说的所有功能都平铺成需求列表，而应该先问：

```
当前系统最大的约束是什么？
```

是数据源不稳定？是部署复杂？是团队人少？是 API 规格不清楚？还是验证成本太高？

真正的 Must Have，应该优先改善约束，而不是优先做看起来完整的功能。

### 架构阶段怎么用 TOC

架构设计时，也不是默认微服务、事件驱动、Kafka、K8s 全家桶。

要先问：

```
系统的瓶颈在哪里？
这个架构决策是在改善瓶颈，还是在制造新的复杂度？
```

如果瓶颈是数据库查询，先做索引、缓存、读模型优化。

如果瓶颈是外部 API 限速，系统就要围绕限流、缓冲、重试、降级设计。

如果瓶颈是部署不稳定，就应该优先投资部署验证，而不是继续扩功能。

### 实现阶段怎么用 TOC

这点最关键。

在 LLM 编程里，很多人会认为瓶颈是“模型写代码能力”。但实际长期使用后会发现：

```
LLM 几乎不是主要约束。
真正的约束是：写完之后能否验证、集成、部署、回滚。
```

所以 `/implement` 没有让多个 Agent 一起把所有模块写完，而是强制每个功能都走一个完整闭环：

```
RED -> GREEN -> REVIEW -> DEPLOY -> COMMIT
```

这就是 TOC 的 `Subordinate` 思想：其他环节服从系统约束。

哪怕模型可以并行生成很多代码，也不要一次性堆积大量未验证的实现。否则只是增加 WIP，也就是在制品库存。

在软件项目里，未验证代码、未部署功能、半成品设计、没有合并的分支，本质上都是库存。

库存不是产出。

## 4\. 小批量交付：每个功能必须独立闭环

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

TOC 还有一个重要思想：小批量流动。

传统开发里经常会出现：

```
先把所有功能写完
再统一测试
再统一集成
最后统一部署
```

对人类团队来说，这种方式已经很危险；对 LLM 来说，更不可控。

因为 LLM 生成的代码存在三个问题：

- • 可能无法编译
- • 可能偏离设计
- • 多个模块最后组装时接口不匹配

所以我的实现阶段采用小批量交付：

```
一个功能
  -> 先写验收测试
  -> 再写实现
  -> 再独立评审
  -> 再部署验证
  -> 最后单独 commit
```

这对应到 `/implement` 的 RALPH 循环：

```
READ     读取 checkpoint、文件系统、git notes
ANALYZE  判断每个模块状态
LIST     同步任务列表
PLAN     选择下一个功能
HANDLE   执行 RED -> GREEN -> REVIEW -> DEPLOY -> COMMIT
```

RALPH 的作用不是“聪明地多做事”，而是控制节奏：

```
一次只推进一个可交付功能。
```

这正是 agentic coding 能长期运行的关键。

## 5\. Generator-Evaluator：不要让生成者评价自己

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

LLM 有一个明显问题：自我评估不可靠。

让同一个 Agent 既生成方案，又评价方案，很容易出现确认偏差。它会倾向于解释自己的设计为什么合理，而不是认真寻找问题。

所以我在设计阶段统一使用 Generator-Evaluator 收敛循环：

```
GENERATE -> EVALUATE -> RESOLVE -> CHECK
```

Generator 负责生成方案。

Evaluator 负责找问题。

Resolver 根据问题修正。

Check 判断是否收敛。

比如：

- • 需求阶段：Product Analyst 生成需求，Reviewer 按完整性、可测量性、优先级评估
- • 建模阶段：Product Analyst 生成领域模型，Reviewer 检查边界、聚合粒度、一致性
- • 架构阶段：System Architect 生成架构，Reviewer 检查需求覆盖、可追溯性、简洁性
- • 实现阶段：impl-module 写代码，impl-reviewer 独立评审

这里的 Evaluator 不是“礼貌地提建议”，而是一个对抗性评估者。它必须基于 Rubric 找问题。

这也是 agentic coding 和普通 prompt 最大的区别之一：

```
不是让模型自己变严谨，而是把严谨性设计成流程。
```

## 6\. Checkpoint：阶段之间不靠聊天记录传递

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

长上下文是 LLM 工作流的大敌。

如果所有信息都堆在一次对话里，模型会逐渐丢失中间信息，也会把历史讨论、临时假设、最终决策混在一起。

所以这套 workflow 使用 checkpoint 作为阶段边界。

每个阶段结束后，都产出一个结构化 YAML：

```
checkpoint-1-discovery.yaml      需求
checkpoint-2-modeling.yaml       领域模型
checkpoint-3-architecture.yaml   架构与 ADR
checkpoint-4-specification.yaml  DDL / API / 部署规格
checkpoint-5-review.yaml         评审和技术债
```

下一阶段只读 checkpoint，不依赖上一阶段的聊天记录。

这有几个好处：

1. 1\. 状态可审计
2. 2\. 决策可追溯
3. 3\. 阶段之间可以上下文重置
4. 4\. 实现阶段有明确规格，不靠模型临场发挥

我认为 checkpoint 是整个 workflow 的核心资产。

没有 checkpoint，Agent 只是在“聊天”。

有了 checkpoint，Agent 才是在“执行规格”。

## 7\. Hooks：把规则从提醒变成机制

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

仅靠 prompt 约束 Agent 是不够的。

你告诉它“不要修改测试”，它还是可能修改。

你告诉它“不要改 checkpoint”，它还是可能改。

你告诉它“记得跑测试”，它可能说自己跑了，但实际上没有跑。

所以在实现阶段，我使用 hooks 把规则变成机制。

典型 hooks 包括：

```
PreToolUse
  - protect-checkpoints.sh
  - forbid-test-edit.sh
  - enforce-test-scope.sh
  - block-dangerous-commands.sh

PostToolUse
  - auto-format.sh

SubagentStop
  - verify-red.sh
  - verify-green.sh
  - verify-deploy.sh
  - verify-infra.sh
```

举几个例子。

`impl-acceptance` 只能写测试、契约和模型，不能写实现。

`impl-module` 可以写实现，但不能改测试。

任何 Agent 都不能随便修改 checkpoint。

Agent 结束后，系统自动跑对应验证脚本。

这就是从“文档治理”变成“系统治理”。

不是提醒 Agent 要守规矩，而是让它无法轻易越界。

## 8\. tech-profile：让工作流语言无关

如果 workflow 只能服务 Go 项目，那它的价值有限。

如果只能服务 Python 项目，也一样。

所以我设计了 `tech-profile.yaml` 作为语言抽象层。

它把语言相关命令全部封装起来：

```
language:go
commands:
build:"go build ./..."
test:"go test ./..."
lint:"go vet ./..."
format:"gofmt -w {file}"
compile_check:"go build ./..."
patterns:
source:"**/*.go"
test:"**/*_test.go"
structure:
entry_point:"cmd/server/main.go"
shared_dir:"internal/shared"
```

这样 Agent 和 Hook 不需要知道项目到底是 Go、Python、TypeScript 还是 Rust。

它们只需要读取：

```
commands.build
commands.test
commands.lint
commands.format
```

这让 workflow 的核心逻辑保持稳定，具体技术栈由 profile 适配。

## 9\. 环境与配置：不要让 Agent 猜运行环境

除了语言抽象，另一个容易被忽略的问题是环境和配置。

很多 agentic coding demo 可以直接在本地跑，是因为 demo 的环境是隐含的：数据库在哪里、端口是多少、有没有外部 API Key、消息队列是否存在，这些都被默认处理掉了。

但真实项目不一样。

真实项目里，Agent 必须先知道：

```
应用部署到哪里？
依赖服务在哪里？
外部 API 需要哪些密钥？
哪些配置可以默认？
哪些配置必须由用户提供？
哪些依赖现在没有，只能 mock 或 skip？
```

所以 `/implement` 启动前，主 session 会先收集三类信息。

第一类是应用部署目标：

```
local         本地开发运行
remote-ssh    SSH 到远程服务器部署
docker-remote 远程 docker-compose 部署
k8s           Kubernetes 集群部署
```

第二类是基础设施服务模式：

```
PostgreSQL: local / external / skip
Kafka:      local / external / skip
Redis:      local / external / skip
ClickHouse: local / external / skip
```

第三类是外部 API 和密钥：

```
RPC URL
API Key
Webhook URL
Subgraph URL
第三方服务 endpoint
```

这里有一个重要原则：

```
密钥不进入代码，不进入 checkpoint，也不进入 deploy-manifest。
```

它们只进入 `.env` ，并通过 `.env.example` 和 `scripts/env-check.sh` 做声明和检查。

这部分最终会被固化到两个文件：

```
tech-profile.yaml      说明这个项目怎么构建、测试、格式化、运行
deploy-manifest.yaml   说明这个项目部署到哪里、依赖哪些服务、如何验证
```

`deploy-manifest.yaml` 更像是环境合约。它会描述：

```
deploy_target       应用部署目标
infrastructure      PostgreSQL、Kafka、Redis 等依赖服务
external_apis       外部 API、RPC、Webhook 等依赖
application         服务端口、worker、日志、metrics
env_vars            required secrets 和 optional vars
feature_deploy_map  每个功能如何部署、如何 smoke test
```

为什么这件事要放在 spawn agent 之前？

因为子 agent 被启动后，通常不能再向用户提问。如果部署目标、数据库连接、API Key 状态没有提前确认，后面的 agent 就只能猜。

Agent 一旦开始猜环境，问题会非常多：

- • 把本地服务当成外部服务
- • 把外部服务写死在代码里
- • 在测试里依赖真实 API
- • 忘记生成 `.env.example`
- • 部署脚本只适配本地，不能适配远程
- • smoke test 只能测 `/health` ，不能测真实功能

所以环境声明是 Phase 0 的核心任务。

这一步不是“运维细节”，而是 agentic coding 可持续运行的前提。

如果说 checkpoint 解决的是“做什么”， `tech-profile.yaml` 解决的是“怎么构建”，那么 `deploy-manifest.yaml` 解决的就是：

```
这套东西到底在哪个环境里运行，依赖什么，如何证明它真的跑起来了。
```

## 10\. /change：真正的项目一定需要增量变更

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

很多 agentic coding demo 只展示从 0 到 1。

但真实项目里，更常见的是：

- • 新增一个功能
- • 修改一个已有能力
- • 修一个 bug
- • 重构一个模块
- • 增加一个外部依赖
- • 调整 API 规格

所以我单独设计了 `/change` 流程。

它不是直接让 Agent 改代码，而是先做影响分析：

```
Stage A: ANALYZE
  扫描 checkpoint
  扫描代码库
  找到受影响模块
  检测新增环境依赖
  生成 change-request

Stage B: DESIGN
  增量更新相关 checkpoint
  做 G-E 收敛

Stage C: IMPLEMENT
  复用 RALPH 循环实现变更

Stage D: REGRESS
  全量测试、smoke test、独立评审
```

这一步非常重要。

因为已有项目最怕的不是“功能写不出来”，而是“不知道改动影响了哪里”。

所以 `/change` 的核心不是 coding，而是 impact analysis。

## 11\. 如何设计自己的 Agentic Coding Workflow

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

如果你也想设计自己的工作流，我建议不要一上来就写很多 Agent。

可以按这个顺序来：

### 第一步：写下你自己的开发习惯

比如：

```
我做需求前一定会先问哪些问题？
我做架构时最在意哪些权衡？
我写代码前必须有哪些规格？
我认为一个功能怎样才算完成？
我平时最容易忘记跑哪些检查？
```

这些就是你的 workflow 原型。

### 第二步：把重复判断抽成 knowledge

如果你经常做数据库选型，就写一个 `data-systems.md` 。

如果你经常做 API 设计，就写一个 `api-design.md` 。

如果你经常做领域拆分，就写一个 `domain-modeling.md` 。

不要把这些写进 prompt，要放进 skill 的 knowledge 目录。

### 第三步：定义 checkpoint

每个阶段都应该有明确产物。

```
需求阶段产出什么？
建模阶段产出什么？
架构阶段产出什么？
实现阶段依赖什么？
变更阶段记录什么？
```

如果阶段之间没有结构化产物，workflow 就无法长期运行。

### 第四步：设计 Agent 边界

不要让一个 Agent 做所有事。

至少要拆出：

```
Lead       调度者
Generator  生成者
Reviewer   评估者
Deploy     环境和部署负责人
Acceptance 测试负责人
Module     实现负责人
```

每个 Agent 要有清晰的权限边界。

### 第五步：用 Hooks 固化规则

你越在意的规则，越不要只写在 prompt 里。

要用 hook 固化。

```
不能改 checkpoint -> hook
不能改测试 -> hook
必须跑验证 -> hook
危险命令拦截 -> hook
自动格式化 -> hook
```

Agentic workflow 的可靠性，不来自模型听话，而来自系统约束。

## 结语

这套 Product Design Workflow 的核心，不是我写了多少 prompt，也不是我用了多少 Agent。

真正核心的是一个判断：

```
AI 编程的瓶颈，不是生成代码。
瓶颈是规格、验证、集成、部署和变更管理。
```

所以我的设计不是让 Claude Code “一次生成完整项目”，而是让它进入一套可持续的工程系统：

```
Skill 提供知识
Checkpoint 固化状态
Evaluator 独立质疑
RALPH 控制 WIP
Hooks 强制验证
每个功能小批量交付
```

当我们用这种方式使用 Claude Code 时，角色就变了。

我们不再只是使用一个现成工具，而是在设计自己的开发系统。

AI 不只是帮我们写代码，而是成为我们工程方法的一部分。

**微信扫一扫赞赏作者**

继续滑动看下一个

智熵流

向上滑动看下一个