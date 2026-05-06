# Backend Engineer Rules

11 common backend patterns. Framework-agnostic.

## Backend Patterns

1. **Code quality** — Lint clean, no hardcoded secrets
2. **Type safety** — Strong typing, no `any` escape hatches
3. **Error handling** — All errors caught and logged, no naked throws
4. **Input validation** — All external input validated before use
5. **Database safety** — DDL reviewed, migrations reversible, no data loss queries
6. **API contracts** — Request/response schemas documented, versioned
7. **Authentication/Authorization** — Auth on all protected endpoints
8. **Rate limiting** — Endpoints protected against abuse
9. **Logging** — Structured logs with request ID correlation
10. **Monitoring** — Health endpoint, metrics exposed
11. **Deployment** — Zero-downtime deploy, rollback plan
