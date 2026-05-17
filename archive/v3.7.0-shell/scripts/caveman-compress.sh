#!/bin/bash
# caveman-compress.sh — 上下文压缩脚本
# v2.7.0 新增：实现 caveman 级别压缩（保留核心决策）

set -euo pipefail

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DEFAULT_INPUT=".planning/phases"
readonly DEFAULT_OUTPUT=".planning/CONTEXT.md"
readonly MAX_LINES=500

#------------------------------------------------------------------------------
# 颜色输出
#------------------------------------------------------------------------------
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly NC='\033[0m'

#------------------------------------------------------------------------------
# 提取关键决策
#------------------------------------------------------------------------------
extract_decisions() {
    local input_dir="$1"

    local all_decisions=()

    if [[ ! -d "$input_dir" ]]; then
        return 1
    fi

    while IFS= read -r -d '' file; do
        local basename
        basename=$(basename "$file")
        if [[ "$basename" =~ [Tt][Ee][Mm][Pp][Ll][Aa][Tt][Ee] ]]; then
            continue
        fi

        while IFS= read -r line; do
            if [[ "$line" =~ ^[Dd]ecision|决定|决策 ]]; then
                all_decisions+=("$line")
            fi
        done < "$file"
    done < <(find "$input_dir" -name "*.md" -type f -print0)

    if [[ ${#all_decisions[@]} -gt 0 ]]; then
        echo "## Key Decisions"
        echo ""
        for decision in "${all_decisions[@]}"; do
            echo "- $decision"
        done
        echo ""
    fi
}

#------------------------------------------------------------------------------
# 提取待办事项
#------------------------------------------------------------------------------
extract_todos() {
    local input_dir="$1"

    local all_todos=()

    if [[ ! -d "$input_dir" ]]; then
        return 1
    fi

    while IFS= read -r -d '' file; do
        local basename
        basename=$(basename "$file")
        if [[ "$basename" =~ [Tt][Ee][Mm][Pp][Ll][Aa][Tt][Ee] ]]; then
            continue
        fi

        while IFS= read -r line; do
            if [[ "$line" =~ ^[-*+][[:space:]]*(\[.\])?[[:space:]]*(TODO|FIXME|待办|修复) ]]; then
                all_todos+=("$line")
            fi
        done < "$file"
    done < <(find "$input_dir" -name "*.md" -type f -print0)

    if [[ ${#all_todos[@]} -gt 0 ]]; then
        echo "## Pending Items"
        echo ""
        for todo in "${all_todos[@]}"; do
            echo "$todo"
        done
        echo ""
    fi
}

#------------------------------------------------------------------------------
# 提取文件变更
#------------------------------------------------------------------------------
extract_file_changes() {
    local input_dir="$1"

    local all_changes=()

    if [[ ! -d "$input_dir" ]]; then
        return 1
    fi

    while IFS= read -r -d '' file; do
        local basename
        basename=$(basename "$file")
        if [[ "$basename" =~ [Tt][Ee][Mm][Pp][Ll][Aa][Tt][Ee] ]]; then
            continue
        fi

        while IFS= read -r line; do
            if [[ "$line" =~ ^[-*+][[:space:]]+.*\.(ts|js|py|go|rs|java|cpp|c|h)$ ]]; then
                all_changes+=("$line")
            fi
        done < "$file"
    done < <(find "$input_dir" -name "*.md" -type f -print0)

    if [[ ${#all_changes[@]} -gt 0 ]]; then
        echo "## File Changes"
        echo ""
        for change in "${all_changes[@]}"; do
            echo "$change"
        done
        echo ""
    fi
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local input_dir="${1:-$DEFAULT_INPUT}"
    local output_file="${2:-$DEFAULT_OUTPUT}"

    echo -e "${GREEN}[INFO]${NC} Context Compression"
    echo "Input: $input_dir"
    echo "Output: $output_file"
    echo ""

    if [[ ! -d "$input_dir" ]]; then
        echo -e "${RED}[ERROR]${NC} Input directory not found: $input_dir"
        return 1
    fi

    mkdir -p "$(dirname "$output_file")"

    {
        echo "# Context Summary (Compressed)"
        echo ""
        echo "*Generated: $(date '+%Y-%m-%d %H:%M:%S')*"
        echo ""
        echo "*This is a compressed summary of project context.*"
        echo "*Original files are preserved in: $input_dir*"
        echo ""

        extract_decisions "$input_dir"
        extract_todos "$input_dir"
        extract_file_changes "$input_dir"

        echo "---"
        echo "*End of compressed context*"
    } > "$output_file"

    local line_count
    line_count=$(wc -l < "$output_file")

    echo -e "${GREEN}[OK]${NC} Compressed context written to: $output_file"
    echo "Lines: $line_count"

    if [[ "$line_count" -gt "$MAX_LINES" ]]; then
        echo -e "${YELLOW}[WARN]${NC} Output exceeds $MAX_LINES lines"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi