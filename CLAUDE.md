# flow-kit 项目指南

## 项目概述

flow-kit v2.7.0 — 面向 Claude Code 的结构化开发流程工具包，提供精简命令体系、9 阶段 (Phase 0-8) 开发工作流、棕地/绿地条件路由、护栏建议、Phase 状态持久化和单元测试。

**当前版本：** v2.7.0

## 工作流配置

| 配置项          | 值                   |
| --------------- | -------------------- |
| Mode            | YOLO（自动批准）     |
| Granularity     | Coarse（3-5 phases） |
| Parallelization | 并行执行             |
| Git Tracking    | 启用                 |
| Research        | 每个 phase 前研究    |
| Plan Check      | 启用                 |
| Verifier        | 启用                 |

## 核心能力

- 17 个核心斜杠命令
- Phase 0-8 工作流
- 棕地/绿地差异化工作流
- 自动护栏建议
- `.flow-kit/current-phase` 状态持久化
- 单元测试覆盖核心脚本

## 相关文件

- `flow-kit/GO.md` — 入口文档
- `flow-kit/VERSION` — 当前版本
- `flow-kit/phases/` — Phase 工作流
- `flow-kit/scripts/phase-executor.sh` — 条件路由执行器
- `flow-kit/scripts/generate-commands.sh` — 命令生成器

## 使用 flow-kit

```bash
# 启动第一个变更
@flow-kit/GO.md
```

## 首次使用引导

flow-kit v2.x 支持原生斜杠命令。若未检测到命令注册，启动时会提示：

```
[flow-kit] 检测到斜杠命令未注册
运行 /flow-kit:register-commands 完成一键注册
```

手动注册命令：

```
/flow-kit:register-commands
```

---

_Generated: 2026-05-12_
