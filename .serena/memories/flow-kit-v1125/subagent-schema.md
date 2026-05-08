# subagent-result.schema.json

## P0 Phase Executor JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "SubagentResult",
  "type": "object",
  "required": ["id", "role", "status", "summary", "started_at", "completed_at"],
  "properties": {
    "id": { "type": "string", "pattern": "^agent-[0-9]+$" },
    "role": { "enum": ["Code Executor", "Code Reviewer", "Test Runner"] },
    "status": { "enum": ["SUCCESS", "FAILED", "PARTIAL", "QUEUED"] },
    "summary": { "type": "string" },
    "files_modified": { "type": "array", "items": { "type": "string" } },
    "files_reviewed": { "type": "array", "items": { "type": "string" } },
    "tests_run": { "type": "integer", "minimum": 0 },
    "tests_passed": { "type": "integer", "minimum": 0 },
    "issues": { "type": "array" },
    "context_consumed_pct": { "type": "number", "minimum": 0, "maximum": 100 },
    "started_at": { "type": "string", "format": "date-time" },
    "completed_at": { "type": "string", "format": "date-time" },
    "duration_ms": { "type": "integer", "minimum": 0 }
  }
}
```

## 位置
`flow-kit/lib/validation/schemas/subagent-result.schema.json`
