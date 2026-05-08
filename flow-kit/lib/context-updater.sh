#!/bin/bash
# context-updater.sh — 上下文增量更新
# v1.12.10 新增：实现 /flow-kit:update-context 命令

set -euo pipefail

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
DEFAULT_CONTEXT="${1:-.planning/CONTEXT.md}"
CHANGE_DESC="${2:-}"
PHASE="${3:-unknown}"

#------------------------------------------------------------------------------
# 初始化上下文文件
#------------------------------------------------------------------------------
init_context_file() {
    local context_file="$1"

    if [ -f "$context_file" ]; then
        return 0
    fi

    mkdir -p "$(dirname "$context_file")"

    cat > "$context_file" << 'EOF'
# Context

## Decisions
| ID | Decision | Rationale | Date |
|----|----------|-----------|------|

## Blockers
| Blocker | Status | Since |
|---------|--------|-------|

## State
**Phase**: N/A
**Last Updated**: N/A

## Change Log
| Date | Change | Phase |
|------|--------|-------|
EOF
}

#------------------------------------------------------------------------------
# 检查 Change Log 表头是否存在
#------------------------------------------------------------------------------
has_change_log_header() {
    local context_file="$1"
    grep -q '^\| Date | Change | Phase |' "$context_file" 2>/dev/null
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local context_file="${1:-$DEFAULT_CONTEXT}"
    local change_desc="${2:-$CHANGE_DESC}"
    local phase="${3:-$PHASE}"

    if [ -z "$change_desc" ]; then
        echo "[ERROR] 变更描述不能为空"
        echo "用法: context-updater.sh <context_file> <change_desc> <phase>"
        return 1
    fi

    echo "=========================================="
    echo "Context Updater"
    echo "=========================================="
    echo "Context: $context_file"
    echo "Change: $change_desc"
    echo "Phase: $phase"
    echo ""

    init_context_file "$context_file"

    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if ! has_change_log_header "$context_file"; then
        cat >> "$context_file" << EOF

## Change Log
| Date | Change | Phase |
|------|--------|-------|
EOF
    fi

    local temp_file="${context_file}.tmp"

    awk -v ts="$timestamp" -v desc="$change_desc" -v ph="$phase" '
    /^## Change Log/ { in_log=1 }
    /^\| Date/ && in_log && !header_done {
        print
        header_done=1
        next
    }
    /^\|/ && in_log && header_done && !first_row_done {
        print
        printf "| %s | %s | %s |\n", ts, desc, ph
        first_row_done=1
        next
    }
    { print }
    ' "$context_file" > "$temp_file"

    if [ ! -s "$temp_file" ]; then
        echo "[ERROR] 更新失败，临时文件为空"
        rm -f "$temp_file"
        return 1
    fi

    mv "$temp_file" "$context_file"

    echo "[OK] Context updated: $context_file"
    echo ""
    echo "New entry added:"
    echo "| $timestamp | $change_desc | $phase |"
}

main "$@"