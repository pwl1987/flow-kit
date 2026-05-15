#!/bin/bash
# post-edit-format.sh — PostToolUse hook: 自动格式化代码
# v2.8.2 修复: 移除所有 source 依赖，自包含轻量实现，防止进程爆炸
# Reference: Claude Code hooks 社区最佳实践

set -uo pipefail

INPUT=$(cat)

# 获取项目目录
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"
if [[ -z "$PROJECT_DIR" ]]; then
    PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

START_TIME=$(date +%s%3N 2>/dev/null || echo "0")

# === 并发限制（防资源耗尽） ===
LOCK_DIR="$PROJECT_DIR/.flow-kit/locks"
mkdir -p "$LOCK_DIR"

MAX_JOBS=4

# 简单并发检查 — 用文件计数
for ((waited=0; waited<10; waited++)); do
    RUNNING=$(ls "$LOCK_DIR"/*.lock 2>/dev/null | wc -l)
    if (( RUNNING < MAX_JOBS )); then
        break
    fi
    sleep 0.5
done
if (( waited >= 10 )); then
    exit 0
fi

# 解析 JSON — 轻量提取
TOOL=""
FILE_PATH=""
if command -v jq &>/dev/null && echo "$INPUT" | jq -e '.' >/dev/null 2>&1; then
    TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
fi

# 仅处理 Edit 和 Write
if [[ "$TOOL" != "Edit" && "$TOOL" != "Write" ]]; then
    exit 0
fi

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# === 文件锁（防同一文件重复格式化） ===
FILE_LOCK="$LOCK_DIR/$(echo "$FILE_PATH" | md5sum | cut -d' ' -f1).lock"
if [[ -f "$FILE_LOCK" ]]; then
    LOCK_AGE=$(($(date +%s) - $(stat -c %Y "$FILE_LOCK" 2>/dev/null || echo 0)))
    if (( LOCK_AGE < 30 )); then
        exit 0
    fi
    rm -f "$FILE_LOCK"
fi
touch "$FILE_LOCK"

cleanup() { rm -f "$FILE_LOCK"; }
trap cleanup EXIT

# v3.5.2: prettier 仅对 JS/TS/CSS/JSON/MD 且有 .prettierrc 时启用，超时 1s
case "$FILE_PATH" in
    *.js|*.ts|*.jsx|*.tsx|*.css|*.json|*.md)
        if [[ -f "$PROJECT_DIR/.prettierrc" || -f "$PROJECT_DIR/.prettierrc.json" ]]; then
            command -v prettier &>/dev/null && timeout 1 prettier --write "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
esac

# 多语言格式化支持
case "$FILE_PATH" in
    *.py)
        command -v black &>/dev/null && timeout 5 black "$FILE_PATH" 2>/dev/null || true
        ;;
    *.go)
        command -v gofmt &>/dev/null && timeout 5 gofmt -w "$FILE_PATH" 2>/dev/null || true
        ;;
    *.rs)
        command -v rustfmt &>/dev/null && timeout 5 rustfmt "$FILE_PATH" 2>/dev/null || true
        ;;
    *.sh|*.bash)
        command -v shfmt &>/dev/null && timeout 5 shfmt -w "$FILE_PATH" 2>/dev/null || true
        ;;
    *.java|*.c|*.cpp|*.h|*.hpp)
        command -v clang-format &>/dev/null && timeout 5 clang-format -i "$FILE_PATH" 2>/dev/null || true
        ;;
esac

# 遥测 — 轻量实现
END_TIME=$(date +%s%3N 2>/dev/null || echo "0")
ELAPSED=$((END_TIME - START_TIME))
LOGS_DIR="$PROJECT_DIR/.flow-kit/logs"
mkdir -p "$LOGS_DIR"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [post-edit-format] [OK] [${ELAPSED}ms]" >> "$LOGS_DIR/hooks-execution.log" 2>/dev/null || true

exit 0
