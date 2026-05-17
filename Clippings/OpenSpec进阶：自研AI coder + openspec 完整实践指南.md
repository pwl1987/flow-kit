---
title: "OpenSpec进阶：自研AI coder + openspec 完整实践指南"
source: "https://mp.weixin.qq.com/s/q3BIm02F2LlRTGd2DRePEg"
author:
  - "[[超世先锋-明哥]]"
published:
created: 2026-05-15
description: "问：公司自研AI编码工具没有适配openspec的A I编码工具，如何使用openspec？答：完全可以的！"
tags:
  - "clippings"
---
超世先锋-明哥 *2026年4月11日 08:00*

![[_resources/OpenSpec进阶：自研AI coder + openspec 完整实践指南/06baa6ac60201706667b264a047e9946_MD5.webp]]

问：公司自研AI编码工具没有适配openspec的A I编码工具，如何使用openspec？

答：完全可以的！

OpenSpec的设计哲学本身就是“工具无关”的规范框架。核心原理很简单：通过自然语言对话和项目里的文件来驱动，而不是依赖特定命令。

即使咱们用的AI编码工具（比如一些自研工具）没有内置 /opsx 这样的斜杠命令，也丝毫不影响使用 OpenSpec。

一、项目环境

1，项目地址

```javascript
https://github.com/Fission-AI/OpenSpec
```

2，Node环境（>=20.19.0）

```shell
$ node -v v22.22.0
```

二、OpenSpec 环境安装

1，安装OpenSpec CLI

```nginx
#说明：安装0.xx版本需要指定版本安装npm install -g @fission-ai/openspec@latest#npm install -g @fission-ai/openspec@0.23.0openspec --version  # 验证安装
```

说明：openspec最新版1.x的命令和0.x版本不兼容，本示例以最新版本为例，如果使用老版本则指定0.23.0版本安装

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

2，初始化项目及目录结构

```perl
mkdir my-openspec-project cd my-openspec-project
```

#初始化OpenSpec

```cs
openspec init
```

#项目目录结构

```bash
openspec/├── specs/                      # 已确定的系统行为规范│   └── <domain>/                # 按领域或模块组织（如 auth, payment）│       └── spec.md              # 该领域的最终规范（Markdown）├── changes/                     # 所有进行中的变更（每个变更一个文件夹）│   └── <change-name>/            # 例如 add-login-api│       ├── proposal.md           # 变更提案：为什么要做、范围、影响│       ├── design.md             # （可选）技术设计方案│       ├── tasks.md              # 实施任务清单（带复选框）│       └── specs/                 # 增量规范：本次变更新增或修改的规范│           └── <domain>/          # 对应主规范的领域│               └── spec.md        # 仅包含变更部分的规范（标记 ADDED/MODIFIED）└── config.yaml                   # 项目配置文件（schema、上下文、规则等）
```

\# 目录/文件详解

```css
Source
作用：存放项目当前真实状态的规范。当多个变更完成后，它们的内容最终会合并到这里。组织方式：按领域（domain）划分子目录，每个领域一个 spec.md。这有助于大型项目保持清晰。使用场景：AI 在生成代码或验证时，会参考这里的规范来确保实现与设计一致。（2）changes/ — 变更工作区作用：每个独立的开发任务（功能、修复、重构）都在这里创建一个子目录，所有相关文件都隔离在该目录中，互不干扰。（3）changes中变更目录内文件：proposal.md：高层描述，包括动机、目标、非目标、验收标准。design.md：可选的技术设计，包含架构图、接口定义、数据流等。tasks.md：可执行的实施步骤，通常以 Markdown 任务列表形式出现，每个任务都可被 AI 逐个执行。specs/：增量规范，结构与主规范相同，但只包含本次变更要修改的部分。文件中会用 ADDED、MODIFIED、REMOVED 等标记来指示变化。.yaml
作用：定义项目的全局上下文（技术栈、编码约定）、默认工作流（schema）以及针对特定工件（如 proposal、tasks）的附加规则。自动注入：每次通过 CLI 或 OPSX 命令创建工件时，context 和 rules 中的内容会自动附加到给 AI 的指令中，确保所有输出符合项目标准。
```

3，OpenSpec常用指令指南

#OpenSpec CLI 命令（版本v1.0.0+）

```xml
openspec init 在项目中初始化 OpenSpec，创建目录结构和配置文件 。openspec update 刷新已配置 AI 工具的技能和命令文件，支持智能版本检测 。openspec list 列出所有活跃的变更（changes）或规范（specs）。openspec view 显示一个交互式的仪表板，概览规范和变更状态 。openspec show <change>  显示指定变更的详细信息（如提案、任务等）。openspec validate <change>  验证变更的格式和结构是否符合规范 。openspec archive <change> 将已完成的变更归档，并同步增量规范到主规范 。openspec status 查询指定变更的工件（artifacts）完成状态（如 DONE, READY, BLOCKED）。openspec instructions <artifact>  为创建特定工件（如 proposal）或实施任务（apply）生成包含上下文的动态指令 。openspec config 管理全局配置 。openspec schema 检查和列出可用的工作流 schema 。openspec completion 管理 shell 自动补全 。openspec feedback 提交 CLI 反馈 。
```

#AI 斜杠命令 (OPSX)

说明：斜杠命令在支持的工具（如 Claude Code, Cursor）聊天框中使用，驱动整个变更生命周期。（在不支持的AI编程工具中不能使用）

```bash
/opsx:explore 前期  探索想法、调研问题，只读模式不写代码 。/opsx:new <name>  规划  创建一个新的变更目录，并逐步创建第一个工件模板 。/opsx:continue  规划  继续推进当前变更，每次调用只创建下一个依赖已就绪的工件 。/opsx:ff  规划  快进模式，一次性按依赖顺序生成所有规划工件（proposal, specs, design, tasks）。/opsx:apply 实施  实施变更，根据 tasks.md 的任务清单逐个实现代码 。/opsx:verify  验证  验证代码实现与规范、提案、设计等是否一致，并生成验证报告 。/opsx:sync  管理  同步增量规范到主规范 (openspec/specs/)，但不关闭变更 。/opsx:archive 收尾  归档已完成变更，将其移动到归档目录 。/opsx:bulk-archive  收尾  批量归档多个已完成变更，并带有冲突检测功能 。/opsx:onboard 引导  15分钟的交互式引导，带领新用户完成第一个完整变更 。
```

#新版本主要变化：

旧版命令已失效：所有以 /openspec: 开头的旧版斜杠命令（如 /openspec:proposal、/openspec:apply）在 v1.0.0+以上版本中已全部移除 。

CLI 变化：旧的 openspec change 命令组已弃用，其功能被新的、更具体的命令（如 status、instructions）所取代 。

三、自研AICoder + openspec 1.x 项目示例

在 OpenSpec 中，完全可以使用自然语言驱动AI 通过背后执行的 /opsx: 命令来驱动整个规范化的流程。

注意：本示例不局限于具体的AICoder工具，所用的理论和方法可以应用于所有AICoder编程工具！

#关键意图对应的操作：

```bash
创建一个新功能/变更 → /opsx:new生成所有规划文件 → /opsx:ff (快进)开始实施 → /opsx:apply归档完成的工作 → /opsx:archive
```

1，创建或进入项目

```bash
mkdir task-manager-apicd task-manager-api
```

2，git初始化

```bash
git initecho "node_modules/" > .gitignore
```

3，openspec初始化

```cs
openspec init
```

选择 Claude Code 后（方向键移动，空格选择） 回车继续

#执行结果

```bash
\`\`\`shell 日志                        Welcome to OpenSpec                        A lightweight spec-driven framework        ████            This setup will configure:      ██    ██            • Agent Skills for AI tools    ░░  ████  ░░          • /opsx:* slash commands    ░░  ████  ░░    ░░  ████  ░░        Quick start after setup:      ██    ██            /opsx:new      Create a change        ████              /opsx:continue Next artifact                          /opsx:apply    Implement tasks                        Press Enter to select tools...\`\`\`
```

#openspec项目初始化 openspec init ，回车确认继续

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

#选择claude code，回车确认

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

\# 初始化完成

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

4，确定项目规范(config.yaml)

说明：config.yaml文件位于项目根目录的 openspec/ 文件夹下，类似老版本的 project.md，集成AI编程工具后，所有 AI 命令（如 /opsx:new、/opsx:apply）将自动加载该配置。

\# 默认生成内容

```makefile
\`\`\`yamlschema: spec-driven# Project context (optional)# This is shown to AI when creating artifacts.# Add your tech stack, conventions, style guides, domain knowledge, etc.# Example:#   context: |#     Tech stack: TypeScript, React, Node.js#     We use conventional commits#     Domain: e-commerce platform# Per-artifact rules (optional)# Add custom rules for specific artifacts.# Example:#   rules:#     proposal:#       - Keep proposals under 500 words#       - Always include a "Non-goals" section#     tasks:#       - Break tasks into chunks of max 2 hours\`\`\`
```

#中文内容

```makefile
\`\`\`yamlschema: spec-driven# 项目上下文（可选）# 在创建工件时会向AI展示此内容。# 添加你的技术栈、约定、风格指南、领域知识等。# 示例：#   context: |#     技术栈：TypeScript, React, Node.js#     我们使用约定式提交#     领域：电子商务平台# 每工件规则（可选）# 为特定工件添加自定义规则。# 示例：#   rules:#     proposal:#       - 将提案保持在500字以内#       - 始终包含“非目标”部分#     tasks:#       - 将任务分解为最多2小时的工作块\`\`\`
```

编辑 openspec/config.yaml

\# 手动设置 openspec/config.yaml

```shell
\`\`\`yaml# openspec/config.yaml# 项目核心配置文件，由 openspec init 生成，可根据需要手动修改# 默认工作流: spec-driven | task-driven | agenticschema: spec-driven# 项目背景和全局规范（原 project.md 内容）context: |  # Task Manager API - 项目规范  ## 技术栈  - 运行时: Node.js 20.x  - 框架: Express 4.x  - 语言: TypeScript 5.x  - 数据库: SQLite (开发环境)，Prisma ORM  - 测试: Jest, Supertest  - 验证: Zod  ## 项目结构  \`\`\`  src/  ├── controllers/    # HTTP请求处理  ├── services/       # 业务逻辑  ├── repositories/   # 数据访问  ├── models/         # 类型定义  ├── middleware/     # 中间件  ├── utils/          # 工具函数  └── app.ts          # 应用入口  \`\`\`  ## 代码规范  ### 1. TypeScript配置  - 使用严格模式 (tsconfig.json strict: true)  - 所有导出必须有类型  - 禁止使用any类型  ### 2. API设计规范  - RESTful API设计  - 统一响应格式:  \`\`\`typescript  interface ApiResponse<T = any> {    success: boolean;    data?: T;    error?: string;    timestamp: string;  }  \`\`\`  ### 3. 错误处理  - 服务层抛出特定错误类: ValidationError, NotFoundError, AuthenticationError  - Controller层统一捕获，返回标准格式  - HTTP状态码映射:    - 400: 验证错误    - 401: 未认证    - 404: 资源不存在    - 500: 服务器错误  ### 4. 安全规范  - 所有用户输入必须用Zod验证  - 密码使用bcrypt哈希  - JWT令牌认证  - 敏感信息不记录日志  ### 5. 数据库规范  - 使用Prisma Client进行所有数据库操作  - 查询必须参数化  - 事务用于多步骤操作  ### 6. 测试规范  - 单元测试覆盖核心业务逻辑  - 集成测试覆盖API端点  - 测试覆盖率≥80%  - 每个PR必须有测试  ## 命名约定  - 文件: kebab-case (user-controller.ts)  - 类: PascalCase (UserController)  - 变量/函数: camelCase (getUserById)  - 常量: UPPER_SNAKE_CASE (MAX_RETRY_COUNT)# rules 字段可选，此处未定义特定工件的规则，可根据需要补充# rules:#   proposal:#     - "必须包含..."#   tasks:#     - "任务需原子化..."\`\`\`
```

#说明：openspec/config.yaml 可以由老版本openspec/project.md进行转换。

schema：采用最常见的 \`spec-driven\` 工作流，与project.md文档的“规范先行”理念一致。

context：完整保留原 \`project.md\` 的 Markdown 格式，作为项目背景自动注入每次 AI 交互，确保规范始终被遵守。

rules：新版本新增，老版本project.md文档未定义针对特定工件（如提案、任务）的额外规则，此处省略；后续可根据需要在此添加。

\# 确定项目规范(config.yaml)

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

5，需求阶段：利用AI需求探索

#项目准备：初始化并告知AI

在AI编程工具聊天框里告诉AI：

```javascript
\`\`\`markdown项目根目录为 task-manager-api，项目根目录下包含以下信息：openspec/ 目录: 这是所有规范文件的核心目录。openspec/config.yaml: 这是项目的配置文件，包含了项目上下文（如技术栈）和其他设置。技能文件: 在项目对应的目录下 .claude/skills 生成一系列文件。我们将在这个项目中使用 OpenSpec 来进行规范驱动开发。请准备就绪。\`\`\`
```

执行结果

```bash
\`\`\`shell 日志任务已完成已成功为 Task Manager API 项目完成 OpenSpec 规范驱动开发的准备工作：1. __项目分析__：分析了项目结构，确认了 task-manager-api 作为项目根目录2. __OpenSpec 配置验证__：检查了 openspec/config.yaml 文件，确认包含完整的技术栈信息（Node.js 20.x, Express 4.x, TypeScript 5.x, SQLite, Prisma ORM, Jest, Zod 等）和项目规范3. __规范文件检查__：查看了 openspec/project.md 文件，确认包含详细的代码规范、API设计规范、错误处理、安全规范等4. __技能文件目录创建__：确认了 .claude/commands/opsx/ 目录已包含所有必要的命令文件：   - apply.md - 应用变更   - archive.md - 归档变更   - explore.md - 探索项目   - propose.md - 提议新变更5. __技能文件目录创建__：确认了 .claude/skills/ 目录已包含所有必要的技能文件：   - openspec-apply-change/SKILL.md   - openspec-archive-change/SKILL.md   - openspec-explore/SKILL.md   - openspec-propose/SKILL.md6. __OpenSpec CLI 验证__：确认 openspec CLI (v1.2.0) 已安装并可正常工作7. __系统功能测试__：成功创建并测试了测试变更 "test-api-endpoint"，验证了 OpenSpec 系统可以正常创建变更并显示状态项目现在已完全准备好使用 OpenSpec 进行规范驱动开发。用户可以使用以下命令：- \`/opsx:propose\` - 提议新变更- \`/opsx:apply\` - 应用变更- \`/opsx:explore\` - 探索项目- \`/opsx:archive\` - 归档变更所有必要的配置文件和技能文件都已就位，可以开始进行规范驱动的开发工作。\`\`\`
```

\# 告诉AI编程工具项目环境，并完成OpenSpec 规范驱动开发的准备工作

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

#利用AI探索需求，生成的研究报告

#在AI编程工具聊天面板中输入：

```javascript
\`\`\`shell我需要构建一个任务管理API，功能包括：1. 用户注册/登录2. 任务的CRUD操作3. 任务状态管理（待处理、进行中、已完成）4. 任务分配和过滤请帮我分析：1. 需要哪些数据库表？2. API端点如何设计？3. 需要哪些核心业务逻辑？4. 安全方面需要考虑什么？请生成一份详细的研究报告，报告保存为 \`task-api-analysis.md\`\`\`\`
```

注意：此处技术报告分析和生成建议放到一个prompt中，具体效果所用的AI 编程工具及选择的模型有关。

#需求阶段：技术方案生成

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

6，开发阶段：创建一个变更

#旧版本 claude code + openspect 0.23.0

```javascript
\`\`\`shell /openspec:proposal 实现任务管理API的用户认证模块参考文档：@task-api-analysis.md范围：用户注册、登录、JWT认证中间件\`\`\`
```

#新版本 自研AIcoder + openspect 1.2.0

```javascript
\`\`\`shell 使用 .claude/skills/openspec-propose 技能，实现任务管理API的用户认证模块参考文档：@task-api-analysis.md范围：用户注册、登录、JWT认证中间件\`\`\`
```

说明：注意技能路径，如果有父子目录需要根据实践调整

执行结果

```javascript
\`\`\`shell 日志任务已完成根据 OpenSpec 规范驱动开发方法，已成功完成任务管理API的用户认证模块创建。所有必需的工件均已创建并验证：1. 变更配置文件：   - \`.openspec.yaml\` - 包含 spec-driven schema 配置2. 规范文件（符合 spec-driven schema）：   - \`specs/user-model.spec.md\` - 用户数据模型规范，包含Prisma模型定义、字段验证规则、安全要求等   - \`specs/auth-endpoints.spec.md\` - 认证端点规范，包含所有API端点的详细定义、请求/响应格式、业务逻辑等   - \`specs/jwt-middleware.spec.md\` - JWT中间件规范，包含认证中间件、授权中间件、令牌管理和安全配置3. 实施任务文件：   - \`tasks.md\` - 详细的实施任务清单，包含9个实施阶段和完整的验收标准所有工件都遵循了项目配置的 spec-driven schema（在 openspec/config.yaml 中定义），确保了规范与实现任务之间的一致性。这些工件为后续的开发工作提供了完整的指导，确保开发团队能够按照既定的规范实现用户认证模块，包括用户注册、登录和JWT认证中间件等功能。\`\`\`
```

说明：此处生成的规范文件明显没有严格按照技能说明来，而且变更中缺规划文件，这主要是和选择的初始AI 编码工具（此处为 claude code）和模型（此处使用DeepSeek）匹配度相关；可以调整提示词或模型重新执行，也可以按以下方法分步调整；

```css
最佳实践：可以调整初始化的AI编码工具和模型，使其尽可能相配，能有更好的生成效果。如：claude code 工具 + claude 模型
```

如果没有claude模型怎么办，也不用慌，👇下面演示使用分步执行命令自动调整过来

##开发阶段：创建第一个变更提案

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

（1）调整规划文件

```javascript
\`\`\`请为这个变更创建所有必要的规划文件，比如提案、任务清单等。\`\`\`
```

执行结果：缺失的规划文件已创建，但规范文件目录及格式仍然不对

```javascript
\`\`\`shell 日志任务已完成已成功使用 OpenSpec 规范驱动开发方法完成任务管理API的用户认证模块创建。所有必需的规划文件和工件均已创建并验证：1. 变更配置文件：   - \`task-manager-api/openspec/changes/user-authentication-module/.openspec.yaml\` - 包含 spec-driven schema 配置2. 规划文件：   - \`task-manager-api/openspec/changes/user-authentication-module/proposal.md\` - 用户认证模块变更提案，详细描述了变更的目标、解决方案和成功标准   - \`task-manager-api/openspec/changes/user-authentication-module/design.md\` - 用户认证模块设计文档，详细描述了系统架构、组件设计、API设计和安全措施3. 规范文件（符合 spec-driven schema）：   - \`task-manager-api/openspec/changes/user-authentication-module/specs/user-model.spec.md\` - 用户数据模型规范，包含Prisma模型定义、字段验证规则、安全要求等   - \`task-manager-api/openspec/changes/user-authentication-module/specs/auth-endpoints.spec.md\` - 认证端点规范，包含所有API端点的详细定义、请求/响应格式、业务逻辑等   - \`task-manager-api/openspec/changes/user-authentication-module/specs/jwt-middleware.spec.md\` - JWT中间件规范，包含认证中间件、授权中间件、令牌管理和安全配置4. 实施任务文件：   - \`task-manager-api/openspec/changes/user-authentication-module/tasks.md\` - 详细的实施任务清单，包含9个实施阶段和完整的验收标准，现已更新以反映所有相关文件所有工件都遵循了项目配置的 spec-driven schema（在 task-manager-api/openspec/config.yaml 中定义），确保了规范与实现任务之间的一致性。这些工件为后续的开发工作提供了完整的指导，确保开发团队能够按照既定的规范实现用户认证模块，包括用户注册、登录和JWT认证中间件等功能。\`\`\`
```

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

（2）调整规范驱动文件（specs/ 目录） -- 修复错误、中文化

#修复规范文件（目录结构及内容）

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

终端执行验证，将错误丢到聊天框，直到自动修复

```javascript
\`\`\`shellopenspec validate user-authentication-module\`\`\`
```

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

#规范驱动文件（specs/ 目录）

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

#规范文件中文化

```javascript
\`\`\`shell将规范驱动文件（specs/ 目录）中描述文本 使用中文表达\`\`\`
```

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

说明：任何调整，都需要验证变更有效

```ruby
openspec list#查看状态openspec status --change user-authentication-module#验证有效openspec validate user-authentication-module
```

7，开发阶段：修改变更（修改内容）

手动或自然语言让模型帮修改

#修改后验证

```sql
openspec validate user-authentication-module
```

此处参考上篇相关内容

8，开发阶段：实施变更（实现功能）

```javascript
\`\`\`shell使用 task-manager-api/.claude/skills/openspec-apply-change/SKILL.md 技能，开始按任务清单实施 user-authentication-module 这个变更\`\`\`
```

\# 实施变更

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

说明1：执行实施变更，会根据变更tasks.md内容生成代码，代码的完整性和质量和所选的模型关系很大（可能是初始化的claude code工具技能，实测 Claude模型生成质量最高)

说明2：执行实施变更，可能会出现tasks.md中任务已经完成，但没有进行 \[x\] 标示；此情形，可以在实施提示词中附加描述，或根据AI完成提示和实际测试情况手动调整，调整后再执行归档。

\# 实施变更完成调整 - 检查或标示任务是否完成

```swift
\`\`\`shell检查task-manager-api/openspec/changes/user-authentication-module/tasks.md中任务是否完成，如果完成则标示为完成参考技能：task-manager-api/.claude/skills/openspec-apply-change/SKILL.md\`\`\`
```

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

9，开发阶段：归档变更（开发完成了进行归档）

直接在终端中使用opensec archive命令进行归档

```sql
openspec archive user-authentication-module --yes
```

执行结果：

```sql
\`\`\`shell 日志$ openspec archive user-authentication-module --yesProposal warnings in proposal.md (non-blocking):  ⚠ Change must have a Why section. Missing required sections. Expected headers: "## Why" and "## What Changes". Ensure deltas are documented in specs/ using delta headers.Task status: ✓ CompleteSpecs to update:  auth-endpoints: create  jwt-middleware: create  user-model: createApplying changes to openspec/specs/auth-endpoints/spec.md:  + 1 addedApplying changes to openspec/specs/jwt-middleware/spec.md:  + 1 addedApplying changes to openspec/specs/user-model/spec.md:  + 1 addedTotals: + 3, ~ 0, - 0, → 0Specs updated successfully.Change 'user-authentication-module' archived as '2026-03-04-user-authentication-module'.\`\`\`
```

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

五、问题总结：

问题1：技能文件不存在

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

说明：此处和所用的模型上下文长度有关，这里明显已经遗忘了前面注入openspec项目环境规范信息，可以重新注入，也可以尝试使用完整技能路径。

解决：取消使用技能完整路径，重新执行

大模型-多智能体-AI Agent · 目录

继续滑动看下一个

超世先锋

向上滑动看下一个