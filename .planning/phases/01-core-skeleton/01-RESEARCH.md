# Phase 1: Core Skeleton - Research

**Researched:** 2026-05-06
**Domain:** Directory creation patterns, GO.md routing, 8-phase structure, template system
**Confidence:** HIGH

## Summary

Phase 1 requires creating the complete flow-kit directory structure with all phase files, templates, and routing logic. The core challenge is implementing GO.md with exact-match + fuzzy routing (Levenshtein distance), then creating 8 phase files (0-change through 8-rollback) with trigger/behavior/boundary structure, and 8 template files with `{{placeholder}}` format. All files must follow PRD-mandated format: begin with `> 【CLAUDE CODE INSTRUCTION 强制约束】` block and use `--- BEGIN ---` / `--- END ---` wrapper.

**Primary recommendation:** Create all directories first (per CORE-01), then write GO.md with routing logic, then create all phase and template files in parallel where possible.

## User Constraints (from CONTEXT.md)

### Locked Decisions

- **Directory Layout:** `phases/` top-level + flat per phase (no subdirectories). Structure: `flow-kit/` with `GO.md`, `README.md`, `core/`, `guardrails/`, `skills/`, `commands/`, `mcp/`, `reference/`, `reference/language-specs/`, `templates/`, `config/`, `archive/`

- **GO.md Routing:** Exact match first, then fuzzy fallback with Levenshtein distance (threshold ≤ 2 or substring match), confirmation prompt before routing.

- **Phase File Structure:** Trigger/Behavior/Boundary format with `{{TRIGGER}}`, `{{CORE_BEHAVIOR}}`, `{{BOUNDARY_CASES}}`, `{{OUTPUTS}}` placeholders.

- **Template Placeholder Format:** `{{PLACEHOLDER}}` — lowercase with double curly braces. Standard placeholders: `{{PHASE_NAME}}`, `{{PHASE_NUMBER}}`, `{{GOAL}}`, `{{TRIGGER}}`, `{{OUTPUTS}}`, `{{STEPS}}`, `{{BOUNDARY_CASES}}`, `{{TEMPLATE_VERSION}}`, `{{DATE}}`.

### Deferred Ideas

- Phase naming conflict between `phases/01-core-skeleton/` and `phases/0-change/` (defer to Phase 2)

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-------------------|
| CORE-01 | Complete directory structure per PRD spec | PRD Section 一 specifies all directories + project-side `.specs/` |
| CORE-02 | GO.md serves as single entry point with routing logic | PRD Section 二.2 + CONTEXT.md Decisions |
| CORE-03 | README.md with quick start, cost table, scenario decision tree | PRD Section 二.3 specifies content |
| CORE-10 | 0-change.md — Change ID generation and立项 | PRD Section 二.4 defines change-id format `{slug}-{YYYYMMDD}` |
| CORE-11 | 1-requirement.md — Requirements clarification workflow | PRD Section 二.5 with grill-me template |
| CORE-12 | 2-design.md — Architecture design with 5 stack cards | PRD Section 二.6 |
| CORE-13 | 2a-ui-design.md — UI-specific design workflow | PRD Section 二.7 |
| CORE-14 | 3-task.md — Task breakdown into 5-15 min atomic tasks | PRD Section 二.8 with XML format |
| CORE-15 | 4-dev.md — Development execution with TDD | PRD Section 二.9 |
| CORE-16 | 5-test.md — Test verification workflow | PRD Section 二.10 |
| CORE-17 | 6-review.md — Three-layer code review | PRD Section 二.11 |
| CORE-18 | 7-integration.md — Integration and archival | PRD Section 二.12 |
| CORE-19 | 8-rollback.md — Change rollback workflow | PRD Section 二.13 |
| TMPL-70 | CONTEXT.md.template — 老项目上下文模板 | PRD Section 二.14 |
| TMPL-71 | REQUIREMENT.md.template — 需求文档模板 | PRD Section 二.14 |
| TMPL-72 | DESIGN.md.template — 设计文档模板 | PRD Section 二.14 |
| TMPL-73 | TASK.md.template — XML 格式任务模板 | PRD Section 二.14 with XML example |
| TMPL-74 | SUMMARY.md.template — 总结模板 | PRD Section 二.14 |
| TMPL-75 | REVIEW.md.template — 审查报告模板 | PRD Section 二.14 |
| TMPL-76 | LESSONS.md.template — 经验教训模板 | PRD Section 二.14 |
| TMPL-77 | ROLLBACK.md.template — 回滚报告模板 | PRD Section 二.14 |

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Directory creation | API/Backend | — | File system operations, mkdir commands |
| GO.md routing logic | API/Backend | — | Pure command parsing and dispatch |
| Phase file content | API/Backend | — | Markdown file generation |
| Template placeholders | API/Backend | — | String templating |
| README.md generation | API/Backend | — | Static content generation |

## Standard Stack

No external libraries — flow-kit is markdown-only with zero dependencies. All implementation is pure markdown with embedded instruction blocks.

| Component | Approach | Why Standard |
|-----------|----------|---------------|
| Routing algorithm | Levenshtein distance (custom impl) | Simple enough to inline in GO.md |
| File generation | Write tool directly | No template engine needed |
| Command parsing | Regex/string matching | Sufficient for the command set |

## Directory Structure (from PRD)

```
flow-kit/                          # ROOT: Entry point + docs
├── GO.md                          # Single entry point
├── README.md                      # Quick start + cost table + decision tree
├── CONSTITUTION.md                # (deferred to Phase 2)
├── core/                          # 8 phase files
│   ├── 0-change.md
│   ├── 1-requirement.md
│   ├── 2-design.md
│   ├── 2a-ui-design.md
│   ├── 3-task.md
│   ├── 4-dev.md
│   ├── 5-test.md
│   ├── 6-review.md
│   ├── 7-integration.md
│   └── 8-rollback.md
├── guardrails/                    # (deferred to Phase 2)
├── skills/                        # (deferred to Phase 2)
├── commands/                      # (deferred to Phase 2)
├── mcp/                           # (deferred to Phase 2)
├── reference/                     # (deferred to Phase 2)
│   └── language-specs/           # (deferred to Phase 2)
├── templates/                     # 8 template files
│   ├── CONTEXT.md.template
│   ├── REQUIREMENT.md.template
│   ├── DESIGN.md.template
│   ├── TASK.md.template
│   ├── SUMMARY.md.template
│   ├── REVIEW.md.template
│   ├── LESSONS.md.template
│   └── ROLLBACK.md.template
├── config/                        # (deferred to Phase 2)
└── archive/                      # (deferred to Phase 2)

.specs/                            # PROJECT-SIDE: Auto-created
├── CONTEXT.md
├── LESSONS.md
├── COST-REPORT.md
├── pending-approvals/
└── archive/
```

**Note:** PRD uses `core/` but CONTEXT.md uses `phases/`. CONTEXT.md locked decision is `phases/` top-level. Phase files go in `phases/0-change/` through `phases/8-rollback/` (flat, no subdirs). Root-level files (GO.md, README.md) stay at flow-kit/ level.

## Architecture Patterns

### GO.md Routing Pattern

**What:** Command routing with exact match first, fuzzy fallback second.

**When to use:** User invokes `/flow-kit:*` commands.

**Algorithm:**
```
1. Parse user input for /flow-kit:xxx command
2. EXACT MATCH: if command == known command -> route directly
3. FUZZY SEARCH:
   - Calculate Levenshtein distance to all known commands
   - If min_distance <= 2 -> prompt "Did you mean {closest}? [y/n]"
   - If y -> route to closest
4. SUBSTRING MATCH: if command is substring of any known -> suggest
5. NO MATCH: show available commands + usage hint
```

**Known commands to route:**
- `/flow-kit:health` → `@flow-kit/commands/M-health.md`
- `/flow-kit:scan` → `@flow-kit/commands/I-intel-scan.md`
- `/flow-kit:update-context` → `@flow-kit/commands/update-context.md`
- `/flow-kit:sync-config` → `@flow-kit/commands/sync-team-config.md`
- `/flow-kit:archive` → `@flow-kit/archive/archive-change.md`

### Phase File Structure Pattern

**What:** Each phase file follows trigger/behavior/boundary format.

**Structure:**
```markdown
# Phase X: {Name}

## 触发条件
{{TRIGGER}}

## 核心行为
{{CORE_BEHAVIOR}}

## 边界情况
{{BOUNDARY_CASES}}

## 输出物
{{OUTPUTS}}
```

### Template Placeholder Pattern

**What:** All placeholders use `{{PLACEHOLDER}}` format (lowercase, double curly braces).

**Standard placeholders:**
- `{{PHASE_NAME}}` - Name of current phase
- `{{PHASE_NUMBER}}` - Numeric identifier
- `{{GOAL}}` - Phase goal description
- `{{TRIGGER}}` - When to activate this phase
- `{{OUTPUTS}}` - What the phase produces
- `{{STEPS}}` - Step-by-step actions
- `{{BOUNDARY_CASES}}` - Edge cases and handling
- `{{TEMPLATE_VERSION}}` - Version stamp
- `{{DATE}}` - Creation date

### File Output Format (PRD Mandated)

**Every file must use this wrapper:**
```
--- BEGIN flow-kit/xxx.md ---
[content with > 【CLAUDE CODE INSTRUCTION 强制约束】 block at top]
--- END flow-kit/xxx.md ---
```

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Template engine | Custom templating system | Direct Write with placeholders | Markdown files are simple enough |
| Command routing library | Heavy router | Simple string matching + Levenshtein | 5 commands only, inline implementation sufficient |
| Change-id generation | UUID library | Slugify function (lowercase, strip special chars, add date) | Simple enough to implement directly |

**Key insight:** flow-kit is zero-dependency markdown files. Any "library" needed is simple enough to implement inline in GO.md.

## Common Pitfalls

### Pitfall 1: File format inconsistency

**What goes wrong:** Files missing `> 【CLAUDE CODE INSTRUCTION 强制约束】` block or wrapper format.

**Why it happens:** PRD Section 六 specifies format that differs from normal markdown.

**How to avoid:** Every file MUST start with the instruction block. Use wrapper `--- BEGIN ---` / `--- END ---` for all generated content.

**Warning signs:** Missing `> 【CLAUDE CODE INSTRUCTION 强制约束】` at file start, missing `--- BEGIN ---` wrapper.

### Pitfall 2: Directory structure mismatch

**What goes wrong:** Creating wrong directory structure (e.g., `core/` instead of `phases/`).

**Why it happens:** PRD uses `core/` but CONTEXT.md locked decision uses `phases/`.

**How to avoid:** Follow CONTEXT.md locked decision: `phases/` top-level with flat phase directories (`phases/0-change/`, `phases/1-requirement/`, etc.). Root-level files (GO.md, README.md) stay at flow-kit/ level.

### Pitfall 3: Levenshtein implementation error

**What goes wrong:** Fuzzy matching too permissive or too strict.

**Why it happens:** Threshold selection matters.

**How to avoid:** Use threshold ≤ 2 for Levenshtein distance. Add substring match as secondary fallback.

## Code Examples

### Change-ID Generation (from PRD Section 二.4)
```
> 【CLAUDE CODE INSTRUCTION 强制约束·change-id 生成规则】
> 1. 从用户需求提取核心功能关键词，转小写、数字、短横线组合（slugify）。
>    中文转拼音首字母或直译英文，移除特殊字符。
>    示例："添加通知中心" → "notification-center"
> 2. 最终格式：{slugified-function}-{YYYYMMDD}
> 3. 生成 .specs/{change-id}/ 目录，内部创建 CHANGE.md 和 .STATE。
```

### XML Task Format (from PRD Section 二.8)
```xml
<tasks change-id="{{change-id}}">
  <task id="001" parallel="false">
    <desc>创建数据库迁移脚本</desc>
    <files read="db/schema.sql" write="db/migrations/20240506_add_notification.sql"/>
    <verify>npx sequelize db:migrate --dry-run</verify>
  </task>
  <task id="002" parallel="true">
    <desc>创建 Notification 模型</desc>
    <files read="src/models/index.ts" write="src/models/Notification.ts"/>
    <verify>npx jest src/models/Notification.test.ts</verify>
  </task>
</tasks>
```

### GO.md Priority Loading (from PRD Section 二.2)
```
> 【CLAUDE CODE INSTRUCTION 强制约束·第一步】
> 1. 立即加载 @flow-kit/config/constitution.md（全局最高优先级，任何逻辑不得违反）
> 2. 立即加载 @flow-kit/config/default-user-config.md，若存在 .flow-kit/user-config.md 则优先加载用户自定义配置
> 3. 后续所有逻辑必须遵守这两份配置
```

## State of the Art

flow-kit is a novel framework — no prior art to compare. It synthesizes:
- TDD methodology (red/green/refactor)
- Architecture decision records (ADR)
- Brownfield project guardrails (B1-B6)
- Phase-gated workflow (8 phases)

**No deprecated approaches** — this is greenfield development.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | PRD `core/` directory name is overridden by CONTEXT.md `phases/` decision | Directory Structure | Planner must use `phases/` per locked decision |
| A2 | GO.md routing Levenshtein threshold of 2 is correct | GO.md Routing | May need tuning based on user feedback |

**If this table is empty:** All claims in this research were verified or cited — no user confirmation needed.

## Open Questions

1. **Levenshtein threshold calibration**
   - What we know: Threshold ≤ 2 suggested in CONTEXT.md
   - What's unclear: Whether 2 is optimal for typo correction
   - Recommendation: Start with 2, adjust based on user feedback

2. **Phase directory naming conflict**
   - What we know: `phases/01-core-skeleton/` (phase spec) vs `phases/0-change/` (phase file) share namespace
   - What's unclear: Whether this causes any practical issues
   - Recommendation: Defer resolution to Phase 2 (per CONTEXT.md Deferred Ideas)

## Environment Availability

Step 2.6: SKIPPED (no external dependencies — flow-kit is markdown-only files, all work is file creation via Write tool)

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual verification |
| Config file | None — file existence checks |
| Quick run command | N/A |
| Full suite command | N/A |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Verification Method |
|--------|----------|-----------|---------------------|
| CORE-01 | Directory structure matches PRD | File existence | `ls` check all required directories exist |
| CORE-02 | GO.md routes all commands | Routing logic | Manual test of each command |
| CORE-03 | README.md contains cost table + decision tree | Content check | Read file, verify sections exist |
| CORE-10~19 | 8 phase files exist with correct structure | File existence + structure | Read each file, verify trigger/behavior/boundary |
| TMPL-70~77 | 8 template files exist with placeholders | File existence + placeholder | Read each file, verify `{{` placeholders |

### Wave 0 Gaps

None — Phase 1 creates all infrastructure, no prior test files exist.

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V4 Access Control | No | N/A — flow-kit is workflow documentation |
| V5 Input Validation | No | N/A — no user input processing in this phase |

**Reason:** Phase 1 creates directory structure and markdown files. No security-relevant processing occurs.

## Sources

### Primary (HIGH confidence)
- PRD specification (`/data/Code/flow-kit/prd.md`) — comprehensive file structure and content specs
- CONTEXT.md — locked decisions on directory layout, routing, phase structure

### Secondary (MEDIUM confidence)
- ROADMAP.md — success criteria and phase goals
- REQUIREMENTS.md — requirement traceability matrix

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — zero dependencies, inline implementation
- Architecture: HIGH — straightforward file generation
- Pitfalls: HIGH — well-documented in PRD and CONTEXT.md

**Research date:** 2026-05-06
**Valid until:** 30 days (stable domain)