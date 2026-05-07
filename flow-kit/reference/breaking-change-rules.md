# Breaking Change Detection Rules

## Overview

Breaking changes are categorized into four domains:
1. **API Changes** — Interface signature modifications
2. **Database Changes** — Schema/field deletions
3. **Configuration Changes** — Config structure modifications
4. **Dependency Changes** — Incompatible version updates

## Detection Methods

### Pattern-based (Fast)

File fingerprint detection for quick scanning:
- `BREAKING-CHANGE.md` file presence
- `*.sql` files (DDL/DML)
- `migration/` directory
- Lock file changes (`package-lock.json`, `yarn.lock`, `go.sum`, `Pipfile.lock`)

### AST-based (Precise)

Abstract syntax tree analysis for API signature changes:
- Function signature changes (parameter types, return types)
- Interface removal or modification
- Public API removal
- Type definition changes

## API Breaking Changes

| Change Type | Detection Pattern | Severity |
|-------------|-------------------|----------|
| Function signature change | Parameter type/return type mismatch | HIGH |
| Interface removal | Type not exported | CRITICAL |
| Public API removal | Method deleted | CRITICAL |
| Enum value change | Enum member removed | HIGH |

## Database Breaking Changes

| Change Type | Detection Pattern | Severity |
|-------------|-------------------|----------|
| Column deletion | ALTER TABLE DROP COLUMN | CRITICAL |
| Column type change | ALTER TABLE ALTER COLUMN | HIGH |
| Index removal | DROP INDEX | MEDIUM |
| Cascade delete added | FOREIGN KEY + ON DELETE CASCADE | HIGH |

## Configuration Breaking Changes

| Change Type | Detection Pattern | Severity |
|-------------|-------------------|----------|
| Required config removed | Key not present | HIGH |
| Default value changed | Different default | MEDIUM |
| Format structure changed | JSON/YAML schema mismatch | HIGH |

## Dependency Breaking Changes

| Change Type | Detection Pattern | Severity |
|-------------|-------------------|----------|
| Major version bump | semver major increment | CRITICAL |
| Removed dependency | Package deleted | HIGH |
| Incompatible API | Lock file hash change | HIGH |

## Language-specific Rules

Each language spec (`go.md`, `java.md`, `php.md`, `python.md`, `rust.md`, `typescript.md`)
should reference this file and add language-specific patterns.