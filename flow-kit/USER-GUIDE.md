# flow-kit 用户指导手册

> **版本**: v1.12.7  
> **更新日期**: 2026-05-08  
> **适用环境**: Claude Code / Windsurf / Cursor / GitHub Copilot

---

## 目录

- [第一章：概述](#第一章概述)
  - [1.1 什么是 flow-kit](#11-什么是-flow-kit)
  - [1.2 核心特性](#12-核心特性)
  - [1.3 适用场景](#13-适用场景)
  - [1.4 术语表](#14-术语表)
- [第二章：安装与配置](#第二章安装与配置)
  - [2.1 安装方式](#21-安装方式)
  - [2.2 初始化配置](#22-初始化配置)
  - [2.3 多 IDE 适配](#23-多-ide-适配)
  - [2.4 验证安装](#24-验证安装)
- [第三章：核心概念](#第三章核心概念)
  - [3.1 8 阶段工作流](#31-8-阶段工作流)
  - [3.2 棕地护栏 B1-B6](#32-棕地护栏-b1-b6)
  - [3.3 元技能包](#33-元技能包)
  - [3.4 执行模式](#34-执行模式)
  - [3.5 上下文预算管理](#35-上下文预算管理)
- [第四章：快速开始](#第四章快速开始)
  - [4.1 首次健康扫描](#41-首次健康扫描)
  - [4.2 创建变更规格](#42-创建变更规格)
  - [4.3 启动开发流程](#43-启动开发流程)
  - [4.4 场景决策指南](#44-场景决策指南)
- [第五章：阶段详解](#第五章阶段详解)
  - [5.1 Phase 0: 变更立项](#51-phase-0-变更立项)
  - [5.2 Phase 1: 需求澄清](#52-phase-1-需求澄清)
  - [5.3 Phase 2: 架构设计](#53-phase-2-架构设计)
  - [5.4 Phase 3: 任务拆解](#54-phase-3-任务拆解)
  - [5.5 Phase 4: 开发执行](#55-phase-4-开发执行)
  - [5.6 Phase 5: 测试验证](#56-phase-5-测试验证)
  - [5.7 Phase 6: 代码审查](#57-phase-6-代码审查)
  - [5.8 Phase 7: 集成归档](#58-phase-7-集成归档)
  - [5.9 Phase 8: 变更回滚](#59-phase-8-变更回滚)
- [第六章：命令参考](#第六章命令参考)
  - [6.1 核心命令](#61-核心命令)
  - [6.2 管理命令](#62-管理命令)
  - [6.3 多代理编排命令](#63-多代理编排命令)
- [第七章：多代理编排](#第七章多代理编排)
  - [7.1 并行执行引擎](#71-并行执行引擎)
  - [7.2 子代理重试机制](#72-子代理重试机制)
  - [7.3 超时终止机制](#73-超时终止机制)
  - [7.4 结果聚合与验证](#74-结果聚合与验证)
- [第八章：最佳实践](#第八章最佳实践)
  - [8.1 项目类型识别](#81-项目类型识别)
  - [8.2 规模评估策略](#82-规模评估策略)
  - [8.3 渐进披露原则](#83-渐进披露原则)
  - [8.4 上下文优化技巧](#84-上下文优化技巧)
  - [8.5 团队协作规范](#85-团队协作规范)
- [第九章：故障排查](#第九章故障排查)
  - [9.1 常见问题](#91-常见问题)
  - [9.2 错误代码参考](#92-错误代码参考)
  - [9.3 日志分析](#93-日志分析)
  - [9.4 恢复策略](#94-恢复策略)
- [附录](#附录)
  - [A. 项目结构说明](#a-项目结构说明)
  - [B. 版本历史](#b-版本历史)
  - [C. 贡献指南](#c-贡献指南)

---

## 第一章：概述

### 1.1 什么是 flow-kit

flow-kit 是面向 Claude Code 的结构化开发流程工具包，提供完整的 8 阶段开发工作流、棕地护栏规则、可复用技能包、工程模板和参考材料。它旨在帮助开发团队在 AI 辅助编程环境中保持工程规范、控制上下文窗口使用率、并确保代码质量。

### 1.2 核心特性

| 特性 | 描述 |
|------|------|
| **8 阶段工作流** | 从需求立项到集成归档的完整开发流程 |
| **棕地护栏 B1-B6** | 六大护栏保护现有代码库免受破坏性变更 |
| **多代理编排** | 支持并行执行多个子代理，主上下文维持在 30-40% |
| **元技能包** | 15+ 个可复用技能模块覆盖需求、开发、测试、审查 |
| **多语言支持** | TypeScript、Python、Java、Go、Rust、PHP 工程规范 |
| **上下文预算** | 智能 token 估算与预算管理，防止上下文溢出 |
| **Hooks 系统** | 5 个自动化钩子实现质量门禁和通知 |

### 1.3 适用场景

| 场景 | 推荐配置 |
|------|---------|
| 简单功能变更（1-3 文件） | L0 极简模式，跳过 Phase 2-3 |
| 中等复杂度新功能 | L1 标准 8 阶段流程 |
| 复杂架构变更 | L2-L3 完整流程 + 设计评审 + 多代理并行 |
| 棕地项目迭代 | 启用 B1-B6 全部护栏 |
| 团队并行开发 | 多代理编排 + 角色分工 |

### 1.4 术语表

| 术语 | 定义 |
|------|------|
| **Phase** | 开发流程的一个阶段，共 0-8 九个阶段 |
| **Guardrail** | 护栏规则，防止破坏性变更的安全检查 |
| **Skill** | 可复用的技能模块，提供特定能力 |
| **Hook** | 自动化钩子，在特定事件触发时执行 |
| **Context Budget** | 上下文窗口预算，控制 token 使用量 |
| **Subagent** | 子代理，在独立上下文中执行任务的 AI 实例 |
| **Brownfield** | 棕地项目，已有代码库的迭代开发 |
| **Greenfield** | 绿地项目，从零开始的新项目开发 |

---

## 第二章：安装与配置

### 2.1 安装方式

#### 方式一：克隆到项目（推荐）

```bash
git clone https://github.com/pwl1987/flow-kit.git /path/to/your-project/.flow-kit
```

#### 方式二：复制核心文件

```bash
# 复制核心文件到项目
cp flow-kit/GO.md /path/to/project/
cp -r flow-kit/phases /path/to/project/
cp -r flow-kit/templates /path/to/project/
cp -r flow-kit/config /path/to/project/
```

#### 方式三：作为 Git 子模块

```bash
git submodule add https://github.com/pwl1987/flow-kit.git .flow-kit
```

### 2.2 初始化配置

1. **加载宪法文件**（最高优先级）
   - `config/constitution.md` — 安全规则、数据完整性、部署规则、Git 安全
   - `config/default-user-config.md` — 默认用户配置
   - `config/system-rules.md` — R1-R8 系统级硬规则

2. **检测项目类型**
   ```
   /flow-kit:project-type detect
   ```

3. **安装 Hooks**（可选但推荐）
   ```
   /flow-kit:hooks install
   ```

### 2.3 多 IDE 适配

flow-kit 支持多种 AI 编程环境：

| IDE | 配置文件 | 自动检测 |
|-----|---------|---------|
| Claude Code | `.claude/settings.json` | 默认支持 |
| Windsurf | `.windsurfrules` | 自动适配 |
| Cursor | `.cursorrules` | 自动适配 |
| GitHub Copilot | `copilot.*` 配置 | 需手动配置 |

检测到非 Claude Code 环境时，请参考 `reference/multi-ide-guide.md` 完成适配。

### 2.4 验证安装

运行健康扫描验证安装是否成功：

```bash
/flow-kit:health
```

预期输出应包含：
- 项目类型检测结果
- 上下文状态
- Hooks 安装状态
- 建议的下一步操作

---

## 第三章：核心概念

### 3.1 8 阶段工作流

```
┌─────────────────────────────────────────────────────────────┐
│  0-CHANGE  →  1-REQUIREMENT  →  2-DESIGN  →  3-TASK       │
│                                                             │
│  4-DEV     →  5-TEST       →  6-REVIEW   →  7-INTEGRATION  │
│                                                             │
│                                                    ↓        │
│                                              8-ROLLBACK     │
└─────────────────────────────────────────────────────────────┘
```

| 阶段 | 名称 | 主要产出 | 关键活动 |
|------|------|---------|---------|
| 0 | 变更立项 | change-id、变更摘要 | 立项申请、影响评估 |
| 1 | 需求澄清 | 需求文档、验收标准 | 需求分析、边界定义 |
| 2 | 架构设计 | 设计文档、技术选型 | 架构设计、方案对比 |
| 3 | 任务拆解 | 任务列表、依赖图 | 任务拆分、并行检测 |
| 4 | 开发执行 | 代码实现、单元测试 | TDD 驱动、编码实现 |
| 5 | 测试验证 | 测试报告、覆盖率 | 集成测试、性能测试 |
| 6 | 代码审查 | 审查报告、修改建议 | 三轮评审、问题修复 |
| 7 | 集成归档 | 归档记录、经验教训 | 合并代码、知识沉淀 |
| 8 | 变更回滚 | 回滚记录、事故报告 | 紧急回滚、原因分析 |

### 3.2 棕地护栏 B1-B6

| 护栏 | 名称 | 检查内容 | 触发条件 |
|------|------|---------|---------|
| B1 | 文件变更限制 | 单文件修改行数 | > 50 行警告 |
| B2 | 破坏性变更 | API 签名变更、删除公共接口 | 任何破坏性变更 |
| B3 | 数据库安全 | DROP/ALTER/TRUNCATE 操作 | 危险 SQL 语句 |
| B4 | 安全检查 | 凭证泄露、注入漏洞 | 安全风险检测 |
| B5 | 性能护栏 | O(n²)循环、N+1查询、缺失索引 | 性能退化风险 |
| B6 | 测试覆盖率 | 新增代码测试覆盖率 | < 60% 阻断 |

### 3.3 元技能包

| 技能 | 用途 | 调用方式 |
|------|------|---------|
| requirement-clarify | 需求澄清与边界定义 | `/flow-kit:skill:requirement-clarify` |
| task-master | 任务拆解与依赖管理 | `/flow-kit:skill:task-master` |
| subagent-execution | 子代理执行与进度恢复 | `/flow-kit:skill:subagent-execution` |
| code-review | 三层代码审查 | `/flow-kit:skill:code-review` |
| debugging | 系统化调试 | `/flow-kit:skill:debugging` |
| parallel-dispatch | 并行任务分发 | `/flow-kit:skill:parallel-dispatch` |
| verification | 全量验证与对照 | `/flow-kit:skill:verification` |
| agent-orchestrator | 多代理编排决策 | `/flow-kit:skill:agent-orchestrator` |
| agent-pipeline | Agent 交接验证 | `/flow-kit:skill:agent-pipeline` |
| caveman-compress | 上下文压缩 | `/flow-kit:skill:caveman-compress` |
| dag-resolver | 依赖图解析 | `/flow-kit:skill:dag-resolver` |
| failure-detector | 失败检测与恢复 | `/flow-kit:skill:failure-detector` |
| output-self-check | 产物自检 | `/flow-kit:skill:output-self-check` |
| team-dispatch | 团队任务分发 | `/flow-kit:skill:team-dispatch` |
| ubiquitous-language | 统一语言定义 | `/flow-kit:skill:ubiquitous-language` |

### 3.4 执行模式

| 模式 | 名称 | 适用场景 | 特点 |
|------|------|---------|------|
| L0 | 极简模式 | 1-3 文件变更 | 跳过 Phase 2-3，最多改 3 文件 |
| L1 | 标准模式 | 中等复杂度功能 | 完整 8 阶段流程 |
| L2 | 团队模式 | 复杂架构变更 | 多代理并行 + 角色分工 |
| L3 | 大规模并行 | 大型项目重构 | 多 IDE 并行 + 全量护栏 |

切换模式：
```
/flow-kit:mode <autopilot|team|ralph>
```

### 3.5 上下文预算管理

flow-kit 提供智能上下文预算管理：

```bash
# 查看当前预算状态
context-budget.sh --status

# 估算文本 token
context-budget.sh --estimate "Hello world"

# 估算文件 token
context-budget.sh --estimate-file .planning/PROJECT.md

# 检查预算使用率
context-budget.sh --check 75000 100000

# 设置模型（claude/gpt4/gemini）
context-budget.sh --model claude

# 列出支持的模型
context-budget.sh --list-models

# 触发压缩
context-budget.sh --compress "auto-trigger"
```

**Token 估算精度**：
- Claude: 英文 0.25x, 中文 1.5x, 代码 0.35x
- GPT-4: 英文 0.25x, 中文 1.6x, 代码 0.30x
- Gemini: 英文 0.20x, 中文 1.4x, 代码 0.30x

---

## 第四章：快速开始

### 4.1 首次健康扫描

在开始任何开发工作前，运行健康扫描了解项目当前状态：

```bash
/flow-kit:health
```

健康扫描将检查：
- 项目类型（棕地/绿地）
- 技术栈识别
- 现有代码质量
- 潜在技术债务
- 建议的开发流程

### 4.2 创建变更规格

为每次变更创建独立的规格目录：

```bash
mkdir .specs/$(date +%Y%m%d%H%M%S)
```

规格目录应包含：
- `CHANGE.md` — 变更摘要
- `REQUIREMENT.md` — 需求文档
- `DESIGN.md` — 设计文档
- `TASK.md` — 任务列表
- `PROGRESS.md` — 进度记录
- `SUMMARY.md` — 完成总结

### 4.3 启动开发流程

从 GO.md 入口启动：

```bash
@flow-kit/GO.md
```

GO.md 将自动执行：
1. 加载宪法文件（constitution.md）
2. 加载用户配置（default-user-config.md）
3. 加载系统规则（system-rules.md）
4. 执行启动检查（上下文过期检测、Token 估算、Hooks 状态）
5. 检测项目类型
6. 评估项目规模（L0-L3）

### 4.4 场景决策指南

| 场景 | 推荐流程 | 预计耗时 |
|------|---------|---------|
| 修复单个 Bug | L0 极简模式 | 15-30 分钟 |
| 添加新功能（< 5 文件） | L1 标准模式 | 1-2 小时 |
| 重构模块（5-20 文件） | L2 团队模式 | 2-4 小时 |
| 架构升级（> 20 文件） | L3 大规模并行 | 4-8 小时 |

---

## 第五章：阶段详解

### 5.1 Phase 0: 变更立项

**目标**: 创建变更标识，评估影响范围

**输入**: 变更描述
**输出**: `CHANGE.md`、change-id

**步骤**:
1. 运行 `/flow-kit:phase:0`
2. 填写变更摘要
3. 评估影响范围（文件数、模块数）
4. 生成唯一 change-id
5. 创建 `.specs/{change-id}/CHANGE.md`

**关键检查点**:
- [ ] change-id 唯一性
- [ ] 影响范围评估完整
- [ ] 变更分类正确（bugfix/feature/refactor）

### 5.2 Phase 1: 需求澄清

**目标**: 明确需求边界和验收标准

**输入**: CHANGE.md
**输出**: `REQUIREMENT.md`

**步骤**:
1. 运行 `/flow-kit:phase:1`
2. 使用 requirement-clarify 技能
3. 定义用户故事和验收标准
4. 识别边界条件和异常场景
5. 创建 `.specs/{change-id}/REQUIREMENT.md`

**关键检查点**:
- [ ] 需求描述清晰无歧义
- [ ] 验收标准可测试
- [ ] 边界条件已识别
- [ ] 依赖项已列出

### 5.3 Phase 2: 架构设计

**目标**: 设计技术方案，选择技术栈

**输入**: REQUIREMENT.md
**输出**: `DESIGN.md`

**步骤**:
1. 运行 `/flow-kit:phase:2`
2. 列出候选技术方案
3. 对比优缺点
4. 选择最优方案并说明理由
5. 创建 `.specs/{change-id}/DESIGN.md`

**关键检查点**:
- [ ] 技术方案对比完整
- [ ] 选型理由充分
- [ ] 风险评估到位
- [ ] 回滚方案可行

**注意**: REFERENCE 文件采用渐进披露，首轮加载 ≤ 150 行

### 5.4 Phase 3: 任务拆解

**目标**: 将设计拆解为可执行任务

**输入**: DESIGN.md
**输出**: `TASK.md`

**步骤**:
1. 运行 `/flow-kit:phase:3`
2. 使用 task-master 技能
3. 拆解为原子任务（每个 < 2 小时）
4. 识别任务依赖关系
5. 检测可并行执行的任务
6. 创建 `.specs/{change-id}/TASK.md`

**关键检查点**:
- [ ] 任务粒度合理
- [ ] 依赖关系清晰
- [ ] 并行机会已识别
- [ ] 风险任务已标记

### 5.5 Phase 4: 开发执行

**目标**: 按任务列表执行开发

**输入**: TASK.md
**输出**: 代码实现、单元测试

**步骤**:
1. 运行 `/flow-kit:phase:4`
2. 按依赖顺序执行任务
3. 遵循 TDD 标准（先写测试，再写实现）
4. 每完成一个任务更新 PROGRESS.md
5. 触发 output-self-check 自检

**关键检查点**:
- [ ] 测试先行（TDD）
- [ ] 代码符合工程规范
- [ ] 进度记录完整
- [ ] 产物自检通过

**多代理并行执行**:
```bash
# 生成并行计划
dispatch.sh --plan "实现用户认证模块" --parallel 3

# 执行子代理
dispatch.sh --execute

# 查看执行状态
dispatch.sh --status

# 聚合结果
dispatch.sh --aggregate
```

### 5.6 Phase 5: 测试验证

**目标**: 验证代码质量和功能正确性

**输入**: 代码实现
**输出**: 测试报告、覆盖率报告

**步骤**:
1. 运行 `/flow-kit:phase:5`
2. 运行单元测试
3. 运行集成测试
4. 检查测试覆盖率（B6 护栏）
5. 运行性能测试（B5 护栏）
6. 生成测试报告

**关键检查点**:
- [ ] 所有测试通过
- [ ] 新增代码覆盖率 ≥ 80%
- [ ] 无性能退化
- [ ] 无安全漏洞

### 5.7 Phase 6: 代码审查

**目标**: 通过三轮审查确保代码质量

**输入**: 代码实现、测试报告
**输出**: `REVIEW.md`

**步骤**:
1. 运行 `/flow-kit:phase:6`
2. 第一轮：架构师审查（架构合理性）
3. 第二轮：设计审查（设计模式应用）
4. 第三轮：工程审查（代码规范、性能）
5. 修复审查发现的问题
6. 创建 `.specs/{change-id}/REVIEW.md`

**关键检查点**:
- [ ] 三轮审查完成
- [ ] 所有问题已修复
- [ ] 审查记录完整
- [ ] 无遗留问题

### 5.8 Phase 7: 集成归档

**目标**: 合并代码，沉淀经验

**输入**: REVIEW.md
**输出**: `SUMMARY.md`、归档记录

**步骤**:
1. 运行 `/flow-kit:phase:7`
2. 合并代码到主分支
3. 更新项目文档
4. 编写变更总结
5. 归档变更规格
6. 提取经验教训

**关键检查点**:
- [ ] 代码已合并
- [ ] 文档已更新
- [ ] 归档记录完整
- [ ] 经验教训已记录

### 5.9 Phase 8: 变更回滚

**目标**: 紧急回滚变更，记录事故

**触发条件**: 生产环境出现严重问题

**步骤**:
1. 运行 `/flow-kit:phase:8` 或 `/flow-kit:rollback`
2. 执行回滚操作
3. 验证回滚结果
4. 记录事故原因
5. 制定修复计划

**关键检查点**:
- [ ] 回滚执行成功
- [ ] 服务恢复正常
- [ ] 事故记录完整
- [ ] 修复计划明确

---

## 第六章：命令参考

### 6.1 核心命令

| 命令 | 描述 | 示例 |
|------|------|------|
| `/flow-kit:health` | 代码健康度扫描 | `/flow-kit:health` |
| `/flow-kit:scan` | 技术债务扫描 | `/flow-kit:scan` |
| `/flow-kit:update-context` | 更新项目上下文 | `/flow-kit:update-context` |
| `/flow-kit:sync-config` | 同步团队配置 | `/flow-kit:sync-config` |
| `/flow-kit:archive` | 归档完成变更 | `/flow-kit:archive` |
| `/flow-kit:minimal` | 启用极简模式 | `/flow-kit:minimal` |
| `/flow-kit:offline` | 启用离线模式 | `/flow-kit:offline` |

### 6.2 管理命令

| 命令 | 描述 | 示例 |
|------|------|------|
| `/flow-kit:mode` | 切换执行模式 | `/flow-kit:mode team` |
| `/flow-kit:hooks` | 管理 Hooks | `/flow-kit:hooks install` |
| `/flow-kit:project-type` | 检测项目类型 | `/flow-kit:project-type detect` |
| `/flow-kit:cost-report` | 生成成本报告 | `/flow-kit:cost-report` |
| `/flow-kit:share-install` | 团队共享安装 | `/flow-kit:share-install` |

### 6.3 多代理编排命令

| 命令 | 描述 | 示例 |
|------|------|------|
| `dispatch.sh --plan` | 生成并行计划 | `dispatch.sh --plan "实现认证" --parallel 3` |
| `dispatch.sh --execute` | 执行子代理 | `dispatch.sh --execute` |
| `dispatch.sh --status` | 查看执行状态 | `dispatch.sh --status` |
| `dispatch.sh --aggregate` | 聚合执行结果 | `dispatch.sh --aggregate` |
| `dispatch.sh --wait` | 等待执行完成 | `dispatch.sh --wait` |

---

## 第七章：多代理编排

### 7.1 并行执行引擎

flow-kit v1.12.7 实现了真正的并行执行引擎：

**工作原理**:
1. 使用 bash 后台进程（`&`）启动子代理
2. 使用 `wait` 命令等待所有后台进程完成
3. 记录 PID 支持超时终止和进程管理
4. 原子写入结果文件避免竞态条件

**执行流程**:
```
主代理
  ├── 生成并行计划
  ├── 启动子代理 A (后台) ──→ 执行任务 ──→ 写入结果
  ├── 启动子代理 B (后台) ──→ 执行任务 ──→ 写入结果
  ├── 启动子代理 C (后台) ──→ 执行任务 ──→ 写入结果
  └── wait 等待所有完成 ──→ 聚合结果 ──→ 验证输出
```

### 7.2 子代理重试机制

**配置参数**:
- `max_retries`: 最大重试次数（默认 2 次）
- `retry_interval`: 重试间隔（默认 10 秒）

**重试策略**:
1. 子代理执行失败时自动重试
2. 每次重试记录尝试次数
3. 结果 JSON 包含 `attempts` 字段
4. 超过最大重试次数后标记为 FAILED

**示例输出**:
```json
{
  "id": "agent-1",
  "role": "Code Executor",
  "status": "SUCCESS",
  "attempts": 2,
  "summary": "执行完成（重试 1 次）"
}
```

### 7.3 超时终止机制

**配置参数**:
- `timeout_seconds`: 超时时间（默认 300 秒）
- `check_interval`: 检查间隔（默认 5 秒）

**超时控制**:
1. 每 5 秒检查一次子代理状态
2. 超时自动发送 TERM 信号终止进程
3. 超时结果自动写入 JSON 文件
4. 显示实时进度（完成数/运行中/已用时）

**超时处理流程**:
```
检测超时 → 发送 TERM 信号 → 等待 1 秒 → 发送 KILL 信号 → 写入超时结果
```

### 7.4 结果聚合与验证

**聚合命令**:
```bash
dispatch.sh --aggregate
```

**聚合输出**:
```json
{
  "task_id": "TASK-001",
  "task_desc": "实现用户认证模块",
  "parallel_n": 3,
  "status": "COMPLETED",
  "agents": [
    {"id": "agent-1", "status": "SUCCESS"},
    {"id": "agent-2", "status": "SUCCESS"},
    {"id": "agent-3", "status": "FAILED"}
  ],
  "summary": "2/3 子代理执行成功"
}
```

**验证步骤**:
1. 检查所有子代理状态
2. 验证结果文件完整性
3. 对照目标验证输出
4. 生成最终报告

---

## 第八章：最佳实践

### 8.1 项目类型识别

**棕地项目（Brownfield）**:
- 已有代码库的迭代开发
- 必须启用 B1-B6 全部护栏
- 重点关注破坏性变更检测
- 建议启用代码审查技能

**绿地项目（Greenfield）**:
- 从零开始的新项目
- 可适度放宽护栏
- 重点关注架构设计
- 建议启用任务拆解技能

**识别方法**:
```bash
/flow-kit:project-type detect
```

### 8.2 规模评估策略

| 级别 | 改动范围 | 推荐流程 | 预计耗时 |
|------|---------|---------|---------|
| L0 | 1-3 文件 | 极简模式，跳过 Phase 2-3 | 15-30 分钟 |
| L1 | 4-10 文件 | 标准 8 阶段 | 1-2 小时 |
| L2 | 11-30 文件 | 完整流程 + 设计评审 | 2-4 小时 |
| L3 | > 30 文件 | 多代理并行 + 全量护栏 | 4-8 小时 |

**自动评估**:
```bash
# 根据改动范围自动评估
@flow-kit/commands/scale-level.md
```

### 8.3 渐进披露原则

**核心原则**: 按需加载，避免一次性加载过多文件

**文件分类**:
| 类型 | 路径示例 | 典型长度 | 加载方式 |
|------|---------|---------|---------|
| SPEC（项目产物） | `.specs/{change-id}/*.md` | < 200 行 | 整读 OK |
| REFERENCE（查阅型） | `flow-kit/reference/*.md` | 75~470 行 | 禁止默认整读，只 grep/read offset |
| PROMPT/TEMPLATE | `flow-kit/phases/*.md` | < 150 行 | 整读 OK |

**首轮加载约束**: 进入任何阶段时，首轮加载的 REFERENCE 总行数 ≤ 150 行

### 8.4 上下文优化技巧

**执行计划三要素声明**:
```
✅ 已加载：列出所有已加载文件，含起止行
   例："REQUIREMENT.md（全读，98行）""tech-stacks.md（仅查适用矩阵，line 380-405）"

✅ 未加载：列出本阶段不需但后续可能用到的文件，说明何时才拉
   例："deployment.md（本阶段不需要，Phase 7 才拉）"

✅ 第一动作：具体下一步操作
   例："按 2-design 步骤 0，列 5 张技术栈卡片"
```

**上下文压缩**:
```bash
# 触发压缩
context-budget.sh --compress "auto-trigger"

# 使用 caveman-compress 技能
/flow-kit:skill:caveman-compress
```

**压缩策略**:
- 标准压缩：保留核心信息，压缩率 50%
- 极限压缩：仅保留关键决策，压缩率 80%

### 8.5 团队协作规范

**角色定义**:
| 角色 | 职责 | 权限 |
|------|------|------|
| Product Owner | 需求定义、优先级排序 | P0 审批 |
| Architect | 架构设计、技术选型 | 架构决策 |
| Tech Lead | 任务拆解、代码审查 | 审查批准 |
| Developer | 开发执行、单元测试 | 代码提交 |
| QA Engineer | 测试验证、质量门禁 | 质量否决 |

**P0 变更审批流程**:
1. 提交 P0 审批申请
2. Architect 审核架构影响
3. Tech Lead 审核实现方案
4. Product Owner 批准执行
5. 执行后必须经过三轮审查

---

## 第九章：故障排查

### 9.1 常见问题

**Q1: 上下文窗口溢出怎么办？**

A: 运行上下文压缩：
```bash
context-budget.sh --compress "manual"
```
或使用 caveman-compress 技能进行标准/极限压缩。

**Q2: 子代理执行失败如何处理？**

A: flow-kit 自动重试机制会处理：
- 默认重试 2 次，间隔 10 秒
- 查看日志：`cat .flow-kit/tmp/subagent-{id}.log`
- 手动重试：`dispatch.sh --execute --retry`

**Q3: 如何查看执行进度？**

A: 使用状态命令：
```bash
dispatch.sh --status
```

**Q4: Hooks 未安装如何修复？**

A: 运行安装命令：
```bash
/flow-kit:hooks install
```

**Q5: 项目类型检测不准确？**

A: 手动设置项目类型：
```bash
/flow-kit:project-type brownfield  # 设为棕地
/flow-kit:project-type greenfield  # 设为绿地
```

### 9.2 错误代码参考

| 错误代码 | 描述 | 解决方案 |
|---------|------|---------|
| E001 | 上下文窗口溢出 | 运行压缩或归档旧变更 |
| E002 | 子代理执行超时 | 检查任务复杂度，增加超时时间 |
| E003 | 文件锁冲突 | 等待锁释放或手动清理 `.flow-kit/locks/` |
| E004 | JSON Schema 验证失败 | 检查产物格式，参考对应 schema |
| E005 | 测试覆盖率不达标 | 补充单元测试，确保覆盖率 ≥ 80% |
| E006 | 破坏性变更检测 | 评估影响，制定迁移方案 |
| E007 | 安全风险检测 | 修复安全漏洞，重新扫描 |
| E008 | 性能退化检测 | 优化代码，消除 O(n²) 循环 |

### 9.3 日志分析

**日志位置**:
- 子代理日志：`.flow-kit/tmp/subagent-{id}.log`
- Hooks 日志：`.flow-kit/hooks-log/`
- 执行摘要：`.flow-kit/tmp/dispatch-summary.json`

**查看最近 20 条 Hooks 执行记录**:
```bash
flow-kit.sh hooks summary
```

**分析子代理执行结果**:
```bash
dispatch.sh --aggregate
```

### 9.4 恢复策略

**上下文过期恢复**:
1. 归档旧变更：`/flow-kit:archive`
2. 清理过期文件：`rm -rf .planning/phases/`
3. 重新启动流程

**执行中断恢复**:
1. 查看进度文件：`cat .specs/{change-id}/PROGRESS.md`
2. 使用进度恢复模板：`@flow-kit/skills/subagent-execution.md`
3. 从中断点继续执行

**锁冲突恢复**:
1. 检查锁状态：`ls -la .flow-kit/locks/`
2. 清理过期锁：`rm -rf .flow-kit/locks/{filepath_hash}.lock`
3. 重新执行操作

---

## 附录

### A. 项目结构说明

```
flow-kit/
├── GO.md                      # 唯一入口，启动检查与命令路由
├── README.md                  # 项目文档
├── VERSION                    # 当前版本号
├── CHANGELOG.md               # 版本变更历史
├── flow-kit.sh                # CLI 入口脚本
│
├── phases/                    # 8 阶段流程定义
│   ├── 0-change/              # 变更立项
│   ├── 1-requirement/         # 需求澄清
│   ├── 2-design/              # 架构设计
│   ├── 2a-ui-design/          # UI 设计（可选）
│   ├── 3-task/                # 任务拆解
│   ├── 4-dev/                 # 开发执行
│   ├── 5-test/                # 测试验证
│   ├── 6-review/              # 代码审查
│   ├── 7-integration/         # 集成归档
│   └── 8-rollback/            # 变更回滚
│
├── guardrails/                # 棕地护栏
│   ├── brownfield-guardrails.md  # B1-B2 基础护栏
│   ├── breaking-change.md        # B2 破坏性变更
│   ├── database-guardrails.md    # B3 数据库安全
│   ├── security-checklist.md     # B4 安全检查
│   ├── performance-guardrails.md # B5 性能护栏
│   ├── testing-coverage-gate.md  # B6 测试覆盖率
│   └── ui-guardrails.md          # UI 护栏
│
├── skills/                    # 元技能包
│   ├── requirement-clarify.md   # 需求澄清
│   ├── task-master.md           # 任务拆解
│   ├── subagent-execution.md    # 子代理执行
│   ├── code-review.md           # 代码审查
│   ├── debugging.md             # 调试
│   ├── parallel-dispatch.md     # 并行分发
│   ├── verification.md          # 验证
│   ├── agent-orchestrator.md    # 多代理编排
│   ├── agent-pipeline.md        # Agent 交接
│   ├── caveman-compress.md      # 上下文压缩
│   ├── dag-resolver.md          # 依赖图解析
│   ├── failure-detector.md      # 失败检测
│   ├── output-self-check.md     # 产物自检
│   ├── team-dispatch.md         # 团队分发
│   └── ubiquitous-language.md   # 统一语言
│
├── commands/                  # 横向命令
├── config/                    # 配置文件
│   ├── constitution.md          # 全局最高约束
│   ├── default-user-config.md   # 默认用户配置
│   ├── system-rules.md          # 系统级硬规则
│   └── team-roles.md            # 团队角色
│
├── hooks/                     # 自动化钩子
│   ├── pre-tool-guard.sh        # 工具执行前检查
│   ├── post-edit-format.sh      # 编辑后格式化
│   ├── stop-quality-gate.sh     # 停止质量门禁
│   ├── session-start.sh         # 会话启动
│   └── notification.sh          # 通知
│
├── lib/                       # 共享库
│   ├── context-budget.sh        # 上下文预算管理
│   ├── error-handler.sh         # 错误处理
│   ├── health-rotation.sh       # 健康轮转
│   └── phase-executor.md        # 阶段执行器
│
├── scripts/                   # 脚本工具
│   ├── dispatch.sh              # 多代理编排
│   ├── validate-phase.sh        # 阶段验证
│   └── dispatch-aggregate.sh    # 结果聚合
│
├── reference/                 # 工程规范
│   ├── frontend-engineer-rules.md  # 前端规范
│   ├── backend-engineer-rules.md   # 后端规范
│   ├── tdd-standard.md             # TDD 标准
│   ├── adr-template.md             # ADR 模板
│   └── language-specs/             # 多语言规则
│
├── templates/                 # 工件模板
├── archive/                   # 归档逻辑
└── tests/                     # 测试
    └── e2e-test-harness.sh      # E2E 测试
```

### B. 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|---------|
| v1.12.7 | 2026-05-08 | 真正并行执行引擎 + 重试机制 + 超时终止 + JSON Schema 完整验证 + token 估算精度提升 |
| v1.12.6 | 2026-05-08 | 多代理编排引擎 + 高危修复 + 全量中文化 + 阶段契约验证 |
| v1.12.3 | 2026-05-08 | 版本号统一 + Hooks 补全参考来源 |
| v1.12.2 | 2026-05-08 | 动态变量 + 自动提取项目名 |
| v1.12 | 2026-05-08 | CLI 子命令 + 交接验证 + 团队共享安装 |
| v1.11 | 2026-05-08 | Hooks 参考来源 + 阶段切换门 + 显式模式切换 |
| v1.10 | 2026-05-08 | 任务过大检测 + Agent 交接验证门 + 任务对齐检查 |
| v1.9 | 2026-05-08 | Hooks 路由 + 整链路预算 + 三路线选择 |
| v1.8 | 2026-05-08 | Schema 变更规则 + 5 个 Hook 脚本 |
| v1.7 | 2026-05-08 | 进度恢复 + 执行计划三要素 + 成本对比 |

### C. 贡献指南

欢迎提交 Issue 和 Pull Request！

**提交 Issue**:
- 描述问题现象
- 提供复现步骤
- 附上相关日志或截图

**提交 PR**:
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交变更 (`git commit -m 'feat: add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

**代码规范**:
- 遵循现有代码风格
- 添加必要的注释
- 更新相关文档
- 确保测试通过

---

**许可证**: [MIT License](LICENSE)

**项目地址**: https://github.com/pwl1987/flow-kit
