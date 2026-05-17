---
title: "Ralph Wiggum 插件 | 技术文档"
source: "https://api.leagsoft.ai/aicodex-docs/ai-cli/claude/ralph-wiggum.html"
author:
published:
created: 2026-05-15
description: "技术文档网站"
tags:
  - "clippings"
---
## Ralph Wiggum 插件

Ralph Wiggum 是 Claude Code 的官方插件，实现了自主迭代开发循环技术。该插件让 Claude 能够在无需人工干预的情况下，通过自我引用反馈循环持续改进工作，直到任务完成。

## 概述

### 什么是 Ralph Wiggum？

Ralph Wiggum 是一种"循环"技术——你给 Claude Code 一个任务，它开始工作，当它尝试退出时，Stop 钩子会阻止退出并将相同的提示词重新注入，循环继续。每次迭代中，之前修改的文件仍然存在，因此每次迭代都能在上一次的基础上继续构建。

核心概念可以用一个简单的 shell 循环来描述：

```bash
while :; do cat PROMPT.md | claude ; done
```

### 名称由来

该技术以《辛普森一家》中的角色 Ralph Wiggum 命名，体现了"尽管遭遇挫折仍持续迭代"的哲学——"确定性地失败，直到成功"。

### 工作原理

1. **启动循环** ：用户通过 `/ralph-loop` 命令启动一个自主循环
2. **执行任务** ：Claude 读取提示词并开始工作
3. **尝试退出** ：当 Claude 尝试退出时
4. **拦截退出** ：Stop 钩子（hooks/stop-hook.sh）拦截退出，返回退出码 2
5. **重新注入** ：相同的提示词被重新注入，循环继续
6. **状态保留** ：每次迭代都能看到之前修改的文件和 git 历史
7. **完成退出** ：当满足完成条件或达到最大迭代次数时，循环结束

## 安装

### 前置条件

- 已安装 Claude Code
- macOS 或 Linux 系统
- 安装 `jq` （JSON 处理工具）
```bash
# macOS
brew install jq

# Linux (Debian/Ubuntu)
sudo apt install jq

# Linux (Fedora/RHEL)
sudo dnf install jq
```

### 第一步：添加官方插件市场

在安装插件之前，需要先添加 Anthropic 官方插件市场：

```bash
# 进入 Claude Code
claude

# 添加官方插件市场
> /plugin marketplace add anthropics/claude-code
```

执行成功后，会显示： `Successfully added marketplace: claude-code-plugins`

### 第二步：安装 Ralph Wiggum 插件

添加市场后，安装 Ralph Wiggum 插件：

```bash
# 安装 Ralph Wiggum 插件
> /plugin install ralph-wiggum@claude-plugins-official
```

> **注意** ： `claude-plugins-official` 是 Anthropic 官方维护的默认插件市场，包含经过审核的官方插件。

### 第三步：验证安装

```bash
# 查看已安装的插件
> /plugin

# 查看帮助信息，确认新命令可用
> /help
```

安装成功后，你应该能看到以下命令：

- `/ralph-loop` - 启动自主迭代循环
- `/cancel-ralph` - 取消循环
- `/ralph-wiggum:help` - 查看帮助信息

## 命令参考

### /ralph-loop

启动一个 Ralph 自主迭代循环。

**语法：**

```bash
/ralph-loop "<提示词>" --max-iterations <n> --completion-promise "<完成标记>"
```

**参数：**

| 参数 | 描述 | 默认值 |
| --- | --- | --- |
| `<提示词>` | 要执行的任务描述（必需） | \- |
| `--max-iterations <n>` | 最大迭代次数 | 无限制 |
| `--completion-promise <text>` | 表示任务完成的精确字符串 | 无 |

**示例：**

```bash
# 基础用法
/ralph-loop "重构用户认证模块，添加单元测试" --max-iterations 30

# 带完成标记
/ralph-loop "构建 REST API。要求：CRUD 操作、输入验证、测试。完成时输出 <promise>COMPLETE</promise>" --completion-promise "COMPLETE" --max-iterations 50
```

### /cancel-ralph

取消当前活跃的 Ralph 循环。

**语法：**

```bash
/cancel-ralph
```

## 编写有效的提示词

### 1\. 明确的完成标准

提示词必须包含清晰、可验证的完成条件。

❌ **不好的写法：**

```
构建一个 todo API，让它变得很好。
```

✅ **好的写法：**

```
构建一个 REST API 用于 todo 管理。

完成标准：
- 所有 CRUD 端点正常工作
- 输入验证已实现
- 测试通过（覆盖率 > 80%）
- README 包含 API 文档
- 完成时输出：<promise>COMPLETE</promise>
```

### 2\. 渐进式目标

将大任务拆分为多个阶段。

❌ **不好的写法：**

```
创建一个完整的电商平台。
```

✅ **好的写法：**

```
分阶段实现电商功能：

阶段 1：用户认证（JWT、测试）
阶段 2：产品目录（列表/搜索、测试）
阶段 3：购物车（添加/删除、测试）

每个阶段完成后运行测试验证。
所有阶段完成后输出 <promise>COMPLETE</promise>
```

### 3\. 自我纠错机制

引导 Claude 使用测试驱动的方法。

```
使用 TDD 方法实现功能 X：
1. 编写失败的测试
2. 实现功能
3. 运行测试
4. 如果测试失败，调试并修复
5. 需要时进行重构
6. 重复直到所有测试通过
7. 完成时输出：<promise>COMPLETE</promise>
```

### 4\. 安全退出策略

**始终设置 `--max-iterations` 作为安全阀：**

```bash
# 推荐：始终设置合理的迭代限制
/ralph-loop "尝试实现功能 X" --max-iterations 20
```

在提示词中包含卡住时的处理方式：

```
如果经过 15 次迭代后仍未完成：
- 记录阻碍进度的问题
- 列出已尝试的方法
- 建议替代方案
```

> ⚠️ **重要提示：** `--completion-promise` 使用精确字符串匹配，不够可靠。始终将 `--max-iterations` 作为主要的安全机制。

## 适用场景

### 适合使用 Ralph Wiggum 的任务

| 场景 | 描述 |
| --- | --- |
| **大规模重构** | 框架迁移、依赖升级 |
| **批量操作** | 文档生成、代码标准化 |
| **测试覆盖扩展** | 为未覆盖的函数编写测试 |
| **绿地项目脚手架** | 过夜初始化项目并迭代完善 |
| **有自动验证的任务** | 有测试、linter 等自动检查的任务 |

### 不适合使用的场景

| 场景 | 原因 |
| --- | --- |
| **需要人工判断的任务** | 设计决策、架构选择 |
| **一次性操作** | 简单的单次修改 |
| **不明确的成功标准** | 无法自动验证完成状态 |
| **生产环境调试** | 需要人工审核和判断 |
| **安全敏感代码** | 认证、支付、数据处理 |

## 最佳实践

### 1\. 保守设置迭代次数

```bash
# 小任务：10-20 次迭代
/ralph-loop "添加输入验证" --max-iterations 15

# 中等任务：30-50 次迭代
/ralph-loop "重构认证模块" --max-iterations 40

# 大任务：50-100 次迭代（谨慎使用）
/ralph-loop "迁移到新框架" --max-iterations 80
```

### 2\. 监控成本

大规模循环可能消耗大量 API 额度：

- 50 次迭代的大型代码库任务可能消耗 $50-100+ API 费用
- 建议从较小的迭代次数开始测试
- 使用 `--max-iterations` 控制成本上限

### 3\. 利用 Git 历史

Ralph Wiggum 在每次迭代中保留 git 历史。建议：

- 在启动循环前创建一个新分支
- 循环结束后审查所有提交
- 如果结果不满意，可以轻松回滚
```bash
# 启动前
git checkout -b feature/ralph-refactor

# 运行 Ralph 循环
/ralph-loop "..." --max-iterations 30

# 循环后审查
git log --oneline
git diff main
```

### 4\. 提示词模板

**通用任务模板：**

```
任务：[任务描述]

要求：
- [要求 1]
- [要求 2]
- [要求 3]

验证步骤：
1. 运行测试：[测试命令]
2. 检查覆盖率：[覆盖率命令]
3. 运行 linter：[lint 命令]

完成标准：
- 所有测试通过
- 覆盖率 >= [目标]%
- 无 linter 错误

完成时输出：<promise>DONE</promise>

如果卡住超过 [N] 次迭代：
- 输出当前进度
- 列出遇到的问题
- 提供解决建议
```

## 实际案例

### 案例 1：API 开发

```bash
/ralph-loop "构建用户管理 REST API。

端点要求：
- POST /users - 创建用户
- GET /users/:id - 获取用户
- PUT /users/:id - 更新用户
- DELETE /users/:id - 删除用户

技术要求：
- 使用 Express.js
- 输入验证使用 Joi
- JWT 认证
- Jest 测试覆盖率 > 80%

每次迭代：
1. 实现一个端点
2. 编写测试
3. 运行测试
4. 修复失败的测试
5. 继续下一个端点

完成时输出：<promise>API_COMPLETE</promise>" --completion-promise "API_COMPLETE" --max-iterations 40
```

### 案例 2：代码迁移

```bash
/ralph-loop "将项目从 JavaScript 迁移到 TypeScript。

步骤：
1. 配置 tsconfig.json
2. 安装必要的类型定义
3. 逐文件转换（保持功能不变）
4. 修复类型错误
5. 运行测试确保功能正常

优先级：
- 先转换无依赖的文件
- 再转换有内部依赖的文件
- 最后处理外部依赖

完成标准：
- 所有 .js 文件转换为 .ts
- 无 TypeScript 编译错误
- 所有测试通过

完成时输出：<promise>MIGRATION_DONE</promise>" --completion-promise "MIGRATION_DONE" --max-iterations 60
```

## 故障排除

### 常见问题

| 问题 | 解决方案 |
| --- | --- |
| 循环不停止 | 确保设置了 `--max-iterations` |
| 完成标记无效 | 使用精确匹配的字符串，避免特殊字符 |
| jq 未找到 | 安装 jq： `brew install jq` 或 `apt install jq` |
| 循环卡在同一错误 | 检查提示词是否包含明确的错误处理指导 |

### 手动取消循环

```bash
# 使用命令取消
/cancel-ralph

# 如果命令无效，可以：
# 1. 按 Ctrl+C 中断当前进程
# 2. 关闭终端窗口
```

## 相关资源

- **官方插件仓库** ： [anthropics/claude-code/plugins/ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)
- **原始技术文章** ： [ghuntley.com/ralph](https://ghuntley.com/ralph/)
- **社区实现** ： [frankbria/ralph-claude-code](https://github.com/frankbria/ralph-claude-code)
- **详细教程** ： [paddo.dev/blog/ralph-wiggum-autonomous-loops](https://paddo.dev/blog/ralph-wiggum-autonomous-loops/)

## 哲学与思考

Ralph Wiggum 技术体现了以下理念：

1. **迭代优于完美** ：不要追求一次完美，让循环不断改进
2. **失败是数据** ："确定性地失败"提供了调整提示词的信息
3. **操作者技能很重要** ：成功取决于编写好的提示词，而不仅仅是拥有好的模型
4. **持久性获胜** ：持续尝试直到成功；循环自动处理重试逻辑

正如创始人所说："如果你能精确描述'完成'是什么样子，Ralph 就能迭代实现它。"