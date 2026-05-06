# TDD Standard

Test-Driven Development workflow, naming conventions, and skip criteria.

## The Cycle

1. **Red** — Write failing test. One assertion only.
2. **Green** — Minimal code to pass. No optimization.
3. **Refactor** — Improve code, maintain passing tests.

## Naming Conventions

- Unit: `[unit]-[behavior]` (e.g., `calculator-adds-two-numbers`)
- Integration: `[flow]-[outcome]` (e.g., `user-submits-form-success`)
- E2E: `[user-journey]-[result]` (e.g., `customer-completes-purchase`)

## When to Skip TDD

- Spike / exploration
- Trivial changes (typos, docs)
- Config-only changes
- When test maintenance cost > test value

## Integration with verification.md

- TDD standard defines the WHAT of testing
- verification.md skill defines the HOW of verification
- They are orthogonal — TDD for writing, verification for validating
