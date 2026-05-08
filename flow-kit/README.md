<!-- HEADER -->

> 【CLAUDE CODE INSTRUCTION 强制约束】
>
> 本文件为 flow-kit 的入口文档。所有 flow-kit 操作从本文档开始。
> 禁止修改本文档结构。如需变更，参考 .planning/ROADMAP.md 的变更流程。

--- BEGIN flow-kit/README.md ---

# flow-kit

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Ready-blue)](https://claude.ai/code)
[![Phases](https://img.shields.io/badge/Phases-8-green)](./phases)
[![Language](https://img.shields.io/badge/Markdown-Zero%20Dependencies-orange)](https://example.com)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

**flow-kit** 是面向 Claude Code 的结构化开发流程工具包，提供 8 阶段开发工作流、护栏规则、技能包、模板和工程参考材料。

---

## 目录

- [特性](#特性)
- [安装](#安装)
- [快速开始](#快速开始)
- [工作流](#工作流)
- [命令参考](#命令参考)
- [示例](#示例)
- [项目结构](#项目结构)
- [贡献](#贡献)

---

## 特性

| 特性             | 描述                                    |
| ---------------- | --------------------------------------- |
| **8 阶段工作流** | 从需求到集成的完整开发流程              |
| **棕地护栏**     | B1-B6 六大护栏，保护现有代码库          |
| **元技能包**     | 7 个可复用技能模块                      |
| **多语言支持**   | TypeScript、Python、Java、Go、Rust、PHP |
| **工程规范**     | 前端/后端硬规则、TDD 标准、ADR 模板     |
| **团队协作**     | 角色定义、P0 审批、成本报告             |

---

## 安装

### 方式一：克隆到项目

```bash
git clone https://github.com/pwl1987/flow-kit.git /path/to/your-project/.flow-kit
```

### 方式二：复制所需文件

```bash
# 复制核心文件到项目
cp flow-kit/GO.md /path/to/project/
cp -r flow-kit/phases /path/to/project/
cp -r flow-kit/templates /path/to/project/
```

### 方式三：作为子模块

```bash
git submodule add https://github.com/pwl1987/flow-kit.git .flow-kit
```

---

## 快速开始

### 1. 首次健康扫描

```bash
/flow-kit:health
```

### 2. 创建变更规格目录

```bash
mkdir .specs/$(date +%Y%m%d%H%M%S)
```

### 3. 启动开发流程

```bash
@flow-kit/GO.md
```

### 场景决策

| 场景                 | 推荐流程                |
| -------------------- | ----------------------- |
| 简单变更（1-3 文件） | 极简模式，跳过测试/审查 |
| 中等复杂度（新功能） | 标准 8 阶段             |
| 复杂架构变更         | 完整流程 + 设计评审     |
| 棕地项目迭代         | 启用 B1-B6 护栏         |

---

## 工作流

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

### 阶段说明

| 阶段 | 文件                                                        | 描述                     |
| ---- | ----------------------------------------------------------- | ------------------------ |
| 0    | [0-change.md](./phases/0-change/0-change.md)                | 变更立项、生成 change-id |
| 1    | [1-requirement.md](./phases/1-requirement/1-requirement.md) | 需求澄清、验收标准       |
| 2    | [2-design.md](./phases/2-design/2-design.md)                | 架构设计、技术选型       |
| 3    | [3-task.md](./phases/3-task/3-task.md)                      | 任务拆解、并行检测       |
| 4    | [4-dev.md](./phases/4-dev/4-dev.md)                         | 开发执行、TDD 驱动       |
| 5    | [5-test.md](./phases/5-test/5-test.md)                      | 测试验证、覆盖率报告     |
| 6    | [6-review.md](./phases/6-review/6-review.md)                | 代码审查、三轮评审       |
| 7    | [7-integration.md](./phases/7-integration/7-integration.md) | 集成归档、经验沉淀       |
| 8    | [8-rollback.md](./phases/8-rollback/8-rollback.md)          | 变更回滚、事故记录       |

---

## 命令参考

| 命令                       | 描述                       |
| -------------------------- | -------------------------- |
| `/flow-kit:health`         | 代码健康度扫描             |
| `/flow-kit:scan`           | 技术债务扫描（TODO/FIXME） |
| `/flow-kit:update-context` | 更新项目上下文             |
| `/flow-kit:sync-config`    | 同步团队配置               |
| `/flow-kit:archive`        | 归档完成变更               |
| `/flow-kit:minimal`        | 启用极简模式               |
| `/flow-kit:offline`        | 启用离线模式               |

详细命令文档请参阅 [GO.md](./GO.md)。

---

## 示例

参见 [examples/](../examples/) 目录：

- [simple-feature/](../examples/simple-feature/) — 简单功能变更示例
- [brownfield-project/](../examples/brownfield-project/) — 棕地项目示例

---

## 项目结构

```
flow-kit/
├── GO.md                      # 唯一入口
├── README.md                  # 本文档
├── phases/                    # 8 阶段流程定义
│   ├── 0-change/
│   ├── 1-requirement/
│   ├── 2-design/
│   ├── 3-task/
│   ├── 4-dev/
│   ├── 5-test/
│   ├── 6-review/
│   ├── 7-integration/
│   └── 8-rollback/
├── guardrails/                # 棕地护栏
│   ├── brownfield-guardrails.md
│   ├── breaking-change.md
│   ├── database-guardrails.md
│   ├── security-checklist.md
│   └── ui-guardrails.md
├── skills/                    # 元技能包
│   ├── requirement-clarify.md
│   ├── task-master.md
│   ├── subagent-execution.md
│   ├── code-review.md
│   ├── debugging.md
│   ├── parallel-dispatch.md
│   └── verification.md
├── commands/                  # 横向命令
├── reference/                 # 工程规范
│   ├── frontend-engineer-rules.md
│   ├── backend-engineer-rules.md
│   ├── tdd-standard.md
│   ├── adr-template.md
│   └── language-specs/        # 多语言栈规则
├── templates/                 # 工件模板
├── config/                    # 配置文件
│   ├── constitution.md        # 全局最高约束
│   ├── default-user-config.md
│   └── team-roles.md
├── mcp/                       # MCP 工具适配
├── lib/                       # 共享库
└── archive/                   # 归档逻辑
```

---

## 贡献

欢迎提交 Issue 和 Pull Request！

---

## 许可证

[MIT License](../LICENSE)

_Generated with flow-kit v1.12.7_

---

## Changelog

### v1.12.7 (2026-05-08)

- dispatch.sh: 真正并行执行引擎（后台进程+wait等待）+ 子代理重试机制（默认2次）+ 超时终止机制（300秒）+ 竞态条件修复（原子写入）
- validate-phase.sh: 完善JSON Schema验证（字符串长度/数字范围/数组items/嵌套对象递归验证）
- context-budget.sh: 提升token估算精度（多模型配置claude/gpt4/gemini + 中英文分别估算 + 代码/文本/注释不同系数，误差<15%）

### v1.12.6 (2026-05-08)

- dispatch.sh: --execute/--wait/--aggregate 三模式真正并行执行引擎
- context-budget.sh: 上下文预算管理（token估算/预算检查/自动压缩）
- validate-phase.sh: Phase 0/1/2 产物 JSON Schema 验证
- e2e-test-harness.sh: 16项E2E测试覆盖所有v1.12.6功能

### v1.12.3 (2026-05-08)

- CLAUDE.md: 版本号统一为 v1.12.3
- hooks/\*.sh: 全部 5 个 hooks 补全参考来源段落
- flow-kit/VERSION: v1.12.3

### v1.12.2 (2026-05-08)

- skills/output-self-check.md: +动态$CHANGE_ID变量+回退逻辑
- flow-kit.sh: show_share()自动提取PROJECT_NAME
- VERSION/CLAUDE.md: v1.12.2

### v1.12 (2026-05-08)

- flow-kit.sh: +help/status/share子命令
- GO.md: /flow-kit:mode切换后确认提示（保存到.flow-kit/mode）
- skills/output-self-check.md: +6项可执行检查命令示例
- skills/agent-pipeline.md: +交接验证失败自动修复循环（最多2轮）
- commands/share-install.md: +团队共享安装命令
- VERSION/CLAUDE.md/README.md: v1.12

### v1.11 (2026-05-08)

- commands/hooks-guide.md: 参考来源替换为Anthropic官方+garrytan/gstack+smallnest/autoresearch
- phases/4-dev.md,5-test.md,6-review.md: +阶段切换交接验证门触发指令
- GO.md: +/flow-kit:mode显式模式切换命令 (autopilot/team/ralph)
- skills/output-self-check.md: +R8.3产物自检清单（6项检查）
- lib/phase-executor.md: +阶段完成后触发output-self-check自检
- commands/register-commands.md: +map-codebase返回重索引逻辑
- flow-kit.sh: +CLI入口脚本（环境检测+命令路由映射）
- VERSION/CLAUDE.md/README.md: v1.11

### v1.10 (2026-05-08)

- config/system-rules.md: +R1.7 任务过大早期信号检测 + v1.10补充恢复后第一动作规范
- skills/agent-pipeline.md: +三阶段Agent交接验证门（含Handler覆盖矩阵）
- skills/team-dispatch.md: +Task-PRD对齐检查 + 追责链机制
- GO.md: +执行模式自动检测（L0极简/L1标准/L2-L3团队并行）

### v1.9 (2026-05-08)

- GO.md: +/flow-kit:hooks 路由 + hooks 启动检测 + 整链路预算 + 三路线选择
- CLAUDE.md: 版本号更新为 v1.9
- hooks/\*.sh: +参考来源段落
- templates/LESSONS.md.template: +提名条件与复核剪枝机制
- skills/team-dispatch.md: +一键启动说明
- commands/register-commands.md: +/flow-kit:map-codebase 子命令

### v1.8 (2026-05-08)

- config/system-rules.md: +R4.5 Schema变更必伴随迁移文件 +R4.6 破坏性变更高门槛
- flow-kit/hooks/: 5个hook脚本（pre-tool-guard/post-edit-format/stop-quality-gate/session-start/notification）
- commands/hooks-guide.md: hooks完整使用指南
- .claude/settings.json: 注册5个hooks配置

### v1.7 (2026-05-08)

- skills/subagent-execution.md: +进度恢复四段模板
- GO.md: +执行计划三要素声明
- commands/strategy-first.md: +三路线成本对比
- phases/6-review.md: +两阶段独立审查（防信息污染）
- phases/5-test.md: +测试金字塔裁剪路由
- templates/PROGRESS.md.template: 新增进度文件模板

--- END flow-kit/README.md ---
