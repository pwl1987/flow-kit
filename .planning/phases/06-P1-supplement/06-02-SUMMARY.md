---
phase: "06-P1-supplement"
plan: "02"
subsystem: "phase-executor + skills/debugging + skills/verification"
tags: ["auto-cleanup", "token-budget", "debug-snapshot", "verification-gating"]
dependency_graph:
  requires: []
  provides:
    - "自动清窗机制 (phase-executor.md)"
    - "错误模式库 (debugging.md)"
    - "debug-snapshot (debugging.md)"
    - "分阶段验证门控 (verification.md)"
  affects:
    - "flow-kit/lib/phase-executor.md"
    - "flow-kit/skills/debugging.md"
    - "flow-kit/skills/verification.md"
tech_stack:
  added:
    - "渐进式压缩机制 (80%/90%/100% 三档)"
    - "归档清理策略"
    - "错误模式库 (5种错误类型)"
    - "debug-snapshot 命令"
    - "分阶段验证门控 (轻量/基础/全量)"
    - "棕地/绿地差异检查"
    - "Token 预算联动"
    - "验证失败恢复指南"
  patterns:
    - "归档而非删除 (archive/ directory)"
    - "渐进式警告 (WARNING -> HINT -> BLOCK)"
    - "分阶段验证 (Phase1-2/3-4/5-6)"
key_files:
  created: []
  modified:
    - "flow-kit/lib/phase-executor.md"
    - "flow-kit/skills/debugging.md"
    - "flow-kit/skills/verification.md"
decisions:
  - "清理粒度：归档 checkpoint + logs，保留 CONTEXT.md/PLAN.md/SUMMARY.md"
  - "三档压缩：80%警告、90%提示、100%强制"
  - "验证分级：Phase1-2轻量、Phase3-4基础、Phase5-6全量"
metrics:
  duration: "< 1 minute"
  completed: "2026-05-07T00:31:36Z"
---

# Phase 6 Plan 02 Summary

## One-liner
实现了 phase-executor 渐进式压缩机制和 debugging/verification 技能包增强。

## Completed Tasks

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | phase-executor 自动清窗机制 | - | phase-executor.md |
| 2 | debugging.md 增强 | - | debugging.md |
| 3 | verification.md 增强 | - | verification.md |

## Implementation Details

### Task 1: phase-executor 自动清窗机制

**新增 Section 8: Auto Cleanup（自动清窗机制）**

- **D-09 渐进式压缩**：
  - >= 80%: WARNING 输出
  - >= 90%: HINT 提示用户运行 `/flow-kit:cleanup`
  - >= 100%: BLOCK + 强制压缩

- **D-10 清理粒度**：
  - 清理目标：已完成 phase 的 checkpoint 文件和 logs
  - 保留文件：CONTEXT.md, PLAN.md, SUMMARY.md
  - 归档到 `.planning/archive/` 而非删除
  - 归档文件名格式：`.planning/archive/{phase}-{timestamp}.json`

- **Cleanup 命令**：
  - `/flow-kit:cleanup` — 手动触发清理
  - `/flow-kit:cleanup --force` — 强制清理（包括未完成 phase）

### Task 2: debugging.md 增强

**D-19 错误模式库**：
| 错误类型 | 症状 | 联动命令 |
|----------|------|----------|
| Phase 文件格式错误 | 解析失败、占位符未替换 | `/flow-kit:validate-phase` |
| Checkpoint 残留 | 断点续跑提示旧状态 | `/flow-kit:reset-checkpoint` |
| Context 过期 | 上下文丢失、重复加载 | `/flow-kit:check-expiry` |
| Token 预算耗尽 | 执行中断、压缩提示 | `/flow-kit:estimate-tokens` |
| 棕地检测失败 | 错误的护栏激活 | `/flow-kit:project-type detect` |

**D-20 debug-snapshot**：
- `/flow-kit:debug-snapshot` 命令输出环境信息、项目状态、最近变更、Phase 状态
- 棕地项目自动关联数据库状态快照

### Task 3: verification.md 增强

**分阶段验证门控（D-21）**：
| Phase | 验证级别 | 检查项 |
|-------|----------|--------|
| Phase 1-2 | 轻量 | lint, typecheck, build |
| Phase 3-4 | 基础 | + unit tests, coverage >= 70% |
| Phase 5-6 | 全量 | + integration tests, security scan, E2E |

**棕地/绿地差异**：
- 棕地：历史兼容性检查、依赖风险分析
- 绿地：标准检查（无历史包袱）

**Token 预算联动**：
- Phase 5-6 全量检查前自动检测 token 预算
- >= 80% 时提示用户先清理

**验证失败恢复指南**：
| 失败类型 | 修复命令 |
|----------|----------|
| Lint 失败 | `npm run lint:fix` |
| Typecheck 失败 | `npm run typecheck:fix` |
| 测试失败 | `npm run test:debug` |
| 构建失败 | `npm run build:debug` |
| 安全扫描失败 | `/flow-kit:security-fix` |

## Deviations from Plan

None - plan executed exactly as written.

## Threat Flags

| Flag | File | Description |
|------|------|-------------|
| T-06-04 | phase-executor.md | Archive cleanup only (no delete) |
| T-06-05 | debugging.md | debug-snapshot failure is non-blocking |
| T-06-06 | debugging.md | debug-snapshot output to terminal only |

## Verification

- `grep -c "80%\|90%\|100%" phase-executor.md` = 7 (>= 3 required)
- `grep -c "错误模式\|debug-snapshot" debugging.md` = 4 (>= 2 required)
- `grep -c "Phase 1-2\|Phase 5-6" verification.md` = 3 (>= 2 required)

## Requirements Covered

- REQ-006: 自动清窗机制
- REQ-008: 错误模式库 + debug-snapshot