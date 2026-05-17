---
title: "Skill语法完全手册：从入门到精通，让AI100%按你的规则执行"
source: "https://mp.weixin.qq.com/s/r2Dbvr6Z1uzRjOtt5JnhBw"
author:
  - "[[虾丞相]]"
published:
created: 2026-05-15
description: "AI工具调用次次错？流程教了八百遍还是忘？\x0d\x0aSkill就是你的终极解决方案！\x0d\x0a\x0d\x0a\x0d\x0aSkill"
tags:
  - "clippings"
---
虾丞相 *2026年3月27日 07:00*

AI工具调用次次错？流程教了八百遍还是忘？

Skill就是你的终极解决方案！

## Skill语法完全手册：从入门到精通

让AI100%按你的规则执行任务

## 🚀 什么是Skill？

Skill是符合AgentSkills规范的可执行技能包，本质上是给AI代理用的标准化操作SOP。

不用你每次都一步步告诉AI：先搜资料、再写文件、最后发消息。把流程固化成Skill，AI自动就能按标准流程执行， **成功率100%** 。

目前所有主流AI开发平台（OpenClaw、Claude Desktop、Cursor等）都已经支持Skill语法，一次编写，多平台运行。

💡 核心设计理念：渐进式披露（Progressive Disclosure）——元数据常驻上下文，SKILL.md按需加载，脚本和引用文件只在需要时调用，高效管理有限的上下文窗口资源。

## 📂 Skill文件结构与生效范围

一个标准Skill就是一个独立文件夹，核心是 `SKILL.md` 文件，采用 **YAML Frontmatter + Markdown内容** 的双层结构：

```
--- name: skill-name description: 技能的详细描述，AI据此判断是否触发 allowed-tools: Read, Grep, Bash model: sonnet ---  # 技能标题 这里是技能的指令内容，Markdown格式...
```

完整的目录结构示例：

```
skill-name/ ├── SKILL.md          # 核心文件，必须有 ├── reference.md      # 可选：参考文档 ├── examples.md       # 可选：示例集合 └── scripts/          # 可选：自定义脚本     └── run.py
```

### 生效范围与优先级

Skill的存放位置决定了生效范围，优先级从高到低：

| 位置类型 | 路径 | 适用范围 |
| --- | --- | --- |
| Enterprise | 企业托管路径 | 组织内所有成员 |
| Personal | `~/.claude/skills/{skill-name}/` | 当前用户所有项目 |
| Project | `.claude/skills/{skill-name}/` | 当前代码库，可提交Git共享团队 |
| Plugin | `{plugin}/skills/{skill-name}/` | 安装了该插件的用户 |

## ⚙️ YAML Frontmatter元数据语法

### 必填字段

| 字段 | 语法示例 | 说明 |
| --- | --- | --- |
| `name` | `name: mysql-nl2sql` | 技能名称，仅限小写字母、数字和连字符，最大64字符，通常与文件夹名一致 |
| `description` | `description: 当用户询问数据库、数据分析时自动触发` | 技能用途描述，AI匹配意图的关键依据，最大1024字符 |

💡 编写技巧：description要写得"pushy"一些，明确列出触发场景的关键词，因为AI倾向于"欠触发"而非"过触发"。

### 可选字段

| 字段 | 语法示例 | 说明 |
| --- | --- | --- |
| `allowed-tools` | `allowed-tools: Read, Bash(python:*)` | 技能激活后，允许AI无需询问直接使用的工具列表，可精确到命令级别限制 |
| `model` | `model: sonnet` | 指定运行该技能时使用的特定模型，默认继承对话模型 |
| `context` | `context: fork` | 在隔离的subagent中运行技能，不污染主对话上下文 |
| `disable-model-invocation` | `disable-model-invocation: true` | 禁止模型自动触发，只能手动通过 `/skill-name` 调用 |

## 📝 内容区核心语法

### 3.1 参数传递语法

Skill支持接收用户输入的参数，通过占位符实现：

| 语法 | 说明 | 示例 |
| --- | --- | --- |
| `$ARGUMENTS` | 获取用户输入的所有参数（推荐） | `/fix-issue 123`  → `$ARGUMENTS = "123"` |
| `$0, $1, $2` | 按位置获取单个参数 | `/run test --verbose`  → `$0="test", $1="--verbose"` |

使用示例：

```
--- name: fix-issue description: 修复GitHub issue ---  # 指令 修复GitHub issue #$ARGUMENTS，步骤如下： 1. 分析问题 2. 编写修复代码 3. 提交PR
```

### 3.2 动态上下文语法

在执行Skill时，可以动态插入shell命令的输出结果，语法为`` ! `command` `` ：

```
--- name: pr-review description: 审查PR代码 ---  # 当前PR信息 PR详情：! \`gh pr view $ARGUMENTS --json title,body,author\`  # 审查要求 基于以上PR信息进行代码审查...
```

技能运行时，每个! backtick命令会立即执行，输出替换占位符，AI收到的是已渲染的完整提示词。

### 3.3 文件引用语法（渐进式披露）

为优化上下文窗口，Skill支持将详细内容拆分到子文件中，通过Markdown链接引用，AI只有在需要时才会读取这些文件：

```
## 附加资源 - API详细文档请参阅 [reference.md](reference.md) - 完整示例请参阅 [examples.md](examples.md) - 校验脚本位于 [scripts/validator.py](scripts/validator.py)
```

### 3.4 工具调用与权限

在frontmatter中使用 `allowed-tools` 声明技能可使用的工具：

```
allowed-tools: Read, Write, Bash(python:*, pip:*), Grep
```

不在白名单内的工具，AI调用时必须获得用户二次确认，安全可控。

## 💯 完整实战示例

以下是一个综合运用多种语法的MySQL自然语言转SQL查询Skill：

```
--- name: mysql-nl2sql description: 将中文业务问题转换为SQL查询并执行分析。当用户询问数据库、数据分析、员工薪资、部门统计时自动触发 allowed-tools: Read, Bash(python:*) model: sonnet ---  # MySQL数据分析技能  ## 参数接收 用户问题：$ARGUMENTS  ## 数据库背景 当前连接employees示例数据库，可用表： - employees（员工信息） - salaries（薪资记录） - departments（部门信息）  ## 执行流程 1. **理解用户问题**：$ARGUMENTS 2. **生成SQL**：根据问题生成单条安全的MySQL查询 3. **执行查询**： \`\`\`bash python scripts/execute_sql.py "$(cat <<'SQL' {生成的SQL} SQL )" 4. 输出分析报告：基于查询结果生成结构化报告  ## 参考文档 详细示例请参阅 [examples.md](examples.md) SQL生成规则： - 只生成SELECT查询 - 必须包含LIMIT（不超过1000） - 禁止DROP、DELETE、UPDATE - 详细规则见 [reference.md](reference.md)
```

对应的目录结构：

```
mysql-nl2sql/ ├── SKILL.md ├── reference.md    # 详细规则文档 ├── examples.md     # 示例集合 └── scripts/     └── execute_sql.py
```

## ⚔️ Skill vs MCP：核心区别是什么？

很多人搞混这俩，看完下面的对比你就懂了：

#### Skill 定位：AI的操作指南

✅ 应用层，专注于任务流程编排

✅ 定义"什么时候用什么工具，怎么用"

✅ 多平台通用，所有主流AI开发平台都支持

✅ 可以编排复杂多步工作流

✅ 内置安全控制、权限过滤

#### MCP 定位：工具连接协议

✅ 协议层，专注于LLM与外部资源的通信标准

✅ 定义"怎么和工具/服务通信"

✅ 语言平台无关，支持所有兼容MCP的主机

✅ 仅定义单次工具调用的通信规范

✅ 安全控制依赖主机实现

举个直白的例子：

MCP是USB接口标准，定义了充电器和手机怎么传数据。

Skill是手机里的快捷指令，定义了插上充电器之后自动开低电量、关蓝牙、同步相册。

两者是互补关系，不是替代关系。

## 💼 典型使用场景

#### 场景1：高频工作流固化

把公众号发布、代码审查、故障排查等固定流程做成Skill，AI自动按流程执行，不用反复引导。

#### 场景2：团队知识沉淀

把踩过的坑、最佳实践做成Skill，新人入职直接加载就能用，不用反复问老人。

#### 场景3：多代理分工协作

不同代理加载不同Skill：开发代理加载代码Skill，运维代理加载服务器Skill，内容代理加载写作Skill，分工明确。

## 📋 语法速查表

<table><thead><tr><th><p>语法类别</p></th><th><p>语法元素</p></th><th><p>示例</p></th></tr></thead><tbody><tr><td rowspan="6"><strong>Frontmatter元数据</strong></td><td><code>name:</code></td><td><code>name: my-skill</code></td></tr><tr><td><code>description:</code></td><td><code>description: 用于...</code></td></tr><tr><td><code>allowed-tools:</code></td><td><code>allowed-tools: Read, Bash</code></td></tr><tr><td><code>model:</code></td><td><code>model: sonnet</code></td></tr><tr><td><code>context:</code></td><td><code>context: fork</code></td></tr><tr><td><code>disable-model-invocation:</code></td><td><code>disable-model-invocation: true</code></td></tr><tr><td rowspan="2"><strong>参数传递</strong></td><td><code>$ARGUMENTS</code></td><td><p>获取全部参数</p></td></tr><tr><td><code>$0, $1</code></td><td><p>获取位置参数</p></td></tr><tr><td><strong>动态内容</strong></td><td><code>! `command`</code></td><td><code>! `date`</code></td></tr><tr><td><strong>文件引用</strong></td><td><code>[text](file.md)</code></td><td><code>[参考](reference.md)</code></td></tr></tbody></table>

Skill本质上是把人的经验固化成AI可以理解、可以执行的标准化流程

你最想做一个什么Skill？评论区聊聊~

AI入门系列文章 · 目录

继续滑动看下一个

架构师的野望

向上滑动看下一个