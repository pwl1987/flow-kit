---
title: "按角色选 Claude Code 配置：前端/后端/全栈各自的三个必装 Skills"
source: "https://mp.weixin.qq.com/s/xogE_8FvfAxE96M4dq92DA"
author:
  - "[[程序员潘子]]"
published:
created: 2026-05-15
description: "裸用 Claude Code 是一种浪费：8 个亲测 Skills + 8 个 MCP，配置完开发效率翻倍两周"
tags:
  - "clippings"
---
程序员潘子 *2026年4月1日 11:30*

## 裸用 Claude Code 是一种浪费：8 个亲测 Skills + 8 个 MCP，配置完开发效率翻倍

两周前，我帮一个朋友配 Claude Code 环境。他用了两个月，一直觉得「Claude Code 生成的界面太丑了，根本没法直接用」。

我看了一眼他的配置，问题立刻找到了：他一个 Skill 都没装。

装完 frontend-design 之后，同一个 Dashboard 需求，同一个 prompt，输出质量直接不在一个量级。这个技能社区安装量已经超过 52.7K——不是我一个人的感受。

![[_resources/按角色选 Claude Code 配置：前端后端全栈各自的三个必装 Skills/0bc92f2738fdf9810e32b292f9f56d4b_MD5.webp]]

## 先搞懂：Skills 和 MCP 是两套完全不同的机制

这是大多数人装了半天还搞不清楚的地方。一句话讲透：

| 维度 | Skills 技能 | MCP 服务器 |
| --- | --- | --- |
| 核心本质 | 封装好的提示词工作流 | 本地运行的真实工具 |
| 让 Claude... | **更聪明**  （懂更多领域知识） | **更能干**  （真的去执行操作） |
| 安装方式 | npx skills add 一键安装 | 修改 mcp.json 配置文件 |
| 能访问外部资源 | 不支持 | 支持（文件/浏览器/API） |
| 额外依赖 | 仅需 node 环境 | 部分需要 API Key |

**最香的点：** 绝大多数 Skills 会自动触发。你说「帮我写个 README」，Claude Code 会自动激活 technical-writer；你说「帮我做个 Dashboard」，会自动激活 frontend-design。不需要手动调用。

## 按角色选最小配置——别一次性全装

社区有 32 个精选 Skills，但装太多会增加上下文负担，响应速度会变慢。按角色选最小集，是最省钱的姿势：

### 🎨 前端开发者（3 个必装）

✅ **frontend-design** — 界面生成可直接落地，安装量 52.7K

✅ **canvas-design** — 架构图/流程图一句话生成，不用再开 Figma

✅ **vercel-react-best-practices** — Vercel 官方出品，安装量 109.8K

### ⚙️ 后端开发者（3 个必装）

✅ **technical-writer** — README/接口文档自动生成，规范可直接用

✅ **code-review** — 代码审查，对标 Senior 级别反馈

✅ **git-workflow** — 提交规范、PR 描述自动生成

### 🚀 全栈开发者（3 个起步）

✅ **find-skills** — 技能发现，相当于装了「应用商店」，先装这个

✅ **frontend-design** + **technical-writer** — 前端 + 文档双覆盖

▼ 统一安装命令格式

```
# 基础安装（技能名替换即可） npx skills add frontend-design -y -g npx skills add technical-writer -y -g npx skills add find-skills -y -g  # Vercel 官方技能（完整包名） npx skills add vercel-labs/agent-skills@vercel-react-best-practices -y -g  # 查看已安装列表 npx skills list -g
```

**⚠️ 两个高频坑：**  
1\. 安装必须加 `-g` 全局参数，否则 Claude Code 识别不到  
2\. 安装完成后必须 **完全退出再重新打开** Claude Code，不是刷新，是重启

## 8 个 MCP 服务器：让 Claude 真正能「去干活」

MCP 的配置核心是修改 mcp.json 文件，Claude Code 启动时会自动加载对应的服务器进程。

▼ mcp.json 配置示例（filesystem + puppeteer）

```
{   "mcpServers": {     "filesystem": {       "command": "npx",       "args": ["-y", "@modelcontextprotocol/server-filesystem", "/your/project/path"]     },     "puppeteer": {       "command": "npx",       "args": ["-y", "@modelcontextprotocol/server-puppeteer"]     }   } }
```

| MCP 服务器 | 能力 | 适合场景 |
| --- | --- | --- |
| filesystem | 读写本地文件 | 所有开发场景，必配 |
| puppeteer | 控制 Chrome 浏览器 | 自动化测试、截图、爬虫 |
| figma | 读取 Figma 设计稿 | 前端开发，设计还原 |
| sqlite | 操作本地数据库 | 后端开发、数据分析 |
| github | 操作 GitHub 仓库 | 代码管理、PR 自动化 |
| sequential-thinking | 增强推理能力 | 复杂问题分析 |
| memory | 持久化记忆存储 | 跨会话保留项目细节 |
| brave-search | 联网搜索 | 查最新文档、解决方案 |

## 按角色选最小配置——别一次性全装

社区有 32 个精选 Skills，但装太多会增加上下文负担，响应速度会变慢。按角色选最小集，是最省钱的姿势：

### 🎨 前端开发者（3 个必装）

✅ **frontend-design** — 界面生成可直接落地，安装量 52.7K

✅ **canvas-design** — 架构图/流程图一句话生成，不用再开 Figma

✅ **vercel-react-best-practices** — Vercel 官方出品，安装量 109.8K

### ⚙️ 后端开发者（3 个必装）

✅ **technical-writer** — README/接口文档自动生成，规范可直接用

✅ **code-review** — 代码审查，对标 Senior 级别反馈

✅ **git-workflow** — 提交规范、PR 描述自动生成

### 🚀 全栈开发者（3 个起步）

✅ **find-skills** — 技能发现，相当于装了「应用商店」，先装这个

✅ **frontend-design** + **technical-writer** — 前端 + 文档双覆盖

▼ 统一安装命令格式

```
# 基础安装（技能名替换即可） npx skills add frontend-design -y -g npx skills add technical-writer -y -g npx skills add find-skills -y -g  # Vercel 官方技能（完整包名） npx skills add vercel-labs/agent-skills@vercel-react-best-practices -y -g  # 查看已安装列表 npx skills list -g
```

**⚠️ 两个高频坑：**  
1\. 安装必须加 `-g` 全局参数，否则 Claude Code 识别不到  
2\. 安装完成后必须 **完全退出再重新打开** Claude Code，不是刷新，是重启

## 8 个 MCP 服务器：让 Claude 真正能「去干活」

MCP 的配置核心是修改 mcp.json 文件，Claude Code 启动时会自动加载对应的服务器进程。

▼ mcp.json 配置示例（filesystem + puppeteer）

```
{   "mcpServers": {     "filesystem": {       "command": "npx",       "args": ["-y", "@modelcontextprotocol/server-filesystem", "/your/project/path"]     },     "puppeteer": {       "command": "npx",       "args": ["-y", "@modelcontextprotocol/server-puppeteer"]     }   } }
```

| MCP 服务器 | 能力 | 适合场景 |
| --- | --- | --- |
| filesystem | 读写本地文件 | 所有开发场景，必配 |
| puppeteer | 控制 Chrome 浏览器 | 自动化测试、截图、爬虫 |
| figma | 读取 Figma 设计稿 | 前端开发，设计还原 |
| sqlite | 操作本地数据库 | 后端开发、数据分析 |
| github | 操作 GitHub 仓库 | 代码管理、PR 自动化 |
| sequential-thinking | 增强推理能力 | 复杂问题分析 |
| memory | 持久化记忆存储 | 跨会话保留项目细节 |
| brave-search | 联网搜索 | 查最新文档、解决方案 |

## 避坑全指南：4 个高频问题

**Q1：安装完技能，Claude Code 没反应？**

按顺序排查：① 确认加了 `-g` 参数 → ② 完全退出重启 Claude Code（不是刷新）→ ③ 用 `npx skills list -g` 确认安装成功

**Q2：MCP 配置完，工具列表里不显示？**

先用在线 JSON 校验器检查 mcp.json 格式，然后确认配置文件路径正确，最后完全重启 Claude Code。

**Q3：装了技能之后响应变慢了？**

技能装太多会增加大模型上下文负担。建议按角色保留 3-5 个常用技能，把不常用的卸载： `npx skills remove <技能名> -g`

**Q4：Windows 系统能用吗？**

完全可以。命令格式相同，mcp.json 路径改用 Windows 路径分隔符（反斜杠）即可。

## 可以明天就做的三件事

**1\. 装 find-skills** — 相当于给 Claude Code 装了应用商店，后续发现新技能不用去网页翻：

```
npx skills add find-skills -y -g
```

**2\. 装角色对应的 3 个核心技能** — 前端装 frontend-design + canvas-design + vercel-react-best-practices；后端装 technical-writer + code-review + git-workflow。

**3\. 配 filesystem MCP** — 让 Claude Code 能读写你的本地项目文件，这是最基础也最有用的 MCP：

```
{   "mcpServers": {     "filesystem": {       "command": "npx",       "args": ["-y", "@modelcontextprotocol/server-filesystem", "/你的项目路径"]     }   } }
```

Skills 让 Claude 更聪明，MCP 让 Claude 更能干。

两套机制搭配，才能把 Claude Code 从「只会补代码的助手」，变成「能帮你搞定全流程的开发搭档」。

• 按角色选 3 个必装 Skills，不要贪多

• filesystem MCP 是第一个配置的 MCP

• 安装必须加 -g，装完必须重启

#ClaudeCode #AI编程 #Skills #MCP #程序员工具 #开发效率

**微信扫一扫赞赏作者**

继续滑动看下一个

攀云信息科技

向上滑动看下一个