---
title: "superpowers-zh Skills 软件开发应用指南"
source: "https://mp.weixin.qq.com/s/CdYzBlg_zXM9mphzTXCpWw"
author:
  - "[[南邑技术]]"
published:
created: 2026-05-15
description: "superpowers-zh 是 superpowers（159k+ Stars 英文原版）的中文增强版，在完整翻译基础上新增 6 个中国原创 skills，共 20 个 skills，支持 Claude Code 等 17 款 AI 编程工具。"
tags:
  - "clippings"
---
南邑技术 *2026年4月23日 07:03*

## 项目简介

superpowers-zh 是 superpowers（159k+ Stars 英文原版）的中文增强版，在完整翻译基础上新增 6 个中国原创 skills，共 20 个 skills，支持 Claude Code 等 17 款 AI 编程工具。

| **翻译 Skills** | **中国原创 Skills** | **支持工具** |
| --- | --- | --- |
| **14 个** | **6 个** | Claude Code / Cursor / Windsurf / Kiro / Gemini CLI 等 17 款 |

## Skills 完整列表与应用场景

## 一、需求与设计阶段

**1\. 头脑风暴** *(brainstorming)*

• **用途：** 需求分析 → 设计规格，不写代码先想清楚

• **触发时机：** 拿到需求，不知从哪下手

• **使用方式：** 输入 /brainstorming，描述需求，AI 拆解设计规格、给出 2-3 个方案

• **示例：** 输入 \[批量导出功能\]，AI 先问：导出格式？数据量？权限？方案确认后再动手

**2\. 编写计划** *(writing-plans)*

• **用途：** 把规格拆成可执行的实施步骤票

• **触发时机：** 规格确认后，需要拆分开发任务

• **使用方式：** 输入 /writing-plans，提供规格，获得分步骤执行计划

## 二、编码实施阶段

**3\. 执行计划** *(executing-plans)*

• **用途：** 按计划逐步实施，每步验证

• **触发时机：** 有了计划，开始逐步推进

• **使用方式：** 输入 /executing-plans，AI 按步骤执行并在每步验证结果

**4\. 测试驱动开发** *(test-driven-development)*

• **用途：** 严格 TDD：先写测试，再写代码

• **触发时机：** 需要高质量、可测试的功能开发

• **使用方式：** 输入 /test-driven-development，AI 先生成测试用例，再实现功能

**5\. Git Worktree 使用** *(using-git-worktrees)*

• **用途：** 隔离式特性开发

• **触发时机：** 需要同时开发多个特性，或不想污染主分支

• **使用方式：** 输入 /using-git-worktrees，AI 指导创建隔离的工作树分支

**6\. 派遣并行 Agent** *(dispatching-parallel-agents)*

• **用途：** 多任务并发执行

• **触发时机：** 有多个独立子任务需要同时处理

• **使用方式：** 输入 /dispatching-parallel-agents，AI 拆分任务并行执行，提升效率

**7\. 子 Agent 驱动开发** *(subagent-driven-development)*

• **用途：** 每个任务一个 agent，两轮审查

• **触发时机：** 复杂任务需要独立审查和双重校验

• **使用方式：** 输入 /subagent-driven-development，每个子任务由独立 agent 完成并经两轮审查

## 三、调试与修复阶段

**8\. 系统化调试** *(systematic-debugging)*

• **用途：** 四阶段调试法：定位 → 分析 → 假设 → 修复

• **触发时机：** 遇到 bug，不知从哪排查

• **使用方式：** 输入 /systematic-debugging，AI 按四阶段方法论系统排查，不瞎猜

## 四、代码审查阶段

**9\. 请求代码审查** *(requesting-code-review)*

• **用途：** 派遣审查 agent 检查代码质量

• **触发时机：** 提 PR 前，或完成功能后自查

• **使用方式：** 输入 /requesting-code-review，AI 扮演审查者全面检查代码

**10\. 接收代码审查** *(receiving-code-review)*

• **用途：** 技术严谨地处理审查反馈，拒绝敷衍

• **触发时机：** 收到 code review 意见，需要认真处理

• **使用方式：** 输入 /receiving-code-review，AI 帮你严谨回应每条审查意见

**11\. 中文代码审查** *(chinese-code-review)* **【中国原创】**

• **用途：** 符合国内团队文化的代码审查规范

• **触发时机：** 国内团队协作，需要适配沟通文化的审查风格

• **使用方式：** 输入 /chinese-code-review，获得符合国内团队习惯的审查反馈

## 五、提交与合并阶段

**12\. 中文提交规范** *(chinese-commit-conventions)* **【中国原创】**

• **用途：** 适配国内团队的 commit message 规范

• **触发时机：** 写 Git commit message

• **使用方式：** 输入 /chinese-commit-conventions，生成符合 Conventional Commits 的中文 commit

**13\. 完成开发分支** *(finishing-a-development-branch)*

• **用途：** 合并 / PR / 保留 / 丢弃 四选一

• **触发时机：** 分支开发完成，需要决定如何处理

• **使用方式：** 输入 /finishing-a-development-branch，AI 引导完成分支收尾工作

**14\. 中文 Git 工作流** *(chinese-git-workflow)* **【中国原创】**

• **用途：** 适配 Gitee / Coding / 极狐 GitLab

• **触发时机：** 使用国内 Git 平台开发

• **使用方式：** 输入 /chinese-git-workflow，获得适配国内平台的工作流指导

## 六、文档与规范阶段

**15\. 中文技术文档** *(chinese-documentation)* **【中国原创】**

• **用途：** 中文排版 + 中英混排规则 + 告别机翻味

• **触发时机：** 需要编写技术文档、 README、API 文档

• **使用方式：** 输入 /chinese-documentation，AI 按中文排版规范生成专业文档

**16\. 完成前验证** *(verification-before-completion)*

• **用途：** 证据先行 ——声称完成前必须跑验证

• **触发时机：** 功能开发完成，声称 \[完成\]之前

• **使用方式：** 输入 /verification-before-completion，强制执行验证，不允许未测试就说完成

## 七、进阶工具类

**17\. MCP 服务器构建** *(mcp-builder)* **【中国原创】**

• **用途：** 构建生产级 MCP 工具，扩展 AI 能力边界

• **触发时机：** 需要为 AI 工具开发自定义 MCP 服务

• **使用方式：** 输入 /mcp-builder，获得生产级 MCP 工具构建指导

**18\. 工作流执行器** *(workflow-runner)* **【中国原创】**

• **用途：** 在 AI 工具内运行多角色 YAML 工作流

• **触发时机：** 需要多角色协作完成复杂流程

• **使用方式：** 输入 /workflow-runner，用 YAML 编排多角色协作工作流

**19\. 编写 Skills** *(writing-skills)*

• **用途：** 创建新 skill 的方法论

• **触发时机：** 现有 skills 不满足需求，需要自定义

• **使用方式：** 输入 /writing-skills，学习如何创建符合规范的自定义 skill

**20\. 使用 Superpowers** *(using-superpowers)*

• **用途：** 元技能：如何调用和优先使用 skills

• **触发时机：** 不知道应该用哪个 skill

• **使用方式：** 输入 /using-superpowers，AI 帮你选择最合适的 skill 组合

## 典型开发工作流

## 新功能完整开发流程

| **/brainstorming**  需求分析 | **/writing-plans**  编写计划 | **/executing-plans**  执行计划 | **/test-driven-development**  TDD 开发 | **/systematic-debugging**  遇 bug 调试 | **/requesting-code-review**  代码审查 | **/chinese-commit-conventions**  提交代码 | **/finishing-a-development-branch**  完成分支 |
| --- | --- | --- | --- | --- | --- | --- | --- |

## 快速修复流程

| **/systematic-debugging**  系统化调试 | **/receiving-code-review**  处理审查意见 | **/chinese-commit-conventions**  提交修复 |
| --- | --- | --- |

## 文档输出流程

| **/chinese-documentation**  生成中文技术文档 | **/verification-before-completion**  验证后声称完成 |
| --- | --- |

## 安装方式

在项目根目录执行（推荐）：

npx superpowers-zh

Claude Code 会自动识别并将 skills 安装到.claude/skills/ 目录，之后在对话框中输入 /skill名 即可使用。

## 各工具安装路径

| **工具** | **安装命令** | **Skills 目录** |
| --- | --- | --- |
| Claude Code | npx superpowers-zh | .claude/skills/ |
| Cursor | npx superpowers-zh | .cursor/skills/ |
| Windsurf | npx superpowers-zh | .windsurf/skills/ |
| Kiro | npx superpowers-zh | .kiro/steering/ |
| Gemini CLI | npx superpowers-zh | .gemini/skills/ |
| Copilot CLI | npx superpowers-zh --tool copilot | .claude/skills/ |

GitHub: https://github.com/jnMetaCode/superpowers-zh

AI · 目录

继续滑动看下一个

南邑技术

向上滑动看下一个