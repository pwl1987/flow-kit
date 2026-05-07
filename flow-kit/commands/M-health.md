--- BEGIN flow-kit/commands/M-health.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】

## 优先级加载（任何逻辑不得违反）

1. **立即加载** `@flow-kit/config/constitution.md`（全局最高优先级）
2. **立即加载** `@flow-kit/config/default-user-config.md`，若存在 `.flow-kit/user-config.md` 则优先加载用户自定义配置
3. 后续所有逻辑必须遵守这两份配置

---

# Code Health Scan

## Command

`/flow-kit:health`

## Purpose

Perform comprehensive code health scan detecting tech stack, test coverage, lint status, and dependency health. Generate health report with scores per category.

## Execution

### 1. Stack Detection

Scan for project type files:
- `package.json` → Node.js/npm ecosystem
- `go.mod` → Go
- `pom.xml` → Java/Maven
- `Cargo.toml` → Rust
- `pyproject.toml` → Python
- `composer.json` → PHP
- `*.sln` or `*.csproj` → .NET

Report detected stack.

### 2. Test Coverage Analysis

**Thresholds:**
| Coverage | Status | Action |
|----------|--------|--------|
| >80% | PASS | Healthy |
| 60-80% | WARN | Improve |
| <60% | FAIL | Critical |

**Methods by Stack:**
- **Node.js**: `npm test` + `coverage/` report (Istanbul/NYC)
- **Go**: `go test -cover` → parse coverage.out
- **Python**: `pytest --cov` → `.coverage` (Coverage.py)
- **Rust**: `cargo test --lib` → llvm-coverage
- **Java**: `mvn test` → `target/site/jacoco/`
- **.NET**: `dotnet test /p:CollectCoverage=true` → `TestResults/`

**Output Format:**
```json
{
  "coverage": 78,
  "status": "WARN",
  "trend": -2,
  "files_below_threshold": [
    { "file": "src/api/auth.ts", "coverage": 45 },
    { "file": "src/core/worker.ts", "coverage": 52 }
  ]
}
```

**Trend Calculation:** Compare current vs previous scan (stored in `.flow-kit/health-history.json`)

### 3. Lint Status

**Error Classification:**
| Type | Indicators | Fix Command |
|------|------------|-------------|
| Syntax | Unexpected token, missing } | Manual fix |
| Style | Indentation, semicolons, quotes | `eslint --fix` |
| Type | Type 'X' not assignable to 'Y' | `tsc --noEmit` |

**Commands by Stack:**
- **Node.js**: `npm run lint` or `npx eslint . --format json`
- **Go**: `go vet ./...` → stderr parse
- **Python**: `flake8 . --statistics` or `pylint . --output-format=text`
- **Rust**: `cargo clippy -- -D warnings` → stderr parse
- **Java**: `mvn checkstyle:check`
- **.NET**: `dotnet format --verify-no-changes`

**Output Format:**
```json
{
  "errors": 3,
  "breakdown": { "syntax": 0, "style": 2, "type": 1 },
  "top_errors": [
    { "file": "src/api/auth.ts", "line": 45, "error": "Unexpected token" }
  ],
  "status": "PASS"
}
```

**Trend:** Compare error count vs previous scan. -5 = improved, +3 = degraded.

### 4. Dependency Health

**Commands by Stack:**
- **Node.js**: `npm audit --json` → parse `vulnerabilities`
- **Go**: `go list -m all | xargs go mod graph` → check conflicts
- **Python**: `pip-audit` or `safety check --json`
- **Rust**: `cargo audit` → stderr/JSON
- **Docker**: `trivy image .` if Dockerfile exists

**Severity Table:**
```markdown
| Severity | Count | Action |
|----------|-------|--------|
| CRITICAL | 2 | `npm audit fix --force` |
| HIGH | 5 | `npm audit fix` |
| MEDIUM | 12 | Review and fix |
| LOW | 23 | Optional |
```

**Output Format:**
```json
{
  "total": 42,
  "breakdown": { "critical": 2, "high": 5, "medium": 12, "low": 23 },
  "critical_items": [
    { "package": "json5@1.0.1", "cve": "CVE-2022-46175", "fix": ">=2.0.0" }
  ],
  "status": "WARN"
}
```

**Score Calculation:**
- CRITICAL: -20 per item
- HIGH: -10 per item
- MEDIUM: -5 per item
- LOW: -1 per item
- Total subtracted from 100

### 5. Code Quality Indicators

**Complexity Detection:**
- Use `eslint --print-config` or language-specific tools
- **Threshold**: >50 cyclomatic complexity = hotspot

```markdown
| Complexity | File | Function |
|------------|------|----------|
| 127 | src/core/processor.ts | processItems() |
| 89 | src/api/handler.ts | handleRequest() |
```

**Duplication Detection:**
- **Node.js**: `npx jscpd .` or `pmd cpd`
- **Python**: `pylint --disable=all --enable=DuplicationDefinedName`
- **Go**: `mvdan.cc/gofumpt` + custom analysis

```markdown
| Lines | File | Similar |
|-------|------|---------|
| 47 | src/utils/auth.ts | src/compat/legacy-auth.ts:124 |
| 23 | src/api/users.ts | src/api/accounts.ts:89 |
```

**Dead Code Detection:**
- **Node.js**: `ts-prune` or `depcheck`
- **Python**: `vulture`
- **Unused exports**: AST analysis

```markdown
**Dead Code (5 items):**
- `src/core/legacy.ts` - unused export: `processLegacy`
- `src/api/v1/users.ts` - unused: `getUserStats`
```

**Output Format:**
```json
{
  "complexity_hotspots": 3,
  "duplication_blocks": 5,
  "dead_code_items": 7,
  "score": 85,
  "status": "PASS"
}
```

## Output Format

```markdown
## Health Report

**Stack**: TypeScript, React, Node.js
**Scan Time**: 2026-05-07 10:30:00
**Duration**: 45s

### Summary

| Category | Score | Status | Trend |
|----------|-------|--------|-------|
| Test Coverage | 78% | WARN | -2% |
| Lint Status | 3 errors | PASS | -5 |
| Dependencies | 2 HIGH | WARN | -1 |
| Code Quality | 85 | PASS | +3 |

**Overall**: PASS (1 warning)

### Details

[Test Coverage]
- Files below 60%: src/api/auth.ts (45%), src/core/worker.ts (52%)
- Trend: -2% from last scan

[Dependencies]
- CRITICAL: json5@1.0.1 (CVE-2022-46175)
- HIGH: express@4.18.0 (CVE-2022-44946)

[Code Quality]
- Hotspots: src/core/processor.ts (127 complexity)
- Dead code: 7 unused exports

### Action Items

1. [WARN] Test coverage below 80% target
2. [CRITICAL] Fix 2 CRITICAL vulnerabilities
3. [LOW] Remove 7 dead code exports

### JSON Output (for automation)

```json
{
  "scan_time": "2026-05-07T10:30:00Z",
  "stack": ["TypeScript", "React", "Node.js"],
  "duration_seconds": 45,
  "summary": {
    "test_coverage": { "score": 78, "status": "WARN", "trend": -2 },
    "lint_status": { "errors": 3, "status": "PASS", "trend": -5 },
    "dependencies": { "critical": 0, "high": 2, "status": "WARN", "trend": -1 },
    "code_quality": { "score": 85, "status": "PASS", "trend": 3 }
  },
  "overall": { "status": "PASS", "score": 82, "warnings": 1 }
}
```

## Scoring

| Score | Status | Meaning |
|-------|--------|---------|
| 90-100 | EXCELLENT | Health optimal |
| 70-89 | PASS | Minor issues |
| 50-69 | WARN | Needs attention |
| <50 | FAIL | Critical issues |

## Usage

```bash
@flow-kit/commands/M-health.md
```

--- END flow-kit/commands/M-health.md ---