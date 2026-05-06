--- BEGIN flow-kit/mcp/external-lint-adapter.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】

## 优先级

本文件定义外部 lint 工具适配规则。适配器将外部 linter 输出转换为 flow-kit 格式。

---

# External Lint Adapter (MCP-52)

## Purpose

Adapt external lint tools (eslint, prettier, tslint) to flow-kit format. Standardize lint results across different tools.

## Adapter Pattern

```
1. Detect available linters (package.json, config files)
2. Run linter with --format=json
3. Transform output to flow-kit format
4. Return structured results
```

## Supported Linters

### ESLint

```bash
eslint . --format=json --max-warnings=0
```

### Prettier

```bash
prettier --check . --format json
```

### TSLint

```bash
tslint -t json .
```

### Additional Support

- `golangci-lint` — Go linter
- `phpstan` — PHP static analyzer
- `pylint` — Python linter
- `rustfmt` / `clippy` — Rust linters

## Output Format

All adapters convert to unified flow-kit format:

```typescript
interface LintResult {
  file: string;      // Relative path
  line: number;     // Line number
  column?: number;  // Column (optional)
  severity: "flag" | "block" | "warning" | "error";
  message: string;  // Human-readable message
  rule?: string;    // Linter rule ID (if available)
}
```

## Severity Mapping

| Linter Output | flow-kit Severity |
|---------------|-------------------|
| Error | `block` (must fix) |
| Warning | `flag` (should fix) |
| Info | `flag` (optional fix) |

## Fallback Behavior

If no linter found:
```
1. Check for package.json scripts: lint, lint:fix
2. Check for config files: .eslintrc*, .prettierrc*, tslint.json
3. If none found: use built-in basic checks
   - Trailing whitespace
   - Console.log/debugger statements
   - TODO/FIXME comments
```

## Integration with M-health Command

The `/flow-kit:health` command calls this adapter:

```
/flow-kit:health
  → Run all available linters
  → Aggregate results
  → Display formatted output
  → Exit code = blocked issues count
```

---

## Key Links

- **MCP tools config:** `flow-kit/mcp/mcp-tools-config.md` (tier definitions)
- **Git integration:** `flow-kit/mcp/git-integration.md` (post-commit lint validation)
- **Health command:** `flow-kit/commands/M-health.md` (lint integration point)
- **Constitution:** `flow-kit/config/constitution.md` (lint rules override)

--- END flow-kit/mcp/external-lint-adapter.md ---