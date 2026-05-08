# CHANGE.md — flow-kit v1.12.4 多代理编排引擎

## 变更概述

**变更 ID**: multi-agent-orchestration-20260508
**版本**: v1.12.4
**分支**: feat/v1.12.4-multi-agent-orchestration
**日期**: 2026-05-08

## 目标

1. **P1 高危修复** — pre-tool-guard.sh 误拦截修复、post-edit-format.sh 异步竞态、版本号硬编码、并发锁原子性
2. **P0 多代理编排引擎** — dispatch.sh、subagent-task.md、agent-orchestrator.md、minimal 命令
3. **全量中文化** — constitution.md、code-review.md、M-health.md、I-intel-scan.md
4. **阶段契约验证 + 护栏补全** — JSON Schema 验证层、B5/B6 护栏
5. **P3 优化项** — 统一错误处理框架、hooks 遥测、caveman-compress 中文策略

## 影响范围

- `flow-kit/hooks/` — 3 个 hook 修复
- `flow-kit/flow-kit.sh` — 版本号动态读取 + minimal 命令
- `flow-kit/commands/careful.md` — 并发锁方案
- `flow-kit/scripts/dispatch.sh` — 新建
- `flow-kit/skills/agent-orchestrator.md` — 新建
- `flow-kit/templates/subagent-task.md` — 新建
- `flow-kit/config/constitution.md` — 全量汉化
- `flow-kit/skills/code-review.md` — 全量汉化
- `flow-kit/commands/M-health.md` — 全量汉化
- `flow-kit/commands/I-intel-scan.md` — 全量汉化
- `flow-kit/lib/validation/schemas/` — JSON Schema 验证层（新建）
- `flow-kit/guardrails/performance-guardrails.md` — B5（新建）
- `flow-kit/guardrails/testing-coverage-gate.md` — B6（新建）
- `flow-kit/lib/error-handler.sh` — 统一错误处理（新建）

## 验收标准

1. pre-tool-guard.sh 使用 jq 精确提取 JSON 字段，DROP COLUMN/ALTER TABLE RENAME/TRUNCATE TABLE 拦截
2. post-edit-format.sh 同步执行 + timeout 3 保护
3. flow-kit.sh 版本号从 flow-kit/VERSION 动态读取
4. careful.md 使用 mkdir 原子文件锁
5. dispatch.sh 支持 N 并行，创建 .flow-kit/tmp/subagent-\*-prompt.txt
6. subagent-task.md 三种角色模板
7. agent-orchestrator.md 决策树 + 上下文预算管理
8. minimal 命令跳过 Phase 1-3，最多改 3 文件
9. constitution/code-review/M-health/I-intel-scan 全量中文化
10. JSON Schema phase-0/1/2 output schemas
11. B5 性能护栏 + B6 测试覆盖率门禁
12. error-handler.sh 统一日志框架
13. hooks 遥测日志
14. caveman-compress 中文压缩策略
