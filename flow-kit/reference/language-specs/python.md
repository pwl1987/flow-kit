# Python Engineer Reference

## Toolchain

- Lint: `flake8 .` or `pylint .` or `ruff check .`
- Test: `pytest` or `unittest discover`
- Type check: `mypy .` or `pyright`
- Build: `pip install -e .` or `poetry install` (no compile step)

## Core Concepts

- **Duck typing** — If it walks like a duck...; runtime polymorphism over static typing
- **Whitespace significance** — Indentation defines scope; no braces

## Debug Guide

- Use `python -m pdb script.py` for CLI debugging
- VS Code debug config: launch.json with "python" debug type
- Enable type hints: `from __future__ import annotations`

## Breaking Change Detection

Reference: `flow-kit/reference/breaking-change-rules.md`

### Python-specific Patterns

| Pattern | Example | Severity |
|---------|---------|----------|
| Function signature change | `def foo(x: int)` -> `def foo(x: str)` | HIGH |
| Abstract method added | New `@abstractmethod` added | HIGH |
| Import path change | `from foo import Bar` -> `from baz import Bar` | HIGH |
| Return type change | `-> int` -> `-> str` | HIGH |
| Required parameter added | `def foo()` -> `def foo(x)` | HIGH |

### Detection Commands

```bash
# API signature changes
mypy . or pyright

# Dependency audit
pip audit or poetry show --outdated

# Lock file change detection
git diff poetry.lock | grep -E "^\[.*\].*version"
