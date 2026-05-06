# Requirements — flow-kit

## v1 Requirements

### CORE-01 — Project Structure
- [ ] **CORE-01**: Complete directory structure per PRD specification
- [ ] **CORE-02**: GO.md serves as single entry point with routing logic
- [ ] **CORE-03**: README.md with quick start, cost table, scenario decision tree

### CORE-10 — 8-Phase Workflow (core/)
- [ ] **CORE-10**: 0-change.md — Change ID generation and立项
- [ ] **CORE-11**: 1-requirement.md — Requirements clarification workflow
- [ ] **CORE-12**: 2-design.md — Architecture design with 5 stack cards
- [ ] **CORE-13**: 2a-ui-design.md — UI-specific design workflow
- [ ] **CORE-14**: 3-task.md — Task breakdown into 5-15 min atomic tasks
- [ ] **CORE-15**: 4-dev.md — Development execution with TDD
- [ ] **CORE-16**: 5-test.md — Test verification workflow
- [ ] **CORE-17**: 6-review.md — Three-layer code review
- [ ] **CORE-18**: 7-integration.md — Integration and archival
- [ ] **CORE-19**: 8-rollback.md — Change rollback workflow

### GUARD-20 — Brownfield Guardrails (guardrails/)
- [ ] **GUARD-20**: brownfield-guardrails.md — B1-B6 总纲
- [ ] **GUARD-21**: breaking-change.md — P0/P1/P2 分级审批
- [ ] **GUARD-22**: database-guardrails.md — DDL/DML 安全规范
- [ ] **GUARD-23**: security-checklist.md — YAML 安全检查清单
- [ ] **GUARD-24**: ui-guardrails.md — 视觉语汇对齐流程

### SKILL-30 — Skills Packages (skills/)
- [ ] **SKILL-30**: requirement-clarify.md — grill-me 对话模板
- [ ] **SKILL-31**: task-master.md — parse_prd → expand_task 两步法
- [ ] **SKILL-32**: subagent-execution.md — 子代理任务包格式
- [ ] **SKILL-33**: code-review.md — CEO/Design/Eng 三层审查要点
- [ ] **SKILL-34**: debugging.md — 独立诊断子代理
- [ ] **SKILL-35**: parallel-dispatch.md — 并行冲突检测算法
- [ ] **SKILL-36**: verification-before-completion.md — 交付前自检清单

### CMD-40 — Lateral Commands (commands/)
- [ ] **CMD-40**: M-health.md — 代码健康度扫描
- [ ] **CMD-41**: I-intel-scan.md — 技术栈/TODO/FIXME 扫描
- [ ] **CMD-42**: update-context.md — 增量更新 CONTEXT.md
- [ ] **CMD-43**: sync-team-config.md — 团队配置同步

### MCP-50 — MCP Tool Adaptation (mcp/)
- [ ] **MCP-50**: mcp-tools-config.md — core/standard/all 三级工具分层
- [ ] **MCP-51**: git-integration.md — git 安全封装
- [ ] **MCP-52**: external-lint-adapter.md — 外部 lint 检测适配

### REF-60 — Engineering Reference (reference/)
- [ ] **REF-60**: frontend-engineer-rules.md — 前端 11 条硬规则
- [ ] **REF-61**: backend-engineer-rules.md — 后端规范
- [ ] **REF-62**: tdd-standard.md — 红/绿/重构标准
- [ ] **REF-63**: adr-template.md — 架构决策记录模板
- [ ] **REF-64**: typescript.md — TypeScript 语言栈规则
- [ ] **REF-65**: python.md — Python 语言栈规则
- [ ] **REF-66**: java.md — Java 语言栈规则
- [ ] **REF-67**: go.md — Go 语言栈规则
- [ ] **REF-68**: rust.md — Rust 语言栈规则
- [ ] **REF-69**: php.md — PHP 语言栈规则

### TMPL-70 — Templates (templates/)
- [ ] **TMPL-70**: CONTEXT.md.template — 老项目上下文模板
- [ ] **TMPL-71**: REQUIREMENT.md.template — 需求文档模板
- [ ] **TMPL-72**: DESIGN.md.template — 设计文档模板
- [ ] **TMPL-73**: TASK.md.template — XML 格式任务模板
- [ ] **TMPL-74**: SUMMARY.md.template — 总结模板
- [ ] **TMPL-75**: REVIEW.md.template — 审查报告模板
- [ ] **TMPL-76**: LESSONS.md.template — 经验教训模板
- [ ] **TMPL-77**: ROLLBACK.md.template — 回滚报告模板

### CFG-80 — Configuration (config/)
- [ ] **CFG-80**: constitution.md — 全局最高约束
- [ ] **CFG-81**: default-user-config.md — 默认用户配置

### ARCH-90 — Archive (archive/)
- [ ] **ARCH-90**: archive-change.md — 变更归档逻辑

## v2 Requirements (Deferred)

- Context 过期自动检测（集成到 GO.md）
- Token 用量实时估算（集成到各阶段）
- 完整离线模式支持
- P0 变更审批流文件交互
- PR 描述自动生成
- 月度成本报告自动生成

## Out of Scope

- **Runtime execution engine** — flow-kit 是 markdown 文件，不是可执行代码
- **Web UI / CLI interface** — 文件专为 Claude Code 消费设计
- **Language-specific framework bindings** — 所有内容为框架无关指导

## Traceability

| REQ-ID | Phase | Status |
|--------|-------|--------|
| CORE-01 ~ CORE-03 | Phase 1 | Pending |
| CORE-10 ~ CORE-19 | Phase 1 | Pending |
| GUARD-20 ~ GUARD-24 | Phase 2 | Pending |
| SKILL-30 ~ SKILL-36 | Phase 2 | Pending |
| CMD-40 ~ CMD-43 | Phase 2 | Pending |
| MCP-50 ~ MCP-52 | Phase 2 | Pending |
| REF-60 ~ REF-69 | Phase 2 | Pending |
| TMPL-70 ~ TMPL-77 | Phase 1 | Pending |
| CFG-80 ~ CFG-81 | Phase 2 | Pending |
| ARCH-90 | Phase 2 | Pending |

---
*Last updated: 2026-05-06 after requirements definition*
