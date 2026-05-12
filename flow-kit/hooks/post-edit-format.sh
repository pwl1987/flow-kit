#!/bin/bash
set -euo pipefail
# post-edit-format.sh — PostToolUse hook: 自动格式化代码
# v1.12.17 P1 修复: 简化 PROJECT_DIR 解析 + date 兼容性
# Reference: Claude Code hooks 社区最佳实践

INPUT=$(cat)

# 获取项目目录
if echo "$INPUT" | jq -e '.' >/dev/null 2>&1; then
    PROJECT_DIR="${PROJECT_DIR:-$(echo "$INPUT" | jq -r '.project_dir // empty')}"
    if [[ -z "$PROJECT_DIR" || "$PROJECT_DIR" == "empty" ]]; then
        PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    fi
else
    PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
fi

# 引入统一错误处理框架
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PROJECT_DIR/flow-kit/lib/error-handler.sh"

# 获取毫秒级时间戳（兼容 GNU date 和 macOS）
get_epoch_ms() {
    if date +%s%3N 2>/dev/null | grep -qE '^[0-9]+$'; then
        date +%s%3N
    elif python3 -c "import time; print(int(time.time() * 1000))" >/dev/null 2>&1; then
        python3 -c "import time; print(int(time.time() * 1000))"
    else
        perl -MTime::HiRes -e 'printf "%d\n", int(Time::HiRes::time() * 1000)'
    fi
}

START_TIME=$(get_epoch_ms)

TOOL=$(echo "$INPUT" | jq -r '.tool_name')

# 仅处理 Edit 和 Write
if [ "$TOOL" != "Edit" ] && [ "$TOOL" != "Write" ]; then
    exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# P1 修复：prettier 错误写入日志而非丢弃
if command -v npx &> /dev/null; then
    prettier_log="$PROJECT_DIR/.flow-kit/logs/prettier-errors.log"
    mkdir -p "$PROJECT_DIR/.flow-kit/logs"

    if ! timeout 3 npx prettier --write "$FILE_PATH" > "$prettier_log" 2>&1; then
        log_warn "prettier 格式化失败或超时: $FILE_PATH，详情: $prettier_log"
    fi
fi

# v1.12.10 改进：多语言格式化支持
detect_and_format() {
    local file="$1"

    case "$file" in
        *.py)
            if command -v black &>/dev/null; then
                timeout 5 black "$file" 2>/dev/null && return 0
            fi
            if command -v autopep8 &>/dev/null; then
                timeout 5 autopep8 --in-place "$file" 2>/dev/null && return 0
            fi
            ;;
        *.go)
            if command -v gofmt &>/dev/null; then
                timeout 5 gofmt -w "$file" 2>/dev/null && return 0
            fi
            ;;
        *.rs)
            if command -v rustfmt &>/dev/null; then
                timeout 5 rustfmt "$file" 2>/dev/null && return 0
            fi
            ;;
        *.sh|*.bash)
            if command -v shfmt &>/dev/null; then
                timeout 5 shfmt -w "$file" 2>/dev/null && return 0
            fi
            ;;
        *.java|*.c|*.cpp|*.h|*.hpp)
            if command -v clang-format &>/dev/null; then
                timeout 5 clang-format -i "$file" 2>/dev/null && return 0
            fi
            ;;
    esac
    return 1
}

detect_and_format "$FILE_PATH" || true

# hooks 执行遥测
END_TIME=$(get_epoch_ms)
ELAPSED=$((END_TIME - START_TIME))
mkdir -p "$PROJECT_DIR/.flow-kit/logs"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [post-edit-format] [OK] [${ELAPSED}ms]" >> "$PROJECT_DIR/.flow-kit/logs/hooks-execution.log" 2>/dev/null || true

exit 0

# v1.12.10 修复：URL 放在 bash 注释中避免被解析
# 参考来源：
# - Claude Code Hooks 官方文档：https://docs.anthropic.com/en/docs/claude-code/hooks
# - garrytan/gstack：https://github.com/garrytan/gstack