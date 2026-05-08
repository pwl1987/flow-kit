#!/bin/bash
# context-budget.sh — 上下文预算管理
# v1.12.6 P0 新增
# 实现 token 估算和预算控制

set -e

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
readonly DEFAULT_BUDGET=100000
readonly WARN_THRESHOLD=0.80
readonly BLOCK_THRESHOLD=1.00
readonly CAVEMAN_SCRIPT="flow-kit/scripts/caveman-compress.sh"

# 多模型token估算配置
# 格式: 模型名:英文系数:中文系数:代码系数
readonly MODEL_CONFIGS=(
    "claude:0.25:1.5:0.35"
    "gpt4:0.25:1.6:0.30"
    "gemini:0.20:1.4:0.30"
)

# 当前使用的模型（默认claude）
CURRENT_MODEL="${CONTEXT_BUDGET_MODEL:-claude}"

#------------------------------------------------------------------------------
# 获取当前模型的配置参数
#------------------------------------------------------------------------------
get_model_params() {
    local model="$1"
    local config=""

    for c in "${MODEL_CONFIGS[@]}"; do
        local model_name=$(echo "$c" | cut -d: -f1)
        if [ "$model_name" = "$model" ]; then
            config="$c"
            break
        fi
    done

    if [ -z "$config" ]; then
        # 默认使用claude配置
        config="claude:0.25:1.5:0.35"
    fi

    echo "$config"
}

#------------------------------------------------------------------------------
# 检测文本语言类型（POSIX 兼容，v1.12.8 修复 grep -oP 移植性）
#------------------------------------------------------------------------------
detect_language_type() {
    local text="$1"

    # P0 修复：使用 awk 替代 grep -oP（POSIX 兼容）
    # awk 检测 UTF-8 中文字符范围 [一-龥]
    local chinese_count
    chinese_count=$(printf '%s' "$text" | awk '
    BEGIN { count = 0 }
    {
        n = split($0, chars, "")
        for (i = 1; i <= n; i++) {
            c = chars[i]
            if (c >= "\xe4\xb8\x80" && c <= "\xe9\xbe\xbf") {
                count++
            }
        }
    }
    END { print count }
    ' 2>/dev/null || echo "0")

    local total_chars=${#text}

    if [ "$total_chars" -eq 0 ]; then
        echo "mixed"
        return
    fi

    # 如果中文字符超过30%，认为是中文为主
    local chinese_pct=$((chinese_count * 100 / total_chars))
    if [ "$chinese_pct" -gt 30 ]; then
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

    # 检测代码特征
    if echo "$text" | grep -qE '(function|class|import|export|const|let|var|if|for|while|return)' 2>/dev/null; then
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
    if [ -z "$text" ]; then
        text=$(cat)
    fi

    local char_count=${#text}
    if [ "$char_count" -eq 0 ]; then
        echo "0"
        return
    fi

    # 获取当前模型配置
    local config=$(get_model_params "$CURRENT_MODEL")
    local english_factor=$(echo "$config" | cut -d: -f2)
    local chinese_factor=$(echo "$config" | cut -d: -f3)
    local code_factor=$(echo "$config" | cut -d: -f4)

    # 检测语言和 content 类型
    local lang_type=$(detect_language_type "$text")
    local content_type=$(detect_content_type "$text")

    # 选择合适的系数
    local factor
    if [ "$content_type" = "code" ]; then
        factor=$code_factor
    elif [ "$lang_type" = "chinese" ]; then
        factor=$chinese_factor
    else
        factor=$english_factor
    fi

    # 计算token估算值
    local token_estimate=$(echo "$char_count * $factor" | bc -l 2>/dev/null | cut -d. -f1)
    if [ -z "$token_estimate" ]; then
        token_estimate=$((char_count / 4))
    fi

    echo "$token_estimate"
}

#------------------------------------------------------------------------------
# 估算文件 token（智能估算）
#------------------------------------------------------------------------------
estimate_file_tokens() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "0"
        return
    fi

    # 获取文件扩展名
    local ext="${file##*.}"

    # 代码文件使用代码系数
    case "$ext" in
        sh|bash|py|js|ts|jsx|tsx|java|c|cpp|h|go|rs|rb|php)
            local char_count=$(wc -c < "$file" 2>/dev/null || echo 0)
            local config=$(get_model_params "$CURRENT_MODEL")
            local code_factor=$(echo "$config" | cut -d: -f4)
            echo "$(echo "$char_count * $code_factor" | bc -l 2>/dev/null | cut -d. -f1)"
            ;;
        md|txt|log)
            # 文本文件，需要检测语言
            local content=$(cat "$file" 2>/dev/null || echo "")
            estimate_tokens "$content"
            ;;
        *)
            # 默认估算
            local char_count=$(wc -c < "$file" 2>/dev/null || echo 0)
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
        if [ -f "$file" ]; then
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

    local usage_pct
    usage_pct=$(echo "scale=2; $used_tokens * 100 / $total_budget" | bc 2>/dev/null || echo "0")
    local remaining_tokens=$((total_budget - used_tokens))
    local remaining_pct
    remaining_pct=$(echo "scale=2; $remaining_tokens * 100 / $total_budget" | bc 2>/dev/null || echo "0")

    local status="HEALTHY"
    local usage_cmp
    usage_cmp=$(echo "$usage_pct" | bc -l 2>/dev/null || echo "0")
    local warn_thresh
    warn_thresh=$(echo "$WARN_THRESHOLD * 100" | bc -l 2>/dev/null || echo "80")
    local block_thresh
    block_thresh=$(echo "$BLOCK_THRESHOLD * 100" | bc -l 2>/dev/null || echo "100")

    if [ "$(echo "$usage_cmp >= $block_thresh" | bc -l 2>/dev/null)" = "1" ]; then
        status="BLOCK"
    elif [ "$(echo "$usage_cmp >= $warn_thresh" | bc -l 2>/dev/null)" = "1" ]; then
        status="WARNING"
    fi

    local warnings_json="[]"
    if [ "$status" = "WARNING" ]; then
        warnings_json='["Budget approaching 80%"]'
    elif [ "$status" = "BLOCK" ]; then
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
    local planning_tokens=$(estimate_dir_tokens "$project_dir/.planning" 2>/dev/null || echo 0)

    # 估算 flow-kit 目录的 token（排除 hooks/scripts 等）
    local flowkit_tokens=$(estimate_dir_tokens "$project_dir/flow-kit" 2>/dev/null || echo 0)

    # 估算当前会话上下文的 token（粗略估算）
    local context_file="$project_dir/.flow-kit/context/current.md"
    local context_tokens=0
    if [ -f "$context_file" ]; then
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

    if [ -f "$CAVEMAN_SCRIPT" ]; then
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
            if [ -n "${2:-}" ]; then
                estimate_tokens "$2"
            else
                estimate_tokens
            fi
            ;;
        --estimate-file|-f)
            if [ -z "${2:-}" ]; then
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
            if [ -z "${2:-}" ]; then
                echo "[context-budget] 错误: 需要指定模型名称" >&2
                exit 1
            fi
            echo "$2" > .flow-kit/context-budget-model
            echo "[context-budget] ✅ 模型已设置为: $2"
            ;;
        --list-models)
            echo "[context-budget] 支持的模型:"
            for c in "${MODEL_CONFIGS[@]}"; do
                local model_name=$(echo "$c" | cut -d: -f1)
                local english_factor=$(echo "$c" | cut -d: -f2)
                local chinese_factor=$(echo "$c" | cut -d: -f3)
                local code_factor=$(echo "$c" | cut -d: -f4)
                echo "  - $model_name (英文: ${english_factor}x, 中文: ${chinese_factor}x, 代码: ${code_factor}x)"
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

main "$@"
