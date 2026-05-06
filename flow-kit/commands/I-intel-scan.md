--- BEGIN flow-kit/commands/I-intel-scan.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】

## 优先级加载（任何逻辑不得违反）

1. **立即加载** `@flow-kit/config/constitution.md`（全局最高优先级）
2. **立即加载** `@flow-kit/config/default-user-config.md`，若存在 `.flow-kit/user-config.md` 则优先加载用户自定义配置
3. 后续所有逻辑必须遵守这两份配置

---

# Technology Intel Scan

## Command

`/flow-kit:scan`

## Purpose

Scan codebase for technology stack inventory, TODO/FIXME/HACK comments, large files, and architectural issues. Generate categorized intel report.

## Execution

### 1. Stack Detection (same as M-health)

Detect and report:
- Languages (by file extension)
- Frameworks (package.json, go.mod, etc.)
- Build systems
- Database/ORM usage
- API frameworks

### 2. TODO/FIXME/HACK Detection

Scan all source files for markers:
- `TODO` comments → pending tasks
- `FIXME` comments → known bugs
- `HACK` comments → workarounds
- `XXX` comments → warning flags
- `NOTE:` comments → important notes

Report format:
```
| Marker | Count | Locations |
|--------|-------|-----------|
| TODO | 47 | src/api/auth.ts:23, src/utils/helpers.ts:156, ... |
| FIXME | 12 | src/core/worker.ts:89, ... |
| HACK | 3 | src/compat/legacy.ts:45, ... |
```

### 3. Large Files Detection

Find files exceeding size thresholds:

| Type | Threshold | Rationale |
|------|-----------|----------|
| Source code | >1000 lines | Hard to maintain |
| Config | >500 lines | Over-configured |
| Test | >2000 lines | Consider splitting |
| Template | >500 lines | May need partials |

Report top 10 largest files with line counts and paths.

### 4. Circular Dependency Detection

- **Node.js**: Use `madge --circular`
- **Python**: Use `pydeps`
- **Go**: Use `go mod graph` + analysis
- **Rust**: Use `cargo metadata` + `cargo-udeps`

Report any circular dependency chains found.

### 5. Architecture Issues

- Detect god objects (>3000 lines in single file)
- Detect deep nesting (>5 levels)
- Detect large modules (>50 exported functions)
- Flag missing error handling patterns

## Output Format

```
## Intel Scan Report

**Scan Time**: [timestamp]
**Scope**: [directories scanned]

### Technology Stack

| Category | Detected |
|----------|----------|
| Languages | TypeScript, Python |
| Frameworks | React, FastAPI |
| Build | Vite, Poetry |
| API | REST |

### Marker Summary

| Marker | Count | Oldest | Newest |
|--------|-------|--------|--------|
| TODO | 47 | 2024-01-15 | 2026-03-20 |
| FIXME | 12 | 2025-06-10 | 2026-04-28 |
| HACK | 3 | 2025-11-02 | 2026-02-14 |

### Large Files

| File | Lines | Type |
|------|-------|------|
| src/monolith.ts | 2847 | source |
| tests/integration.spec.ts | 1923 | test |

### Circular Dependencies

```
src/A.ts → src/B.ts → src/A.ts (DETECTED)
```

### Recommendations

1. Address 12 FIXME comments (known bugs)
2. Split `src/monolith.ts` (>2000 lines)
3. Resolve circular dependency between A and B modules
```

## Usage

```bash
@flow-kit/commands/I-intel-scan.md
```

--- END flow-kit/commands/I-intel-scan.md ---