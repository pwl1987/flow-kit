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

#------------------------------------------------------------------------------
# 估算 token（基于字符数/4 的近似计算）
#------------------------------------------------------------------------------
estimate_tokens() {
    local text="${1:-}"
    if [ -z "$text" ]; then
        # 从 stdin 读取
        text=$(cat)
    fi
    local char_count=${#text}
    local token_estimate=$((char_count / 4))
    echo "$token_estimate"
}

#------------------------------------------------------------------------------
# 估算文件 token
#------------------------------------------------------------------------------
estimate_file_tokens() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "0"
        return
    fi
    local char_count=$(wc -c < "$file" 2>/dev/null || echo 0)
    local token_estimate=$((char_count / 4))
    echo "$token_estimate"
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

示例:
  context-budget.sh --status
  context-budget.sh --estimate "Hello world"
  context-budget.sh --estimate-file .planning/PROJECT.md
  context-budget.sh --check 75000 100000
  context-budget.sh --compress "auto-trigger"

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
