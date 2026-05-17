---
title: "AI 编程工作流选型：Spec-Kit、OpenSpec、Superpowers 深度对比"
source: "https://mp.weixin.qq.com/s/4V9LTNFmCQvuIvtQohNH1A"
author:
  - "[[运维有术]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
运维有术 *2026年3月27日 08:30*

> 🚩 2026 年「术哥无界」系列实战文档 X 篇原创计划 第 *64* 篇，AI 编程最佳实战「2026」系列第 *8* 篇
> 
> 大家好，欢迎来到 **术哥无界 | ShugeX ｜ 运维有术** 。
> 
> 我是 **术哥** ，一名专注于 AI 编程、AI 智能体、Agent Skills、MCP、云原生、AIOps、Milvus 向量数据库的 **技术实践者与开源布道者** ！
> 
> **Talk is cheap, let's explore。无界探索，有术而行。**

![[_resources/AI 编程工作流选型：Spec-Kit、OpenSpec、Superpowers 深度对比/ae0f0fda743ddb3d93f8f25db6e0d550_MD5.webp]]

AI 编程工作流选型对比

*图 1：Spec-Kit、OpenSpec、Superpowers 三款 AI 编程工作流工具对比*

用 AI 编程代理写代码，你有没有遇到过这些问题：

- 代理写出的代码风格飘忽不定，每次都要重新解释项目规范
- 多人协作时代理理解不一致，同样的需求给出完全不同的实现
- 想让代理遵循测试驱动开发，但它总爱跳过测试直接写代码

这些问题背后是同一个核心矛盾： **AI 代理缺乏结构化的工作流约束** 。

解决方案有三个热门选手：GitHub 官方的 **Spec-Kit** （82.5K Star）、轻量级的 **OpenSpec** （34.5K Star）、技能驱动的 **Superpowers** （115K Star）。看着都是"规范驱动"，但底层哲学完全不同——选错了就是工具束缚人。

花时间对比了三者的官方文档和实现机制，把差异梳理清楚了。

## 1\. 三者的背景与定位

### Spec-Kit：规范可执行化

GitHub 官方出品，由 Den Delimarsky 和 John Lam 等核心开发者维护。

官方定位很明确：

> **Spec-Driven Development flips the script on traditional software development. Specifications become executable, directly generating working implementations rather than just guiding them.**

翻译过来：规范不只是"指导文档"，而是 **可执行的** ——能直接生成工作代码。

Spec-Kit 的核心是七个阶段： `constitution` （项目治理）→ `specify` （定义需求）→ `clarify` （澄清模糊）→ `plan` （技术计划）→ `tasks` （任务分解）→ `analyze` （一致性检查）→ `implement` （执行实现）。

每个阶段都有明确的输入输出，像工厂流水线一样。

### OpenSpec：轻量规范层

Fission-AI 团队开发，核心理念是四个词： **fluid、iterative、easy、built for brownfield** 。

官方定义：

> **A lightweight spec-driven framework for coding agents and CLIs — universal, open source, and no API keys or MCP required.**

关键点：轻量级、通用、 **无需 API Key 和 MCP** 。

OpenSpec 不追求"规范生成代码"，而是做一层轻量的规范管理——通过 `/opsx:propose` （创建提案）→ `/opsx:apply` （执行）→ `/opsx:archive` （归档）的流程，让规范成为活文档。

### Superpowers：技能驱动工作流

Jesse Vincent（obra）出品，社区规模最大——115K Star。

官方定义：

> **A complete software development workflow for your coding agents, built on top of a set of composable 'skills'.**

关键词： **技能组合** 。Superpowers 不是规范驱动，而是通过一组可组合的"技能"来约束代理行为。

核心技能包括： `test-driven-development` （强制 TDD）、 `systematic-debugging` （系统化调试）、 `brainstorming` （苏格拉底式设计细化）、 `subagent-driven-development` （子代理并发执行）等。

## 2\. 技术架构深度对比

### 底层实现机制

![架构对比](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

架构对比

*图 2：三者的技术架构对比（技术栈、核心组件、数据流）*

**Spec-Kit 的架构** ：

```
┌─────────────────────────────────────────────┐
│              Specify CLI (Python)            │
├─────────────────────────────────────────────┤
│  Templates  │  Extensions  │  Presets       │
├─────────────────────────────────────────────┤
│         AI Agent Integration Layer          │
│  Claude │ Copilot │ Cursor │ Gemini │ ...  │
└─────────────────────────────────────────────┘
```

Spec-Kit 基于 Python，使用 `uv` 作为包管理器。核心是 **模板引擎 + 扩展系统** ——规范通过模板渲染成代码，扩展系统允许自定义工作流。

```
# 伪代码：Spec-Kit 的规范执行流程
class SpecKit:
    def execute_spec(self, spec_content):
        plan = self.plan_engine.generate(spec_content)
        tasks = self.task_breakdown.decompose(plan)
        return self.implementation_engine.execute(tasks)
```

**OpenSpec 的架构** ：

```
openspec/
├── changes/           # 活跃变更
│   └── add-dark-mode/
│       ├── proposal.md
│       ├── design.md
│       ├── tasks.md
│       └── specs/
├── specs/            # 持久规范
└── archive/          # 归档变更
```

OpenSpec 基于 TypeScript，核心是 **变更驱动的工作流** 。每个功能变更是独立目录，包含提案、设计、任务和规范增量（Spec Delta）。

```
// 伪代码：OpenSpec 的变更管理
class OpenSpec {
  async propose(description: string): Promise<Change> {
    const change = await this.changes.create(description);
    const affectedSpecs = await this.specs.findRelated(description);
    change.specDeltas = await this.generateSpecDeltas(affectedSpecs);
    return change;
  }
}
```

**Superpowers 的架构** ：

```
┌────────────────────────────────────────┐
│           Skills Library               │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐  │
│  │ Testing │ │Debugging│ │  Collab │  │
│  └─────────┘ └─────────┘ └─────────┘  │
├────────────────────────────────────────┤
│           Hooks System                 │
│  Pre-task │ Post-task │ Triggers      │
├────────────────────────────────────────┤
│       Agent Integration                │
└────────────────────────────────────────┘
```

Superpowers 基于 Shell/JavaScript，核心是 **技能触发系统** ——不是手动调用命令，而是通过 Hook 自动激活相关技能。

```
# 伪代码：Superpowers 的技能触发
trigger(event, context) {
  for (const skill of this.findRelevantSkills(event)) {
    if (skill.shouldActivate(context)) {
      return skill.execute(context);
    }
  }
}
```

### 数据流对比

| 维度 | Spec-Kit | OpenSpec | Superpowers |
| --- | --- | --- | --- |
| 规范存储 | 中心化配置文件 | 分布式目录结构 | 无独立规范层 |
| 变更追踪 | Git 分支隔离 | changes/ 目录 | Git Worktrees |
| 状态管理 | 阶段门控 | 提案状态 | 技能激活状态 |

## 3\. 核心特性对比

![核心特性雷达图](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

核心特性雷达图

*图 3：三者在易用性、工具支持、流程严格度等多维度的能力对比*

| 维度 | Spec-Kit | OpenSpec | Superpowers |
| --- | --- | --- | --- |
| **核心范式** | 规范可执行化 | 轻量规范层 | 技能组合 |
| **主要语言** | Python | TypeScript | Shell/JavaScript |
| **Star 数** | 82.5K | 34.5K | 115K |
| **安装方式** | `uv tool install` | `npm install -g` | 插件市场/手动配置 |
| **AI 代理支持** | 11+ | 20+ | 5+ |
| **是否需要 API Key** | 取决于代理 | ❌ 不需要 | 取决于代理 |
| **是否需要 MCP** | 取决于代理 | ❌ 不需要 | 取决于代理 |
| **TDD 强制** | ❌ 不强制 | ❌ 不强制 | ✅ 强制 |
| **Brownfield 支持** | ✅ 支持 | ✅ 优先设计 | ✅ 支持 |
| **团队协作** | ✅ 企业级 | 🚧 开发中 | ✅ Discord 社区 |
| **学习曲线** | 中等 | 平缓 | 平缓 |
| **定制性** | 高（扩展/预设） | 中等 | 高（技能系统） |

几个关键差异点：

**工具支持范围** ：OpenScore 支持最广（20+ 工具），包括 Claude Code、Cursor、Codex、Windsurf、Gemini CLI 等。Spec-Kit 支持 11+，Superpowers 专注少数平台（主要为 Claude Code 优化）。

**TDD 强制** ：只有 Superpowers 强制 RED-GREEN-REFACTOR 循环。如果你的团队对测试有严格要求，这是重要考量。

**Brownfield 支持** ：OpenSpec 明确打出 **built for brownfield** 的旗号——它的设计优先考虑现有代码库的渐进式改造。

## 4\. 工作流范式对比

三者最大的差异在于 **工作流范式** ——这是选型的核心依据。

![工作流范式对比](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

工作流范式对比

*图 4：三种工作流范式对比（阶段门控式 vs 流畅迭代式 vs 技能触发式）*

### Spec-Kit：阶段门控式

```
constitution → specify → clarify → plan → tasks → analyze → implement
     ↓            ↓         ↓        ↓       ↓        ↓         ↓
   [门控]      [门控]    [门控]   [门控]  [门控]   [门控]    [门控]
```

每个阶段都是一道"门"——必须完成当前阶段才能进入下一阶段。好处是流程严格、质量可控；坏处是灵活性低，适合大型项目。

Spec-Kit 的哲学是： **结构胜过混乱** 。

### OpenSpec：流畅迭代式

```
/opsx:propose → /opsx:apply → /opsx:archive
      ↓              ↓             ↓
   [提案]         [执行]        [归档]
```

没有严格的阶段门，可以随时调整提案。变更驱动——每个功能是独立的变更目录，完成后归档。

OpenSpec 的哲学是： **迭代胜过瀑布** 。

### Superpowers：技能触发式

```
brainstorming → writing-plans → executing-plans → TDD → code-review
      ↓              ↓               ↓            ↓        ↓
   [自动触发]     [自动触发]       [自动触发]   [自动触发] [自动触发]
```

不是手动调用命令，而是通过上下文自动触发相关技能。比如写代码前自动激活 TDD 技能，写完代码自动激活 code-review 技能。

Superpowers 的哲学是： **流程胜过猜测** 。

### 你适合哪种范式？

| 你的情况 | 推荐范式 | 原因 |
| --- | --- | --- |
| 大型项目、多人协作 | 阶段门控（Spec-Kit） | 质量可控、流程可追溯 |
| 快速迭代、频繁调整 | 流畅迭代（OpenSpec） | 灵活性高、学习曲线低 |
| 质量优先、强制 TDD | 技能触发（Superpowers） | 自动强制质量门 |

## 5\. 实战示例

### Spec-Kit 实战

安装：

```
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

初始化项目：

```
specify init my-project
```

定义规范（`.specify/specs/features/login.md` ）：

```
# User Login Feature

## User Story
As a user, I want to log in to access my account.

## Acceptance Criteria
- User can enter email and password
- System validates credentials
- User receives error message for invalid credentials
- Successful login redirects to dashboard

## Technical Constraints
- Use JWT for session management
- Password must be hashed with bcrypt
```

执行规范生成代码：

```
# 通过 AI 代理调用
/speckit.implement
```

Spec-Kit 会自动解析规范，生成计划，分解任务，然后执行实现。

### OpenSpec 实战

安装：

```
npm install -g @fission-ai/openspec@latest
```

创建变更提案：

```
# 通过 AI 代理调用
/opsx:propose Add dark mode support to the dashboard
```

OpenSpec 会在 `openspec/changes/add-dark-mode/` 目录下生成：

```
add-dark-mode/
├── proposal.md    # 变更提案
├── design.md      # 技术设计
├── tasks.md       # 任务列表
└── specs/         # 规范增量
```

执行实现：

```
/opsx:apply add-dark-mode
```

完成后归档：

```
/opsx:archive add-dark-mode
```

规范会被合并到 `openspec/specs/` 目录，成为持久规范的一部分。

### Superpowers 实战

安装（以 Claude Code 为例）：

```
/plugin install superpowers@claude-plugins-official
```

使用—— **不需要手动调用命令** ，技能会自动触发：

```
# 你只需要说：
我想给登录功能加一个"记住我"选项

# Superpowers 会自动：
1. 激活 brainstorming 技能，细化需求
2. 激活 writing-plans 技能，生成实现计划
3. 激活 test-driven-development 技能，先写测试
4. 实现功能
5. 激活 verification-before-completion 技能，验证修复
6. 激活 requesting-code-review 技能，自我审查
```

核心技能示例：

```
# test-driven-development skill

## Trigger
When writing new code or modifying existing code

## Workflow
1. RED: Write a failing test
2. GREEN: Write minimal code to pass
3. REFACTOR: Improve code quality
4. Repeat until feature complete

## Constraints
- Never skip the RED phase
- Always run tests after GREEN phase
- Refactor only when tests pass
```

## 6\. 技术选型建议

![技术选型决策树](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

技术选型决策树

*图 5：根据项目场景快速选择合适的 AI 编程工作流工具*

### 企业级项目场景

**推荐：Spec-Kit**

理由：

- GitHub 官方维护，长期支持有保障
- 阶段门控确保质量可控
- 丰富的扩展生态支持定制化
- 企业级团队功能成熟

适合：大型团队、严格流程要求、需要可追溯性的项目。

### 快速迭代场景

**推荐：OpenSpec**

理由：

- 轻量级，学习曲线平缓
- 流畅迭代，无需严格门控
- 支持 20+ 工具，切换成本低
- 无需配置 API Key 和 MCP

适合：创业团队、个人项目、需要频繁调整方案。

### 质量优先场景

**推荐：Superpowers**

理由：

- 强制 TDD，质量有保障
- 自动技能触发，减少人为疏漏
- 子代理并发执行，效率高
- 社区规模最大（115K Star）

适合：对代码质量有严格要求、重视测试覆盖率的团队。

### Brownfield（遗留系统）改造场景

**推荐：OpenSpec**

理由：

- 明确打出"built for brownfield"旗号
- 变更驱动，适合渐进式改造
- 规范持久化在代码库中，不影响现有结构
- 灵活迭代，不需要一次性迁移

适合：现有代码库的渐进式现代化。

### 跨工具开发场景

**推荐：OpenSpec**

理由：

- 支持 20+ AI 编程工具
- 切换工具无需重新配置
- 规范是通用格式

适合：需要在不同 AI 工具间切换的开发者。

### 需要规范生成代码的场景

**推荐：Spec-Kit**

理由：

- 规范可执行化是核心定位
- 模板引擎支持代码生成
- 扩展系统支持自定义生成逻辑

适合：希望通过规范自动生成代码的场景。

## 7\. 三者的局限与权衡

没有完美工具，选型本质是做权衡。

### Spec-Kit 的局限

- **相对重量级** ：需要 Python 3.11+ 和 uv，环境配置有一定门槛
- **阶段门较严格** ：不适合需要频繁调整方向的项目
- **学习曲线较陡** ：七个阶段需要时间理解

### OpenSpec 的局限

- **规范不直接生成代码** ：只能指导，不能执行
- **企业功能开发中** ：团队协作功能尚不完善
- **社区规模较小** ：34.5K Star，生态相对薄弱

### Superpowers 的局限

- **非规范驱动** ：没有独立规范层，规范是副产品
- **依赖代理平台** ：安装方式因平台而异
- **缺少正式文档站点** ：主要靠 GitHub README 和社区

## 总结

三个工具的核心差异可以概括为一句话：

- **Spec-Kit** ：规范 **可执行** ，生成代码
- **OpenSpec** ：规范 **轻量化** ，灵活迭代
- **Superpowers** ：技能 **自动触发** ，强制质量

选型建议：

| 场景 | 推荐 |
| --- | --- |
| 大型企业项目 | Spec-Kit |
| 快速迭代/个人项目 | OpenSpec |
| 质量优先/强制 TDD | Superpowers |
| 现有代码库改造 | OpenSpec |
| 跨工具开发 | OpenSpec |
| 需要规范生成代码 | Spec-Kit |

最后说一句：工具是手段不是目的。如果你的项目规模小、团队人数少，简单的 Git 提交规范 + Code Review 可能就够了——别为了用工具而用工具。

你在用哪个 AI 编程工作流工具？评论区聊聊你的选择理由。

**好啦，谢谢你观看我的文章，如果喜欢可以点赞转发给需要的朋友，我们下一期再见！敬请期待！**

**扫码关注，获取更多 AI 工具的实战经验和最佳实践。不错过每一篇干货！**

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**微信扫一扫赞赏作者**

AI编程最佳实战「2026」 · 目录

继续滑动看下一个

术哥无界

向上滑动看下一个