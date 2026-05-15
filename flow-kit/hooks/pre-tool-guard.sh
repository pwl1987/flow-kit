#!/bin/bash
# pre-tool-guard.sh — PreToolUse hook: 阻止危险命令和敏感文件编辑
# v2.7.1 修复: 移除 source 链，自包含轻量实现，防止 hook 卡死
# Reference: gstack /careful + Morph Claude Code Hooks

set -uo pipefail

# === CLI ===
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat << 'EOHELP'
pre-tool-guard — PreToolUse hook: 阻止危险命令和敏感文件编辑

用法: pre-tool-guard

无参数运行，hook 自动生效。

-h, --help  显示此帮助
EOHELP
    exit 0
fi

INPUT=$(cat)

# 轻量 JSON 解析（避免 source error-handler/time-utils/paths 链）
TOOL=""
COMMAND=""
FILE_PATH=""

if echo "$INPUT" | jq -e '.' >/dev/null 2>&1; then
    TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
fi

# 空 TOOL 直接放行
if [[ -z "$TOOL" ]]; then
    exit 0
fi

# 放行只读语句
if echo "$COMMAND" | grep -qE '^(COMMENT|COMMENT ON|SHOW|DESCRIBE|EXPLAIN)[[:space:]]'; then
    exit 0
fi
if echo "$COMMAND" | grep -qE '^SELECT[[:space:]]' && ! echo "$COMMAND" | grep -qiE 'INTO[[:space:]]+(OUTFILE|DUMPFILE)'; then
    exit 0
fi

# 阻止危险的 Bash 命令
if [[ "$TOOL" == "Bash" ]]; then
    # 高危模式
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
    # DDL 高危操作
    if echo "$COMMAND" | grep -qiE 'DROP[[:space:]]+COLUMN|ALTER[[:space:]]+TABLE[[:space:]]+[^[:space:]]+[[:space:]]+(RENAME|RENAME[[:space:]]+TO|RENAME[[:space:]]+COLUMN)|TRUNCATE[[:space:]]+TABLE'; then
        echo "BLOCKED: DDL 高危操作被 flow-kit 护栏拦截（DROP COLUMN/ALTER TABLE RENAME/TRUNCATE TABLE）。" >&2
        exit 2
    fi
fi

# 阻止编辑敏感文件
if [[ "$TOOL" == "Edit" || "$TOOL" == "Write" ]]; then
    if echo "$FILE_PATH" | grep -qE '(^|/)\.env([._-]|$)|migrations/|package-lock\.json|\.git/'; then
        echo "BLOCKED: $FILE_PATH 是受保护文件。" >&2
        exit 2
    fi
fi

exit 0
