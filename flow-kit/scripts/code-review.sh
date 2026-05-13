#!/bin/bash
# code-review.sh — v3.3.0 P2 自动化代码评审
# 扫描目标目录，运行语法检查 + 安全扫描，按严重度分类，生成 REVIEW.md

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/preflight.sh"
source "$SCRIPT_DIR/../lib/session-state.sh"

require_jq

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
TARGET_DIR=""
OUTPUT_FILE="REVIEW.md"
THRESHOLD="low"
HAS_SHELLCHECK=false
HAS_SHFMT=false

# 临时文件
REVIEW_TMP_DIR=""
trap 'rm -rf "${REVIEW_TMP_DIR:-}"' EXIT

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
code-review.sh — 自动化代码评审

用法:
  ./code-review.sh [选项]

选项:
  --dir <目录>       目标目录（默认: 当前项目）
  --output <文件>    输出文件（默认: REVIEW.md）
  --threshold <级别> 最低报告级别: low|medium|high|critical（默认: low）
  -h, --help         显示帮助信息

功能:
  1. 文件扫描（.sh/.md/.json）
  2. 语法检查（bash -n + shellcheck）
  3. 安全扫描（复用 security-scanner.sh）
  4. 严重度分类（严重P0/高P1/中P2/低P3）
  5. 生成 REVIEW.md 评审报告

示例:
  ./code-review.sh --dir .
  ./code-review.sh --dir flow-kit/ --output REPORT.md
  ./code-review.sh --threshold high
EOF
}

#------------------------------------------------------------------------------
# 参数解析
#------------------------------------------------------------------------------
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --dir)        TARGET_DIR="$2"; shift 2 ;;
            --output)     OUTPUT_FILE="$2"; shift 2 ;;
            --threshold)  THRESHOLD="$2"; shift 2 ;;
            -h|--help)    show_help; exit 0 ;;
            *)            echo "[review] 未知选项: $1" >&2; exit 1 ;;
        esac
    done

    TARGET_DIR="${TARGET_DIR:-$FLOW_KIT_DIR}"
    OUTPUT_FILE="${OUTPUT_FILE:-$PROJECT_DIR/REVIEW.md}"

    # 标准化路径
    if [[ "$OUTPUT_FILE" != /* ]]; then
        OUTPUT_FILE="$PROJECT_DIR/$OUTPUT_FILE"
    fi
}

#------------------------------------------------------------------------------
# 扫描目标文件
#------------------------------------------------------------------------------
scan_targets() {
    local dir="$1"
    local files
    files=$(find "$dir" \
        -type f \( -name '*.sh' -o -name '*.md' -o -name '*.json' \) \
        -not -path '*/.git/*' \
        -not -path '*/.flow-kit/tmp/*' \
        -not -path '*/.flow-kit/archive/*' \
        -not -path '*/node_modules/*' \
        -not -path '*/.claude/commands/*' \
        2>/dev/null || true)
    echo "$files"
}

#------------------------------------------------------------------------------
# 语法检查
#------------------------------------------------------------------------------
run_syntax_check() {
    local findings_file="$REVIEW_TMP_DIR/syntax-findings.json"
    echo '[]' > "$findings_file"

    local sh_files
    sh_files=$(find "$TARGET_DIR" \
        -type f -name '*.sh' \
        -not -path '*/.git/*' \
        -not -path '*/.flow-kit/tmp/*' \
        2>/dev/null || true)

    local total=0
    local failed=0

    for file in $sh_files; do
        total=$((total + 1))
        local rel="${file#$TARGET_DIR/}"

        # bash -n 语法检查
        if ! bash -n "$file" 2>"$REVIEW_TMP_DIR/syntax-err.txt"; then
            local err_msg
            err_msg=$(head -1 "$REVIEW_TMP_DIR/syntax-err.txt" 2>/dev/null || echo "syntax error")
            failed=$((failed + 1))

            local tmp
            tmp=$(jq --arg file "$rel" --arg msg "$err_msg" \
                '. + [{file: $file, line: 0, code: "bash-n", message: $msg, severity: "critical", priority: "P0"}]' \
                "$findings_file")
            echo "$tmp" > "$findings_file"
            continue
        fi

        # run shellcheck if available
        if [ "$HAS_SHELLCHECK" = true ]; then
            local sc_output
            sc_output=$(shellcheck --format=json "$file" 2>/dev/null || true)
            if [ -n "$sc_output" ] && [ "$sc_output" != "[]" ]; then
                local sc_findings
                sc_findings=$(echo "$sc_output" | jq -c '
                    [.[] | {
                        file: $file,
                        line: .line,
                        code: ("SC" + (.code | tostring)),
                        message: .message,
                        severity: (if .level == "error" then "high"
                                   elif .level == "warning" then "medium"
                                   else "low" end),
                        priority: (if (.code >= 2000 and .code < 3000) then "P1"
                                   elif (.code >= 1000 and .code < 2000) then "P3"
                                   else "P2" end)
                    }]
                ' --arg file "$rel" 2>/dev/null || echo '[]')

                if [ "$sc_findings" != "[]" ]; then
                    local tmp
                    tmp=$(jq -s 'add' "$findings_file" <(echo "$sc_findings") 2>/dev/null || echo '[]')
                    echo "$tmp" > "$findings_file"
                fi
            fi
        fi
    done

    echo "[review] 语法检查: $total 文件, $failed 语法错误"
    cat "$findings_file"
}

#------------------------------------------------------------------------------
# 安全扫描
#------------------------------------------------------------------------------
run_security_scan() {
    local findings_file="$REVIEW_TMP_DIR/security-findings.json"
    echo '[]' > "$findings_file"

    # 扫描硬编码密钥
    local secret_patterns=(
        'api_key\s*=\s*["'"'"'][^"'"'"'\s]{8,}["'"'"']'
        'secret\s*=\s*["'"'"'][^"'"'"'\s]{8,}["'"'"']'
        'password\s*=\s*["'"'"'][^"'"'"'\s]{4,}["'"'"']'
        'AWS_ACCESS_KEY'
        'AWS_SECRET_KEY'
        'sk-[0-9a-zA-Z]{20,}'
    )

    for pattern in "${secret_patterns[@]}"; do
        while IFS= read -r match; do
            [ -z "$match" ] && continue
            local file line_num
            file=$(echo "$match" | cut -d: -f1)
            line_num=$(echo "$match" | cut -d: -f2)
            local rel="${file#$TARGET_DIR/}"

            local tmp
            tmp=$(jq --arg file "$rel" --argjson line "$line_num" --arg pat "$pattern" \
                '. + [{file: $file, line: $line, code: "SEC-SECRET", message: ("疑似硬编码密钥: " + $pat), severity: "critical", priority: "P0"}]' \
                "$findings_file")
            echo "$tmp" > "$findings_file"
        done < <(grep -rnE "$pattern" --include="*.sh" --include="*.js" --include="*.py" --include="*.json" "$TARGET_DIR" 2>/dev/null | grep -v '.git' | grep -v 'test-' | grep -v 'security-scanner' || true)
    done

    # 扫描危险 shell 命令
    local dangerous_patterns=(
        'rm\s+-rf\s+/'
        '>\s*/dev/sda'
        'dd\s+if=.*of=/dev/'
    )

    for pattern in "${dangerous_patterns[@]}"; do
        while IFS= read -r match; do
            [ -z "$match" ] && continue
            local file line_num
            file=$(echo "$match" | cut -d: -f1)
            line_num=$(echo "$match" | cut -d: -f2)
            local rel="${file#$TARGET_DIR/}"

            local tmp
            tmp=$(jq --arg file "$rel" --argjson line "$line_num" --arg pat "$pattern" \
                '. + [{file: $file, line: $line, code: "SEC-DANGEROUS", message: ("危险命令: " + $pat), severity: "critical", priority: "P0"}]' \
                "$findings_file")
            echo "$tmp" > "$findings_file"
        done < <(grep -rnE "$pattern" --include="*.sh" "$TARGET_DIR" 2>/dev/null | grep -v '.git' | grep -v 'security-scanner' | grep -v 'code-review' || true)
    done

    local count
    count=$(jq 'length' "$findings_file")
    echo "[review] 安全扫描: $count 个发现"
    cat "$findings_file"
}

#------------------------------------------------------------------------------
# 风格检查（shfmt，如果可用）
#------------------------------------------------------------------------------
run_style_check() {
    local findings_file="$REVIEW_TMP_DIR/style-findings.json"
    echo '[]' > "$findings_file"

    if [ "$HAS_SHFMT" != true ]; then
        cat "$findings_file"
        return
    fi

    local sh_files
    sh_files=$(find "$TARGET_DIR" -type f -name '*.sh' -not -path '*/.git/*' 2>/dev/null || true)

    for file in $sh_files; do
        local rel="${file#$TARGET_DIR/}"
        local diff_output
        diff_output=$(shfmt -d "$file" 2>/dev/null || true)

        if [ -n "$diff_output" ]; then
            local diff_lines
            diff_lines=$(echo "$diff_output" | grep -c '^@@' || echo 0)

            local tmp
            tmp=$(jq --arg file "$rel" --argjson count "$diff_lines" \
                '. + [{file: $file, line: 0, code: "STYLE", message: ("格式不一致: " + ($count|tostring) + " 处差异"), severity: "low", priority: "P3"}]' \
                "$findings_file")
            echo "$tmp" > "$findings_file"
        fi
    done

    cat "$findings_file"
}

#------------------------------------------------------------------------------
# 合并所有发现
#------------------------------------------------------------------------------
merge_findings() {
    local syntax="$1"
    local security="$2"
    local style="$3"

    local merged
    merged=$(jq -s 'add' \
        <(echo "$syntax") \
        <(echo "$security") \
        <(echo "$style") \
        2>/dev/null || echo '[]')

    # 按优先级排序
    merged=$(echo "$merged" | jq 'sort_by(
        if .priority == "P0" then 0
        elif .priority == "P1" then 1
        elif .priority == "P2" then 2
        else 3 end
    )')

    echo "$merged"
}

#------------------------------------------------------------------------------
# 生成报告
#------------------------------------------------------------------------------
generate_review_report() {
    local findings="$1"
    local output="$2"

    local total p0_count p1_count p2_count p3_count
    total=$(echo "$findings" | jq 'length')
    p0_count=$(echo "$findings" | jq '[.[] | select(.priority == "P0")] | length')
    p1_count=$(echo "$findings" | jq '[.[] | select(.priority == "P1")] | length')
    p2_count=$(echo "$findings" | jq '[.[] | select(.priority == "P2")] | length')
    p3_count=$(echo "$findings" | jq '[.[] | select(.priority == "P3")] | length')

    local date
    date=$(date +%Y-%m-%d)
    local target_name
    target_name=$(basename "$TARGET_DIR")

    {
        echo "# 代码评审报告"
        echo ""
        echo "日期: $date | 目标: $target_name/ | 扫描器: bash-n$([ "$HAS_SHELLCHECK" = true ] && echo " + shellcheck" || echo "")"
        echo ""
        echo "## 汇总"
        echo ""
        echo "| 严重度 | 数量 |"
        echo "|--------|------|"
        echo "| 严重 (P0) | $p0_count |"
        echo "| 高 (P1)   | $p1_count |"
        echo "| 中 (P2)   | $p2_count |"
        echo "| 低 (P3)   | $p3_count |"
        echo "| **总计**  | **$total** |"
        echo ""

        if [ "$total" -eq 0 ]; then
            echo "未发现问题。代码质量良好。"
            return
        fi

        echo "## 详细发现"
        echo ""

        # 按优先级分组输出
        for priority in P0 P1 P2 P3; do
            local label
            case "$priority" in
                P0) label="P0 严重" ;;
                P1) label="P1 高" ;;
                P2) label="P2 中" ;;
                P3) label="P3 低" ;;
            esac

            local items
            items=$(echo "$findings" | jq -c --arg p "$priority" '[.[] | select(.priority == $p)]')

            local count
            count=$(echo "$items" | jq 'length')

            if [ "$count" -eq 0 ]; then
                continue
            fi

            echo "### $label ($count)"
            echo ""

            echo "$items" | jq -c '.[]' | while IFS= read -r item; do
                local file line code msg
                file=$(echo "$item" | jq -r '.file')
                line=$(echo "$item" | jq -r '.line')
                code=$(echo "$item" | jq -r '.code')
                msg=$(echo "$item" | jq -r '.message')

                if [ "$line" = "0" ] || [ "$line" = "null" ]; then
                    echo "- \`${file}\`: ${msg} [${code}]"
                else
                    echo "- \`${file}:${line}\`: ${msg} [${code}]"
                fi
            done

            echo ""
        done

        echo "---"
        echo ""
        echo "_Generated by flow-kit v3.3.0 code-review_"
    } > "$output"

    echo "[review] 报告已生成: $output"
    echo "[review] 总计 $total 个发现 (P0=$p0_count P1=$p1_count P2=$p2_count P3=$p3_count)"
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    parse_args "$@"

    if [ ! -d "$TARGET_DIR" ]; then
        echo "[review] 错误: 目录不存在 $TARGET_DIR" >&2
        exit 1
    fi

    # 创建临时目录
    REVIEW_TMP_DIR=$(mktemp -d)

    # 检测可用工具
    command -v shellcheck &>/dev/null && HAS_SHELLCHECK=true || HAS_SHELLCHECK=false
    command -v shfmt &>/dev/null && HAS_SHFMT=true || HAS_SHFMT=false

    echo "[review] 目标: $TARGET_DIR"
    echo "[review] shellcheck: $HAS_SHELLCHECK | shfmt: $HAS_SHFMT"
    echo ""

    # 扫描文件
    local file_count
    file_count=$(scan_targets "$TARGET_DIR" | wc -l | tr -d ' ')
    echo "[review] 扫描文件: $file_count"

    # 运行检查
    echo "[review] 运行语法检查..."
    local syntax_findings
    syntax_findings=$(run_syntax_check)

    echo "[review] 运行安全扫描..."
    local security_findings
    security_findings=$(run_security_scan)

    echo "[review] 运行风格检查..."
    local style_findings
    style_findings=$(run_style_check)

    # 合并发现
    local all_findings
    all_findings=$(merge_findings "$syntax_findings" "$security_findings" "$style_findings")

    # 生成报告
    echo ""
    generate_review_report "$all_findings" "$OUTPUT_FILE"

    # 记录历史
    session_history_add "code-review" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
