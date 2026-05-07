# Rust Engineer Reference

## Toolchain

- Lint: `cargo clippy` or `rustfmt --check`
- Test: `cargo test` (`cargo test -- --nocapture` for output)
- Type check: `cargo check` (faster than build, no code generation)
- Build: `cargo build --release` (optimized binary)

## Core Concepts

- **Ownership** — Each value has single owner; prevents data races and leaks
- **Borrow checker** — Compile-time borrow validation; no GC needed

## Debug Guide

- Use `cargo build` (debug) then `rust-gdb` or `rust-lldb`
- Panic messages: `RUST_BACKTRACE=1` for full stack traces
- Miri: `cargo miri` for undefined behavior detection

## Breaking Change Detection

Reference: `flow-kit/reference/breaking-change-rules.md`

### Rust-specific Patterns

| Pattern | Example | Severity |
|---------|---------|----------|
| Trait removal | `impl Foo for Bar` removed | CRITICAL |
| Lifetime change | `&'a str` -> `&'b str` | CRITICAL |
| Struct field type change | `field: i32` -> `field: i64` | HIGH |
| Public struct became private | `pub struct Foo` -> `struct Foo` | CRITICAL |
| `derive` attribute removed | `#[derive(Debug)]` removed | HIGH |

### Detection Commands

```bash
# API signature changes
cargo check

# Dependency audit
cargo audit

# Lock file change detection
git diff Cargo.lock | grep -E "^\[.*\].*version|name"
