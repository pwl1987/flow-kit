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
