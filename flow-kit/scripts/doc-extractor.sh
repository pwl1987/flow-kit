#!/bin/bash
# doc-extractor.sh — API 文档自动提取
# v3.5.3 新增
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT="${1:-$PROJECT_DIR/API-REFERENCE.md}"

{
echo "# API Reference"
echo ""
echo "> 自动生成: $(date -u +%Y-%m-%d)"
echo "> 版本: v3.5.3"
echo ""
echo "---"
echo ""

# lib 模块
echo "## lib/ 模块"
echo ""

for f in "$PROJECT_DIR"/lib/*.sh; do
    [[ -f "$f" ]] || continue
    name=$(basename "$f" .sh)
    echo "### $name"
    echo ""

    # 提取文件级描述注释（前3行中第一个 # 描述）
    desc=$(head -3 "$f" | awk '/^# [^!]/ {gsub(/^# /, ""); print; exit}')
    [[ -n "$desc" ]] && echo "$desc"
    echo ""

    # 提取函数列表：提取 function_name 模式
    grep -Eo '^[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)' "$f" 2>/dev/null | \
    while read -r line; do
        fn="${line%"${line##*[![:space:]]}"}"  # 去除尾部空白
        fn="${fn%"()"}"  # 去除 ()
        [[ -n "$fn" ]] && echo "- \`$fn()\`"
    done

    echo ""
done

# scripts 模块（排除子模块）
echo "## scripts/ 模块"
echo ""

for f in "$PROJECT_DIR"/scripts/*.sh; do
    [[ -f "$f" ]] || continue
    name=$(basename "$f" .sh)
    # 跳过 dispatch- 和 tmux- 子模块
    [[ "$name" =~ ^(dispatch|tmux)- ]] && continue

    echo "### $name"
    echo ""

    # 提取文件级描述注释
    desc=$(head -5 "$f" | awk '/^# [^!]/ {gsub(/^# /, ""); print; exit}')
    [[ -n "$desc" ]] && echo "$desc"
    echo ""

    # 检查是否有 --help 选项
    if grep -q 'getopts\|--help\|-h)' "$f" 2>/dev/null; then
        echo "\`bash $name --help\` 查看用法"
        echo ""
    fi

    echo ""
done

# hooks 模块
echo "## hooks/ 模块"
echo ""

for f in "$PROJECT_DIR"/hooks/*.sh; do
    [[ -f "$f" ]] || continue
    name=$(basename "$f" .sh)
    echo "### $name"
    echo ""

    # 提取文件级描述注释
    desc=$(head -3 "$f" | awk '/^# [^!]/ {gsub(/^# /, ""); print; exit}')
    [[ -n "$desc" ]] && echo "$desc"

    echo ""
done

echo "文档生成完成"
} > "$OUTPUT"

echo "API Reference 已生成: $OUTPUT"