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

### 2. Marker Detection

**Marker Types:**
| Marker | Meaning | Critical Threshold |
|--------|---------|-------------------|
| TODO | Pending task | Age >6 months |
| FIXME | Known bug | Any |
| HACK | Workaround | Age >3 months |
| XXX | Warning flag | Any |
| NOTE | Important note | Age >6 months |

**Age Analysis:**
```markdown
| Age Range | Count | Items |
|-----------|-------|-------|
| >6 months | 15 | TODO need attention |
| 3-6 months | 8 | Need scheduling |
| <1 month | 12 | Recent, OK |
```

**Output Format:**
```json
{
  "markers": {
    "TODO": { "count": 47, "oldest": "2024-01-15", "newest": "2026-03-20", "critical_age_count": 15 },
    "FIXME": { "count": 12, "oldest": "2025-06-10", "newest": "2026-04-28", "critical_age_count": 5 },
    "HACK": { "count": 3, "oldest": "2025-11-02", "newest": "2026-02-14", "critical_age_count": 1 },
    "XXX": { "count": 8, "oldest": "2024-03-01", "newest": "2026-01-15", "critical_age_count": 2 }
  },
  "total_critical": 23
}
```

### 3. Large Files Detection

**Thresholds:**
| Type | Warning | Critical |
|------|---------|----------|
| Source | >500 lines | >1000 lines |
| Config | >300 lines | >500 lines |
| Test | >1000 lines | >2000 lines |
| Generated | >2000 lines | >5000 lines |

**Commands:**
- Find large files: `find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) -exec wc -l {} + | sort -rn | head -20`
- Filter by type using file extension + line count

**Output Format:**
```json
{
  "large_files": [
    { "file": "src/monolith.ts", "lines": 2847, "type": "source", "status": "CRITICAL" },
    { "file": "src/core/worker.ts", "lines": 1523, "type": "source", "status": "WARNING" }
  ],
  "total_critical": 1,
  "total_warning": 3
}
```

### 4. Circular Dependency Detection

**Tools by Stack:**
| Stack | Tool | Command |
|-------|------|---------|
| Node.js | madge | `npx madge --circular` |
| Python | pydeps | `pydeps --max-depth=3` |
| Go | go mod graph | `go mod graph \| grep -E '^(.*)->\1'` |
| Rust | cargo-udeps | `cargo udeps` |

**Output Format:**
```json
{
  "cycles": [
    { "path": "src/A.ts → src/B.ts → src/A.ts", "length": 3 },
    { "path": "src/C.ts → src/D.ts → src/E.ts → src/C.ts", "length": 4 }
  ],
  "total_cycles": 2,
  "status": "FAIL"
}
```

**Severity:** 1 cycle = HIGH, 2+ = CRITICAL

### 5. Architecture Issues

**God Objects (>2000 lines):**
```json
{
  "god_objects": [
    { "file": "src/monolith.ts", "lines": 2847 },
    { "file": "src/core/processor.ts", "lines": 1892 }
  ]
}
```

**Deep Nesting (>5 levels):**
```json
{
  "deep_nesting": [
    { "file": "src/api/auth.ts", "line": 45, "depth": 6 },
    { "file": "src/utils/helpers.ts", "line": 128, "depth": 7 }
  ]
}
```

**Large Modules (>30 exports):**
```json
{
  "large_modules": [
    { "file": "src/utils/index.ts", "exports": 47 },
    { "file": "src/constants/index.ts", "exports": 34 }
  ]
}
```

**Missing Error Handling:**
```json
{
  "missing_error_handling": [
    { "file": "src/api/users.ts", "line": 67 },
    { "file": "src/core/worker.ts", "line": 112 }
  ]
}
```

### 6. Code Smell Detection

**Long Parameter List (>5 parameters):**
```json
{
  "long_parameters": [
    { "file": "src/api/handler.ts", "function": "processRequest", "params": 8 },
    { "file": "src/utils/validator.ts", "function": "validate", "params": 7 }
  ]
}
```

**Feature Envy:**
- Method uses more data from other class than its own
- Detect via AST analysis: method calls on external objects > method calls on `this`

**Inappropriate Intimacy:**
- Two classes heavily coupled via bidirectional references
- Detect: class A imports B and B imports A

**Shotgun Surgery:**
- One change requires modifying many classes
- Detect: single function modified by many PRs (requires history analysis)

**Output Format:**
```json
{
  "code_smells": {
    "long_parameters": 5,
    "feature_envy": 2,
    "inappropriate_intimacy": 3,
    "shotgun_surgery": 0
  },
  "architecture_issues": {
    "god_objects": 2,
    "deep_nesting": 12,
    "large_modules": 1,
    "missing_error_handling": 8
  },
  "total_issues": 33,
  "status": "WARN"
}
```

## Output Format

```markdown
## Intel Scan Report

**Scan Time**: 2026-05-07 10:30:00
**Scope**: src/, tests/, config/
**Duration**: 32s

### Technology Stack

| Category | Detected |
|----------|----------|
| Languages | TypeScript, Python |
| Frameworks | React, FastAPI |
| Build | Vite, Poetry |
| API | REST |

### Marker Summary

| Marker | Count | Age >6mo | Critical |
|--------|-------|----------|----------|
| TODO | 47 | 15 | 3 |
| FIXME | 12 | 4 | 5 |
| HACK | 3 | 1 | 1 |

### Large Files

| File | Lines | Type | Warning |
|------|-------|------|---------|
| src/monolith.ts | 2847 | source | CRITICAL |
| src/core/worker.ts | 1523 | source | WARNING |

### Circular Dependencies

```
src/A.ts → src/B.ts → src/A.ts (cycle)
src/C.ts → src/D.ts → src/C.ts (cycle)
```

### Architecture Issues

1. **God Objects** (3 detected):
   - src/monolith.ts: 2847 lines
   - src/core/processor.ts: 1892 lines

2. **Deep Nesting** (12 locations):
   - src/api/auth.ts:45 (6 levels)
   - src/utils/helpers.ts:128 (7 levels)

3. **Missing Error Handling** (8 locations):
   - src/api/users.ts:67 (no try-catch)
   - src/core/worker.ts:112 (no error handler)

### Recommendations

1. [CRITICAL] Address 5 FIXME comments marked critical
2. [HIGH] Split monolith.ts (2847 lines → target <1000)
3. [HIGH] Fix 2 circular dependencies
4. [MEDIUM] Add error handling to 8 locations

### JSON Output (for automation)

```json
{
  "scan_time": "2026-05-07T10:30:00Z",
  "scope": ["src/", "tests/", "config/"],
  "duration_seconds": 32,
  "stack": {
    "languages": ["TypeScript", "Python"],
    "frameworks": ["React", "FastAPI"],
    "build": ["Vite", "Poetry"],
    "api": ["REST"]
  },
  "markers": {
    "TODO": { "count": 47, "age_6m_plus": 15, "critical": 3 },
    "FIXME": { "count": 12, "age_6m_plus": 4, "critical": 5 },
    "HACK": { "count": 3, "age_6m_plus": 1, "critical": 1 }
  },
  "large_files": [
    { "file": "src/monolith.ts", "lines": 2847, "type": "source", "status": "CRITICAL" },
    { "file": "src/core/worker.ts", "lines": 1523, "type": "source", "status": "WARNING" }
  ],
  "circular_dependencies": {
    "cycles": [
      { "path": "src/A.ts → src/B.ts → src/A.ts", "length": 3 },
      { "path": "src/C.ts → src/D.ts → src/C.ts", "length": 3 }
    ],
    "total": 2
  },
  "architecture_issues": {
    "god_objects": [
      { "file": "src/monolith.ts", "lines": 2847 },
      { "file": "src/core/processor.ts", "lines": 1892 }
    ],
    "deep_nesting": 12,
    "large_modules": 1,
    "missing_error_handling": 8
  },
  "code_smells": {
    "long_parameters": 5,
    "feature_envy": 2,
    "inappropriate_intimacy": 3,
    "shotgun_surgery": 0
  },
  "recommendations": [
    { "priority": "CRITICAL", "action": "Address 5 FIXME comments marked critical" },
    { "priority": "HIGH", "action": "Split monolith.ts (2847 lines → target <1000)" },
    { "priority": "HIGH", "action": "Fix 2 circular dependencies" },
    { "priority": "MEDIUM", "action": "Add error handling to 8 locations" }
  ],
  "status": "WARN"
}
```

## Usage

```bash
@flow-kit/commands/I-intel-scan.md
```

--- END flow-kit/commands/I-intel-scan.md ---