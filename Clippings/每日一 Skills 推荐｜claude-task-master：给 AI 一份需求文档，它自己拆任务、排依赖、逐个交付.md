---
title: "每日一 Skills 推荐｜claude-task-master：给 AI 一份需求文档，它自己拆任务、排依赖、逐个交付"
source: "https://mp.weixin.qq.com/s/8hAVHc55FUY1haulBXxwrA"
author:
  - "[[大模型AI之旅]]"
published:
created: 2026-05-15
description: "每日一 Skills 推荐｜claude-task-master：给 AI 一份需求文档，它自己拆任务、排依赖"
tags:
  - "clippings"
---
大模型AI之旅 *2026年4月21日 07:30*

## 每日一 Skills 推荐｜claude-task-master：给 AI 一份需求文档，它自己拆任务、排依赖、逐个交付

你有没有试过让 AI 做一个「真正的项目」？

不是改一个 bug、写一个函数那种，而是从零开始做一个完整的东西。比如「做一个带用户认证的 REST API，支持 CRUD、权限管理、日志审计」。

你把需求丢给 Claude 或者 Cursor，它开始写代码。写完认证模块，该写 CRUD 了，它问你「接下来做什么」。你说写 CRUD。写完 CRUD，它又问你。你说加权限。一来一回，你变成了人工调度器，手动告诉 AI 下一步干什么。

项目越大，这个问题越明显。AI 能写代码，但它不会管项目。哪些任务有依赖关系、该先做哪个后做哪个、什么时候该换个模型，这些它统统不管。你得一直盯着它，像带实习生一样。

## 一个 AI 项目经理

Taskmaster（claude-task-master）想解决的就是这个问题。它不是 Skill，是一个 MCP Server，作用是给 AI 加上项目管理能力。

作者 Eyal Toledano，npm 包名 `task-master-ai` 。Star 数非常夸张，是 AI 编程工具生态里最热门的项目之一。

核心思路：你写一份 PRD（产品需求文档），Taskmaster 把它解析成结构化的任务列表，自动分析依赖关系，然后 AI 按照依赖顺序一个一个执行。你不用手动调度，它自己知道下一步该做什么。

安装：

```
123456# Claude Code 用户
claude mcp add taskmaster-ai -- npx -y task-master-ai
 
# 或者全局安装 CLI
npm install -g task-master-ai
task-master init
```

## PRD 驱动

Taskmaster 的起点是一份 PRD 文件。你把需求写在 `.taskmaster/docs/prd.txt` 里，越详细越好。

然后对 AI 说一句：「帮我解析 PRD，生成任务」。

Taskmaster 会调用 AI 模型分析你的 PRD，输出一份 `tasks.json` ：

```
1234567891011121314151617181920212223242526272829303132{
  "tasks": [
    {
      "id": 1,
      "title": "初始化项目结构",
      "status": "pending",
      "dependencies": [],
      "subtasks": [
        { "id": 1, "title": "创建 Express 项目骨架" },
        { "id": 2, "title": "配置 TypeScript + ESLint" },
        { "id": 3, "title": "设置数据库连接（PostgreSQL）" }
      ]
    },
    {
      "id": 2,
      "title": "实现用户认证模块",
      "status": "pending",
      "dependencies": [1],
      "subtasks": [
        { "id": 1, "title": "JWT 签发与验证中间件" },
        { "id": 2, "title": "注册/登录/刷新 token 端点" },
        { "id": 3, "title": "密码哈希（bcrypt）" }
      ]
    },
    {
      "id": 3,
      "title": "实现 CRUD API",
      "status": "pending",
      "dependencies": [1, 2]
    }
  ]
}
```

每个任务有 ID、标题、状态、依赖列表和子任务。任务 3 依赖任务 1 和 2，所以它不会在认证模块完成之前开始。

你对 AI 说「下一个任务是什么」，它会自动找到所有依赖已完成的任务中优先级最高的那个。不用你操心顺序。

![PRD → 任务链](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

PRD → 任务链

## 三种模型，各司其职

Taskmaster 有个聪明的设计：它把 AI 的工作分成三类，每类用不同的模型。

**主模型（Main）** ：负责核心任务，解析 PRD、生成任务、写代码。通常用 Claude Sonnet 或 GPT-4o，能力强但成本高。

**研究模型（Research）** ：负责搜索最新信息。比如你在实现 JWT 认证，它会去查最新的最佳实践、库版本、安全建议。通常用 Perplexity，擅长联网搜索。

**兜底模型（Fallback）** ：主模型或研究模型挂了的时候顶上。通常用便宜快速的模型，比如 Gemini Flash。

这个分工很实际。你不需要每个操作都用最贵的模型。查个文档用 Perplexity 够了，生成代码才需要 Claude。

配置也很灵活：

```
1> 把主模型换成 claude-code/sonnet，研究模型用 perplexity，兜底用 gemini-flash
```

如果你用 Claude Code，可以直接用 `claude-code/sonnet` 作为主模型，不需要额外的 API Key。

![三种模型，各司其职](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

三种模型，各司其职

## 实际用起来

假设你要做一个博客系统后端。你写了一份 PRD，描述了用户管理、文章 CRUD、评论、标签、搜索这些功能。

```
12345678910111213141516171819202122232425262728293031> 解析我的 PRD，生成任务
 
Taskmaster:
  解析完成，生成了 12 个任务，47 个子任务。
  依赖图：
  Task 1 (项目初始化) → Task 2 (数据库 schema)
  Task 2 → Task 3 (用户认证) → Task 5 (文章 CRUD)
  Task 2 → Task 4 (权限中间件) → Task 5
  Task 5 → Task 6 (评论系统) → Task 8 (通知)
  Task 5 → Task 7 (标签系统) → Task 9 (搜索)
  ...

> 下一个任务是什么？

Taskmaster:
  Task 1：初始化项目结构（无依赖，可立即开始）
  - 子任务 1.1：创建 Express + TypeScript 项目
  - 子任务 1.2：配置 PostgreSQL + Prisma ORM
  - 子任务 1.3：设置测试框架（Jest）

> 帮我实现 Task 1

Claude:
  开始实现 Task 1...
  [创建项目骨架、配置 TypeScript、连接数据库...]
  ✅ Task 1 完成，所有子任务已标记为 done

> 下一个？

Taskmaster:
  Task 2：设计数据库 schema（Task 1 已完成，依赖满足）
```

你只需要不断说「下一个」和「帮我实现」，Taskmaster 自动调度。任务完成后自动更新状态，解锁下游依赖。

如果做到一半发现需求变了——比如客户说要加一个「文章草稿」功能——你可以直接说「加一个任务：文章草稿功能，依赖 Task 5」，Taskmaster 会把它插入到正确的位置。

## 复杂度分析

Taskmaster 还有一个功能：在你动手之前，先分析整个项目的复杂度。

```
1234567891011> 分析一下项目复杂度
 
Taskmaster:
  项目复杂度报告：
  - 总任务数：12
  - 高复杂度任务：3（认证、搜索、通知）
  - 中复杂度任务：5
  - 低复杂度任务：4
  - 预估总工时：~40 小时（AI 辅助下约 8 小时）
  - 关键路径：Task 1 → 2 → 3 → 5 → 9（搜索功能）
  - 建议：先完成关键路径上的任务
```

这个报告能帮你在开始之前就知道项目有多大，哪些任务是瓶颈。

## 36 个工具

Taskmaster 作为 MCP Server，提供了 36 个工具给 AI 调用。但 36 个工具会占大约 21000 token 的上下文空间。

所以它做了分级加载：

| 模式 | 工具数 | Token 占用 | 适合场景 |
| --- | --- | --- | --- |
| core | 7 | ~5000 | 日常开发，够用 |
| standard | 15 | ~10000 | 常规任务管理 |
| all | 36 | ~21000 | 完整功能 |

大多数时候用 `core` 就够了：查看任务、获取下一个任务、更新状态、展开子任务、解析 PRD。省 70% 的 token 开销。

```
1234# 精简模式安装
claude mcp add task-master-ai --scope user \
  --env TASK_MASTER_TOOLS="core" \
  -- npx -y task-master-ai@latest
```

## 跟 planning-with-files 的区别

上一篇推荐的 planning-with-files 也在解决 AI 做复杂任务的问题，但思路不同。

planning-with-files 解决的是「AI 忘事」——用文件做记忆，防止上下文丢失。它不管任务怎么拆、依赖怎么排，它只管把过程记录下来。

Taskmaster 解决的是「AI 不会管项目」——从 PRD 自动拆任务、排依赖、调度执行。它是一个结构化的任务管理系统，不只是记笔记。

两者可以配合使用：Taskmaster 管任务调度，planning-with-files 管过程记忆。一个管「做什么」，一个管「别忘了」。

![Taskmaster vs planning-with-files](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

Taskmaster vs planning-with-files

## 判断

Taskmaster 把 AI 编程从「你告诉它做什么」变成了「你告诉它要什么，它自己安排怎么做」。这个转变对独立开发者特别有价值。一个人做项目，最累的不是写代码，是管理进度和保持全局视野。Taskmaster 把这部分外包给了 AI。

局限也摆在那。它需要至少一个 API Key（除非用 Claude Code CLI），每次调用都有成本。PRD 写得不好，生成的任务质量也不行。36 个工具占 21000 token，对上下文空间是不小的开销，虽然可以用 core 模式缓解。另外它是 MCP Server 而不是 Skill，配置比装一个 Skill 复杂一些。

但如果你经常从零开始做项目，或者项目复杂到需要几十个任务才能完成，Taskmaster 能帮你省掉大量的手动调度时间。

GitHub 仓库：https://github.com/eyaltoledano/claude-task-master

你做过最复杂的 AI 辅助项目是什么？有没有碰到过「AI 不知道下一步做什么」的问题？评论区聊聊。

以上，既然看到这里了，

如果觉得不错，随手点个赞、在看、转发三连吧，

如果想第一时间收到推送，也可以给我个星标⭐～

谢谢你看我的文章

后台回复skill，也可以获取全套skill～

我创建了一个skill分享交流群，有兴趣的可以加入

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**微信扫一扫赞赏作者**

skills · 目录

作者提示: 个人观点，仅供参考

继续滑动看下一个

大模型AI之旅

向上滑动看下一个