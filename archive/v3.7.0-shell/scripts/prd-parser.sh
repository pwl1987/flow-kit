#!/usr/bin/env bash
# prd-parser.sh — PRD 文件预处理，提取结构化信息
# v3.6.0 新增
set -euo pipefail

command -v jq &>/dev/null || { echo "[prd-parser] 错误：需要 jq" >&2; exit 1; }

#------------------------------------------------------------------------------
# 格式检测
#------------------------------------------------------------------------------
detect_format() {
    local file="$1"
    local ext="${file##*.}"
    case "$ext" in
        md|markdown) echo "markdown"; return ;;
        json) echo "json"; return ;;
    esac
    # 内容嗅探
    local first
    first=$(head -1 "$file" 2>/dev/null || echo "")
    if [[ "$first" == "{"* ]]; then
        echo "json"
    elif [[ "$first" == "#"* ]] || grep -q '^#' "$file" 2>/dev/null; then
        echo "markdown"
    else
        echo "unknown"
    fi
}

#------------------------------------------------------------------------------
# Markdown 解析
#------------------------------------------------------------------------------
parse_markdown() {
    local file="$1"

    # 用 awk 一次性提取，输出 JSONL 格式
    awk '
    BEGIN { list_line=0; list_count=0; prev="" }
    /^#{1,4}[[:space:]]+/ {
        flush_list()
        match($0, /^#+/)
        lvl = RLENGTH
        text = substr($0, RLENGTH + 2)
        gsub(/"/, "\\\"", text)
        printf "{\"type\":\"heading\",\"level\":%d,\"text\":\"%s\",\"line\":%d}\n", lvl, text, NR
        prev = $0; next
    }
    /^[[:space:]]*[-\*][[:space:]]+/ {
        if (list_line == 0) list_line = NR
        list_count++
        item = $0
        sub(/^[[:space:]]*[-\*][[:space:]]+/, "", item)
        gsub(/"/, "\\\"", item)
        printf "{\"type\":\"list_item\",\"line\":%d,\"item\":\"%s\",\"list_start\":%d}\n", NR, item, list_line
        prev = $0; next
    }
    /^[[:space:]]*[0-9]+\.[[:space:]]+/ {
        if (list_line == 0) list_line = NR
        list_count++
        item = $0
        sub(/^[[:space:]]*[0-9]+\.[[:space:]]+/, "", item)
        gsub(/"/, "\\\"", item)
        printf "{\"type\":\"list_item\",\"line\":%d,\"item\":\"%s\",\"list_start\":%d}\n", NR, item, list_line
        prev = $0; next
    }
    /^\|.+\|$/ {
        flush_list()
        if ($0 ~ /^\|[-[:space:]:]+\|$/) { prev = $0; next }
        row = $0
        sub(/^\|/, "", row); sub(/\|$/, "", row)
        n = split(row, cells, "|")
        is_header = (prev !~ /^\|/)
        printf "{\"type\":\"table_%s\",\"line\":%d,\"cells\":[", (is_header ? "header" : "data"), NR
        for (i = 1; i <= n; i++) {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", cells[i])
            gsub(/"/, "\\\"", cells[i])
            if (i > 1) printf ","
            printf "\"%s\"", cells[i]
        }
        printf "]}\n"
        prev = $0; next
    }
    { flush_list(); prev = $0 }
    END { flush_list() }
    function flush_list() {
        if (list_count > 0) {
            printf "{\"type\":\"list_end\",\"line\":%d,\"count\":%d}\n", list_line, list_count
        }
        list_line = 0; list_count = 0
    }
    ' "$file" | jq -s '
        def tables:
            [.[] | select(.type == "table_header" or .type == "table_data")] |
            if length == 0 then []
            else
                [foreach .[] as $x ({cur: null, result: []};
                    if $x.type == "table_header" then
                        .cur = {line: $x.line, headers: $x.cells, rows: []} |
                        .result += [.cur]
                    else
                        .cur.rows += [$x.cells]
                    end;
                    .result
                )] | last
            end;
        {
            headings: [.[] | select(.type == "heading") | {level, text, line}],
            lists: ([.[] | select(.type == "list_item")] | group_by(.list_start) | map({line: .[0].list_start, items: map(.item)})),
            tables: tables
        }
    ' 2>/dev/null || echo '{"headings":[],"lists":[],"tables":[]}'
}

#------------------------------------------------------------------------------
# JSON 解析
#------------------------------------------------------------------------------
parse_json_doc() {
    local file="$1"
    local top_keys
    top_keys=$(jq -r 'keys[]' "$file" 2>/dev/null | jq -R -s 'split("\n") | map(select(length > 0))' || echo "[]")

    local nested
    nested=$(jq -r '
        to_entries |
        map(select(.value | type == "object")) |
        map({key: .key, keys: (.value | keys)})
    ' "$file" 2>/dev/null || echo "[]")

    jq -n --argjson tk "$top_keys" --argjson n "$nested" \
        '{"top_level_keys": $tk, "nested": $n}'
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local file="${1:-}"

    if [[ -z "$file" ]]; then
        echo "[prd-parser] 错误：需要文件路径参数" >&2
        exit 1
    fi

    if [[ ! -f "$file" ]]; then
        echo "[prd-parser] 错误：文件不存在: $file" >&2
        exit 1
    fi

    # 空文件
    if [[ ! -s "$file" ]]; then
        jq -n '{format: "empty", source: "", structure: {headings: [], lists: [], tables: []}}'
        exit 0
    fi

    local format
    format=$(detect_format "$file")

    local structure="{}"
    case "$format" in
        markdown)
            structure=$(parse_markdown "$file")
            ;;
        json)
            structure=$(parse_json_doc "$file")
            ;;
        *)
            echo "[prd-parser] 错误：不支持的格式: $format" >&2
            exit 1
            ;;
    esac

    jq -n --arg fmt "$format" --arg src "$file" --argjson str "$structure" \
        '{format: $fmt, source: $src, structure: $str}'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
