# 状态 — flow-kit

## 项目引用

参见: .planning/PROJECT.md（更新于 2026-05-06）

**核心价值：** 为 Claude Code 提供全面的开发结构护栏，在不增加不必要复杂性的情况下实现一致的、高质量的 AI 辅助开发。

**当前里程碑：** v1.2 🔄 (2026-05-07)
**当前阶段：** Phase 12 — Rollback Workflow（待讨论）

## 当前里程碑

**v1.0** ✅ 完成 (2026-05-06)
- Phase 1~4 全部完成
- 62 个文件交付
- 8 阶段工作流、7 个技能包、4 个横向命令、6 个护栏规则、6 种语言规格

**v1.1** ✅ 完成 (2026-05-07)
- Phase 5~7 全部完成
- 11 plans, 全部交付
- REQ-001~015 全部完成

**v1.2** 🔄 进行中 (2026-05-07)
- Phase 8+ 规划中
- 8 项增量升级（详见 PROJECT.md）

| 阶段 | 状态 | 进度 |
|------|------|------|
| Phase 5: P0 缺陷修复 | ✅ 已完成 | 4 plans complete | REQ-001~004 |
| Phase 6: P1 功能补充 | ✅ 已完成 | REQ-005~009 |
| Phase 7: P2 体验增强 | ✅ 已完成 | 5 plans, 10/10 UAT passed | REQ-010~015 |
| Phase 8: Constitution 四原则 | ✅ 已完成 | 08-01-PLAN.md | CONST-01, GUARD-01 |

| Phase 9: Skills 质量升级 | ✅ 已完成 | 09-01-PLAN.md, SUMMARY.md | SKILL-01, SKILL-02 |
| Phase 10: Core 流程增强 | ✅ 已完成 | 10-01-PLAN.md | CORE-01, CORE-02 |
| Phase 11: Templates + Commands | ✅ 已完成 | 11-01-PLAN.md | TPL-01, CMD-01 |

## v1.2 范围

**P0 — 立即修复：**
- REQ-001: phases 棕地/绿地分支检测
- REQ-002: phase-executor 断点续跑
- REQ-003: database-guardrails 数据库类型自动检测
- REQ-004: skills 内容充实 + 实战验证

**P1 — 尽快补充：**
- REQ-005~009: phases 分支增强、自动清窗、GO 智能路由

**P2 — 后续迭代：**
- REQ-010~015: 技术栈约束、审批流、破坏性变更检测、扫描规则

## v1.2 升级清单

| 编号 | 模块 | 操作 |
|------|------|------|
| 1 | constitution.md | 融入 Karpathy 四原则 |
| 2 | requirement-clarify.md | 重写：一次一问 + grill-with-docs + 术语冲突检测 |
| 3 | ubiquitous-language.md | **新增**：领域语言统一技能 |
| 4 | brownfield-guardrails.md | B1 增加依赖关系表 |
| 5 | core/1-requirement.md | 术语对齐前置 + LESSONS 检索 |
| 6 | core/4-dev.md | 强化 Goal-Driven Execution |
| 7 | GLOSSARY.md.template | **新增**：术语表模板 |
| 8 | cross-session-search.md | **新增**：跨会话经验搜索 |

## 变更追踪

| Change ID | 描述 | 阶段 |
|-----------|------|------|
| — | 暂无活动变更 | — |

---
*最后更新：2026-05-07 — Phase 8 执行完成，1 plan，2 tasks
