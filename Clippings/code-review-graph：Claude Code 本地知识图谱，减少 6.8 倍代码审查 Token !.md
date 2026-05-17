---
title: "code-review-graph：Claude Code 本地知识图谱，减少 6.8 倍代码审查 Token !"
source: "https://mp.weixin.qq.com/s/jc5RZB9eIYSAmEUMfMxtkg"
author:
  - "[[AI开源提效指南]]"
published:
created: 2026-05-15
description: "大家好！这里是AI开源提效指南！Code Review Graph 是一个本地知识图谱工具，专为 Claude Code 等 AI 编码助手设计。设计理念：停止浪费 Token，开始更智能地审查。 简单来说 code-review-graph 修复了AI编码工具每次任务都重新读取整个代码库的问题。"
tags:
  - "clippings"
---
AI开源提效指南 *2026年4月9日 22:30*

大家好！这里是 `AI开源提效指南` ！

Code Review Graph 是一个本地知识图谱工具，专为 Claude Code 等 AI 编码助手设计。

设计理念：“ **停止浪费 Token，开始更智能地审查”。** 简单来说 code-review-graph 修复了AI编码工具每次任务都重新读取整个代码库的问题。

**核心价值：**

- 构建代码的结构化地图
- 使用 Tree-sitter 追踪增量变更
- 通过 MCP 给 AI 助手提供精确上下文
- 只读取需要的内容
![[_resources/code-review-graph：Claude Code 本地知识图谱，减少 6.8 倍代码审查 Token !/482a825820092467a6ad4fcfd6c518fb_MD5.webp]]

## 🔥 核心特性

### 📉 Token 效率提升

| 场景 | Token 减少倍数 |
| --- | --- |
| 代码审查 | 6.8 |
| 日常编码任务 | 49 |
| 平均减少 | 8.2 |

### 🌐 支持 19 种语言 + Notebook

完整 Tree-sitter 语法支持，覆盖：

**主流语言:**`Python` 、 `TypeScript/TSX` 、 `JavaScript` 、 `Vue` 、 `Go` 、 `Rust` 、 `Java`

**其他语言:**`Scala` 、 `C#` 、 `Ruby` 、 `Kotlin` 、 `Swift` 、 `PHP` 、 `Solidity` 、 `C/C++` 、 `Dart` 、 `R` 、 `Perl` 、 `Lua`

**Notebook:**`Jupyter/Databricks (.ipynb)` 多语言单元格支持（ `Python、R、SQL` ）

**特殊文件:**`Perl XS` 文件 (.xs)

### 🧠 智能影响分析

**Blast Radius（爆炸半径）分析：**

- 当文件变更时，图谱追踪每个调用者、依赖项和可能受影响的测试
- AI 只读取这些文件，而非扫描整个项目
- **100% 召回率** - 从不错过真正受影响的文件

### ⚡ 增量更新

- 每次 git 提交或文件保存时，钩子自动触发
- 图谱对变更文件进行 diff，通过 SHA-256 哈希检查找到依赖项
- 2900 个文件的项目，重新索引仅需不到 2 秒

### 🏢 大型单体仓库优化

- 27,700+ 个文件被排除在审查上下文之外
- 仅约 15 个文件实际被读取
- 在大型单体仓库中，Token 浪费最痛苦，图谱能切断噪音

## 🚀 快速开始

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### 安装

```
pip install code-review-graph  # 或：pipx install code-review-graph
code-review-graph install      # 自动检测并配置所有支持的平台
code-review-graph build        # 解析代码库
```

**一条命令完成所有配置：**

- `install` 检测你拥有的 AI 编码工具
- 为每个工具写入正确的 MCP 配置
- 将图谱感知指令注入平台规则
- 自动检测是通过 uvx 还是 pip/pipx 安装

### 支持的平台

| 平台 | 命令 |
| --- | --- |
| Cursor | `code-review-graph install --platform cursor` |
| Claude Code | `code-review-graph install --platform claude-code` |
| Windsurf | 自动检测 |
| Zed | 自动检测 |
| Continue | 自动检测 |
| OpenCode | 自动检测 |
| Antigravity | 自动检测 |

> ⚠️ 需要 Python 3.10+。推荐安装 uv，MCP 配置会优先使用 uvx。

### 使用

打开项目后，对你的 AI 助手说：

```
Build the code review graph for this project
```

初始构建：500 个文件的项目约需 10 秒。之后图谱在每次文件编辑和 git 提交时自动更新。

## 📐 工作原理

### 架构图

```
你的代码库
    ↓
Tree-sitter AST 解析
    ↓
图谱节点（函数、类、导入）+ 边（调用、继承、测试覆盖）
    ↓
MCP 查询
    ↓
AI 助手只读取必要内容
```

### 爆炸半径分析

当文件变更时：

1. 图谱追踪每个调用者
2. 找到所有依赖项
3. 识别受影响的测试
4. 计算"爆炸半径"
5. AI 只读取这些文件

### 增量更新流程

```
文件变更 → 钩子触发 → diff 变更文件
    ↓
找到依赖项（SHA-256 哈希检查）
    ↓
仅重新解析变更内容
    ↓
图谱更新完成（<2 秒）
```

## 📊 性能基准测试

所有数据来自对 6 个真实开源仓库的自动化评估（共 13 次提交）。

### Token 效率对比

| 仓库 | 提交数 | 平均 Naive Tokens | 平均 Graph Tokens | 减少倍数 |
| --- | --- | --- | --- | --- |
| express | 2 | 693 | 983 | 0.7x |
| fastapi | 2 | 4,944 | 614 | 8.1x |
| flask | 2 | 44,751 | 4,252 | 9.1x |
| gin | 3 | 21,972 | 1,153 | 16.4x |
| httpx | 2 | 12,044 | 1,728 | 6.9x |
| nextjs | 2 | 9,882 | 1,249 | 8.0x |
| **平均** | **13** | **\-** | **\-** | **8.2x** |

> 💡 **为什么 express 显示 <1x：** 对于小型包中的单文件变更，图谱上下文（元数据、边、审查指导）可能超过原始文件大小。图谱方法在多文件变更时优势明显。

### 影响分析准确率

| 仓库 | 平均 F1 | 平均精确率 | 召回率 |
| --- | --- | --- | --- |
| express | 0.667 | 0.50 | 1.0 |
| fastapi | 0.584 | 0.42 | 1.0 |
| flask | 0.475 | 0.34 | 1.0 |
| gin | 0.429 | 0.29 | 1.0 |
| httpx | 0.762 | 0.63 | 1.0 |
| nextjs | 0.331 | 0.20 | 1.0 |
| **平均** | **0.54** | **0.38** | **1.0** |

> 💡 **100% 召回率** - 爆炸半径分析不会错过真正受影响的文件。这是保守权衡，宁可标记过多文件，也不错过破坏性依赖。

### 构建性能

| 仓库 | 文件数 | 节点数 | 边数 | 流检测 | 搜索延迟 |
| --- | --- | --- | --- | --- | --- |
| express | 141 | 1,910 | 17,553 | 106ms | 0.7ms |
| fastapi | 1,122 | 6,285 | 27,117 | 128ms | 1.5ms |
| flask | 83 | 1,446 | 7,974 | 95ms | 0.7ms |
| gin | 99 | 1,286 | 16,762 | 111ms | 0.5ms |
| httpx | 60 | 1,253 | 7,896 | 96ms | 0.4ms |

## 🛠️ 功能特性

| 功能 | 详情 |
| --- | --- |
| 增量更新 | 仅重新解析变更文件，后续更新 <2 秒 |
| 19 种语言 + Notebook | Python/TS/JS/Go/Rust/Java 等 |
| 爆炸半径分析 | 精确显示变更影响的函数、类、文件 |
| 自动更新钩子 | 每次文件编辑和 git 提交自动更新 |
| 语义搜索 | 可选向量嵌入（sentence-transformers/Google Gemini/MiniMax） |
| 交互式可视化 | D3.js 力导向图，支持边类型切换和搜索 |
| 本地存储 | SQLite 文件在 `.code-review-graph/` ，无需外部数据库 |
| Watch 模式 | 工作时持续更新图谱 |
| 执行流追踪 | 从入口点追踪调用链，按关键性排序 |
| 社区检测 | 通过 Leiden 算法或文件分组聚类相关代码 |
| 架构概览 | 自动生成架构图，带耦合警告 |
| 风险评分审查 | `detect_changes`  将 diff 映射到受影响函数、流和测试缺口 |
| 重构工具 | 重命名预览、死代码检测、社区驱动建议 |
| Wiki 生成 | 从社区结构自动生成 Markdown Wiki |
| 多仓库注册表 | 注册多个仓库，跨所有仓库搜索 |
| MCP Prompts | 5 个工作流模板：review/architecture/debug/onboard/pre-merge |
| 全文搜索 | FTS5 驱动的混合搜索，结合关键词和向量相似度 |

## 🔧 CLI 参考

### 安装命令

```
code-review-graph install                    # 自动检测并配置所有平台
code-review-graph install --platform <name>  # 针对特定平台
```

### 图谱管理

```
code-review-graph build        # 解析整个代码库
code-review-graph update       # 增量更新（仅变更文件）
code-review-graph status       # 图谱统计信息
code-review-graph watch        # 文件变更时自动更新
code-review-graph visualize    # 生成交互式 HTML 图谱
```

### 高级功能

```
code-review-graph wiki              # 从社区生成 Markdown Wiki
code-review-graph detect-changes    # 风险评分的变更影响分析
code-review-graph register <path>   # 注册仓库到多仓库注册表
code-review-graph unregister <id>   # 从注册表移除
code-review-graph repos             # 列出已注册的仓库
code-review-graph eval              # 运行评估基准测试
code-review-graph serve             # 启动 MCP 服务器
```

## 🤖 22 个 MCP 工具

AI 助手在图谱构建后自动使用这些工具：

| 工具 | 描述 |
| --- | --- |
| `build_or_update_graph_tool` | 构建或增量更新图谱 |
| `get_impact_radius_tool` | 变更文件的爆炸半径 |
| `get_review_context_tool` | Token 优化的审查上下文 |
| `query_graph_tool` | 调用者、被调用者、测试、导入、继承查询 |
| `semantic_search_nodes_tool` | 按名称或含义搜索代码实体 |
| `embed_graph_tool` | 计算向量嵌入用于语义搜索 |
| `list_graph_stats_tool` | 图谱大小和健康状态 |
| `find_large_functions_tool` | 查找超过行数阈值的函数/类 |
| `list_flows_tool` | 列出执行流，按关键性排序 |
| `get_flow_tool` | 获取单个执行流的详情 |
| `get_affected_flows_tool` | 查找受变更文件影响的流 |
| `list_communities_tool` | 列出检测到的代码社区 |
| `get_community_tool` | 获取单个社区的详情 |
| `get_architecture_overview_tool` | 从社区结构获取架构概览 |
| `detect_changes_tool` | 代码审查的风险评分变更影响分析 |
| `refactor_tool` | 重命名预览、死代码检测、建议 |
| `apply_refactor_tool` | 应用先前预览的重构 |
| `generate_wiki_tool` | 从社区生成 Markdown Wiki |
| `get_wiki_page_tool` | 检索特定 Wiki 页面 |
| `list_repos_tool` | 列出已注册的仓库 |
| `cross_repo_search_tool` | 跨所有已注册仓库搜索 |

### MCP Prompts（5 个工作流模板）

- `review_changes` - 审查变更
- `architecture_map` - 架构映射
- `debug_issue` - 调试问题
- `onboard_developer` - 开发者入职
- `pre_merge_check` - 合并前检查

## 📁 配置

### 排除路径

在仓库根目录创建 `.code-review-graphignore` 文件：

```
generated/**
*.generated.ts
vendor/**
node_modules/**
```

### 可选依赖组

```
pip install code-review-graph[embeddings]       # 本地向量嵌入
pip install code-review-graph[google-embeddings] # Google Gemini 嵌入
pip install code-review-graph[communities]       # 社区检测
pip install code-review-graph[eval]              # 评估基准测试
pip install code-review-graph[wiki]              # Wiki 生成
pip install code-review-graph[all]               # 所有可选依赖
```

## 🔗 参考

```
- 官方网站: https://code-review-graph.com
- GitHub 仓库: https://github.com/tirth8205/code-review-graph
```

---

**🎯** **觉得这份工具干货有用？不妨这样做**

- ⭐ 星标 / 置顶公众号， **第一时间解锁最新工具分享！**
- ✅ **点赞** 「 **推荐** 」，让更多技术伙伴发现优质干货！
- 🔗 **转发** 给团队小伙伴，一起高效提效！
- 💬 **底部留言区** ，告诉我你想找的工具/项目方向！

**📬 长期追踪优质开源工具**

- 关注「 **AI 开源提效指南** 」｜日更开源神器，玩转技术提效！
- 回复 **【容器加速器】** ，即刻开启你的高效探索之旅～

AI智能体 · 目录

继续滑动看下一个

AI开源提效指南

向上滑动看下一个