---
title: "GitHub 10万星 Claude Code 配置揭秘：84条实用规则精华"
source: "https://mp.weixin.qq.com/s/AM37jgL7VJi5rb_ihferOQ"
author:
  - "[[AI数字公园]]"
published:
created: 2026-05-15
description: "最近很多人在聊 everything-claude-code 这个仓库——10万+ stars，Anthropic 黑客松冠军，但仓库太大太复杂，大多数人看完目录就懵了。今天我就帮你扒干净，提取最实用的规则精华，不用装全套也能用。"
tags:
  - "clippings"
---
AI数字公园 *2026年5月5日 16:35*

最近很多人在聊 everything-claude-code 这个仓库——10万+ stars，Anthropic 黑客松冠军，但仓库太大太复杂，大多数人看完目录就懵了。

今天我就帮你扒干净，提取 **最实用的规则精华** ，不用装全套也能用。

## 先搞懂：Rules 和 Skills 的区别

很多人在这一步就卡住了，其实很好理解：

- • **Rules** = 告诉你"做什么"的标准和规范
- • **Skills** = 告诉你"怎么做"的参考手册

就像做菜： **Rules 告诉你"盐要少放"，Skills 是盐放在哪、用多少、什么时候放** 。

这套仓库有 34+ 条规则，分布在 `common/` （通用）和 `typescript/` 、 `python/` 等语言目录下。

---

## 一、编码风格：三条铁律

**1\. KISS：简单优先**

> Keep It Simple, Stupid

选最简单的可行方案。避免过早优化，追求 **清晰而非巧妙** 。

**2\. DRY：别复制粘贴**

重复逻辑一定要提取成共享函数。复制粘贴会让代码"漂移"——以后改一处改不全。

**3\. YAGNI：别画大饼**

不构建还没需要的抽象。先从简单开始，有实际需求再重构。

**额外：不可变性原则**

```
// ❌ 不推荐：修改原对象
user.name = '新名字'

// ✅ 推荐：创建新对象
const updatedUser = { ...user, name: '新名字' }
```

好处：防止隐藏副作用、简化调试、支持安全并发。

---

## 二、测试规范：TDD + AAA + 80%

**TDD 强制流程：**

```
先写测试（失败）→ 最小实现（通过）→ 重构改进 → 验证覆盖率
```

**AAA 模式组织测试：**

```
# Arrange - 准备数据
user = create_test_user()

# Act - 执行操作
result = user.update_name('新名字')

# Assert - 验证结果
assert result.name == '新名字'
```

**测试覆盖率红线：80%**

三种测试缺一不可：

- • 单元测试（独立函数/组件）
- • 集成测试（API/数据库）
- • 端到端测试（关键用户流程）

---

## 三、安全规范：六项检查清单

每次提交前过一遍：

| 检查项 | 说明 |
| --- | --- |
| 无硬编码密钥 | 密钥放环境变量 |
| 用户输入验证 | 系统边界处验证 |
| 参数化查询 | 防 SQL 注入 |
| HTML 消毒 | 防 XSS |
| CSRF 保护 | 开启 |
| 错误信息 | 不泄露敏感数据 |

**密钥管理红线** ：禁止在源码中硬编码，发现泄露立即轮换。

---

## 四、性能优化：模型选择策略

很多人浪费钱，是因为用错了模型：

| 场景 | 推荐模型 |
| --- | --- |
| 轻量任务（频繁调用） | Haiku 4.5（省3倍成本） |
| 主要开发工作 | Sonnet 4.6（最佳编码） |
| 复杂架构决策 | Opus 4.5（深度推理） |

**上下文窗口红线** ：单次使用不超过 80%，超过就会开始"遗忘"前面的内容。

---

## 五、智能体编排：十种专用 Agent

仓库内置了 10 种专业 Agent（子代理），按需调用：

| Agent | 用途 |
| --- | --- |
| `planner` | 功能规划 |
| `architect` | 系统架构设计 |
| `tdd-guide` | 测试驱动开发 |
| `code-reviewer` | 代码审查 |
| `security-reviewer` | 安全分析 |
| `build-error-resolver` | 构建错误修复 |
| `e2e-runner` | 端到端测试 |
| `refactor-cleaner` | 代码清理 |
| `doc-updater` | 文档更新 |

**并行任务原则** ：独立操作一定要并行执行。比如同时跑安全分析 + 性能审查，不要串行。

---

## 六、Git 工作流：提交规范

**提交信息格式：**

```
<类型>: <描述>

类型：feat / fix / refactor / docs / test / chore / perf / ci
```

**PR 流程关键：**

- • 创建 PR 前要查看完整提交历史（ `git diff [基础分支]...HEAD` ）
- • 写清楚测试计划和待办事项

---

## 七、最容易上手的两条命令

不想装全套？这两个命令装了就能用：

**1\. `/plan` — 先想清楚再动手**

输入你的想法，Claude 会自动生成详细的 `plan.md` ，包含需求分析、技术设计、风险评估。在你开始写代码之前，先确认方向对不对。

**2\. `rules/` — 直接复制规则文件**

把规则文件复制到你的项目：

```
mkdir -p ~/.claude/rules
git clone https://github.com/affaan-m/everything-claude-code.git temp_ecc
cp temp_ecc/rules/common/*.md ~/.claude/rules/
rm -rf temp_ecc
```

这些规则就会在你每次和 Claude Code 对话时生效——相当于给 AI 配了一个"老司机在旁边盯着"。

---

## 总结

everything-claude-code 这仓库看起来吓人，其实核心就两件事：

1. 1\. **Rules 是一套行为规范** ——告诉你什么不该做、什么必须做
2. 2\. **Skills 是一套操作手册** ——告诉你具体怎么做

**最低成本使用方式** ：复制 `rules/common/` 下的规则文件到你的 `~/.claude/rules/` ，不用装插件，不用配环境，Chat with Claude Code 时自动生效。

剩下的 48 个 Agents、182 个 Skills，慢慢按需取用就行。

---

**你觉得哪条规则最有用？** 评论区聊聊，下期可以深入讲某一条。

继续滑动看下一个

AI数字公园

向上滑动看下一个