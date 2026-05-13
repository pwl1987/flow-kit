#!/bin/bash
set -euo pipefail
# pre-tool-guard.sh — PreToolUse hook: 阻止危险命令和敏感文件编辑
# v2.7.0 P1 修复: jq 精确提取 + DDL 高危检测
# v2.7.0 P1 修复: DDL 正则补全 RENAME TO + set -euo pipefail
# Reference: gstack /careful + Morph Claude Code Hooks

# 引入统一错误处理框架
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/error-handler.sh"

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

INPUT=$(cat)

# 检查输入是否为 JSON，若是则用 jq 精确提取
if echo "$INPUT" | jq -e '.' >/dev/null 2>&1; then
    TOOL=$(echo "$INPUT" | jq -r '.tool_name')
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
else
    # 非 JSON 输入，回退到直接使用
    log_warn "pre-tool-guard" "非 JSON 输入格式，使用回退解析 - 可能与新版 Claude Code 不兼容"
    TOOL=$(echo "$INPUT" | grep -oE '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4 || echo "")
    COMMAND=""
    FILE_PATH=""
fi

# 放行只读语句（DDL/DML 中的查询类操作）
# P2 修复：排除 SELECT INTO OUTFILE 等写文件操作
if echo "$COMMAND" | grep -qE '^(COMMENT|COMMENT ON|SHOW|DESCRIBE|EXPLAIN)[[:space:]]'; then
    exit 0
fi
if echo "$COMMAND" | grep -qE '^SELECT[[:space:]]' && ! echo "$COMMAND" | grep -qiE 'INTO[[:space:]]+(OUTFILE|DUMPFILE)'; then
    exit 0
fi

# 阻止危险的 Bash 命令
if [ "$TOOL" = "Bash" ]; then
    # 高危模式（必须拦截）
    if echo "$COMMAND" | grep -qiE 'git[[:space:]]+push[[:space:]]+--force|git[[:space:]]+reset[[:space:]]+--hard|DROP[[:space:]]+TABLE|dd[[:space:]]+if='; then
        echo "BLOCKED: 危险命令被 flow-kit 护栏拦截。请确认后重试。" >&2
        exit 2
    fi
    if echo "$COMMAND" | grep -qE '(^|[;&|[:space:]])rm[[:space:]]+([^;&|]*[[:space:]])?(-[^;&|]*r[^;&|]*f|-f[[:space:]]+-r|-r[[:space:]]+-f|--recursive[[:space:]]+--force|--force[[:space:]]+--recursive)([[:space:]]|$)'; then
        if ! echo "$COMMAND" | grep -qE '(^|[[:space:]])rm[[:space:]]+(-[^[:space:]]+[[:space:]]+)*(-rf|-fr|-r[[:space:]]+-f|-f[[:space:]]+-r)[[:space:]]+(\./)?(node_modules|dist|build|\.next)(/)?([[:space:]]|$)'; then
            echo "BLOCKED: 递归强制删除命令被 flow-kit 护栏拦截。请确认目标路径后重试。" >&2
            exit 2
        fi
    fi
    # P1 修复：DDL 高危操作（补全 RENAME TO 格式）
    # v2.7.0 修复：SQL 关键字间支持任意空白（DROP[[:space:]]+COLUMN 等）
    if echo "$COMMAND" | grep -qiE 'DROP[[:space:]]+COLUMN|ALTER[[:space:]]+TABLE[[:space:]]+[^[:space:]]+[[:space:]]+(RENAME|RENAME[[:space:]]+TO|RENAME[[:space:]]+COLUMN)|TRUNCATE[[:space:]]+TABLE'; then
        echo "BLOCKED: DDL 高危操作被 flow-kit 护栏拦截（DROP COLUMN/ALTER TABLE RENAME/TRUNCATE TABLE）。" >&2
        exit 2
    fi
fi

# 阻止编辑敏感文件
if [ "$TOOL" = "Edit" ] || [ "$TOOL" = "Write" ]; then
    if echo "$FILE_PATH" | grep -qE '(^|/)\.env([._-]|$)|migrations/|package-lock\.json|\.git/'; then
        echo "BLOCKED: $FILE_PATH 是受保护文件。" >&2
        exit 2
    fi
fi

# hooks 执行遥测
END_TIME=$(get_epoch_ms)
ELAPSED=$((END_TIME - START_TIME))
mkdir -p "$SCRIPT_DIR/../../.flow-kit/logs"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [pre-tool-guard] [OK] [${ELAPSED}ms]" >> "$SCRIPT_DIR/../../.flow-kit/logs/hooks-execution.log" 2>/dev/null || true

exit 0

# v2.7.0 修复：URL 放在 bash 注释中避免被解析
# 参考来源：
# - Claude Code Hooks 官方文档：https://docs.anthropic.com/en/docs/claude-code/hooks
# - garrytan/gstack：https://github.com/garrytan/gstack