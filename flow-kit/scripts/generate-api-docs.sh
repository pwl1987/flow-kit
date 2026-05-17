#!/bin/bash
# generate-api-docs.sh — 从脚本头部注释生成 API 文档
# v3.7.0 新增

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="${1:-$ROOT_DIR/docs/api-reference.md}"

usage() {
    cat << 'EOF'
generate-api-docs.sh — 生成 API 文档

用法:
  generate-api-docs.sh                默认输出到 docs/api-reference.md
  generate-api-docs.sh <output-file>  指定输出路径
  generate-api-docs.sh -h             显示帮助
EOF
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { usage; exit 0; }

mkdir -p "$(dirname "$OUTPUT_FILE")" 2>/dev/null || true

{
    echo "# flow-kit API 参考"
    echo ""
    echo "_自动生成: $(date -u +%Y-%m-%d 2>/dev/null || date)_"
    echo ""

    for f in "$SCRIPT_DIR"/*.sh; do
        [[ -f "$f" ]] || continue
        local name
        name=$(basename "$f" .sh)

        echo "## $name"
        echo ""

        # 提取头部注释（前 10 行内连续 # 行）
        local in_header=0
        while IFS= read -r line; do
            if [[ "$line" =~ ^#\ (.*) ]]; then
                local content="${BASH_REMATCH[1]}"
                # 跳过 shebang 行
                [[ "$content" == "!"* ]] && continue
                echo "$content"
                in_header=1
            elif [[ $in_header -eq 1 ]]; then
                break
            fi
        done < <(head -20 "$f")

        echo ""
        echo "**路径**: \`scripts/${name}.sh\`"
        echo ""
    done
} > "$OUTPUT_FILE"

echo "[api-docs] 生成到 $OUTPUT_FILE"
