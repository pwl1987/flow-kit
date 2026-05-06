# ADR Template

Architecture Decision Record template. 5 fields with reversibility guidance.

## Template

```
# ADR-[N]: [Title]

**Status:** Accepted | Deprecated | Superseded by ADR-[N]

## Context
[Problem statement — what prompted this decision]

## Decision
[What was decided — specific and actionable]

## Consequences
- **Immediate:** [What happens now]
- **Long-term:** [What changes over time]
- **Reversed:** [How to undo this decision if needed]
```

## Reversibility Guide

- Every decision should be reversible
- Document the rollback path in **Reversed**
- If reversal is impossible, require explicit approval
- Status values: `Accepted` | `Deprecated` | `Superseded by ADR-[N]`
