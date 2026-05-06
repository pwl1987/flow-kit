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
