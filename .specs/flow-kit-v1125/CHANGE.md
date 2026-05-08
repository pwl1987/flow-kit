# CHANGE.md — flow-kit v1.12.5 多代理编排闭环

## 变更概述

**变更 ID**: multi-agent-close-the-loop-20260508
**版本**: v1.12.5
**分支**: feat/v1.12.5-multi-agent-close-the-loop
**日期**: 2026-05-08

## 目标

1. **P0 阻塞问题修复** — pre-tool-guard.sh 可访问性、dispatch.sh 子代理入口、flow-kit.sh 路由空壳、Phase Executor Schema 验证
2. **P1 高危修复** — dispatch-aggregate 命令、brownfield-guardrails B5/B6 索引、stopquality-gate 联动 B6、Phase Executor 中文化
3. **P2 中危修复** — health-history rotation、B5+B6 联动 M-health、careful.md 死锁安全、post-edit-format source 路径
4. **P3 优化项** — flow-kit.sh 中文化收尾、E2E 测试骨架、dispatch-status 命令

## 影响范围

- `flow-kit/hooks/pre-tool-guard.sh` — 可访问性验证
- `flow-kit/scripts/dispatch.sh` — 子代理实际入口
- `flow-kit/scripts/dispatch-aggregate.sh` — 新建
- `flow-kit/scripts/dispatch-status.sh` — 新建
- `flow-kit/flow-kit.sh` — dispatch/minimal 路由修复
- `flow-kit/lib/phase-executor.md` — JSON Schema 验证 + 中文化
- `flow-kit/guardrails/brownfield-guardrails.md` — B5/B6 索引更新
- `flow-kit/hooks/stopquality-gate.sh` — B6 联动
- `flow-kit/commands/M-health.md` — B5/B6 联动 + rotation
- `flow-kit/lib/health-rotation.sh` — 新建（可选）
- `flow-kit/commands/careful.md` — 死锁检测安全加固
- `flow-kit/tests/e2e-test-harness.sh` — 新建

## 验收标准

1. pre-tool-guard.sh JSON 解析逻辑正确，DDL 拦截生效
2. dispatch.sh --execute 可实际调用子代理
3. flow-kit.sh dispatch/minimal 有实际执行逻辑
4. Phase Executor 完成后调用 JSON Schema 验证
5. dispatch-aggregate 生成聚合报告
6. brownfield-guardrails.md B5/B6 索引已更新
7. stopquality-gate 联动 B6 覆盖率门禁
8. Phase Executor 英文伪代码全量汉化
9. health-history.json >500KB 时自动 rotation
10. M-health 报告中包含 B5/B6 检查结果
11. careful.md 死锁检测双重条件验证
12. post-edit-format.sh source 路径基于 CLAUDE_PROJECT_DIR
13. flow-kit.sh 所有 echo 使用中文
14. E2E 测试骨架可运行
15. dispatch-status 显示格式化状态表
