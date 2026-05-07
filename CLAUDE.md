# flow-kit 项目指南

## 项目概述

flow-kit v1.7 — 面向 Claude Code 的结构化开发流程工具包，提供 8 阶段开发工作流、护栏规则、技能包、模板和工程参考材料。

**当前阶段：** v1.7

## 工作流配置

| 配置项 | 值 |
|--------|-----|
| Mode | YOLO（自动批准） |
| Granularity | Coarse（3-5 phases） |
| Parallelization | 并行执行 |
| Git Tracking | 启用 |
| Research | 每个 phase 前研究 |
| Plan Check | 启用 |
| Verifier | 启用 |

## 下一阶段

执行 `/gsd-discuss-phase 1` 收集上下文并明确方法。

## 相关文件

- `.planning/PROJECT.md` — 项目上下文
- `.planning/REQUIREMENTS.md` — 需求清单
- `.planning/ROADMAP.md` — 阶段路线图
- `.planning/STATE.md` — 当前状态

## 使用 flow-kit

```bash
# 启动第一个变更
@flow-kit/GO.md
```

## 首次使用引导

flow-kit v1.6+ 支持原生斜杠命令。若未检测到命令注册，启动时会提示：

```
[flow-kit] 检测到斜杠命令未注册
运行 /flow-kit:register-commands 完成一键注册
```

手动注册命令：
```
/flow-kit:register-commands
```

---
*Generated: 2026-05-06*
