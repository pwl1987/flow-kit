---
title: "又一个神级编程 Skill 开源！一套规则搞定 AI 编码从需求到上线全链路。"
source: "https://mp.weixin.qq.com/s/9vt4zXoKbMbA0oKmSQb7ug"
author:
  - "[[摸鱼挖开源]]"
published:
created: 2026-05-15
description: "agent-skills 是 Addy Osmani 开源的一套面向 AI 编码代理的工程技能包。是一组可被 Claude Code、Cursor、Gemini CLI、GitHub Copilot等工具消费的技能文件和规则模板。"
tags:
  - "clippings"
---
摸鱼挖开源 *2026年5月7日 14:22*

## agent-skills

`agent-skills` 是 Addy Osmani 开源的一套面向 AI 编码代理的工程技能包。

是一组可被 Claude Code、Cursor、Gemini CLI、GitHub Copilot等工具消费的技能文件和规则模板。

用来约束 AI 在需求定义、规划、实现、测试、评审、上线这些环节的行为。

![[_resources/又一个神级编程 Skill 开源！一套规则搞定 AI 编码从需求到上线全链路。/178b826888c9b91f3f70d183401b92b1_MD5.webp]]

这个项目现在在 GitHub 上已经拿到 **3 万+ Star** ，核心是把资深工程师常用的工作流拆成 `SKILL.md` 、命令入口、Persona 和 Checklist。

如果你平时会把 AI 用在写需求、改代码、补测试、做 Code Review，或者你在团队里已经开始让 AI 参与研发流程，那这个项目的价值在于把 AI 输出拉回可验证、可复用、可审查的工程里。

比如你让 AI 帮你做一个功能，第一轮它直接开始写代码，写完后没有测试；测试挂了就继续修；修到最后，需求边界、接口设计、回滚方案全是临时想出来的。

![[_resources/又一个神级编程 Skill 开源！一套规则搞定 AI 编码从需求到上线全链路。/4f91874d727e6c8d4394a8074bd24fe2_MD5.webp]]

单次看起来省时间，累计起来就会出现每次产出很快，但是返工更多的循环。

agent-skills的切入点就是把这些工程动作包装成 AI 可遵循的技能，让代理在不同阶段自动切换到合适的方法，而不是每次都根据模糊的prompt。

最常见的使用流程有两个：

**个人开发流** ：先用 `/spec` 明确需求，再 `/plan` 拆任务，随后 `/build` 和 `/test` 交替推进，最后 `/review` 做提交前自检。

**团队规则流** ：把相关 `SKILL.md` 、Persona、Checklist 放进 IDE 规则目录或仓库说明文件里，让代理在长期协作中持续遵守同一套标准。

### 核心功能：

### 1\. 用/spec把想法变成可执行规范

比如你在做一个新功能，脑子里只有做个后台告警聚合页思路，这时最容易出现的问题是AI 直接开始实现，但目标用户、边界、命令、代码风格、测试要求都没定，后面改一次就牵一大片。

这个项目对应的能力是spec-driven-development，并通过 `/spec` 作为入口。

它会在编码前先写 PRD，覆盖 objectives、commands、structure、code style、testing 和 boundaries。

并且 `/spec` 是在支持 slash command 的代理环境里调用的，如果你用的是不支持命令的工具，也可以直接复用对应 `skills/spec-driven-development/SKILL.md` 的内容。

对于需求容易漂移、多人协作频繁、AI 经常脑补需求的团队，它能先把分歧前置，而不是把问题留到代码阶段。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### 2\. 需求有了，但任务太大？/plan 强制拆成可验证的小步

再比如一个场景，你已经有了需求说明，但要做的事跨前后端、接口、测试、发布，AI 很容易一次生成一大坨改动，结果要么不好 review，要么一改全乱。

这里对应的是 planning-and-task-breakdown，入口命令是 `/plan` 。

agent-skills 把规格分解成 small, verifiable tasks，并带上 acceptance criteria 和 dependency ordering，它要求任务颗粒度足够小，而且每一步都能验收。

这和很多人常见的让 AI 给个实现方案不太一样。

普通方案容易停留在目录级建议， `agent-skills` 更强调原子化任务和先后依赖，便于你把大需求切成多次提交、多次验证。

对个人开发者来说，这能避免 AI 一口气改 20 个文件；对团队来说，它直接降低了 code review 和回滚的复杂度。

```
Database schema
    │
    ├── API models/types
    │       │
    │       ├── API endpoints
    │       │       │
    │       │       └── Frontend API client
    │       │               │
    │       │               └── UI components
    │       │
    │       └── Validation logic
    │
    └── Seed data / migrations
```
![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### 3\. 写代码不是一次成片，而是 /build 走薄切片增量实现

很多人让 AI 改代码时最头疼的一点，是它喜欢顺手重构一大片，功能还没验证，可能周边结构先被改了，最后难以定位问题来自哪里。

`agent-skills` 在 Build 阶段给出的主能力是 incremental-implementation，通过 `/build` 进入。

采用 thin vertical slices，实现、测试、验证、提交一体推进，并强调 feature flags、safe defaults、rollback-friendly changes。

先打一条能工作的纵向链路，再继续扩展，而不是让 AI 一次性铺完整架构。如果你在做接口改造、页面接入或多文件联动，这种方式尤其有用，因为每一小步都保留了验证点和回退点。

这样做的好处是当 AI 参与真实项目，而不是玩具 demo 时，增量式实现能明显减少改得快、死得也快的情况。

```
┌──────────────────────────────────────┐
│                                      │
│   Implement ──→ Test ──→ Verify ──┐  │
│       ▲                           │  │
│       └───── Commit ◄─────────────┘  │
│              │                       │
│              ▼                       │
│          Next slice                  │
│                                      │
└──────────────────────────────────────┘
```
![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### 4\. 代码写完不算完成，/test 把项目实际落地

这个项目在 Verify 阶段提供了两类关键技能： `/test` 对应 test-driven-development，还有 debugging-and-error-recovery、browser-testing-with-devtools。

如果你是在浏览器环境里调 UI 或前端交互，它还支持基于 Chrome DevTools MCP 的调试与运行时检查，包括 DOM inspection、console logs、network traces、performance profiling。

对使用者来说，它把测试是证明写成了流程规则，对于 AI 辅助开发，可以更加保证项目开发出来后的质量。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### 5\. 合并前使用/review 和 Persona 把质量门禁结构化

如果你带过团队，应该遇到过这种情况,AI 提交的改动能跑，但 review 时发现接口命名不稳、边界校验缺失、安全风险没覆盖，最后 reviewer 只能靠经验逐条挑。

`agent-skills` 在 Review 阶段提供了 code-review-and-quality、code-simplification\*\*、security-and-hardeningdeng ，并且额外提供了 `agents/` 目录下的 Persona.

分别从资深工程师、QA、Security 的角度做有针对性的检查。

这意味着不仅可以让 AI 写代码，也可以让它切换成不同审查角色去看待同一份改动。

再加上 `references/` 目录中的 testing、security、performance、accessibility checklist，review 就不再完全依赖个人记忆。

对于多人协作团队，这种角色化 review + checklist尤其适合做统一质量标准；对于个人项目，它至少能帮你在提交前多一道结构化自检。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### agent-skills和普通开发方案区别

普通 prompt 工程更像是每次临场写一段提示词，效果高度依赖个人表达，而且很难跨工具复用。

`agent-skills` 的差异在于它把这些经验沉淀成了结构化技能，有触发时机、有步骤、有验证要求，甚至还有 anti-rationalization，也就是专门反驳 AI 常见偷懒借口的表格。

和很多AI 编码模板库相比，它也不只是给几个提示词片段，而是覆盖从定义、计划、实现、验证到上线的完整链路。

再加上支持 Claude Code、Cursor、Gemini CLI、Copilot 等多个环境，迁移成本相对低。

但要注意它解决的是 **流程治理和工程约束** ，不是替代模型能力本身，模型推理质量差、项目上下文不全、仓库本身测试薄弱，这些问题不会因为装了技能包就自动消失。

```
开源地址：https://github.com/addyosmani/agent-skills
```

如果你也对这类前沿开源项目感兴趣，想第一时间看到真正有潜力的 GitHub 热门项目解析，关注本公众号。

后面我还会继续挖更多值得收藏、值得实操、值得思考的开源好东西。

继续滑动看下一个

摸鱼挖开源

向上滑动看下一个