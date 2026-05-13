#!/bin/bash
# paths.sh — 统一路径管理
# v2.7.0 P1 新增
# 集中管理 flow-kit 所有路径常量，避免各脚本重复定义

# 注意：paths.sh 不使用 set -u，因为被 source 时可能影响调用脚本的变量检查
# 各调用脚本应自行设置 set -euo pipefail

# v2.7.0 改进：防止重复加载
if [ -n "${PATHS_LOADED:-}" ]; then
    return 0
fi
readonly PATHS_LOADED=true

#------------------------------------------------------------------------------
# 基础路径
#------------------------------------------------------------------------------
# 获取 paths.sh 自身所在目录（flow-kit/lib/）
PATHS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# flow-kit 根目录（lib/ 的父目录）
PATHS_FLOW_KIT_DIR="$(dirname "$PATHS_SCRIPT_DIR")"
# 项目根目录（优先 CLAUDE_PROJECT_DIR，回退向上查找 .git）
# CLAUDE_PROJECT_DIR 由 Claude Code 设置，总是指向项目根目录
if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    PATHS_PROJECT_DIR="$CLAUDE_PROJECT_DIR"
else
    _paths_find_root() {
        local dir="$PATHS_FLOW_KIT_DIR"
        while [ "$dir" != "/" ]; do
            [ -d "$dir/.git" ] && echo "$dir" && return
            dir="$(dirname "$dir")"
        done
        cd "$PATHS_FLOW_KIT_DIR/../.." && pwd
    }
    PATHS_PROJECT_DIR="$(_paths_find_root)"
    unset -f _paths_find_root
fi

#------------------------------------------------------------------------------
# 导出路径常量
#------------------------------------------------------------------------------
readonly FLOW_KIT_DIR="$PATHS_FLOW_KIT_DIR"
readonly PROJECT_DIR="$PATHS_PROJECT_DIR"

# 脚本目录
readonly SCRIPTS_DIR="$FLOW_KIT_DIR/scripts"

# Hooks 目录
readonly HOOKS_DIR="$FLOW_KIT_DIR/hooks"

# 库目录
readonly LIB_DIR="$FLOW_KIT_DIR/lib"

# 配置目录
readonly CONFIG_DIR="$FLOW_KIT_DIR/config"

# 护栏目录
readonly GUARDRAILS_DIR="$FLOW_KIT_DIR/guardrails"

# 命令目录
readonly COMMANDS_DIR="$FLOW_KIT_DIR/commands"

# 技能目录
readonly SKILLS_DIR="$FLOW_KIT_DIR/skills"

# 阶段目录
readonly PHASES_DIR="$FLOW_KIT_DIR/phases"

# 模板目录
readonly TEMPLATES_DIR="$FLOW_KIT_DIR/templates"

# 参考目录
readonly REFERENCE_DIR="$FLOW_KIT_DIR/reference"

# Schema 目录
readonly SCHEMA_DIR="$FLOW_KIT_DIR/lib/validation/schemas"

#------------------------------------------------------------------------------
# 运行时路径（基于项目根目录）
#------------------------------------------------------------------------------
# 临时目录
readonly TMP_DIR="$PROJECT_DIR/.flow-kit/tmp"

# 锁目录
readonly LOCK_DIR="$PROJECT_DIR/.flow-kit/locks"

# 日志目录
readonly LOGS_DIR="$PROJECT_DIR/.flow-kit/logs"

# 上下文目录
readonly CONTEXT_DIR="$PROJECT_DIR/.flow-kit/context"

# 规划目录
readonly PLANNING_DIR="$PROJECT_DIR/.planning"

# 规划输出目录
readonly OUTPUT_DIR="$PLANNING_DIR/outputs"

# 覆盖率目录
readonly COVERAGE_DIR="$PROJECT_DIR/.flow-kit/coverage"

# 健康历史文件
readonly HEALTH_HISTORY_FILE="$PROJECT_DIR/.flow-kit/health-history.json"

# 健康归档目录
readonly HEALTH_ARCHIVE_DIR="$PROJECT_DIR/.flow-kit/health-archive"

# 检查点文件
readonly CHECKPOINT_FILE="$PROJECT_DIR/.flow-kit/checkpoint-state.json"

# 项目类型文件
readonly PROJECT_TYPE_FILE="$PROJECT_DIR/.flow-kit/project-type"

# 当前阶段文件
readonly CURRENT_PHASE_FILE="$PROJECT_DIR/.flow-kit/current-phase"

# 模式文件
readonly MODE_FILE="$PROJECT_DIR/.flow-kit/mode"

#------------------------------------------------------------------------------
# 初始化运行时目录
#------------------------------------------------------------------------------
init_runtime_dirs() {
    mkdir -p "$TMP_DIR"
    mkdir -p "$LOCK_DIR"
    mkdir -p "$LOGS_DIR"
    mkdir -p "$CONTEXT_DIR"
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$COVERAGE_DIR"
    mkdir -p "$HEALTH_ARCHIVE_DIR"
}

#------------------------------------------------------------------------------
# 日志轮转（v2.7.0 新增：防止日志无限增长）
# 用法: rotate_logs <目录> [保留文件数] [文件大小阈值(MB)]
#------------------------------------------------------------------------------
rotate_logs() {
    local log_dir="$1"
    local keep_count="${2:-10}"
    local size_threshold_mb="${3:-10}"

    if [ ! -d "$log_dir" ]; then
        return 0
    fi

    # 归档超过大小阈值的日志文件
    local threshold_bytes=$((size_threshold_mb * 1024 * 1024))
    local archive_dir="$log_dir/archive"
    mkdir -p "$archive_dir"

    for log_file in "$log_dir"/*.log; do
        [ -f "$log_file" ] || continue
        local file_size
        file_size=$(wc -c < "$log_file" 2>/dev/null || echo "0")
        if [ "$file_size" -gt "$threshold_bytes" ]; then
            local basename
            basename=$(basename "$log_file")
            local timestamp
            timestamp=$(date +%Y%m%d%H%M%S%N 2>/dev/null || printf '%s.%s' "$$" "$RANDOM")
            mv "$log_file" "$archive_dir/${basename%.log}.${timestamp}.log"
        fi
    done

    # 清理超过保留数量的归档文件
    local count=0
    while IFS= read -r archived; do
        [ -n "$archived" ] || continue
        count=$((count + 1))
        if [ "$count" -gt "$keep_count" ]; then
            rm -f "$archived" 2>/dev/null || true
        fi
    done < <(ls -t "$archive_dir"/*.log 2>/dev/null)
}

#------------------------------------------------------------------------------
# 使用示例
#------------------------------------------------------------------------------
# source "flow-kit/lib/paths.sh"
# echo "项目根目录: $PROJECT_DIR"
# echo "临时目录: $TMP_DIR"
# init_runtime_dirs
