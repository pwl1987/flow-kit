# Phase 2 Discussion Log

**Phase:** 2 — Guardrails & Capabilities
**Date:** 2026-05-06
**User:** (flow-kit project)

## Areas Discussed

### G1: Brownfield Guardrail Activation
**Options presented:**
- 自动检测 + 手动触发
- @提及激活
- 自动全量激活
- GO.md 路由自动分发

**User selected:** 自动检测 + 手动触发
**Rationale:** Auto-detect brownfield via .git + package manager presence; guardrails activate on explicit `/flow-kit:guardrails` call.

---

### G2: Skill Package Granularity
**Options presented:**
- 独立文件 + 组合分发
- 单一技能索引 + 子文档
- 全部独立调用

**User selected:** 独立文件 + 组合分发
**Rationale:** 7 independent .md files under `skills/`; GO.md routes context-aware suggestions; users can also call directly.

---

### G3: Lateral Command Format
**Options presented:**
- @flow-kit/CMD.md 独立文件
- @flow-kit/commands INDEX
- /flow-kit:health 风格

**User selected:** /flow-kit:health 风格
**Rationale:** Matches Claude Code native slash command style; consistent with Phase 1 routing.

---

### G4: MCP Tool Tiering
**Options presented:**
- 破坏性维度
- 功能域维度
- 分层配置化

**User selected:** 破坏性维度
**Rationale:** core = read-only, standard = write/delete, all = execute. Clear risk-based separation.

---

### G5: Constitution vs User-Config Priority
**Options presented:**
- Constitution 绝对优先
- 用户配置优先
- 分层合并（Constitution 兜底）

**User selected:** 分层合并（Constitution 兜底）
**Rationale:** Safety rules in Constitution cannot be overridden; non-safety rules merge with user-config winning.

---

### G6: ARCH-90 Archive Location
**Options presented:**
- Phase 2（保持 REQUIREMENTS）
- Phase 3（按 ROADMAP）
- 独立子任务（Phase 2）

**User selected:** 独立子任务（Phase 2）
**Rationale:** REQUIREMENTS.md is authoritative; ARCH-90 implemented in Phase 2 scope, documented in Phase 3.

---

## Summary

All 6 gray areas resolved. No scope creep detected. All decisions captured in 02-CONTEXT.md.
