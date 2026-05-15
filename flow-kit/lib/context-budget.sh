#!/bin/bash
# context-budget.sh — 上下文预算管理
# v2.7.0 P0 新增
# 实现 token 估算和预算控制

set -euo pipefail

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
readonly DEFAULT_BUDGET=100000
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly FLOW_KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly CAVEMAN_SCRIPT="$FLOW_KIT_ROOT/scripts/caveman-compress.sh"

# v2.7.0 改进：检测 bc 可用性，提供降级方案
HAS_BC=false
if command -v bc &>/dev/null; then
    HAS_BC=true
fi

is_number() {
    [[ "$1" =~ ^-?[0-9]+([.][0-9]+)?$ ]]
}

is_cmp_op() {
    case "$1" in
        '<'|'>'|'<='|'>='|'=='|'!=') return 0 ;;
        *) return 1 ;;
    esac
}

# 浮点运算封装（支持 bc 降级）
float_cmp() {
    local a="$1"
    local op="$2"
    local b="$3"
    if ! is_number "$a" || ! is_number "$b" || ! is_cmp_op "$op"; then
        return 1
    fi
    if [[ "$HAS_BC" == true ]]; then
        [[ "$(printf '%s %s %s\n' "$a" "$op" "$b" | bc -l 2>/dev/null)" == "1" ]]
    else
        # 降级：使用 awk 进行浮点比较
        awk -v a="$a" -v b="$b" "BEGIN {exit !(a $op b)}" 2>/dev/null
    fi
}

float_mul() {
    local a="$1"
    local b="$2"
    if ! is_number "$a" || ! is_number "$b"; then
        echo "0"
        return
    fi
    if [[ "$HAS_BC" == true ]]; then
        printf '%s * %s\n' "$a" "$b" | bc -l 2>/dev/null | cut -d. -f1
    else
        # 降级：使用 awk
        awk -v a="$a" -v b="$b" 'BEGIN {printf "%d", a * b}' 2>/dev/null || echo "0"
    fi
}

float_scale() {
    local a="$1"
    local scale="${2:-2}"
    if ! is_number "$a" || [[ ! "$scale" =~ ^[0-9]+$ ]]; then
        echo "$a"
        return
    fi
    if [[ "$HAS_BC" == true ]]; then
        printf 'scale=%s; %s\n' "$scale" "$a" | bc -l 2>/dev/null
    else
        # 降级：使用 awk
        awk -v a="$a" -v scale="$scale" 'BEGIN {printf "%.*f", scale, a}' 2>/dev/null || echo "$a"
    fi
}

# 多模型token估算配置
# 格式: "英文系数:中文系数:代码系数"（模型名作为关联数组 key）
# v2.7.0 修复：使用关联数组实现 O(1) 查找
declare -A MODEL_CONFIGS=(
    ["claude"]="0.25:1.5:0.35"
    ["gpt4"]="0.25:1.6:0.30"
    ["gemini"]="0.20:1.4:0.30"
)

# 模型显示顺序（用于 --list-models 保持有序输出）
readonly MODEL_ORDER=(claude gpt4 gemini)

# 当前使用的模型（默认claude）
readonly CURRENT_MODEL="${CONTEXT_BUDGET_MODEL:-claude}"

#------------------------------------------------------------------------------
# 获取当前模型的配置参数
#------------------------------------------------------------------------------
get_model_params() {
    local model="$1"
    # O(1) 关联数组查找，未命中时回退 claude
    echo "${MODEL_CONFIGS[$model]:-${MODEL_CONFIGS[claude]}}"
}

#------------------------------------------------------------------------------
# 检测文本语言类型（POSIX 兼容，v2.7.0 修复 UTF-8 中文字符检测）
#------------------------------------------------------------------------------
detect_language_type() {
    local text="$1"

    # P0 修复：使用 perl 进行 Unicode 中文字符检测（UTF-8 感知）
    # 检测 UTF-8 中文字符范围：一-龥 (U+4E00-U+9FFF)
    local chinese_count
    if command -v perl &>/dev/null; then
        chinese_count=$(printf '%s' "$text" | perl -CS -0777 -ne '
            my $count = () = $_ =~ /\p{Han}/g;
            print $count;
        ' 2>/dev/null || echo "0")
    elif command -v grep &>/dev/null; then
        # 回退：使用 grep -o 配合 Unicode 范围
        chinese_count=$(printf '%s' "$text" | grep -o '['"'"'一-龥'"'"']' 2>/dev/null | wc -l || echo "0")
    else
        # 最后的回退：统计非 ASCII 字符
        chinese_count=$(printf '%s' "$text" | tr -d '[:ascii:]' | wc -c || echo "0")
    fi

    local total_chars=${#text}

    if [[ "$total_chars" -eq 0 ]]; then
        echo "mixed"
        return
    fi

    # 如果中文字符超过30%，认为是中文为主
    local chinese_pct=$((chinese_count * 100 / total_chars))
    if [[ "$chinese_pct" -gt 30 ]]; then
        echo "chinese"
    else
        echo "english"
    fi
}

#------------------------------------------------------------------------------
# 检测内容类型（代码/文本/注释）
#------------------------------------------------------------------------------
detect_content_type() {
    local text="$1"

    if [[ "$text" == *'```'* ]]; then
        echo "code"
    elif [[ "$text" =~ [\;\{\}\(\)] ]]; then
        echo "code"
    elif [[ "$text" =~ ^[[:space:]]*(function|class|import|export|const|let|var|if|for|while|return|def|func|package|pub[[:space:]]+fn|impl|struct|interface|module|use|async|await|fn)[[:space:]] ]]; then
        echo "code"
    else
        echo "text"
    fi
}

#------------------------------------------------------------------------------
# 估算 token（智能估算，基于语言和 content 类型）
#------------------------------------------------------------------------------
estimate_tokens() {
    local text="${1:-}"
    if [[ -z "$text" ]]; then
        text=$(cat)
    fi

    local char_count=${#text}
    if [[ "$char_count" -eq 0 ]]; then
        echo "0"
        return
    fi

    # 获取当前模型配置
    local config
    config=$(get_model_params "$CURRENT_MODEL")
    local english_factor
    english_factor=$(echo "$config" | cut -d: -f1)
    local chinese_factor
    chinese_factor=$(echo "$config" | cut -d: -f2)
    local code_factor
    code_factor=$(echo "$config" | cut -d: -f3)

    # 检测语言和 content 类型
    local lang_type
    lang_type=$(detect_language_type "$text")
    local content_type
    content_type=$(detect_content_type "$text")

    # 选择合适的系数
    local factor
    if [[ "$content_type" == "code" ]]; then
        factor=$code_factor
    elif [[ "$lang_type" == "chinese" ]]; then
        factor=$chinese_factor
    else
        factor=$english_factor
    fi

    # 计算token估算值
    local token_estimate
    token_estimate=$(float_mul "$char_count" "$factor")
    # P1 修复：改进降级判断 - 仅在计算失败时降级（非空且非零才认为是成功）
    if [[ -z "$token_estimate" ]] || ! [[ "$token_estimate" =~ ^[0-9]+$ ]] || [[ "$token_estimate" -eq 0 ]]; then
        token_estimate=$((char_count / 4))
    fi

    echo "$token_estimate"
}

#------------------------------------------------------------------------------
# 估算文件 token（智能估算）
#------------------------------------------------------------------------------
estimate_file_tokens() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "0"
        return
    fi

    # 获取文件扩展名
    local ext="${file##*.}"

    # 代码文件使用代码系数
    case "$ext" in
        sh|bash|py|js|ts|jsx|tsx|java|c|cpp|h|go|rs|rb|php)
            local char_count
            char_count=$(wc -c < "$file" 2>/dev/null || echo 0)
            local config
            config=$(get_model_params "$CURRENT_MODEL")
            local code_factor
            code_factor=$(echo "$config" | cut -d: -f3)
            local result
            result=$(float_mul "$char_count" "$code_factor")
            echo "${result:-0}"
            ;;
        md|txt|log)
            # 文本文件，需要检测语言
            local content
            content=$(cat "$file" 2>/dev/null || echo "")
            estimate_tokens "$content"
            ;;
        *)
            # 默认估算
            local char_count
            char_count=$(wc -c < "$file" 2>/dev/null || echo 0)
            echo "$((char_count / 4))"
            ;;
    esac
}

#------------------------------------------------------------------------------
# 估算目录 token（递归）
#------------------------------------------------------------------------------
estimate_dir_tokens() {
    local dir="${1:-.}"
    local total=0

    # 使用 find 替代 glob（兼容性更好）
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            total=$((total + $(estimate_file_tokens "$file")))
        fi
    done < <(find "$dir" -name "*.md" -type f 2>/dev/null || echo "")

    echo "$total"
}

#------------------------------------------------------------------------------
# 检查预算使用率
#------------------------------------------------------------------------------
check_budget() {
    local used_tokens="${1:-0}"
    local total_budget="${2:-$DEFAULT_BUDGET}"

    # 防止除零
    if [[ "$total_budget" -eq 0 ]] 2>/dev/null; then
        echo "[context-budget] total_budget=0，跳过预算检查"
        return 0
    fi

    local usage_pct
    usage_pct=$(float_scale "$(awk "BEGIN {printf \"%.2f\", $used_tokens * 100 / $total_budget}" 2>/dev/null || echo "0")")
    local remaining_tokens=$((total_budget - used_tokens))
    local remaining_pct
    remaining_pct=$(float_scale "$(awk "BEGIN {printf \"%.2f\", $remaining_tokens * 100 / $total_budget}" 2>/dev/null || echo "0")")

    local status="HEALTHY"

    if float_cmp "$usage_pct" ">=" "100"; then
        status="BLOCK"
    elif float_cmp "$usage_pct" ">=" "80"; then
        status="WARNING"
    fi

    local warnings_json="[]"
    if [[ "$status" == "WARNING" ]]; then
        warnings_json='["Budget approaching 80%"]'
    elif [[ "$status" == "BLOCK" ]]; then
        warnings_json='["Budget exhausted, action required"]'
    fi

    cat << EOF
{
  "used_tokens": $used_tokens,
  "total_budget": $total_budget,
  "remaining_tokens": $remaining_tokens,
  "usage_pct": "$usage_pct%",
  "remaining_pct": "$remaining_pct%",
  "status": "$status",
  "warnings": $warnings_json
}
EOF
}

#------------------------------------------------------------------------------
# 获取预算状态（从上下文计算）
#------------------------------------------------------------------------------
get_budget_status() {
    local project_dir="${1:-.}"

    # 估算 .planning 目录的 token
    local planning_tokens
    planning_tokens=$(estimate_dir_tokens "$project_dir/.planning" 2>/dev/null || echo 0)

    # 估算 flow-kit 目录的 token（排除 hooks/scripts 等）
    local flowkit_tokens
    flowkit_tokens=$(estimate_dir_tokens "$project_dir/flow-kit" 2>/dev/null || echo 0)

    # 估算当前会话上下文的 token（粗略估算）
    local context_file="$project_dir/.flow-kit/context/current.md"
    local context_tokens=0
    if [[ -f "$context_file" ]]; then
        context_tokens=$(estimate_file_tokens "$context_file")
    fi

    local total_used=$((planning_tokens + flowkit_tokens + context_tokens))

    check_budget $total_used $DEFAULT_BUDGET
}

#------------------------------------------------------------------------------
# 触发上下文压缩
#------------------------------------------------------------------------------
trigger_compress() {
    local reason="${1:-manual}"

    echo "[context-budget] 🚨 触发上下文压缩 (reason: $reason)"

    if [[ -f "$CAVEMAN_SCRIPT" ]]; then
        echo "[context-budget] 执行 caveman 压缩..."
        bash "$CAVEMAN_SCRIPT"
        return $?
    else
        echo "[context-budget] ⚠️ caveman-compress.sh 不存在，跳过压缩"
        return 1
    fi
}

#------------------------------------------------------------------------------
# 预算预警（输出到 stderr）
#------------------------------------------------------------------------------
budget_warn() {
    local status="$1"
    local usage_pct="$2"

    case "$status" in
        WARNING)
            echo "[context-budget] ⚠️  上下文预算警告: ${usage_pct}% 已使用" >&2
            echo "[context-budget] 💡 提示: 考虑运行 /flow-kit:cleanup 或等待自动压缩" >&2
            ;;
        BLOCK)
            echo "[context-budget] 🚫 上下文预算耗尽: ${usage_pct}%" >&2
            echo "[context-budget] 💡 需立即压缩上下文才能继续" >&2
            ;;
    esac
}

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
context-budget.sh — 上下文预算管理

用法:
  context-budget.sh --status              # 显示当前预算状态
  context-budget.sh --estimate [text]     # 估算 token
  context-budget.sh --estimate-file <file> # 估算文件 token
  context-budget.sh --check <used> [total] # 检查预算使用率
  context-budget.sh --compress [reason]   # 触发压缩
  context-budget.sh --model <model>       # 设置模型 (claude/gpt4/gemini)
  context-budget.sh --list-models         # 列出支持的模型

示例:
  context-budget.sh --status
  context-budget.sh --estimate "Hello world"
  context-budget.sh --estimate-file .planning/PROJECT.md
  context-budget.sh --check 75000 100000
  context-budget.sh --compress "auto-trigger"
  context-budget.sh --model claude
  context-budget.sh --list-models

输出格式:
  JSON 格式预算状态报告
EOF
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local command="${1:-}"

    case "$command" in
        --status|-s)
            get_budget_status "${2:-.}"
            ;;
        --estimate|-e)
            if [[ -n "${2:-}" ]]; then
                estimate_tokens "$2"
            else
                estimate_tokens
            fi
            ;;
        --estimate-file|-f)
            if [[ -z "${2:-}" ]]; then
                echo "[context-budget] 错误: 需要指定文件路径" >&2
                exit 1
            fi
            estimate_file_tokens "$2"
            ;;
        --check|-c)
            check_budget "${2:-0}" "${3:-$DEFAULT_BUDGET}"
            ;;
        --compress|-m)
            trigger_compress "${2:-manual}"
            ;;
        --model)
            if [[ -z "${2:-}" ]]; then
                echo "[context-budget] 错误: 需要指定模型名称" >&2
                exit 1
            fi
            mkdir -p .flow-kit
            echo "$2" > .flow-kit/context-budget-model
            echo "[context-budget] ✅ 模型已设置为: $2"
            ;;
        --list-models)
            echo "[context-budget] 支持的模型:"
            for model in "${MODEL_ORDER[@]}"; do
                local config="${MODEL_CONFIGS[$model]}"
                local english_factor
                english_factor=$(echo "$config" | cut -d: -f1)
                local chinese_factor
                chinese_factor=$(echo "$config" | cut -d: -f2)
                local code_factor
                code_factor=$(echo "$config" | cut -d: -f3)
                echo "  - $model (英文: ${english_factor}x, 中文: ${chinese_factor}x, 代码: ${code_factor}x)"
            done
            echo ""
            echo "当前模型: $CURRENT_MODEL"
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "[context-budget] 未知命令: $command" >&2
            show_help
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
