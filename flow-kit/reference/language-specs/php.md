# PHP Engineer Reference

## Toolchain

- Lint: `php -l file.php` or `phpcs --standard=PSR12`
- Test: `phpunit` or `pest` (PHPUnit wrapper)
- Type check: `phpstan analyse` or `psalm`
- Build: `composer install` or `composer dump-autoload --optimize`

## Core Concepts

- **Weak typing** — PHP is loosely typed; strict types declared at file top
- **Request lifecycle** — Single request/response; no persistent state

## Debug Guide

- Use `var_dump()` / `print_r()` for quick debugging
- Xdebug: `php -d xdebug.mode=debug` for step debugging
- Error logging: `error_log()` or syslog for production

## Breaking Change Detection

Reference: `flow-kit/reference/breaking-change-rules.md`

### PHP-specific Patterns

| Pattern | Example | Severity |
|---------|---------|----------|
| Method signature change | `function foo(int $x)` -> `function foo(string $x)` | CRITICAL |
| Property type change | `public int $x` -> `public string $x` | HIGH |
| Interface removal | `implements Foo` removed | CRITICAL |
| Trait removal | `use FooTrait` removed | HIGH |
| Constant value change | `const X = 1` -> `const X = 2` | HIGH |

### Detection Commands

```bash
# API signature changes
phpstan analyse or psalm

# Dependency audit
composer audit

# Lock file change detection
git diff composer.lock | grep -E "^[+-].*version"
