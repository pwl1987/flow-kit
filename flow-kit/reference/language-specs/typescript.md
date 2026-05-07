# TypeScript Engineer Reference

## Toolchain

- Lint: `npx eslint . --ext .ts` or `npx tslint -c tslint.json '**/*.ts'`
- Test: `npm test` (jest --coverage) or `npx vitest`
- Type check: `npx tsc --noEmit`
- Build: `npm run build` or `npx tsc`

## Core Concepts

- **Static typing** — TypeScript's primary value; enables compile-time error detection
- **Structural typing** — Types are compatible based on shape, not name

## Debug Guide

- Use `tsc --noEmit` to catch type errors before runtime
- Enable source maps in build for debugger attachment
- tsserver logs: `TSS_LOG=-level verbose` for LSP issues

## Breaking Change Detection

Reference: `flow-kit/reference/breaking-change-rules.md`

### TypeScript-specific Patterns

| Pattern | Example | Severity |
|---------|---------|----------|
| Interface property removed | `interface Foo { bar: string }` -> `interface Foo { }` | CRITICAL |
| Type alias removed | `type Foo = string` removed | CRITICAL |
| Function overload removed | One signature removed from union | HIGH |
| Enum member removed | `enum Foo { A, B }` -> `enum Foo { A }` | HIGH |
| Export removed | `export { Foo }` -> `export { }` | HIGH |

### Detection Commands

```bash
# API signature changes (requires tsc)
npx tsc --noEmit --strict

# Dependency audit
npm audit --json | jq '.metadata.total === 0'

# Lock file change detection
git diff package-lock.json | grep '"version"' | head -20
```
