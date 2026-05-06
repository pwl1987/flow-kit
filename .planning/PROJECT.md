# flow-kit

## What This Is

flow-kit is a Claude Code development framework — a comprehensive toolkit providing 8-phase structured workflow (change → requirement → design → task → dev → test → review → integration → rollback), guardrails for brownfield projects, skill packages, templates, and engineering reference materials. It guides Claude Code through complex development work with built-in safety rails and best practices.

## Core Value

Provide comprehensive development structure and guardrails for Claude Code — enabling consistent, high-quality AI-assisted development without adding unnecessary complexity for simple tasks.

## Requirements

### Validated

**v1.0 — 核心骨架完成 ✓**

- flow-kit/GO.md — 单入口路由 ✓
- flow-kit/core/ — 8 阶段文件 ✓
- flow-kit/guardrails/ — 棕地护轨 B1-B6 ✓
- flow-kit/skills/ — 7 个技能包 ✓
- flow-kit/commands/ — 4 个横向命令 ✓
- flow-kit/templates/ — 模板文件 ✓
- flow-kit/reference/ — 工程规则 + 多语言规格 ✓
- flow-kit/config/ — Constitution + 默认配置 ✓
- phase-executor.md — 阶段执行器 ✓
- check-expiry.md — 上下文过期检测 ✓
- estimate-tokens.md — Token 估算 ✓
- offline-mode.md — 离线模式 ✓
- minimal-mode.md — 最小模式 ✓

### Active

**v1.1 — 迭代优化（Phase 5-7）**

P0 — 立即修复（影响核心能力）:
- [ ] phases 文件增加棕地/绿地分支检测
- [ ] phase-executor 增加断点续跑和自动清窗
- [ ] database-guardrails 增加数据库类型自动检测
- [ ] skills 文件内容充实 + 实战验证

P1 — 尽快补充（提升生产可用性）:
- [ ] phases 文件增加棕地/绿地分支
- [ ] phase-executor 增加断点续跑和自动清窗
- [ ] database-guardrails 增加数据库类型自动检测
- [ ] skills 文件内容充实 + 实战验证
- [ ] GO.md 增加棕地/绿地自动路由

P2 — 后续迭代（体验增强）:
- [ ] constitution 增加技术栈约束和角色定义
- [ ] 增加审批文件自动生成
- [ ] 补充 APPROVAL.md.template
- [ ] 多语言规格增加破坏性变更检测模式
- [ ] M-health / I-intel-scan 充实具体扫描规则
- [ ] sync-team-config.md 实现

### Out of Scope

- Runtime execution engine — flow-kit is markdown files, not executable code
- Web UI / CLI interface — files are designed for Claude Code consumption
- Language-specific framework bindings — all content is framework-agnostic guidance

## Context

- **Project type:** Brownfield → flow-kit 迭代开发
- **Target users:** Developers using Claude Code for complex/large projects, especially team environments
- **Delivery format:** Markdown files only, zero dependencies, copy-paste deployable
- **PRD source:** `prd1.1.md` — v1.1 迭代规格

## Constraints

- **Format**: All files must start with `> 【CLAUDE CODE INSTRUCTION 强制约束】` block
- **Output format**: Files wrapped with `--- BEGIN filename ---` / `--- END filename ---`
- **Directory structure**: Must follow PRD specification exactly
- **File ordering**: Build directory structure first, then write files sequentially

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Markdown-only files | Zero dependencies, maximum portability | ✓ Confirmed |
| CLAUDE CODE INSTRUCTION blocks | Ensures Claude Code respects priority and constraints | ✓ Confirmed |
| 8-phase workflow | Balances structure vs. simplicity | ✓ Confirmed |
| B1-B6 brownfield guardrails | Critical for existing project safety | ✓ Confirmed |
| Minimal mode for simple changes | Avoids over-engineering small tasks | ✓ Confirmed |
| v1.1 P0-first approach | Fix production blockers before adding features | ✓ Confirmed |

---

*Last updated: 2026-05-06 after v1.0 completion and v1.1 initialization*
