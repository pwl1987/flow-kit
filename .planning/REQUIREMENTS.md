# Requirements — flow-kit

## v1.1 Requirements

### P0 — 立即修复（影响核心能力）

| REQ-ID | 事项 | Phase | Category |
|--------|------|-------|----------|
| REQ-001 | phases 文件增加棕地/绿地分支检测 | 5 | Bugfix |
| REQ-002 | phase-executor 增加断点续跑 | 5 | Bugfix |
| REQ-003 | database-guardrails 增加数据库类型自动检测 | 5 | Bugfix |
| REQ-004 | skills 文件内容充实 + 实战验证 | 5 | Bugfix |

### P1 — 尽快补充（提升生产可用性）

| REQ-ID | 事项 | Phase | Category |
|--------|------|-------|----------|
| REQ-005 | phases 文件增加棕地/绿地分支（增强版） | 6 | Enhancement |
| REQ-006 | phase-executor 增加自动清窗 | 6 | Enhancement |
| REQ-007 | GO.md 棕地/绿地自动路由（增强版） | 6 | Enhancement |
| REQ-008 | skills 文件内容充实 | 6 | Enhancement |
| REQ-009 | GO.md 增加棕地/绿地自动路由 | 6 | Enhancement |

### P2 — 后续迭代（体验增强）

| REQ-ID | 事项 | Phase | Category |
|--------|------|-------|----------|
| REQ-010 | constitution 增加技术栈约束和角色定义 | 7 | Enhancement |
| REQ-011 | 增加审批文件自动生成 | 7 | Enhancement |
| REQ-012 | 补充 APPROVAL.md.template | 7 | Enhancement |
| REQ-013 | 多语言规格增加破坏性变更检测模式 | 7 | Enhancement |
| REQ-014 | M-health / I-intel-scan 充实具体扫描规则 | 7 | Enhancement |
| REQ-015 | sync-team-config.md 实现 | 7 | Enhancement |

---

## v1 Requirements（已验收）

### CORE-01 — Project Structure
- [x] **CORE-01**: Complete directory structure per PRD specification
- [x] **CORE-02**: GO.md serves as single entry point with routing logic
- [x] **CORE-03**: README.md with quick start, cost table, scenario decision tree

### CORE-10 — 8-Phase Workflow (core/)
- [x] **CORE-10**: 0-change.md — Change ID generation
- [x] **CORE-11**: 1-requirement.md — Requirements clarification workflow
- [x] **CORE-12**: 2-design.md — Architecture design with 5 stack cards
- [x] **CORE-13**: 2a-ui-design.md — UI-specific design workflow
- [x] **CORE-14**: 3-task.md — Task breakdown into 5-15 min atomic tasks
- [x] **CORE-15**: 4-dev.md — Development execution with TDD
- [x] **CORE-16**: 5-test.md — Test verification workflow
- [x] **CORE-17**: 6-review.md — Three-layer code review
- [x] **CORE-18**: 7-integration.md — Integration and archival
- [x] **CORE-19**: 8-rollback.md — Change rollback workflow

### GUARD-20 — Brownfield Guardrails (guardrails/)
- [x] **GUARD-20**: brownfield-guardrails.md — B1-B6 总纲
- [x] **GUARD-21**: breaking-change.md — P0/P1/P2 分级审批
- [x] **GUARD-22**: database-guardrails.md — DDL/DML 安全规范
- [x] **GUARD-23**: security-checklist.md — YAML 安全检查清单
- [x] **GUARD-24**: ui-guardrails.md — 视觉语汇对齐流程

### SKILL-30 — Skills Packages (skills/)
- [x] **SKILL-30**: requirement-clarify.md — grill-me 对话模板
- [x] **SKILL-31**: task-master.md — parse_prd → expand_task 两步法
- [x] **SKILL-32**: subagent-execution.md — 子代理任务包格式
- [x] **SKILL-33**: code-review.md — CEO/Design/Eng 三层审查要点
- [x] **SKILL-34**: debugging.md — 独立诊断子代理
- [x] **SKILL-35**: parallel-dispatch.md — 并行冲突检测算法
- [x] **SKILL-36**: verification-before-completion.md — 交付前自检清单

### CMD-40 — Lateral Commands (commands/)
- [x] **CMD-40**: M-health.md — 代码健康度扫描
- [x] **CMD-41**: I-intel-scan.md — 技术栈/TODO/FIXME 扫描
- [x] **CMD-42**: update-context.md — 增量更新 CONTEXT.md
- [x] **CMD-43**: sync-team-config.md — 团队配置同步

### MCP-50 — MCP Tool Adaptation (mcp/)
- [x] **MCP-50**: mcp-tools-config.md — core/standard/all 三级工具分层
- [x] **MCP-51**: git-integration.md — git 安全封装
- [x] **MCP-52**: external-lint-adapter.md — 外部 lint 检测适配

### REF-60 — Engineering Reference (reference/)
- [x] **REF-60**: frontend-engineer-rules.md — 前端 11 条硬规则
- [x] **REF-61**: backend-engineer-rules.md — 后端规范
- [x] **REF-62**: tdd-standard.md — 红/绿/重构标准
- [x] **REF-63**: adr-template.md — 架构决策记录模板
- [x] **REF-64**: typescript.md — TypeScript 语言栈规则
- [x] **REF-65**: python.md — Python 语言栈规则
- [x] **REF-66**: java.md — Java 语言栈规则
- [x] **REF-67**: go.md — Go 语言栈规则
- [x] **REF-68**: rust.md — Rust 语言栈规则
- [x] **REF-69**: php.md — PHP 语言栈规则

### TMPL-70 — Templates (templates/)
- [x] **TMPL-70**: CONTEXT.md.template — 老项目上下文模板
- [x] **TMPL-71**: REQUIREMENT.md.template — 需求文档模板
- [x] **TMPL-72**: DESIGN.md.template — 设计文档模板
- [x] **TMPL-73**: TASK.md.template — XML 格式任务模板
- [x] **TMPL-74**: SUMMARY.md.template — 总结模板
- [x] **TMPL-75**: REVIEW.md.template — 审查报告模板
- [x] **TMPL-76**: LESSONS.md.template — 经验教训模板
- [x] **TMPL-77**: ROLLBACK.md.template — 回滚报告模板

### CFG-80 — Configuration (config/)
- [x] **CFG-80**: constitution.md — 全局最高约束
- [x] **CFG-81**: default-user-config.md — 默认用户配置

### ARCH-90 — Archive (archive/)
- [x] **ARCH-90**: archive-change.md — 变更归档逻辑

## v2 Requirements（Deferred to v1.1）

- [x] Context 过期自动检测（集成到 GO.md）
- [x] Token 用量实时估算（集成到各阶段）
- [x] 完整离线模式支持
- [ ] P0 变更审批流文件交互 → REQ-011
- [ ] PR 描述自动生成 → v2.0
- [ ] 月度成本报告自动生成 → v2.0

---

## Traceability

| REQ-ID | Phase | Priority | Status |
|--------|-------|----------|--------|
| REQ-001 ~ REQ-004 | 5 | P0 | Pending |
| REQ-005 ~ REQ-009 | 6 | P1 | Pending |
| REQ-010 ~ REQ-015 | 7 | P2 | Pending |
| CORE-01 ~ CORE-03 | 1 | - | Done |
| CORE-10 ~ CORE-19 | 1 | - | Done |
| GUARD-20 ~ GUARD-24 | 2 | - | Done |
| SKILL-30 ~ SKILL-36 | 2 | - | Done |
| CMD-40 ~ CMD-43 | 2 | - | Done |
| MCP-50 ~ MCP-52 | 2 | - | Done |
| REF-60 ~ REF-69 | 3 | - | Done |
| TMPL-70 ~ TMPL-77 | 1 | - | Done |
| CFG-80 ~ CFG-81 | 2 | - | Done |
| ARCH-90 | 2 | - | Done |

---
*Last updated: 2026-05-06 after v1.1 initialization*
