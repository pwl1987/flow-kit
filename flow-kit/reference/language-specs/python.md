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
