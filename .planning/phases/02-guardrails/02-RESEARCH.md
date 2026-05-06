# Phase 2: Guardrails & Capabilities - Research

**Researched:** 2026-05-06
**Domain:** Brownfield guardrails, skill packages, lateral commands, MCP tool adaptation, configuration files, archive logic
**Confidence:** MEDIUM

## Summary

Phase 2 implements the safety and capability layer for flow-kit. Six locked decisions (G1-G6) constrain the implementation space. Brownfield detection uses `.git/` + package manager file presence (low-precision but fast). Skill packages follow a standalone `.md` file pattern with GO.md routing. MCP tiering mirrors Claude Code's own permission model. Constitution/user-config merge is safety-first with hard overrides.

**Primary recommendation:** Implement guardrails as context-setting files (not enforcement code), skills as reusable templates, and config as merge-on-read rather than runtime resolution.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Brownfield detection | API/Backend | Browser/Client | Detection logic runs on file scan (API tier); result propagates to context |
| Guardrail rules | API/Backend | Browser/Client | Rules are constraints injected into context; execution is implicit |
| Skill packages | API/Backend | — | Templates referenced by GO.md routing |
| Lateral commands | Browser/Client | API/Backend | User invokes command; command may trigger backend scanning |
| MCP tool tiering | API/Backend | — | Configuration consumed by agent runtime |
| Constitution merge | Browser/Client | — | Resolution happens at context load time |

---

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions

**G1: Brownfield Guardrail Activation**
- Auto-detect: `.git/` + `package.json` / `go.mod` / `pom.xml` / `Cargo.toml` → classify as brownfield
- Manual trigger: `/flow-kit:guardrails` or `@flow-kit/guardrails`
- No auto-injection: guardrails do NOT auto-activate

**G2: Skill Package Granularity**
- 7 independent `.md` files under `flow-kit/skills/`
- GO.md routes based on phase context

**G3: Lateral Command Format**
- `/flow-kit:health` style — Claude Code native slash command
- GO.md handles routing for all 4 commands
- Commands live under `commands/` directory

**G4: MCP Tool Tiering**
- Tiered by destructiveness: core (read) < standard (local write) < all (full execution)
- `mcp-tools-config.md` defines each tier's tool list
- Constitution constraints can override tier boundaries

**G5: Constitution vs User-Config Priority**
- Safety rules in Constitution CANNOT be overridden by user-config
- Non-safety rules: user-config wins on conflicts
- Priority order: Constitution > user-config > defaults

**G6: ARCH-90 Archive Location**
- `flow-kit/archive/archive-change.md` belongs to Phase 2 scope

### Claude's Discretion
- Guardrail rule severity levels (what constitutes P0/P1/P2)
- Skill package internal structure (each file's template format)
- Command output formats

### Deferred Ideas
- Phase naming conflict (defer to Phase 4)

</user_constraints>

---

## Standard Stack

No external libraries required. All Phase 2 deliverables are markdown files. Implementation uses:
- File-based detection via glob patterns
- Markdown file references for routing
- Levenshtein distance already implemented in GO.md

### File Structure (Target)

```
flow-kit/
├── guardrails/
│   ├── brownfield-guardrails.md    # GUARD-20: B1-B6 总纲
│   ├── breaking-change.md          # GUARD-21: P0/P1/P2 分级
│   ├── database-guardrails.md      # GUARD-22: DDL/DML 安全
│   ├── security-checklist.md       # GUARD-23: YAML 安全清单
│   └── ui-guardrails.md            # GUARD-24: 视觉语汇对齐
├── skills/
│   ├── requirement-clarify.md      # SKILL-30
│   ├── task-master.md              # SKILL-31
│   ├── subagent-execution.md       # SKILL-32
│   ├── code-review.md              # SKILL-33
│   ├── debugging.md                # SKILL-34
│   ├── parallel-dispatch.md        # SKILL-35
│   └── verification.md             # SKILL-36
├── commands/
│   ├── M-health.md                 # CMD-40
│   ├── I-intel-scan.md             # CMD-41
│   ├── update-context.md           # CMD-42
│   └── sync-team-config.md         # CMD-43
├── mcp/
│   ├── mcp-tools-config.md         # MCP-50: core/standard/all
│   ├── git-integration.md         # MCP-51
│   └── external-lint-adapter.md    # MCP-52
├── config/
│   ├── constitution.md            # CFG-80: 全局最高约束
│   └── default-user-config.md      # CFG-81: 默认用户配置
└── archive/
    └── archive-change.md          # ARCH-90
```

---

## Architecture Patterns

### Pattern 1: Guardrail File Structure

Guardrails follow Trigger/Behavior/Boundary/Output format (matching phase files):

```markdown
--- BEGIN guardrails/brownfield-guardrails.md ---

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 Brownfield 项目护栏总纲，定义 B1-B6 六项护栏规则。

# Brownfield Guardrails (B1-B6)

## 触发条件
{{TRIGGER}}
- 用户通过 `/flow-kit:guardrails` 或 `@flow-kit/guardrails` 激活
- 或检测到 `.git/` + 包管理文件共存时自动设置上下文标记

## 核心行为
{{CORE_BEHAVIOR}}
- B1: 破坏性变更分级审批
- B2: 数据库变更安全审查
- B3: 安全检查清单执行
- B4: UI 视觉语汇对齐
- B5: [additional guardrail]
- B6: [additional guardrail]

## 边界情况
{{BOUNDARY_CASES}}
- 非 brownfield 项目：跳过数据库和 UI 护栏
- 紧急变更：P0 直接快速通道

## 输出物
{{OUTPUTS}}
- 护栏激活确认
- 当前项目分类标记

--- END guardrails/brownfield-guardrails.md ---
```

### Pattern 2: Skill Package Structure

Each skill is a standalone markdown file with four sections:

```markdown
# Skill: {skill-name}

## 何时使用
{{WHEN_TO_USE}}
- Phase context triggers

## 使用方法
{{HOW_TO_USE}}
- Step-by-step template

## 示例
{{EXAMPLE}}
- Concrete example

## 注意事项
{{NOTES}}
- Edge cases, gotchas
```

### Pattern 3: Constitution Config Structure

```markdown
--- BEGIN config/constitution.md ---

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 flow-kit 全局最高约束，所有其他配置不得违反此处规则。

# Constitution — Safety Floor

## 不可_override_规则 (CANNOT be overridden)

### 安全类
- [Rule]: [description]

### 数据完整性类
- [Rule]: [description]

### 部署护栏类
- [Rule]: [description]

## 可_override_规则 (Default overrides allowed)

### 流程偏好类
- [Rule]: [description]

--- END config/constitution.md ---
```

### Pattern 4: User Config with Merge

```markdown
--- BEGIN config/default-user-config.md ---

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 用户可在项目根目录 `.flow-kit/user-config.md` 覆盖此文件中的非安全规则。

# Default User Configuration

## 流程配置
[Setting]: [default value]

## 团队约定
[Setting]: [default value]

--- END config/default-user-config.md ---
```

### Pattern 5: MCP Tool Tiering Config

```markdown
--- BEGIN mcp/mcp-tools-config.md ---

> 【CLAUDE CODE INSTRUCTION 强制约束】
> MCP 工具分层配置。Tier 边界可被 Constitution 规则调整。

# MCP Tool Tiers

## Tier: core (Read-only, always safe)
Tools: Read, Glob, Grep, WebSearch, WebFetch

## Tier: standard (Local mutations, requires confirmation)
Tools: Write, Edit, Bash (local only, --dangerous-level=local)

## Tier: all (Full execution, explicit opt-in required)
Tools: Bash (full), Agent, Task, TodoWrite, Read (all)

--- END mcp/mcp-tools-config.md ---
```

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Brownfield detection | Custom file scanning | Glob patterns + file existence checks | Simple patterns are sufficient |
| Command routing | Custom parser | GO.md Levenshtein already exists | Reuse existing infrastructure |
| Config merge | Runtime merge logic | File load order + context precedence | Keep it simple, document priority |
| Skill invocation | Custom template engine | Markdown file references | Zero dependency, Claude Code reads .md |

---

## Common Pitfalls

### Pitfall 1: Guardrail Over-Activation
**What goes wrong:** Guardrails fire in inappropriate contexts, annoying users.
**Why it happens:** Detection signals are too broad (e.g., `.git` exists in all git projects).
**How to avoid:** Require BOTH `.git/` AND package manager file; require manual trigger.
**Warning signs:** Users report "guardrails interrupting greenfield work."

### Pitfall 2: Constitution Proliferation
**What goes wrong:** Too many rules in Constitution, making it a dumping ground.
**Why it happens:** Every preference gets marked "safety-critical."
**How to avoid:** Strict criteria for Constitution inclusion: security, data integrity, deployment.
**Warning signs:** Constitution exceeds 50 rules.

### Pitfall 3: Skill Package Bloat
**What goes wrong:** Skills become mini-frameworks with their own templates.
**Why it happens:** Over-engineering reusable assets.
**How to avoid:** Each skill is ONE markdown file, max 200 lines.
**Warning signs:** Skills importing other skills.

### Pitfall 4: Tier Boundary Ambiguity
**What goes wrong:** Unclear which tier a tool belongs to.
**Why it happens:** Some tools (Bash, Write) have safe and unsafe modes.
**How to avoid:** Explicit enumeration; Constitution can override per-project.
**Warning signs:** "Does Write to temp count as standard or all?"

### Pitfall 5: Config Conflict Resolution paralysis
**What goes wrong:** Endless debates about safety vs. preference classification.
**Why it happens:** Gray areas in rule classification.
**How to avoid:** Default to Constitution; user-config must explicitly opt out.
**Warning signs:** Rules appearing in both Constitution and user-config.

---

## Code Examples

### Brownfield Detection (Pseudocode)

```javascript
// Source: flow-kit guardrails/brownfield-guardrails.md
function detectBrownfield(cwd) {
  const hasGit = glob('.git').exists(cwd);
  const hasPkgManager = glob('package.json').exists(cwd) ||
                         glob('go.mod').exists(cwd) ||
                         glob('pom.xml').exists(cwd) ||
                         glob('Cargo.toml').exists(cwd);
  return hasGit && hasPkgManager;
}
```

### Constitution-UserConfig Merge (Conceptual)

```markdown
// Source: config/constitution.md
加载顺序:
1. constitution.md (ALWAYS loaded first, safety floor)
2. default-user-config.md (fallback values)
3. .flow-kit/user-config.md (project overrides, if exists)

冲突解决:
- Constitution 安全规则: user-config CANNOT override
- 其他规则: user-config WINS on conflict
- 未定义项: use default-user-config value
```

### GO.md Command Routing (Existing)

```javascript
// Source: flow-kit/GO.md (Phase 1 output)
function levenshtein(a, b) {
  // Already implemented in Phase 1
}
function findClosestCommand(input, commands) {
  // Already implemented in Phase 1
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Auto-activate all guardrails | Manual trigger + detection flag | Phase 2 G1 | Prevents interruption |
| Single config file | Constitution + user-config split | Phase 2 G5 | Safety guarantees preserved |
| Monolithic skills | 7 independent .md files | Phase 2 G2 | Selective use enabled |
| Uniform MCP access | Tiered by destructiveness | Phase 2 G4 | Risk-based access control |

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `.git/` + package manager detection is sufficient for brownfield | G1 Brownfield Detection | Medium — may miss non-git projects or non-standard package managers |
| A2 | Safety rules can be strictly separated from preference rules | G5 Constitution | Medium — some rules are ambiguous |
| A3 | MCP tools core/standard/all tiers align with actual Claude Code behavior | MCP-50 | Unknown — requires Claude Code documentation verification |

**If this table is empty:** All claims in this research were verified or cited — no user confirmation needed.

---

## Open Questions

1. **What constitutes a "safety-critical" rule vs. a "preference"?**
   - What we know: Constitution.md has safety/data/deployment; user-config has team conventions
   - What's unclear: Edge cases like "require tests before merge" — safety or preference?
   - Recommendation: Default to Constitution for any rule affecting artifacts outside the project

2. **Should guardrail B5/B6 be defined now or deferred?**
   - What we know: GUARD-20 lists B1-B6, but only B1-B4 have defined names
   - What's unclear: What are B5 and B6?
   - Recommendation: Leave as placeholder `{{B5_TBD}}`, `{{B6_TBD}}` until Phase 2 planning

3. **MCP tool enumeration accuracy**
   - What we know: Phase 1 output shows GO.md with command routing; G4 describes tiers
   - What's unclear: Exact list of tools in each tier, especially for `standard`
   - Recommendation: Use conservative list (fewer tools in standard) and expand via Constitution overrides

---

## Environment Availability

Step 2.6: SKIPPED (no external dependencies — all Phase 2 deliverables are markdown files)

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | None — markdown-only project |
| Config file | N/A |
| Quick run command | N/A |
| Full suite command | N/A |

### Phase Requirements to File Map

| REQ-ID | File | Format | Verification |
|--------|------|--------|---------------|
| GUARD-20 | guardrails/brownfield-guardrails.md | Trigger/Behavior/Boundary/Output | File exists + B1-B6 listed |
| GUARD-21 | guardrails/breaking-change.md | P0/P1/P2 分级 | File exists + 3 levels defined |
| GUARD-22 | guardrails/database-guardrails.md | DDL/DML 安全规范 | File exists + DDL/DML sections |
| GUARD-23 | guardrails/security-checklist.md | YAML checklist | File exists + valid YAML |
| GUARD-24 | guardrails/ui-guardrails.md | 视觉语汇对齐流程 | File exists |
| SKILL-30 | skills/requirement-clarify.md | 4-section template | File exists |
| SKILL-31 | skills/task-master.md | 4-section template | File exists |
| SKILL-32 | skills/subagent-execution.md | 4-section template | File exists |
| SKILL-33 | skills/code-review.md | 4-section template | File exists |
| SKILL-34 | skills/debugging.md | 4-section template | File exists |
| SKILL-35 | skills/parallel-dispatch.md | 4-section template | File exists |
| SKILL-36 | skills/verification.md | 4-section template | File exists |
| CMD-40 | commands/M-health.md | 命令文件 | File exists |
| CMD-41 | commands/I-intel-scan.md | 命令文件 | File exists |
| CMD-42 | commands/update-context.md | 命令文件 | File exists |
| CMD-43 | commands/sync-team-config.md | 命令文件 | File exists |
| MCP-50 | mcp/mcp-tools-config.md | Tier 定义 | File exists + 3 tiers |
| MCP-51 | mcp/git-integration.md | git 安全封装 | File exists |
| MCP-52 | mcp/external-lint-adapter.md | lint 适配 | File exists |
| CFG-80 | config/constitution.md | 约束文件 | File exists + safety rules |
| CFG-81 | config/default-user-config.md | 配置模板 | File exists |
| ARCH-90 | archive/archive-change.md | 归档逻辑 | File exists |

### Validation Command
```bash
# Verify all Phase 2 files exist
for f in \
  guardrails/brownfield-guardrails.md \
  guardrails/breaking-change.md \
  guardrails/database-guardrails.md \
  guardrails/security-checklist.md \
  guardrails/ui-guardrails.md \
  skills/requirement-clarify.md \
  skills/task-master.md \
  skills/subagent-execution.md \
  skills/code-review.md \
  skills/debugging.md \
  skills/parallel-dispatch.md \
  skills/verification.md \
  commands/M-health.md \
  commands/I-intel-scan.md \
  commands/update-context.md \
  commands/sync-team-config.md \
  mcp/mcp-tools-config.md \
  mcp/git-integration.md \
  mcp/external-lint-adapter.md \
  config/constitution.md \
  config/default-user-config.md \
  archive/archive-change.md; do
  test -f "flow-kit/$f" && echo "OK: $f" || echo "MISSING: $f"
done
```

### Wave 0 Gaps
- None — Phase 1 created directory structure; Phase 2 creates all content files

---

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No | N/A |
| V3 Session Management | No | N/A |
| V4 Access Control | Partial | MCP tiering controls tool access |
| V5 Input Validation | Yes | Guardrails validate inputs to change process |
| V6 Cryptography | No | N/A |

### Known Threat Patterns for flow-kit

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Malicious config override | Tampering | Constitution cannot be overridden by user-config |
| Unsafe MCP tool use | Elevation | Tiered access: core < standard < all |
| Breaking change injection | Tampering | P0/P1/P2分级审批 |
| Data loss via destructive operation | Information Disclosure | Database guardrails (DDL/DML review) |

---

## Sources

### Primary (HIGH confidence)
- `.planning/phases/02-guardrails/02-CONTEXT.md` — Locked decisions G1-G6
- `flow-kit/GO.md` — Existing routing implementation
- `prd.md` — Full PRD specification

### Secondary (MEDIUM confidence)
- `flow-kit/phases/0-change/0-change.md` — Phase file structure reference

### Tertiary (LOW confidence)
- [ASSUMED] MCP tool tier definitions — based on training knowledge, not verified

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all markdown, no external dependencies
- Architecture: MEDIUM — patterns based on Phase 1 output + PRD spec
- Pitfalls: MEDIUM — identified from project structure, not verified against execution

**Research date:** 2026-05-06
**Valid until:** 2026-06-06 (30 days — slow-moving domain)
