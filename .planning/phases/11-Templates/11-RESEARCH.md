# Phase 11: Templates + Commands — Research

**Research Date:** 2026-05-07
**Status:** Complete

---

## 1. LESSONS.md.template Structure Analysis

**Pattern identified:**
- `--- BEGIN flow-kit/templates/xxx.md.template ---` / `--- END ---` markers for extraction
- `> 【CLAUDE CODE INSTRUCTION 强制约束】` directive header (optional, for flow-kit internal templates)
- Top-level sections with `##` headers, sub-sections with `###`
- Tables for structured metadata (文档信息, Patterns Established tables, Key Decisions)
- `{{PLACEHOLDER}}` format for variables
- No frontmatter (YAML/JSON)

**GLOSSARY.md.template alignment:**
- Must use same `--- BEGIN/END ---` markers
- Should NOT include the CLAUDE CODE INSTRUCTION header (this is for project templates, not flow-kit internal)
- Structured sections with `##` headers
- Category tags using `{{TAG}}` style to match LESSONS.md.template placeholder pattern

---

## 2. Commands Directory Structure Pattern

**Existing commands analyzed:** minimal-mode.md, pr-description.md, project-type.md

**Standard structure:**
```
# Command: /flow-kit:command-name

## 功能 / Overview
## 用法 / Usage
## 实现细节 (optional)
## 集成点 (optional)
## 边界情况 (optional)

---

**关联文件**：
- `@flow-kit/...` (cross-references)
```

**Key conventions:**
- Command header: `# Command: /flow-kit:name`
- 中文 section headers (功能, 用法, 集成点)
- `---` separator before footer
- Footer with `**关联文件**：` listing related files
- No frontmatter

**cross-session-search.md must follow:**
- Header: `# Command: /flow-kit:search-lessons`
- Sections: 功能, 用法, 搜索模式, 输出格式, 集成点, 边界情况
- Footer with related files

---

## 3. Keyword + Semantic Hybrid Search Implementation

**Constraints:**
- flow-kit is "markdown files, not executable code" — no runtime engine
- No external dependencies beyond Claude Code environment
- Must work within `/flow-kit:search-lessons` command context

**Implementation approach (hybrid):**

### Phase 1: Keyword Search (primary)
```
grep -i "PATTERN" .specs/LESSONS.md
rg -i "PATTERN" .specs/LESSONS.md
```
- Fast, deterministic
- Works with existing tools
- Handles exact term matching

### Phase 2: Semantic Fallback
- Since no external NLP/semantic search deps, semantic search = **Broader pattern matching**
- Techniques:
  - Synonym expansion via GLOSSARY.md term relationships
  - Category-based filtering (业务术语 → related 技术术语)
  - See Also cross-reference traversal
  - Fuzzy matching with `rg -i -S` (smart case)

**Alternative (deferred):** Full semantic search requires embedding models or external API — out of scope for v1.2

---

## 4. Semantic Search Backend Dependencies

**Current state:**
- No existing semantic search dependencies in flow-kit
- Project explicitly excludes "Runtime execution engine"
- All content is markdown — no database

**Recommendation:**
- Use GLOSSARY.md term relationships as "semantic network"
- Implement `See Also` cross-reference as implicit semantic link
- Category hierarchy provides conceptual clustering
- This satisfies D-CMD-01 "semantic fallback" within existing constraints

**If semantic search needed in future:**
- Requires external service (OpenAI embeddings, or self-hosted)
- Would be v2.0 graphify integration
- Not in scope for Phase 11

---

## 5. GLOSSARY.md Usage Scenarios

**Primary scenario (from 11-CONTEXT):**
- ubiquitous-language skill initializes new project GLOSSARY.md
- Copy `templates/GLOSSARY.md.template` → project root as `GLOSSARY.md`
- Project team fills in terms during development

**Secondary scenarios:**
- Alignment Check (Phase 1) — scan candidate terms
- Design review (Phase 2) — verify terminology consistency
- Code commit (Phase 4) — validate implementation terminology
- Document review (Phase 6) — final terminology check

**Template must include:**
- Sufficient example entries to show format (currently missing in existing GLOSSARY.md)
- Category examples for each level (业务术语/技术术语/模块专属术语)
- Usage Rules examples showing applicable/forbidden/boundary distinction
- See Also examples showing cross-references

---

## 6. Structured Append in Markdown (### Entries / ### Extracted)

**D-CMD-03 decision:** `### Entries` (user write), `### Extracted` (system read-only)

**Implementation pattern:**
```markdown
## Key Decisions

### Entries

<!-- User manually adds entries here -->

### Extracted

<!-- System auto-appends extracted insights here -->
<!-- DO NOT EDIT BELOW: Auto-extracted by /flow-kit:search-lessons -->
```

**Write protocol:**
- User writes to `### Entries` freely
- System appends to `### Extracted` with timestamp + source reference
- System never modifies or deletes user content in `### Entries`
- System can update `### Extracted` (re-extract with new search context)

**Lock mechanism:**
```markdown
<!-- 🔒 SYSTEM-READONLY: Extracted section — do not edit manually -->
```
This prevents accidental user edits to system-generated content.

---

## Open Questions

| # | Question | Recommendation |
|---|----------|----------------|
| OQ-1 | Should GLOSSARY.md.template include example entries or empty template? | Include 2-3 illustrative examples per category — reduces initialization friction |
| OQ-2 | Does semantic fallback need to traverse See Also links recursively? | No — single-level traversal (term → See Also target) is sufficient for v1.2 |
| OQ-3 | Should cross-session-search.md command file include inline examples? | Yes — `## 示例` section with 2-3 usage examples |
| OQ-4 | Does `### Extracted` need conflict resolution if user edits it? | System treats user edits to Extracted as override; re-extract does not revert |

---

## Common Pitfalls to Avoid

1. **Semantic search over-engineering** — Don't add external NLP deps; use GLOSSARY relationship traversal instead
2. **Template too sparse** — GLOSSARY.md.template needs examples; empty template causes initialization paralysis
3. **Command doc missing examples** — Users need `/flow-kit:search-lessons --help` equivalent with usage examples
4. **Ignoring existing GLOSSARY.md** — Phase 9 GLOSSARY.md uses 4-column table (Term/Definition/Source/Version); new template must be compatible but enhanced (6 fields per D-TPL-01)
5. **Category misalignment** — D-TPL-02 requires multi-level category; ensure template categories match LESSONS.md.template tag style

---

## Implementation Approach Summary

### TPL-01: GLOSSARY.md.template

1. Copy LESSONS.md.template BEGIN/END markers
2. Define 6 core fields: Term / Definition / Usage Rules / Category / Example / See Also
3. Use category tags: `#业务术语` `#技术术语` `#模块专属术语` (matching tag style from LESSONS)
4. Include 2-3 example entries per category showing Usage Rules format
5. Add trigger mechanism table (aligns with existing GLOSSARY.md)
6. Path: `flow-kit/templates/GLOSSARY.md.template`

### CMD-01: cross-session-search.md

1. Follow command structure: `# Command: /flow-kit:search-lessons`
2. Implement hybrid search:
   - Primary: `rg -i PATTERN .specs/LESSONS.md`
   - Fallback: traverse See Also links + category expansion
3. Output format: list mode (default), `--verbose` for summary
4. Respect `### Entries` (write) vs `### Extracted` (read-only) boundaries
5. Include `## 示例` section with 2-3 usage examples
6. Path: `flow-kit/commands/cross-session-search.md`

---

## Dependencies Check

| Dependency | Status | Notes |
|------------|--------|-------|
| `rg` (ripgrep) | Available | Used for keyword search |
| GLOSSARY.md term relationships | Available | Semantic fallback via See Also |
| Category hierarchy | Available | Multi-level classification per D-TPL-02 |
| LESSONS.md at .specs/LESSONS.md | Confirmed (Phase 10) | Search target |
| markdown file manipulation | Available | Standard file I/O |

**No new dependencies required for Phase 11.**

---

*Research completed: 2026-05-07*