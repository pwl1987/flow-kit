## Go Engineer Reference

### Toolchain
- Lint: `golangci-lint run` or `go vet ./...`
- Test: `go test ./...` (go test -v -race)
- Type check: `go build ./...` (compiler is also type checker)
- Build: `go build -o output .` or `go install`

### Core Concepts
- **Goroutines** — Lightweight threads; `go func()` spawns concurrent execution
- **Channels** — typed pipes for goroutine communication; `chan` keyword

### Debug Guide
- Use `go run` for quick testing; `go build` for production
- Delve debugger: `dlv debug` for step-by-step debugging
- Race detector: `go test -race` to detect data races

## Breaking Change Detection

Reference: `flow-kit/reference/breaking-change-rules.md`

### Go-specific Patterns

| Pattern | Example | Severity |
|---------|---------|----------|
| Function signature change | `func Foo(int)` -> `func Foo(string)` | CRITICAL |
| Interface removal | `type Foo interface{}` removed | CRITICAL |
| Package path change | `import "foo/bar"` -> `import "baz/bar"` | HIGH |
| Export removal | `func Exported()` -> `func unexported()` | HIGH |
| Struct field type change | `Field int` -> `Field string` | HIGH |

### Detection Commands

```bash
# API signature changes
go build ./...

# Dependency audit
go mod verify

# Lock file change detection
git diff go.sum | grep -E "^[+-]?[a-z0-9.]+"
