#!/bin/bash
#==============================================================================
# flow-kit.sh — flow-kit CLI 入口脚本
#
# 用法:
#   ./flow-kit.sh <command> [args]
#   ./flow-kit.sh health
#   ./flow-kit.sh hooks install
#   ./flow-kit.sh mode team
#
# v1.11 新增：借鉴 OMC CLI 双入口设计
#==============================================================================

set -e

#------------------------------------------------------------------------------
# 环境检测
#------------------------------------------------------------------------------
check_dependencies() {
    local missing=()
    command -v git >/dev/null 2>&1 || missing+=("git")
    command -v jq >/dev/null 2>&1 || missing+=("jq")

    if [ ${#missing[@]} -ne 0 ]; then
        echo "[flow-kit] 警告: 缺少依赖 ${missing[*]}，部分功能可能不可用"
        echo "[flow-kit] 安装: brew install ${missing[*]}"
    fi
}

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
flow-kit v1.11 — 结构化开发流程 CLI

用法:
  flow-kit.sh <command> [args]

命令:
  health                  运行健康扫描
  hooks install           安装 hooks
  hooks status            查看 hooks 状态
  mode <mode>             设置执行模式 (autopilot|team|ralph)
  dispatch <n> "<task>"  启动 Team 模式，n 个并行 executor
  minimal "<task>"        启动 L0 极简模式
  register                注册斜杠命令
  archive                 归档完成变更

示例:
  ./flow-kit.sh health
  ./flow-kit.sh hooks install
  ./flow-kit.sh mode team
  ./flow-kit.sh dispatch 3 "实现用户认证模块"
  ./flow-kit.sh minimal "修复登录 bug"

文档:
  参见 @flow-kit/GO.md
EOF
}

#------------------------------------------------------------------------------
# 命令路由映射表
#------------------------------------------------------------------------------
declare -A COMMANDS=(
    ["health"]="/flow-kit:health"
    ["hooks"]="/flow-kit:hooks"
    ["mode"]="/flow-kit:mode"
    ["dispatch"]="/flow-kit:dispatch"
    ["minimal"]="/flow-kit:minimal"
    ["register"]="/flow-kit:register-commands"
    ["archive"]="/flow-kit:archive"
    ["scan"]="/flow-kit:scan"
    ["cost-report"]="/flow-kit:cost-report"
    ["estimate-tokens"]="/flow-kit:estimate-tokens"
)

#------------------------------------------------------------------------------
# 核心命令处理
#------------------------------------------------------------------------------
route_command() {
    local cmd="$1"
    shift

    case "$cmd" in
        health|hooks|scan|cost-report|estimate-tokens)
            echo "[flow-kit] 路由到 $cmd..."
            echo "[flow-kit] 请在 Claude Code 中执行: /flow-kit:$cmd"
            ;;

        hooks)
            local action="${1:-status}"
            echo "[flow-kit] hooks $action..."
            echo "[flow-kit] 请在 Claude Code 中执行: /flow-kit:hooks $action"
            ;;

        mode)
            local mode="${1:-}"
            if [ -z "$mode" ]; then
                echo "[flow-kit] 错误: mode 需要参数 (autopilot|team|ralph)"
                echo "[flow-kit] 示例: ./flow-kit.sh mode team"
                exit 1
            fi
            echo "[flow-kit] 切换执行模式: $mode"
            echo "[flow-kit] 请在 Claude Code 中执行: /flow-kit:mode $mode"
            ;;

        dispatch)
            local n="${1:-}"
            local task="${2:-}"
            if [ -z "$n" ] || [ -z "$task" ]; then
                echo "[flow-kit] 错误: dispatch 需要 executor 数量和任务描述"
                echo "[flow-kit] 示例: ./flow-kit.sh dispatch 3 \"实现用户认证模块\""
                exit 1
            fi
            echo "[flow-kit] Team 模式启动 ($n executors)..."
            echo "[flow-kit] 请在 Claude Code 中执行: /flow-kit:dispatch $n:\"$task\""
            ;;

        minimal)
            local task="${1:-}"
            if [ -z "$task" ]; then
                echo "[flow-kit] 错误: minimal 需要任务描述"
                echo "[flow-kit] 示例: ./flow-kit.sh minimal \"修复登录 bug\""
                exit 1
            fi
            echo "[flow-kit] L0 极简模式..."
            echo "[flow-kit] 请在 Claude Code 中执行: /flow-kit:minimal \"$task\""
            ;;

        register)
            echo "[flow-kit] 注册斜杠命令..."
            echo "[flow-kit] 请在 Claude Code 中执行: /flow-kit:register-commands"
            ;;

        archive)
            echo "[flow-kit] 归档变更..."
            echo "[flow-kit] 请在 Claude Code 中执行: /flow-kit:archive"
            ;;

        help|--help|-h)
            show_help
            exit 0
            ;;

        *)
            echo "[flow-kit] 未知命令: $cmd"
            echo "[flow-kit] 运行 ./flow-kit.sh help 查看可用命令"
            exit 1
            ;;
    esac
}

#------------------------------------------------------------------------------
# 主入口
#------------------------------------------------------------------------------
main() {
    check_dependencies

    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    local command="$1"
    route_command "$@"
}

main "$@"
