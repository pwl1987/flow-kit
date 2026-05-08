#!/bin/bash
# error-handler.sh — 统一错误处理框架
# v1.12.4 P3 新增
# 提供标准化日志和错误码

#------------------------------------------------------------------------------
# 错误码常量
#------------------------------------------------------------------------------
readonly EXIT_SUCCESS=0
readonly EXIT_GENERAL_ERROR=1
readonly EXIT_GUARD_BLOCK=2
readonly EXIT_MISSING_DEPS=3

#------------------------------------------------------------------------------
# 日志函数
#------------------------------------------------------------------------------

# 信息日志
log_info() {
    local module="${1:-unknown}"
    local message="${2:-}"
    echo "[$(date +%Y-%m-%dT%H:%M:%SZ)][INFO][$module] $message"
}

# 警告日志
log_warn() {
    local module="${1:-unknown}"
    local message="${2:-}"
    echo "[$(date +%Y-%m-%dT%H:%M:%SZ)][WARN][$module] $message" >&2
}

# 错误日志
log_error() {
    local module="${1:-unknown}"
    local message="${2:-}"
    echo "[$(date +%Y-%m-%dT%H:%M:%SZ)][ERROR][$module] $message" >&2
}

# 调试日志（仅 DEBUG 模式启用）
log_debug() {
    if [ "${DEBUG:-0}" = "1" ]; then
        local module="${1:-unknown}"
        local message="${2:-}"
        echo "[$(date +%Y-%m-%dT%H:%M:%SZ)][DEBUG][$module] $message"
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
# 使用示例
#------------------------------------------------------------------------------

# 示例 1: 基本日志
# log_info "my-module" "操作开始"
# log_warn "my-module" "这是一个警告"
# log_error "my-module" "这是一个错误"

# 示例 2: 错误退出
# command_that_might_fail || die $EXIT_GENERAL_ERROR "my-module" "操作失败"

# 示例 3: 检查结果
# some_command
# check_result "my-module" "命令执行成功"

#------------------------------------------------------------------------------
# 参考来源
#------------------------------------------------------------------------------
# [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) — 错误处理规范
