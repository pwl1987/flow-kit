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
