# CHANGE.md — flow-kit v1.12.6 真正多代理编排闭环

## 变更概述

**变更 ID**: orchestration-execution-real-20260508
**版本**: v1.12.6
**分支**: feat/v1.12.6-orchestration-execution-real
**日期**: 2026-05-08

## 目标

1. **P0 核心**：dispatch.sh 真正并行执行引擎 + context-budget.sh 上下文预算管理
2. **P1 重要**：validate-phase.sh JSON Schema 验证执行 + GO.md 命令同步 + 版本号更新
3. **P2 优化**：B5 性能护栏改进 + 功能合并 + E2E 测试 Windows 兼容

## 影响范围

- `flow-kit/scripts/dispatch.sh` — 真正并行执行引擎
- `flow-kit/lib/context-budget.sh` — 新建（上下文预算管理）
- `flow-kit/scripts/validate-phase.sh` — 新建（JSON Schema 验证执行）
- `flow-kit/GO.md` — 命令路由同步
- `flow-kit/VERSION` — v1.12.6
- `flow-kit/CLAUDE.md` — v1.12.6
- `flow-kit/README.md` — v1.12.6
- `flow-kit/CHANGELOG.md` — v1.12.6 条目
- `flow-kit/guardrails/performance-guardrails.md` — B5 检测方法改进
- `flow-kit/tests/e2e-test-harness.ps1` — 新建（PowerShell 版本）

## 验收标准

1. dispatch.sh --execute 能实际启动 N 个并行子代理
2. 子代理完成后自动聚合结果到 dispatch-summary.json
3. 主会话上下文消耗 <40%
4. context-budget.sh 可独立运行，超支时自动压缩并警告
5. validate-phase.sh 可验证 Phase 0/1/2 产物
6. GO.md 命令表与 flow-kit.sh 一致
7. 所有版本号统一为 v1.12.6
8. B5 性能护栏误报率降低
9. dispatch-aggregate.sh 与 collect_results() 分工明确
10. E2E 测试支持 Windows 原生运行

---

## 参考来源

- [anthropic/multi-agent-patterns](https://github.com/anthropic/multi-agent-patterns) — 多代理编排最佳实践
- [task-executor-agent](https://github.com/anthropic/task-executor-agent) — 任务执行代理模式
- [rihebty/flow-kit](https://github.com/rihebty/flow-kit) — R8.3 产物自检清单
