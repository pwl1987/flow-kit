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
flow-kit v1.12 — 结构化开发流程 CLI

用法:
  flow-kit.sh <command> [args]

命令:
  help                    显示帮助信息和使用示例
  status                  显示当前执行模式
  share                   输出团队共享安装指令
  health                  运行健康扫描
  hooks install           安装 hooks
  hooks status            查看 hooks 状态
  mode <mode>             设置执行模式 (autopilot|team|ralph)
  dispatch <n> "<task>"  启动 Team 模式，n 个并行 executor
  minimal "<task>"        启动 L0 极简模式
  register                注册斜杠命令
  archive                 归档完成变更

示例:
  ./flow-kit.sh help                      # 显示帮助
  ./flow-kit.sh status                    # 显示当前模式
  ./flow-kit.sh share                     # 输出团队安装指令
  ./flow-kit.sh health                    # 健康扫描
  ./flow-kit.sh hooks install             # 安装 hooks
  ./flow-kit.sh mode team                # 切换到 Team 模式
  ./flow-kit.sh dispatch 3 "实现用户认证" # 3 并行执行
  ./flow-kit.sh minimal "修复登录 bug"    # 极简模式

文档:
  参见 @flow-kit/GO.md
EOF
}

#------------------------------------------------------------------------------
# 状态显示
#------------------------------------------------------------------------------
show_status() {
    local mode_file=".flow-kit/mode"
    local current_mode="autopilot"

    if [ -f "$mode_file" ]; then
        current_mode=$(cat "$mode_file")
    fi

    echo "flow-kit v1.12 — 执行模式状态"
    echo ""
    echo "当前模式: $current_mode"
    echo ""
    echo "可用模式:"
    echo "  autopilot  — L0-L1 单 Agent 自主执行"
    echo "  team       — L2-L3 多 Agent 协作"
    echo "  ralph      — Team + 验证循环"
    echo ""
    echo "切换模式: ./flow-kit.sh mode <mode>"
}

#------------------------------------------------------------------------------
# 团队共享安装
#------------------------------------------------------------------------------
show_share() {
    echo "flow-kit v1.12 — 团队共享安装指令"
    echo ""
    echo "新成员执行以下命令完成安装:"
    echo ""
    echo "# 1. 克隆项目"
    echo "git clone <repo-url> <project-name>"
    echo "cd <project-name>"
    echo ""
    echo "# 2. 安装 hooks（自动注册斜杠命令）"
    echo "./flow-kit/flow-kit.sh hooks install"
    echo ""
    echo "# 3. 在 Claude Code 中注册命令"
    echo "/flow-kit:register-commands"
    echo ""
    echo "已包含:"
    echo "  • flow-kit/hooks/*.sh          — 5 个保护 hooks"
    echo "  • .claude/settings.json        — hooks 配置"
    echo "  • flow-kit/                   — 完整工具包"
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

        status)
            show_status
            exit 0
            ;;

        share)
            show_share
            exit 0
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
