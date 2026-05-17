---
title: "AI编程五把利器：GSD、Superpowers、Skills、OpenSpec、BMAD选哪个"
source: "https://mp.weixin.qq.com/s/icTfd7hzgoyb_GWp_0ndjg"
author:
  - "[[AI 解放人类]]"
published:
created: 2026-05-15
description: "AI编程五把利器：GSD、Superpowers、Skills、OpenSpec、BMAD选哪个"
tags:
  - "clippings"
---
AI 解放人类 *2026年4月29日 11:37*

## AI编程五把利器：GSD、Superpowers、Skills、OpenSpec、BMAD选哪个

最近AI编程工具爆发得有点猛。光一个Claude Code，围绕它的工作流框架就冒出来一堆——GSD、Superpowers、mattpocock/skills、OpenSpec、BMAD。

每个都说自己是"最优解"。实际上它们解决的是完全不同的问题。今天把这五个放在一起，理清楚它们的本质差异，并给出具体怎么用。

---

## GSD：解决AI"失忆症"

### 它解决什么问题

AI编程有个臭名昭著的问题——对话一长，AI就开始遗忘早期的决策、上下文乱掉、产出质量下降。越复杂的任务，上下文越容易腐烂。

GSD（Get Shit Done）用"上下文隔离"来解决这个问题。它把一个完整项目拆成多个独立阶段，每个阶段有自己专属的记忆空间，互不干扰。

### 核心工作原理

GSD的四阶段循环：

1. **讨论（Discuss）** ：AI像资深架构师一样追问你细节，把决策记录在案
2. **计划（Plan）** ：生成原子化任务，每个不超过3个操作步骤
3. **执行（Execute）** ：无依赖的任务在独立子代理里并行跑，每个有20万token"专属记忆"
4. **验证（Verify）** ：全新代理对照目标，引导你手动测试

关键是"波浪式并行"——把无依赖的任务放同一波，一起执行，互相不干扰。上一波做完再进下一波。这样每个子代理的上下文都是干净的，不受其他任务影响。

### 安装方法

GSD安装只需要一行命令：

```
npx get-shit-done-cc@latest
```

安装过程中会提示你选择AI运行时（Claude Code、OpenCode等），全程无需复杂配置。如果你是首次使用，建议选择Claude Code作为运行时。

### 初始化新项目

安装完成后，新建项目的命令是：

```
/gsd:new-project
```

GSD会通过一系列问题引导你定义项目愿景、目标、技术栈和约束：

- 项目叫什么名字
- 主要解决什么问题
- 用什么技术栈
- 有什么特殊约束（比如必须兼容旧系统）

回答完这些问题后，GSD会自动生成三个核心文件：

- **PROJECT.md** ：项目愿景和总体描述
- **REQUIREMENTS.md** ：详细需求清单
- **ROADMAP.md** ：分阶段路线图

这三个文件就是后续所有任务的"永久记忆"。AI在任何阶段都可以回读这些文件，保持上下文一致。

### 按阶段推进开发

每个阶段都有独立的命令，分四步走：

```
# 第一阶段：讨论需求
/gsd:discuss-phase 1

# 生成第一阶段任务计划
/gsd:plan-phase 1

# 执行第一阶段任务
/gsd:execute-phase 1

# 验证第一阶段产出
/gsd:verify-work 1
```

每个阶段完成后，重复这个循环进入下一阶段，直到项目交付。

### GSD的能力矩阵

| 能力项 | 说明 |
| --- | --- |
| 上下文隔离 | 每个子代理有独立记忆空间，互不污染 |
| 波浪式并行 | 无依赖任务同时执行，充分利用AI并行能力 |
| 自动任务拆解 | 根据目标自动拆成原子化任务 |
| 决策追溯 | 所有讨论记录在案，方便回顾 |
| 验证驱动 | 新代理验证产出，确保符合目标 |

### 适合谁

复杂长任务，比如一个完整项目从零到上线。GSD能让AI在几十步的工作流里保持专注不跑偏。

不适合的场景：简单的一次性任务（比如查个bug、改个配置），用GSD反而杀鸡用牛刀。

---

## Superpowers：给AI上纪律

### 它解决什么问题

不是AI不能写代码，是它写代码的时候太"随意"——不写测试、不做设计、不想后果。代码质量全凭运气。

Superpowers用一套七步流程强制约束，让AI必须按工程纪律办事。

### 核心工作原理

Superpowers的七步流程：

1. **头脑风暴** ：AI先通过苏格拉底式提问理解需求，禁止写代码
2. **隔离工作空间** ：用git-worktrees给每个任务建干净目录
3. **拆解任务** ：设计文档变成功耗2-5分钟的原子化清单
4. **TDD开发** ：先写失败测试，再写功能代码，最后重构
5. **子代理执行** ：任务分派给独立上下文子代理，主代理退居项目经理角色
6. **持续代码审查** ：每完成一个任务就审查，不是最后才审
7. **完成分支** ：清理工作空间，合并或创建PR

TDD是强制性的——没有失败测试，AI不能写任何功能代码。这和传统TDD的要求一样，只是现在连AI也必须遵守。

### 安装方法

Superpowers通过插件市场安装：

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

安装完成后，你会看到新的斜杠命令可用。首次使用建议先跑一下 `/brainstorm-project` 熟悉流程。

### 核心命令一览

Superpowers提供一系列斜杠命令，完整覆盖开发周期：

```
# 头脑风暴，启动需求澄清（AI会追问很多问题来理解需求）
/brainstorm-project

# 生成产品需求文档
/create-prd

# 设计技术架构
/create-architecture

# 拆分任务为独立Story
/create-epics-and-stories

# 开发具体Story
/dev-story
```

### 内置自动触发技能

Superpowers内置14+个自动触发技能，AI会在关键节点自动激活：

| 技能 | 触发时机 | 作用 |
| --- | --- | --- |
| brainstorming | 开始新功能时 | 需求澄清，追问细节 |
| test-driven-development | 开始编码时 | 强制执行TDD流程 |
| subagent-driven-development | 有可执行计划时 | 调度子代理执行任务 |
| systematic-debugging | 遇到错误时 | 根因分析 |
| requesting-code-review | 任务完成时 | 启动审查流程 |

不需要你记住什么时候用什么，AI会在关键节点自动激活对应技能。

### TDD的强制执行

这是Superpowers和其他工具最大的区别。当你开始写代码时：

1. AI先写一个必然会失败的测试
2. 然后写功能代码让测试通过
3. 最后重构优化

这个顺序不能乱。没有测试，AI会拒绝写功能代码。这种强制约束确保了代码质量。

### git-worktrees隔离

每个任务在独立的git-worktree里工作：

- 不会污染主分支
- 可以同时处理多个任务而不冲突
- 出问题了直接删除worktree，不影响其他工作

### 适合谁

对代码质量要求高的核心功能开发或重构。如果你团队重视工程质量，Superpowers能帮你把住这道关。

不适合的场景：快速原型验证、一次性脚本、用完就扔的代码。

---

## mattpocock/skills：模块化工具箱

### 它解决什么问题

前面两个都是完整流水线，mattpocock/skills不一样。它不强迫你接受一套完整信仰，而是一个可插拔的工具箱。挑你想用的拿出来组合就行。

这个项目在GitHub已超过37000颗星，是目前最火的AI skills集合。

### 和GSD、Superpowers的本质区别

GSD和Superpowers是"整车"，提供完整的开发流程。Skills是"零件"，你按需组装。

GSD告诉你"按这个流程走完项目"；Superpowers告诉你"每个代码必须先写测试"；Skills告诉你"遇到这个情况，用这个工具"。

### 核心技能详解

**grill-me（最受欢迎）** ：AI扮演"魔鬼代言人"，连续追问把你的模糊想法逼成清晰决策。

比如你说"我想用微服务架构"，它会立刻追问：

- "为什么不用模块化单体？"
- "你准备怎么处理分布式事务？"
- "服务间通信用什么协议？"
- "如果某个服务挂了怎么处理？"

直到你把所有模糊点都想清楚。

**tdd** ：强制执行测试驱动开发，采用垂直分片策略，确保每个功能都是完整、可交付的切片。不是写完代码再补测试，而是测试先行。

**git-guardrails** ：为AI编程助手设置Git安全护栏，防止它误执行高风险命令：

- `git push --force` （强制推送会覆盖历史）
- `git reset --hard` （会丢失未提交的代码）
- `git push -f` （同上）
- 危险的分支操作

**write-a-skill** ：教你创建属于你自己的Skill，将个人经验和团队规范沉淀下来。写好一个skill后，可以分享给团队其他成员。

**setup-pre-commit** ：自动配置pre-commit钩子，在代码提交前做格式化、lint等检查。

其他实用技能：

- `triage-issue` ：自动分类处理GitHub Issue
- `design-an-interface` ：设计接口时追问边界情况和副作用
- `improve-codebase-architecture` ：分析现有代码库结构，提出改进建议

### 安装方法

```
# 安装全套skills（推荐新手）
npx skills@latest add mattpocock/skills

# 安装单个skill（按需取用）
npx skills@latest add mattpocock/skills/grill-me
npx skills@latest add mattpocock/skills/tdd
npx skills@latest add mattpocock/skills/git-guardrails
npx skills@latest add mattpocock/skills/write-a-skill
npx skills@latest add mattpocock/skills/setup-pre-commit
```

### 工作原理

安装后，AI会根据你描述的需求自动匹配相关技能并激活。比如你说"帮我设计一个支付接口"，AI会自动激活design-an-interface技能，追问你各种边界情况。

你只需要正常提出需求，技能会在关键时刻自动介入，不需要手动调用。

### 适合谁

不想被框架绑死、想按需组合的开发者。你可以：

- 只用grill-me来对齐需求
- 只用tdd来保证代码质量
- 组合使用，按场景切换

这个"反框架"的理念和Superpowers、GSD形成了鲜明对比——后者提供高度集成的端到端解决方案，Skills则让你自由组合。

不适合的场景：如果你需要一套完整的项目管理流程，Skills的碎片化可能让你反而不知道从哪开始。

---

## OpenSpec：规格文档先行的项目管理

### 它解决什么问题

团队里最常见的问题：需求不对齐。产品说要做A，开发理解成B，上线后才发现和预期不符。

OpenSpec解决的是需求对齐问题。它的核心是"规格文档"——动手写代码之前，先把"要做什么"对齐、固化。

### 核心工作原理

四步极简工作流：

1. **提案（Proposal）** ：生成proposal.md、design.md、tasks.md
2. **审查对齐（Review）** ：人工确认方向正确
3. **实施（Implement）** ：严格按照任务清单编码
4. **归档（Archive）** ：完成后合并规范文档到archive

它用增量规格管理需求——不需要一次写全所有需求，用补丁（ADDED/MODIFIED/REMOVED）记录变更。这特别适合已有代码的棕地项目，可以渐进式完善规范。

### 增量规格详解

传统的需求文档是一次性写全，后续变更很难追溯。OpenSpec的增量规格不同：

```
# 变更类型：ADDED
## 新增功能：用户登录
- 支持邮箱密码登录
- 支持第三方OAuth登录

# 变更类型：MODIFIED
## 修改功能：用户信息展示
- 原来显示昵称，现改为显示真实姓名

# 变更类型：REMOVED
## 删除功能：旧版API v1
- v1接口已废弃，统一迁移到v2
```

每次变更都是补丁，可以追溯每一步是怎么演进的。

### 安装方法

确保系统已安装 Node.js 20.19.0 或更高版本，然后：

```
# 全局安装
npm install -g @fission-ai/openspec@latest

# 验证安装
openspec --version
```

### 初始化项目

```
# 进入项目目录
cd your-project

# 初始化OpenSpec目录结构
openspec init
```

执行后会创建 `openspec/` 目录，里面包含：

- `proposals/` ：存放提案文档
- `designs/` ：存放设计文档
- `tasks/` ：存放任务清单
- `archive/` ：归档已完成的需求

### 核心命令

```
# 创建一个新变更
/opsx:new add-dark-mode

# "快进"：AI自动补全提案、设计、任务等规划文档
/opsx:ff

# 开始实施
/opsx:apply

# 归档
/opsx:archive
```

`/opsx:new` 后面的名字是你的变更名称，比如 `add-dark-mode` 、 `fix-login-bug` 、 `refactor-payment` 。

`/opsx:ff` 是Fast Forward的缩写，AI会自动根据变更名称推断需要做什么，生成完整的提案、设计、任务文档。

### 棕地项目适配

OpenSpec特别适合已有代码的棕地项目：

- 新需求用增量规格添加，不用重写历史文档
- 变更记录清晰，方便追溯
- 人工审查确保方向不跑偏

对于绿地项目（新开始的项目），OpenSpec同样适用，只是价值不如棕地项目明显。

### 适合谁

多人协作、需求多变的棕地项目，需要严格的需求管理和可追溯性。OpenSpec的工作流约束比Superpowers小，对开发者的体感负担更低。

不适合的场景：简单的一次性脚本开发，用OpenSpec反而增加复杂度。

---

## BMAD：自带团队的敏捷教练

### 它解决什么问题

你一个人要干一个团队的活：架构师、产品经理、测试、开发、运维。全能但全不精。

BMAD的核心是角色扮演。你下一个命令，BMAD会自动给AI分配最合适的专家角色——可能是架构师，可能是测试，可能是产品经理。它模拟一个完整的敏捷团队。

内置34+工作流，覆盖从需求到部署的全周期。还有个Party Mode——同一会话里召集多个专家角色"圆桌会议"，跨职能探讨复杂问题。

### 核心工作原理

BMAD采用四阶段结构：

1. **分析（Analysis）** ：拆解需求，理解真正要解决的问题
2. **规划（Planning）** ：制定实施方案，评估风险
3. **解决方案（Solution）** ：产出具体代码或设计
4. **实施（Implementation）** ：执行并验证

TEA（Test Architect）模块提供基于风险的测试策略和自动化建议。AI的角色分工确保每个产出都有检查，防止AI自由发挥。

### Party Mode详解

这是BMAD最有趣的功能。面对复杂问题时，你可以"召集"多个专家同时讨论：

```
你：我觉得这个系统应该用微服务架构
BMAD：好，让我召集架构师、运维工程师、开发负责人来评估
- 架构师：微服务适合这里，但你有考虑过运维复杂度吗？
- 运维工程师：我需要知道服务间通信量有多大
- 开发负责人：团队有多少人熟悉K8s？
```

多个角色从不同角度审视同一个问题，发现你没想到的盲区。

### 安装方法

```
# 在项目根目录下执行
npx bmad-method install
```

安装成功后，会在项目下生成：

- `_bmad/` ：BMAD配置目录
- `.cursor/commands/` ：集成文件（如果使用Cursor）

### 核心命令

在IDE中直接用斜杠命令驱动：

```
# 创建产品简报
/product-brief

# 创建产品需求文档
/create-prd

# 设计技术架构
/create-architecture

# 拆分为可执行Story
/create-epics-and-stories
```

### TEA测试架构师

BMAD的TEA模块专门处理测试策略：

- 基于风险的测试优先级排序
- 自动化测试覆盖率建议
- 边界条件和异常场景识别

### 内置工作流一览

BMAD内置34+工作流，覆盖各种场景：

| 类别 | 工作流数量 | 示例 |
| --- | --- | --- |
| 需求分析 | 5+ | 产品简报、PRD生成、用户故事 |
| 架构设计 | 6+ | 技术选型、API设计、数据库设计 |
| 开发执行 | 8+ | 代码实现、重构、Bug修复 |
| 测试保障 | 5+ | 测试策略、自动化测试、回归测试 |
| 部署运维 | 4+ | CI/CD配置、监控告警、容器化 |
| 团队协作 | 6+ | Code Review、周报生成、知识沉淀 |

### 适合谁

企业级复杂项目，以及对敏捷流程不熟悉的团队。BMAD像个不会累的敏捷教练，一直引导你走正确流程。

不适合的场景：个人小项目，BMAD的角色扮演可能显得太重。

---

## 一张表看清楚

|  | 核心哲学 | 解决什么问题 | 适合场景 | 典型命令 |
| --- | --- | --- | --- | --- |
| GSD | 结果驱动 | AI上下文腐烂 | 复杂长任务，项目启动 | `/gsd:new-project` 、 `/gsd:execute-phase 1` |
| Superpowers | 纪律驱动 | 代码质量无保障 | 核心功能重构，高质量要求 | `/brainstorm-project` 、 `/dev-story` |
| mattpocock/skills | 按需赋能 | AI缺乏工程流程意识 | 各种规模，按需组合 | `npx skills@latest add mattpocock/skills/tdd` |
| OpenSpec | 规格驱动 | 需求不对齐 | 棕地项目，多人协作 | `openspec init` 、 `/opsx:apply` |
| BMAD | 角色模拟 | 缺乏专业分工 | 企业级项目，敏捷引导 | `/product-brief` 、 `/create-architecture` |

---

## 怎么选

**选GSD** ：你的任务超长，需要AI在长上下文里不跑偏。它通过上下文隔离和波浪式并行，让AI在几十步的工作流里保持专注。

典型场景：一个完整项目从零到上线，需要几十甚至上百个步骤。

**选Superpowers** ：你对代码质量有洁癖，测试是红线。它用强制TDD和持续审查，让AI必须按工程纪律办事。

典型场景：核心业务代码、重构、测试覆盖率要求高的项目。

**选mattpocock/skills** ：你不想被框架绑定，想灵活组合，或者刚从远程桌面转过来不想学习曲线太陡。它的工具箱模式让你按需取用。

典型场景：各种规模的项目，挑你需要的skill用就行。

**选OpenSpec** ：你的项目是棕地，需求经常变化，需要严格的可追溯性。它用增量规格管理需求，不需要一次写全。

典型场景：多人协作的已有代码库，需要变更管理。

**选BMAD** ：你在带团队，团队对敏捷流程不熟，需要一个永不疲倦的教练。它的多角色模拟让你一个人也能调动完整团队。

典型场景：企业级项目，需要架构师、产品、测试多种角色配合。

---

## 可以组合用

这不是非此即彼的选择。

OpenSpec做需求对齐（做什么），Superpowers做代码质量门禁（怎么做），GSD处理长任务执行（怎么做完）。三个组合起来，刚好覆盖一个完整项目从想法到交付的全链路。

mattpocock/skills可以补充到任何一个上面——比如在GSD流程里加入tdd技能，或者在Superpowers里加入grill-me来强化需求对齐。

BMAD也可以和其他工具组合，用它的Party Mode来解决特定复杂决策。

工具是拿来用的，不是拿来信仰的。

---

## 安装命令速查表

```
# GSD
npx get-shit-done-cc@latest

# Superpowers
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace

# mattpocock/skills
npx skills@latest add mattpocock/skills           # 全套
npx skills@latest add mattpocock/skills/grill-me  # 单个skill

# OpenSpec
npm install -g @fission-ai/openspec@latest

# BMAD
npx bmad-method install
```

---

*工具选对了，AI编程效率翻倍。选错了，就是新的枷锁。*

继续滑动看下一个

AI解放人类

向上滑动看下一个