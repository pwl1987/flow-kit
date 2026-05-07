# Phase 7 Plan 03: 多语言规格破坏性变更检测模式

**Area:** C - 破坏性变更检测模式
**Requirements:** REQ-013
**Status:** Complete

---

## One-liner

6 个语言规格包含破坏性变更检测模式，统一规则在 `flow-kit/reference/breaking-change-rules.md`

---

## Tasks Executed

| # | Task | Commit | Files |
|---|------|--------|-------|
| 1 | 创建 breaking-change-rules.md | 985a785 | flow-kit/reference/breaking-change-rules.md |
| 2 | 更新 typescript.md | 09b0654 | flow-kit/reference/language-specs/typescript.md |
| 3 | 更新其他 5 个语言规格 | 5546857 | go.md, java.md, php.md, python.md, rust.md |

---

## Key Decisions

- **Unified rules file:** `flow-kit/reference/breaking-change-rules.md` — 4 categories (API/DB/Config/Dependency)
- **Detection methods:** Pattern-based (fast) + AST-based (precise)
- **Language-specific approach:** Each spec references unified rules + adds language-specific patterns

---

## Deliverables

### Created
- `flow-kit/reference/breaking-change-rules.md` — 66 lines, unified breaking change detection rules

### Modified
- `flow-kit/reference/language-specs/typescript.md` — +27 lines
- `flow-kit/reference/language-specs/go.md` — +26 lines
- `flow-kit/reference/language-specs/java.md` — +26 lines
- `flow-kit/reference/language-specs/php.md` — +26 lines
- `flow-kit/reference/language-specs/python.md` — +26 lines
- `flow-kit/reference/language-specs/rust.md` — +26 lines

---

## Breaking Change Rules Structure

### 4 Detection Domains
1. **API Changes** — Function signature, interface removal, public API removal
2. **Database Changes** — Column deletion, type change, index removal
3. **Configuration Changes** — Required config removed, default value changed
4. **Dependency Changes** — Major version bump, removed dependency

### Severity Levels
- CRITICAL: Interface removal, public API removal, column deletion, major version bump
- HIGH: Function signature change, enum member removed, config key removed
- MEDIUM: Index removal, default value changed

---

## Language-Specific Patterns

| Language | Key Breaking Patterns |
|----------|----------------------|
| TypeScript | Interface property removed, type alias removed, function overload removed |
| Go | Function signature change, interface removal, package path change |
| Java | Method signature change, annotation removal, class inheritance change |
| PHP | Method signature change, property type change, interface removal |
| Python | Function signature change, abstract method added, import path change |
| Rust | Trait removal, lifetime change, struct field type change |

---

## Commits

- `985a785` feat(07-P2-enhancement): add breaking-change-rules.md
- `09b0654` feat(07-P2-enhancement): add breaking change detection to TypeScript spec
- `5546857` feat(07-P2-enhancement): add breaking change detection to 5 language specs

---

## Self-Check

- [x] `flow-kit/reference/breaking-change-rules.md` exists with 4 detection domains
- [x] All 6 language specs contain Breaking Change Detection section
- [x] Each spec references `flow-kit/reference/breaking-change-rules.md`
- [x] Language-specific patterns included for all 6 languages
- [x] Detection commands provided for each language

## Self-Check: PASSED