#!/bin/bash
set -euo pipefail
# error-handler.sh — 统一错误处理框架
# v2.7.0 P3 新增
# v2.7.0 P1 修复: POSIX date 回退格式 + set -euo pipefail
# 提供标准化日志和错误码

#------------------------------------------------------------------------------
# 错误码常量（防重复 source）
#------------------------------------------------------------------------------
if [ -z "${_ERROR_HANDLER_LOADED:-}" ]; then
readonly EXIT_SUCCESS=0
readonly EXIT_GENERAL_ERROR=1
readonly EXIT_GUARD_BLOCK=2
readonly EXIT_MISSING_DEPS=3
readonly _ERROR_HANDLER_LOADED=1
fi

#------------------------------------------------------------------------------
# 获取 ISO 8601 时间戳（POSIX 兼容）
#------------------------------------------------------------------------------
get_timestamp() {
    # P1 修复：添加 POSIX date 回退格式
    # v2.7.0 修复：第三回退格式统一为 ISO 8601（补 T 和 Z）
    if date -u +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
        # GNU date (Linux)
        date -u +%Y-%m-%dT%H:%M:%SZ
    else
        # BSD date (macOS) 回退
        date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00"
    fi
}

#------------------------------------------------------------------------------
# 日志函数
#------------------------------------------------------------------------------

# 信息日志
log_info() {
    local module="${1:-unknown}"
    local message="${2:-}"
    echo "[$(get_timestamp)][INFO][$module] $message"
}

# 警告日志
log_warn() {
    local module="${1:-unknown}"
    local message="${2:-}"
    echo "[$(get_timestamp)][WARN][$module] $message" >&2
}

# 错误日志
log_error() {
    local module="${1:-unknown}"
    local message="${2:-}"
    echo "[$(get_timestamp)][ERROR][$module] $message" >&2
}

# 调试日志（仅 DEBUG 模式启用）
log_debug() {
    if [ "${DEBUG:-0}" = "1" ]; then
        local module="${1:-unknown}"
        local message="${2:-}"
        echo "[$(get_timestamp)][DEBUG][$module] $message"
    fi
}

#------------------------------------------------------------------------------
# 错误处理
#------------------------------------------------------------------------------

# 退出并记录错误
die() {
    local exit_code="${1:-$EXIT_GENERAL_ERROR}"
    local module="${2:-unknown}"
    local message="${3:-Unknown error}"
    log_error "$module" "$message"
    exit "$exit_code"
}

# 检查上一个命令的返回值
check_result() {
    local exit_code=$?
    local module="${1:-unknown}"
    local message="${2:-Operation failed}"

    if [ $exit_code -ne 0 ]; then
        log_error "$module" "$message (exit code: $exit_code)"
        return $exit_code
    fi
    log_info "$module" "$message"
    return 0
}

#------------------------------------------------------------------------------
# 错误上下文管理（v2.7.0 强化）
#------------------------------------------------------------------------------
ERROR_CONTEXT_DIR="${ERROR_CONTEXT_DIR:-$HOME/.flow-kit/error-contexts}"
mkdir -p "$ERROR_CONTEXT_DIR" 2>/dev/null || true

create_error_context() {
    local error_file="${1:-}"
    local error_type="${2:-UNKNOWN}"
    local context="${3:-unknown}"

    if [ -z "$error_file" ]; then
        error_file="$ERROR_CONTEXT_DIR/error-$(date +%Y%m%d%H%M%S)-$$.json"
    fi

    mkdir -p "$(dirname "$error_file")" 2>/dev/null || true

    local timestamp
    timestamp=$(get_timestamp)

    # P0 修复：提前获取调用栈信息，避免在 here-doc 中引用不存在的数组索引
    # BASH_SOURCE[0] 是当前脚本，BASH_SOURCE[1] 是调用者
    local caller_script="${BASH_SOURCE[1]:-${BASH_SOURCE[0]:-unknown}}"
    local caller_line="${BASH_LINENO[0]:-0}"

    # v2.7.0 使用 jq 生成 JSON，避免注入风险
    jq -n \
        --arg type "$error_type" \
        --arg ctx "$context" \
        --arg ts "$timestamp" \
        --arg script "$caller_script" \
        --arg cmd "$BASH_COMMAND" \
        --arg line "$caller_line" \
        '{
          type: $type,
          context: $ctx,
          timestamp: $ts,
          script: $script,
          line: ($line | tonumber),
          command: $cmd,
          recovery_suggestions: []
        }' > "$error_file"

    echo "$error_file"
}

get_error_recovery_suggestion() {
    local error_type="$1"

    case "$error_type" in
        MISSING_DEPS)
            echo "请安装缺失的依赖后重试"
            ;;
        GUARD_BLOCK)
            echo "当前操作被安全护栏阻断，请检查配置或联系管理员"
            ;;
        TIMEOUT)
            echo "操作超时，请检查网络连接或增加超时时间"
            ;;
        PERMISSION_DENIED)
            echo "权限不足，请检查文件权限设置"
            ;;
        *)
            echo "请查看错误日志获取更多信息"
            ;;
    esac
}

safe_exit() {
    local exit_code="${1:-0}"
    local error_file="${2:-}"
    local message="${3:-}"

    if [ -n "$message" ]; then
        log_info "exit" "$message"
    fi

    if [ -n "$error_file" ] && [ -f "$error_file" ]; then
        # P0 修复：使用 jq 优先，sed 回退（macOS/Linux 全兼容）
        local error_type
        if command -v jq &>/dev/null; then
            error_type=$(jq -r '.type // empty' "$error_file" 2>/dev/null || echo "UNKNOWN")
        elif command -v sed &>/dev/null; then
            error_type=$(sed -n 's/.*"type": *"\([^"]*\)".*/\1/p' "$error_file" 2>/dev/null | head -1)
            [ -z "$error_type" ] && error_type="UNKNOWN"
        else
            error_type="UNKNOWN"
        fi

        if [ "$exit_code" -ne 0 ]; then
            local suggestion
            suggestion=$(get_error_recovery_suggestion "$error_type")
            log_warn "exit" "错误类型: $error_type"
            log_warn "exit" "恢复建议: $suggestion"
        fi
    fi

    exit "$exit_code"
}

# v2.7.0 P2 修复: 使用 jq 生成 JSON，避免注入风险
aggregate_errors() {
    local error_log="$1"
    shift
    local errors=("$@")

    if [ ${#errors[@]} -eq 0 ]; then
        return 0
    fi

    # 将错误数组转换为 JSON 数组（安全转义特殊字符）
    local errors_json
    errors_json=$(printf '%s\n' "${errors[@]}" | jq -Rs 'split("\n")[:-1]' 2>/dev/null || echo "[]")

    jq -n \
        --arg ts "$(get_timestamp)" \
        --argjson total "${#errors[@]}" \
        --argjson errs "$errors_json" \
        '{
          aggregated_at: $ts,
          total_errors: $total,
          errors: $errs
        }' > "$error_log"
}
