#!/bin/bash
# plan-generate.sh — v3.3.0 P2 基于评审结果生成开发方案
# 解析 REVIEW.md，按模块分组，生成分里程碑的 DEV-PLAN.md

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/preflight.sh"
source "$SCRIPT_DIR/../lib/session-state.sh"

require_jq

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
INPUT_FILE=""
OUTPUT_FILE="DEV-PLAN.md"
TARGET_VERSION=""

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
plan-generate.sh — 基于评审结果生成开发方案

用法:
  ./plan-generate.sh [选项]

选项:
  --input <文件>     评审报告（默认: REVIEW.md）
  --output <文件>    输出文件（默认: DEV-PLAN.md）
  --version <版本>   目标版本号（默认: 从 VERSION 文件读取）
  -h, --help         显示帮助信息

功能:
  1. 解析 REVIEW.md 评审发现
  2. 按模块分组
  3. 生成改进项（问题+目标+步骤+工期）
  4. 按优先级分里程碑
  5. 输出 DEV-PLAN.md

示例:
  ./plan-generate.sh --input REVIEW.md
  ./plan-generate.sh --input REVIEW.md --version v3.4.0
EOF
}

#------------------------------------------------------------------------------
# 参数解析
#------------------------------------------------------------------------------
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --input)    INPUT_FILE="$2"; shift 2 ;;
            --output)   OUTPUT_FILE="$2"; shift 2 ;;
            --version)  TARGET_VERSION="$2"; shift 2 ;;
            -h|--help)  show_help; exit 0 ;;
            *)          echo "[plan] 未知选项: $1" >&2; exit 1 ;;
        esac
    done

    INPUT_FILE="${INPUT_FILE:-$PROJECT_DIR/REVIEW.md}"
    OUTPUT_FILE="${OUTPUT_FILE:-$PROJECT_DIR/DEV-PLAN.md}"

    if [[ "$OUTPUT_FILE" != /* ]]; then
        OUTPUT_FILE="$PROJECT_DIR/$OUTPUT_FILE"
    fi

    if [ -z "$TARGET_VERSION" ] && [ -f "$FLOW_KIT_DIR/VERSION" ]; then
        TARGET_VERSION=$(cat "$FLOW_KIT_DIR/VERSION" | tr -d '\n')
    fi
    TARGET_VERSION="${TARGET_VERSION:-v3.4.0}"
}

#------------------------------------------------------------------------------
# 解析 REVIEW.md
#------------------------------------------------------------------------------
parse_review() {
    local review_file="$1"
    local findings_json="$REVIEW_TMP_DIR/findings.json"
    local findings_ndjson="$REVIEW_TMP_DIR/findings.ndjson"
    echo '[]' > "$findings_json"
    > "$findings_ndjson"

    if [ ! -f "$review_file" ]; then
        echo "[plan] 错误: 评审报告不存在 $review_file" >&2
        return 1
    fi

    # 检查是否有发现
    if grep -q "未发现问题" "$review_file"; then
        echo "[plan] 评审报告无问题，无需生成方案"
        echo '[]' > "$findings_json"
        cat "$findings_json"
        return 0
    fi

    # 解析详细发现段落，先收集到 ndjson
    local current_priority=""

    while IFS= read -r line; do
        # 检测优先级标题
        if [[ "$line" =~ ^###\ (P[0-3]) ]]; then
            current_priority="${BASH_REMATCH[1]}"
            continue
        fi

        # 解析发现行: - `file:line`: description [CODE]
        if [[ "$line" =~ ^-\ \`([^:]+):?([0-9]*)\`:\ (.+)\ \[([A-Z0-9-]+)\]$ ]]; then
            local file="${BASH_REMATCH[1]}"
            local line_num="${BASH_REMATCH[2]:-0}"
            local message="${BASH_REMATCH[3]}"
            local code="${BASH_REMATCH[4]}"
            local priority="${current_priority:-P2}"

            local severity
            case "$priority" in
                P0) severity="critical" ;;
                P1) severity="high" ;;
                P2) severity="medium" ;;
                *)  severity="low" ;;
            esac

            local module
            module=$(echo "$file" | cut -d/ -f1)

            jq -n --arg file "$file" \
                --argjson line "$line_num" \
                --arg msg "$message" \
                --arg code "$code" \
                --arg priority "$priority" \
                --arg severity "$severity" \
                --arg module "$module" \
                '{file: $file, line: $line, message: $msg, code: $code, priority: $priority, severity: $severity, module: $module}' \
                >> "$findings_ndjson"
        fi
    done < "$review_file"

    # 合并 ndjson 到 JSON 数组
    local count
    count=$(wc -l < "$findings_ndjson" | tr -d ' ')

    if [ "$count" -gt 0 ]; then
        jq -s '.' "$findings_ndjson" > "$findings_json"
    fi

    echo "[plan] 解析发现: $count 条" >&2
    cat "$findings_json"
}

#------------------------------------------------------------------------------
# 按模块分组
#------------------------------------------------------------------------------
group_by_module() {
    local findings="$1"
    local groups_file="$REVIEW_TMP_DIR/module-groups.json"

    local modules
    modules=$(echo "$findings" | jq -r '.[].module' | sort -u)

    echo '{}' > "$groups_file"

    for module in $modules; do
        [ -z "$module" ] && continue
        local module_findings
        module_findings=$(echo "$findings" | jq --arg m "$module" '[.[] | select(.module == $m)]')

        local count
        count=$(echo "$module_findings" | jq 'length')

        local p0 p1 p2 p3
        p0=$(echo "$module_findings" | jq '[.[] | select(.priority == "P0")] | length')
        p1=$(echo "$module_findings" | jq '[.[] | select(.priority == "P1")] | length')
        p2=$(echo "$module_findings" | jq '[.[] | select(.priority == "P2")] | length')
        p3=$(echo "$module_findings" | jq '[.[] | select(.priority == "P3")] | length')

        local tmp
        tmp=$(jq --arg module "$module" \
            --argjson count "$count" \
            --argjson p0 "$p0" --argjson p1 "$p1" --argjson p2 "$p2" --argjson p3 "$p3" \
            --argjson findings "$module_findings" \
            '. + {($module): {count: $count, p0: $p0, p1: $p1, p2: $p2, p3: $p3, findings: $findings}}' \
            "$groups_file")
        echo "$tmp" > "$groups_file"
    done

    cat "$groups_file"
}

#------------------------------------------------------------------------------
# 工期估算
#------------------------------------------------------------------------------
estimate_effort() {
    local priority="$1"
    case "$priority" in
        P0) echo "0.5d" ;;
        P1) echo "1d" ;;
        P2) echo "0.5d" ;;
        P3) echo "0.25d" ;;
    esac
}

#------------------------------------------------------------------------------
# 生成改进项
#------------------------------------------------------------------------------
generate_improvement_items() {
    local groups="$1"
    local items_file="$REVIEW_TMP_DIR/improvement-items.json"
    echo '[]' > "$items_file"

    local modules
    modules=$(echo "$groups" | jq -r 'keys[]')

    for module in $modules; do
        local findings
        findings=$(echo "$groups" | jq --arg m "$module" '.[$m].findings')

        # 按优先级排序
        local sorted
        sorted=$(echo "$findings" | jq 'sort_by(if .priority == "P0" then 0 elif .priority == "P1" then 1 elif .priority == "P2" then 2 else 3 end)')

        # 汇总模块问题描述
        local problem
        problem=$(echo "$sorted" | jq -r '.[] | "\(.file):\(.line) \(.message)"' | head -5 | tr '\n' '; ' | sed 's/; $//')

        local priorities
        priorities=$(echo "$sorted" | jq -r '[.[].priority] | unique | join(",")')

        local total_effort="0"
        local item_count
        item_count=$(echo "$sorted" | jq 'length')

        # 计算总工期
        for ((i=0; i<item_count; i++)); do
            local p
            p=$(echo "$sorted" | jq -r ".[$i].priority")
            local eff
            eff=$(estimate_effort "$p")
            local eff_num
            eff_num=$(echo "$eff" | sed 's/d$//')
            total_effort=$(echo "$total_effort + $eff_num" | bc 2>/dev/null || echo "$total_effort")
        done

        local top_priority
        top_priority=$(echo "$sorted" | jq -r '.[0].priority')

        local tmp
        tmp=$(jq --arg module "$module" \
            --arg problem "$problem" \
            --arg priorities "$priorities" \
            --argjson item_count "$item_count" \
            --arg total_effort "$total_effort" \
            --arg top_priority "$top_priority" \
            --argjson findings "$sorted" \
            '. + [{
                module: $module,
                problem: $problem,
                priorities: $priorities,
                item_count: $item_count,
                total_effort: ($total_effort + "d"),
                top_priority: $top_priority,
                findings: $findings
            }]' \
            "$items_file")
        echo "$tmp" > "$items_file"
    done

    # 按最高优先级排序
    local sorted_items
    sorted_items=$(jq 'sort_by(if .top_priority == "P0" then 0 elif .top_priority == "P1" then 1 elif .top_priority == "P2" then 2 else 3 end)' "$items_file")

    echo "$sorted_items"
}

#------------------------------------------------------------------------------
# 生成里程碑
#------------------------------------------------------------------------------
generate_milestones() {
    local items="$1"
    local milestones_file="$REVIEW_TMP_DIR/milestones.json"

    # 分组
    local m1_items m2_items m3_items m4_items
    m1_items=$(echo "$items" | jq '[.[] | select(.top_priority == "P0")]')
    m2_items=$(echo "$items" | jq '[.[] | select(.top_priority == "P1")]')
    m3_items=$(echo "$items" | jq '[.[] | select(.top_priority == "P2")]')
    m4_items=$(echo "$items" | jq '[.[] | select(.top_priority == "P3")]')

    local m1_count m2_count m3_count m4_count
    m1_count=$(echo "$m1_items" | jq 'length')
    m2_count=$(echo "$m2_items" | jq 'length')
    m3_count=$(echo "$m3_items" | jq 'length')
    m4_count=$(echo "$m4_items" | jq 'length')

    jq -n \
        --argjson m1_count "$m1_count" --argjson m1_items "$m1_items" \
        --argjson m2_count "$m2_count" --argjson m2_items "$m2_items" \
        --argjson m3_count "$m3_count" --argjson m3_items "$m3_items" \
        --argjson m4_count "$m4_count" --argjson m4_items "$m4_items" \
        '{
            m1: {name: "紧急修复", timeline: "本周", count: $m1_count, items: $m1_items},
            m2: {name: "高优先级改进", timeline: "1-2周", count: $m2_count, items: $m2_items},
            m3: {name: "中等优先级优化", timeline: "3-4周", count: $m3_count, items: $m3_items},
            m4: {name: "低优先级改善", timeline: "backlog", count: $m4_count, items: $m4_items}
        }' > "$milestones_file"

    cat "$milestones_file"
}

#------------------------------------------------------------------------------
# 写开发方案
#------------------------------------------------------------------------------
write_dev_plan() {
    local milestones="$1"
    local output="$2"
    local total_findings="$3"

    local date
    date=$(date +%Y-%m-%d)

    {
        echo "# 开发方案"
        echo ""
        echo "目标版本: $TARGET_VERSION | 源评审: $(basename "$INPUT_FILE") | 总发现: $total_findings"
        echo "生成日期: $date"
        echo ""

        # 概览
        echo "## 概览"
        echo ""
        echo "| 里程碑 | 名称 | 时间线 | 发现数 |"
        echo "|--------|------|--------|--------|"

        for m in m1 m2 m3 m4; do
            local name timeline count
            name=$(echo "$milestones" | jq -r ".$m.name")
            timeline=$(echo "$milestones" | jq -r ".$m.timeline")
            count=$(echo "$milestones" | jq -r ".$m.count")
            [ "$count" = "0" ] && continue
            echo "| $m | $name | $timeline | $count |"
        done
        echo ""

        # 详细里程碑
        for m in m1 m2 m3 m4; do
            local count
            count=$(echo "$milestones" | jq -r ".$m.count")
            [ "$count" = "0" ] && continue

            local name timeline
            name=$(echo "$milestones" | jq -r ".$m.name")
            timeline=$(echo "$milestones" | jq -r ".$m.timeline")

            echo "## 里程碑: $name ($timeline)"
            echo ""

            echo "| 模块 | 发现数 | 工期 | 问题描述 |"
            echo "|------|--------|------|----------|"

            echo "$milestones" | jq -c ".$m.items[]" | while IFS= read -r item; do
                local module item_count effort problem
                module=$(echo "$item" | jq -r '.module')
                item_count=$(echo "$item" | jq -r '.item_count')
                effort=$(echo "$item" | jq -r '.total_effort')
                problem=$(echo "$item" | jq -r '.problem' | cut -c1-60)
                echo "| $module | $item_count | $effort | $problem |"
            done
            echo ""
        done

        echo "---"
        echo ""
        echo "_Generated by flow-kit v3.3.0 plan-generate_"
    } > "$output"

    echo "[plan] 方案已生成: $output"
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    parse_args "$@"

    REVIEW_TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$REVIEW_TMP_DIR"' EXIT

    if [ ! -f "$INPUT_FILE" ]; then
        echo "[plan] 错误: 评审报告不存在 $INPUT_FILE" >&2
        echo "[plan] 提示: 先运行 /flow-kit:code-review 生成评审报告" >&2
        exit 1
    fi

    echo "[plan] 输入: $INPUT_FILE"
    echo "[plan] 目标版本: $TARGET_VERSION"
    echo ""

    # 1. 解析评审
    echo "[plan] 解析评审报告..."
    local findings
    findings=$(parse_review "$INPUT_FILE")

    local total
    total=$(echo "$findings" | jq 'length')

    if [ "$total" -eq 0 ]; then
        echo "[plan] 无发现问题，生成空方案"
        echo "# 开发方案" > "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "源评审未发现问题，无需改进。" >> "$OUTPUT_FILE"
        echo "[plan] 空方案已生成: $OUTPUT_FILE"
        return 0
    fi

    # 2. 按模块分组
    echo "[plan] 按模块分组..."
    local groups
    groups=$(group_by_module "$findings")

    # 3. 生成改进项
    echo "[plan] 生成改进项..."
    local items
    items=$(generate_improvement_items "$groups")

    # 4. 生成里程碑
    echo "[plan] 生成里程碑..."
    local milestones
    milestones=$(generate_milestones "$items")

    # 5. 写方案
    echo ""
    write_dev_plan "$milestones" "$OUTPUT_FILE" "$total"

    # 记录历史
    session_history_add "plan-generate" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
