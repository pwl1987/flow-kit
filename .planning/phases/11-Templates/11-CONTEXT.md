# Phase 11: Templates + Commands - Context

**Gathered:** 2026-05-07
**Status:** Ready for planning

<domain>
## Phase Boundary

新增 `templates/GLOSSARY.md.template`（术语表模板）和 `commands/cross-session-search.md`（`/flow-kit:search-lessons` 命令）。

**Requirements:** TPL-01, CMD-01

</domain>

<decisions>
## Implementation Decisions

### GLOSSARY.md.template 模板结构（D-TPL-01~04）

- **D-TPL-01:** 强制核心字段 = Term / Definition / Usage Rules / Category / Example / See Also
- **D-TPL-02:** `Category` 支持多级分类（业务术语 / 技术术语 / 模块专属术语），与 LESSONS.md.template 标签体系对齐
- **D-TPL-03:** `Usage Rules` 是约束性字段，含适用/禁用/边界区分，非模糊一句话
- **D-TPL-04:** 模板风格 = 结构化 Markdown + 分类标签，与 LESSONS.md.template 保持一致

### 模板路径定位（D-TPL-05~06）

- **D-TPL-05:** 模板路径 = `flow-kit/templates/GLOSSARY.md.template`
- **D-TPL-06:** `templates/` 根目录不存在，`flow-kit/templates/` 是唯一正确路径

### search-lessons 命令设计（D-CMD-01~03）

- **D-CMD-01:** 搜索方式 = 混合模式（关键词优先 + 语义兜底）
- **D-CMD-02:** 输出格式 = 可切换（默认列表，`--verbose` 摘要模式）
- **D-CMD-03:** LESSONS.md 读写权限 = 结构化追加（`### Entries` 用户写，`### Extracted` 系统只读）

</domain>

<canonical_refs>
## Canonical References

- `flow-kit/templates/LESSONS.md.template` — LESSONS.md.template 作为模板风格参考
- `flow-kit/config/GLOSSARY.md` — Phase 9 GLOSSARY.md 权威定义（已有）
- `.specs/LESSONS.md` — Phase 10 LESSONS.md 路径（已有）
- `.planning/phases/09-Skills/09-CONTEXT.md` — Phase 9 三阶段结构、ubiquitous-language 触发时机决策
- `.planning/phases/10-Core-Process-Enhancement/10-CONTEXT.md` — Phase 10 LESSONS.md 路径决策

</canonical_refs>

<prior_decisions>
## Prior Decisions Applied

- LESSONS.md 路径 = `.specs/LESSONS.md`（Phase 10 D-L01）
- GLOSSARY.md 位置 = `flow-kit/config/GLOSSARY.md`（Phase 9）
- ubiquitous-language 触发时机 = Alignment Check 第1步（Phase 9 D-UL-01）

</prior_decisions>

<deferred>
## Deferred Ideas

- 是否将 search-lessons 命令打包为独立 Skill（供其他 phase 复用）— 下次讨论 Skills 升级时再定

</deferred>
