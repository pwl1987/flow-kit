# scripts/ — 脚本目录

flow-kit 可执行脚本，按功能分为 8 个分组。

## Dispatch（调度）

| 文件 | 职责 |
|------|------|
| `dispatch.sh` | 多代理调度主入口 |
| `dispatch-lock.sh` | 锁管理（冲突检测、超时、并发池） |
| `dispatch-parse.sh` | 任务描述解析 |
| `dispatch-status.sh` | 调度状态查询 |
| `dispatch-aggregate.sh` | 结果聚合 |

## Quality（质量）

| 文件 | 职责 |
|------|------|
| `validate-phase.sh` | Phase 产出物验证 |
| `code-review.sh` | 代码审查 |
| `p0-check.sh` | P0 变更检测 |
| `caveman-compress.sh` | 压缩输出 |
| `performance-regression.sh` | 性能回归检测 |

## Workflow（工作流）

| 文件 | 职责 |
|------|------|
| `phase-executor.sh` | Phase 条件路由执行 |
| `auto-pilot.sh` | 半自动执行状态机 |
| `next-phase.sh` | 推进到下一阶段 |
| `init-change.sh` | 变更初始化 |
| `plan-generate.sh` | 规划生成 |

## Utils（工具）

| 文件 | 职责 |
|------|------|
| `doc-extractor.sh` | 文档提取 |
| `log-aggregator.sh` | 日志聚合 |
| `prd-parser.sh` | PRD 解析 |
| `health-scheduler.sh` | 健康调度 |
| `ide-adapter.sh` | IDE 适配 |

## Metrics（指标）

| 文件 | 职责 |
|------|------|
| `metrics.sh` | /metrics CLI 命令（v3.7.0） |

## Recall（召回）

| 文件 | 职责 |
|------|------|
| `recall.sh` | /recall 项目上下文摘要（v3.7.0） |

## Docs（文档）

| 文件 | 职责 |
|------|------|
| `generate-commands.sh` | 斜杠命令生成 |
| `pr-description.sh` | PR 描述生成 |

## Config（配置）

| 文件 | 职责 |
|------|------|
| `install.sh` | 安装部署 |
| `offline-mode.sh` | 离线模式切换 |

## Tmux（终端复用）

| 文件 | 职责 |
|------|------|
| `tmux-init.sh` | tmux 会话初始化 |
| `tmux-run.sh` | 任务执行 |
| `tmux-aggregate.sh` | 结果聚合 |
| `tmux-cleanup.sh` | 会话清理 |

## v3.8.0 迁移计划

当前 30 个脚本平铺在 scripts/。v3.8.0 计划按分组创建子目录：

```
scripts/
├── dispatch/     ← dispatch-*.sh
├── quality/      ← validate-phase.sh, code-review.sh, p0-check.sh
├── workflow/     ← phase-executor.sh, auto-pilot.sh, next-phase.sh
├── metrics/      ← metrics.sh
├── recall/       ← recall.sh
├── tmux/         ← tmux-*.sh
└── utils/        ← 其余工具脚本
```

迁移原则：保持向后兼容（旧路径 symlink → 新路径）。
