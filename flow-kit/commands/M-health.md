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

- **Node.js**: Run `npm test` or check coverage from `coverage/`
- **Go**: Run `go test -cover`
- **Python**: Run `pytest --cov` or check `.coverage`
- **Rust**: Run `cargo test --lib` (shows coverage %)
- **Java**: Check `target/site/jacoco/`
- **.NET**: Check `TestResults/` or run `dotnet test /p:CollectCoverage=true`

Report coverage percentage and trend (if historical data available).

### 3. Lint Status

Run appropriate linter for detected stack:
- **Node.js**: `npm run lint` or `npx eslint .`
- **Go**: `go vet ./...`
- **Python**: `flake8 .` or `pylint .`
- **Rust**: `cargo clippy -- -D warnings`
- **Java**: `mvn checkstyle:check`
- **.NET**: `dotnet format --verify-no-changes`

Report error/warning count and categories.

### 4. Dependency Health

- **Node.js**: Run `npm audit --json` → parse vulnerabilities
- **Go**: Run `go list -m all | xargs go mod graph` → check for conflicts
- **Python**: Check `pip-audit` or `safety check`
- **Rust**: Run `cargo audit`
- **Docker**: Check `trivy image .` if Dockerfile exists

Report: critical/high/medium/low vulnerabilities by severity.

### 5. Code Quality Indicators

- **Complexity**: Check for high-complexity files (>50 cyclomatic complexity)
- **Duplication**: Check for repeated code blocks
- **Dead code**: Detect unused functions/files

## Output Format

```
## Health Report

**Stack**: [detected stack]
**Scan Time**: [timestamp]

| Category | Score | Status | Details |
|----------|-------|--------|---------|
| Test Coverage | 85% | PASS | Above 80% threshold |
| Lint Status | 0 errors | PASS | Clean |
| Dependencies | 2 medium, 1 low | WARN | Run `npm audit fix` |
| Complexity | 3 hotspots | PASS | Within limits |

**Overall**: PASS (some warnings)
**Action Items**:
- [ ] Run `npm audit fix` to resolve 3 vulnerabilities
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