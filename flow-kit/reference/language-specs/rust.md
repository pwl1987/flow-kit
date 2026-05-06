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
