# REQUIREMENTS — flow-kit v1.2

> 增量升级：需求质量与结构化增强
> PRD: `prd1.2.md`
> Milestone: v1.2
> Status: Active

## Traceability

| REQ-ID | 文件 | 需求 | Phase |
|--------|------|------|-------|

---

## 需求

### Constitution（1 项）

- [ ] **CONST-01**: `config/constitution.md` 融入 Karpathy 四原则（Think Before Coding、Simplicity First、Surgical Changes、Goal-Driven Execution），作为最高行为约束，优先级高于其他所有规则。

### Skills（2 项）

- [ ] **SKILL-01**: `skills/requirement-clarify.md` 重写 — 整合 grill-with-docs 机制，执行"一次一问"原则，增加术语冲突检测和实时 CONTEXT.md 更新。
- [ ] **SKILL-02**: `skills/ubiquitous-language.md` **新增** — 领域语言统一技能，全流程（需求、设计、编码、审查）术语检查，维护 `GLOSSARY.md` 作为单一真相来源。

### Guardrails（1 项）

- [ ] **GUARD-01**: `guardrails/brownfield-guardrails.md` B1 入场扫描增加 **Module Dependency Table**（`.specs/dependency-map.md`），包含模块名、导出、被引用、依赖、关键抽象。

### Core（2 项）

- [ ] **CORE-01**: `core/1-requirement.md` 增加**术语对齐前置步骤**（激活 ubiquitous-language）和**历史教训自动检索**（加载 `.specs/LESSONS.md`）。
- [ ] **CORE-02**: `core/4-dev.md` TDD 步骤强化 **Goal-Driven Execution**：必须先写验证（test）再实现（code），不可测试的定义为"需要澄清"。

### Templates（1 项）

- [ ] **TPL-01**: `templates/GLOSSARY.md.template` **新增** — 术语表模板，供 ubiquitous-language 初始化项目 GLOSSARY.md 使用。

### Commands（1 项）

- [ ] **CMD-01**: `commands/cross-session-search.md` **新增** — 跨会话经验搜索命令 `/flow-kit:search-lessons`，支持按关键词检索 LESSONS.md 历史教训。

---

## 未来考虑（Out of Scope）

- v1.3: cep 知识复合闭环（LESSONS.md 实时注入）、oh-my-claudecode 智能模型路由建议、ce-code-review diff 感知审查者选择
- v2.0: graphify 依赖图引擎深度集成（`/flow-kit:graph` 命令）、71.5x Token 压缩导航式上下文

---

## Out of Scope

- Runtime execution engine — flow-kit is markdown files, not executable code
- Web UI / CLI interface — files are designed for Claude Code consumption
- Language-specific framework bindings — all content is framework-agnostic guidance
- Rollback workflow（Phase 8）— 属于 v2.0 范围

---

## Traceability

| REQ-ID | Phase |
|--------|-------|
| CONST-01 | Phase 8 |
| SKILL-01 | Phase 9 |
| SKILL-02 | Phase 9 |
| GUARD-01 | Phase 8 |
| CORE-01 | Phase 10 |
| CORE-02 | Phase 10 |
| TPL-01 | Phase 11 |
| CMD-01 | Phase 11 |

---

*Last updated: 2026-05-07 — v1.2 requirements defined*
