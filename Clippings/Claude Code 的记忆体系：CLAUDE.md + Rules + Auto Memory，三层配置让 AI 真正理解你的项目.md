---
title: "Claude Code 的记忆体系：CLAUDE.md + Rules + Auto Memory，三层配置让 AI 真正理解你的项目"
source: "https://mp.weixin.qq.com/s/xWKmyeUV19zRrAx4G-r7lA"
author:
  - "[[HelloDong]]"
published:
created: 2026-05-15
description: "Claude Code 每次对话都像个失忆的新人？那是因为你没用好它的记忆系统。"
tags:
  - "clippings"
---
HelloDong *2026年3月24日 20:30*

> Claude Code 每次对话都像个失忆的新人？那是因为你没用好它的记忆系统。这篇把 CLAUDE.md、.claude/rules/ 和 Auto Memory 三层配置讲透，配置一次，长期受益。

## 你是不是每次都在重复同样的话？

"我们用 pnpm 不用 npm。" "API 返回格式是 `{ code, data, message }` 。" "组件放 `src/components/` 下，不要放 `src/views/` 。" "写中文注释。"

如果你每次开一个新的 Claude Code 会话都要重复这些指令，说明你没有用好它的记忆系统。

Claude Code 有一套 **三层记忆架构** ，从上到下分别是：

| 层级 | 文件位置 | 谁来写 | 作用域 |
| --- | --- | --- | --- |
| 用户级 | `~/.claude/CLAUDE.md` | 你 | 所有项目 |
| 项目级 | 项目根目录 `CLAUDE.md` + `.claude/rules/*.md` | 你/团队 | 当前项目 |
| 自动记忆 | `~/.claude/projects/<project>/memory/` | Claude 自己 | 当前项目 |

**你写的规则（CLAUDE.md / Rules）告诉 Claude "按我说的做"，自动记忆（Auto Memory）让 Claude 把"学到的东西"记下来。** 两者互补，缺一不可。

## 第一层：CLAUDE.md——你的项目说明书

### 放在哪

```
your-project/
├── CLAUDE.md              ← 项目级（团队共享，提交到 Git）
├── .claude/
│   └── settings.json
├── src/
└── package.json

~/.claude/
├── CLAUDE.md              ← 用户级（个人偏好，不进 Git）
```
- **项目根目录的 `CLAUDE.md`**
	：跟着仓库走，团队所有人共享。写项目的技术栈、架构约定、编码规范
- **`~/.claude/CLAUDE.md`**
	：你个人的全局偏好。写你习惯的代码风格、语言偏好、通用工作流

### 写什么

项目级 CLAUDE.md 模板：

```
# 项目概述

基于 Next.js 15 + TypeScript + Tailwind CSS 的 SaaS 产品。
后端用 Drizzle ORM + PostgreSQL，部署在 Vercel。

## 常用命令

-\`pnpm dev\` 启动开发服务器
-\`pnpm test\` 运行测试（Vitest）
-\`pnpm lint\` 运行 ESLint
-\`pnpm build\` 构建生产版本

## 编码规范

- 使用函数组件 + React Hooks，不用 Class 组件
- 状态管理用 Zustand，不用 Redux
- API 返回格式统一为 \`{ code: number, data: T, message: string }\`
- 文件命名用 kebab-case，组件命名用 PascalCase
- 写中文注释

## 目录结构

-\`src/components/\` — 可复用的 UI 组件
-\`src/app/\` — Next.js App Router 页面
-\`src/lib/\` — 工具函数和业务逻辑
-\`src/db/\` — 数据库 Schema 和查询

## 注意事项

- 不要使用 Pages Router
- 所有 API 路由放在 \`src/app/api/\` 下
- 数据库迁移用 \`pnpm drizzle-kit push\`
```

用户级 `~/.claude/CLAUDE.md` 模板：

```
# 个人偏好

- 用中文回复
- 代码注释用中文
- 优先使用 pnpm
- 喜欢简洁的代码风格，不要过度抽象
- 不需要在每次操作后总结做了什么
```

### 关键原则

**控制在 200 行以内。** Claude Code 启动时读取 CLAUDE.md，超过 200 行的内容在上下文压缩时可能被截断。研究表明， **列表格式比段落格式的遵守率高 60%** ——用 bullet points，别写长段落。

## 第二层：.claude/rules/——按场景加载的模块化规则

CLAUDE.md 解决的是"全局规则"，但很多规则只在特定场景下才需要。比如：

- 写前端组件时，需要加载设计规范
- 写 API 接口时，需要加载接口协议
- 写测试时，需要加载测试约定

**把这些拆到 `.claude/rules/` 目录下，每个文件聚焦一个主题** ：

```
your-project/
├── CLAUDE.md
├── .claude/
│   └── rules/
│       ├── frontend.md      ← 前端组件规范
│       ├── api.md           ← API 接口约定
│       ├── testing.md       ← 测试编写规则
│       └── database.md      ← 数据库操作规范
```

### 所有.md 文件自动加载

不需要任何配置。`.claude/rules/` 下的所有 `.md` 文件会被 Claude Code 自动发现并加载。子目录也支持递归发现。

### 用 Glob 精准控制加载范围

这是 Rules 最强大的特性： **通过 YAML frontmatter 指定文件匹配模式，规则只在操作匹配文件时才生效。**

```
---
paths:
  - "src/components/**/*.tsx"
  - "src/components/**/*.css"
---

# 前端组件规范

- 每个组件一个目录，包含 index.tsx + styles.css
- 使用 Tailwind CSS 工具类，避免自定义 CSS
- 组件 Props 用 interface 定义，不用 type
- 必须导出 displayName
```
```
---
paths:
  - "src/app/api/**/*.ts"
---

# API 接口规范

- 所有接口用 zod 做参数校验
- 返回格式统一为 { code, data, message }
- 错误码遵循 HTTP 标准（400/401/403/404/500）
- 每个接口文件导出 GET/POST/PUT/DELETE 函数
```

**效果** ：当你让 Claude 修改一个 React 组件时，它自动加载 `frontend.md` 的规则；当你让它写 API 接口时，它自动加载 `api.md` 。 **不同场景加载不同规则，既精准又不浪费上下文窗口。**

### CLAUDE.md vs Rules：怎么分工？

| 内容 | 放 CLAUDE.md | 放.claude/rules/ |
| --- | --- | --- |
| 项目概述和技术栈 | ✓ |  |
| 常用命令 | ✓ |  |
| 通用编码规范 | ✓ |  |
| 前端组件规范 |  | ✓（配 paths glob） |
| API 接口规范 |  | ✓（配 paths glob） |
| 测试编写规则 |  | ✓（配 paths glob） |
| 数据库操作规范 |  | ✓（配 paths glob） |

**原则：全局通用的放 CLAUDE.md，场景特定的拆到 Rules。**

## 第三层：Auto Memory——让 Claude 自己记笔记

前两层是你主动告诉 Claude 的规则，Auto Memory 是 Claude **自动记下来的东西** 。

### 它会记什么

你在对话中纠正 Claude："不要用 npm，我们用 pnpm。" 下一次对话，它不会再犯同样的错误——因为它把这个纠正存进了 Auto Memory。

Claude 自动记录的内容分为四类：

| 类型 | 内容 | 示例 |
| --- | --- | --- |
| **user** | 你的角色、偏好、知识水平 | "用户是高级前端开发者，熟悉 React 生态" |
| **feedback** | 你的纠正和反馈 | "不要在这个项目用 Redux，用 Zustand" |
| **project** | 项目的状态和决策 | "正在做认证模块重构，deadline 是 3/15" |
| **reference** | 外部资源的位置 | "Bug 追踪在 Linear 的 INFRA 项目里" |

### 存在哪

```
~/.claude/projects/<your-project>/memory/
├── MEMORY.md                ← 索引文件（前 200 行被加载）
├── user_role.md             ← 用户信息
├── feedback_testing.md      ← 测试相关的反馈
├── project_auth_refactor.md ← 项目进展
└── reference_linear.md      ← 外部资源
```

`MEMORY.md` 是索引，Claude 每次启动时读取前 200 行。具体内容存在单独的 `.md` 文件里，通过索引链接。

### 怎么管理

**查看** ：输入 `/memory` ，可以浏览所有已加载的记忆文件。

**主动让 Claude 记住** ：

```
你：记住，我们这个项目的 CI 用 GitHub Actions，不要写 GitLab CI 的配置
Claude：[保存到 auto memory]
```

**让 Claude 忘记** ：

```
你：忘掉之前说的用 Zustand，我们改回 Redux 了
Claude：[更新 auto memory]
```

**手动编辑** ：直接打开 `~/.claude/projects/<project>/memory/` 目录下的文件编辑，完全是普通的 Markdown 文件。

### Auto Memory 不该记什么

Auto Memory 不是什么都记的。以下内容 **不应该** 存进记忆：

- **代码结构和文件路径**
	——直接读项目就行
- **Git 历史**
	—— `git log` 更准确
- **调试方案和修复步骤**
	——修复已经在代码里了
- **CLAUDE.md 已有的内容**
	——避免重复
- **临时状态**
	——当前对话的上下文不需要持久化

## 三层协作的完整示例

假设你是一个全栈开发者，团队有 5 个人，用 Next.js 做一个 SaaS 产品。

### 你的配置

**`~/.claude/CLAUDE.md`** （个人偏好）：

```
- 用中文回复和注释
- 优先用 pnpm
- 不要在每次操作后总结
- 我是高级开发者，不需要解释基础概念
```

**项目根目录 `CLAUDE.md`** （团队共享）：

```
# SaaS Dashboard

Next.js 15 + TypeScript + Tailwind CSS + Drizzle ORM + PostgreSQL

## 命令
- pnpm dev / pnpm test / pnpm build

## 规范
- 组合式 API，不用 Class
- API 返回格式 { code, data, message }
- 文件命名 kebab-case
```

**`.claude/rules/frontend.md`** （前端场景规则）：

```
---
paths:
  - "src/components/**"
  - "src/app/**/page.tsx"
---

# 前端规范
- Tailwind 工具类优先
- 组件 Props 用 interface
- Server Component 优先，必要时才用 'use client'
```

**Auto Memory** （Claude 自动积累）：

```
# MEMORY.md
- [user_role.md](./user_role.md) - 高级全栈开发者，擅长 React
- [feedback_pnpm.md](./feedback_pnpm.md) - 必须用 pnpm 不用 npm
- [project_auth.md](./project_auth.md) - 认证模块重构进行中
```

**加载顺序** ：用户级 CLAUDE.md → 项目级 CLAUDE.md → Rules（按 glob 匹配）→ Auto Memory。 **更具体的配置优先级更高。**

## 实战技巧

### 技巧 1：用 /memory 定期审计

每隔一两周跑一次 `/memory` ，看看 Claude 记了什么。有时候它会记错或者记了过时的信息。直接编辑或让它删掉。

### 技巧 2：新项目的第一件事是写 CLAUDE.md

不是写代码，是写 CLAUDE.md。花 10 分钟把技术栈、命令、规范写清楚，后面几百个小时的开发都受益。

### 技巧 3：Rules 按改动频率组织

经常改的规则拆到单独文件里，稳定的规则放 CLAUDE.md。比如 API 格式规范很少变，放 CLAUDE.md；设计系统的组件规范经常迭代，拆到 `rules/design-system.md` 。

### 技巧 4：利用 Auto Memory 做团队 onboarding

新人加入项目时，Auto Memory 会在他使用 Claude Code 的过程中自动积累项目知识。几天后，Claude 就"认识"这个人了——知道他的技术水平、编码习惯、常犯的错误。 **相当于一个不知疲倦的 mentor。**

### 技巧 5：敏感信息放.env，不要放 CLAUDE.md

CLAUDE.md 会提交到 Git。API Key、数据库密码、内部 URL 等敏感信息永远不要写进去。用 `.env` + `process.env` 引用。

## 效率对比

| 场景 | 没有配置 | 配好三层记忆 |
| --- | --- | --- |
| 新对话启动 | 每次重复说明技术栈和规范 | 自动加载，零配置 |
| 代码风格 | AI 随意发挥 | 严格遵循项目规范 |
| 不同模块规范 | 全塞在一个文件里 | Rules 按场景自动加载 |
| 多次纠正 | 下次还犯同样的错 | Auto Memory 记住反馈 |
| 新人上手 | 手动教 AI 项目背景 | Auto Memory 自动积累 |

## 常见问题

**Q：CLAUDE.md 和 Auto Memory 冲突了怎么办？** CLAUDE.md 的优先级更高。如果 Auto Memory 记错了，你可以用 `/memory` 找到对应文件删掉，或者直接在 CLAUDE.md 里写明正确的规则。

**Q：Auto Memory 可以关掉吗？** 可以。在 `/memory` 菜单里切换，或者在 settings.json 里设置 `autoMemoryEnabled: false` 。但不建议关——它的价值会随着使用时间越来越大。

**Q：团队成员的 Auto Memory 会冲突吗？** 不会。Auto Memory 存在每个人本地的 `~/.claude/` 目录下，不进 Git，每个人独立。

## 总结

- Claude Code 的记忆体系分三层： **CLAUDE.md（你的规则）→ Rules（场景规则）→ Auto Memory（Claude 的笔记）**
- **CLAUDE.md**
	控制在 200 行内，用列表格式，写全局通用规则
- **`.claude/rules/`**
	用 YAML frontmatter 的 `paths` 字段做 glob 匹配，不同场景加载不同规则
- **Auto Memory**
	自动记录你的纠正、偏好、项目状态，跨会话保持一致
- **第一步**
	：花 10 分钟写好你的 CLAUDE.md，这是投入产出比最高的事情

**你的 CLAUDE.md 长什么样？** 欢迎在评论区分享你的配置，看看有什么可以互相借鉴的。

## 往期相关

- 《我靠这份配置文件，让 AI 写出的代码直接通过了 Code Review》——CLAUDE.md 和.cursorrules 入门
- 《Claude Code 进阶配置：Hooks + Skills + 自定义 Agent》——Hooks / Skills / Agent 详解
- 《装上 Superpowers 插件后，Claude Code 终于像一个真正的高级工程师了》——Superpowers 插件最佳实践

## 延伸阅读

- Claude Code Memory 官方文档 — 完整的记忆系统说明
- CLAUDE.md 完整指南 — 详细配置教程
- Auto Memory 工作原理 — 自动记忆的技术细节

---

*每周四更新工具推荐，关注「开发者效率局」不迷路。*

**微信扫一扫赞赏作者**

继续滑动看下一个

开发者效率局

向上滑动看下一个