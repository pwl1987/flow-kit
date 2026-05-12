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
# v1.12.2 新增：借鉴 OMC CLI 双入口设计
#==============================================================================

set -euo pipefail

#------------------------------------------------------------------------------
# 版本读取（v1.12.4 新增）
#------------------------------------------------------------------------------
read_version() {
    local -r version_file="$(dirname "$0")/VERSION"
    if [ -f "$version_file" ]; then
        cat "$version_file"
    else
        echo "v2.5.0"
    fi
}

load_paths() {
    local paths_file="$(dirname "$0")/lib/paths.sh"
    if [ -f "$paths_file" ]; then
        source "$paths_file"
    fi
}

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
    local ver
    ver=$(read_version)
    cat << EOF
flow-kit $ver — 结构化开发流程 CLI

用法:
  flow-kit.sh <command> [args]

命令:
  help                    显示帮助信息和使用示例
  status                  显示当前执行模式
  share                   输出团队共享安装指令
  map-codebase           运行存量项目代码库扫描
  health                  运行健康扫描
  hooks install           安装 hooks
  hooks status            查看 hooks 状态
  hooks-summary           显示 hooks 执行摘要
  mode <mode>             设置执行模式 (autopilot|team|ralph)
  dispatch <n> "<task>"  启动 Team 模式，n 个并行 executor
  minimal "<task>"        启动 L0 极简模式
  register                注册斜杠命令
  archive                 归档完成变更
  estimate-tokens        估算 token 使用量
  check-expiry           检查上下文过期状态
  cost-report            生成成本报告
  update-context         更新上下文变更日志
  pr-description         生成 PR 描述
  p0                     P0 变更检测
  dispatch-status        查看多代理编排状态
  dispatch-aggregate     查看多代理聚合报告
  uninstall              卸载 flow-kit（删除 hooks 和配置）

示例:
  ./flow-kit.sh help                      # 显示帮助
  ./flow-kit.sh status                    # 显示当前模式
  ./flow-kit.sh share                     # 输出团队安装指令
  ./flow-kit.sh map-codebase              # 扫描当前项目
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
    local ver
    ver=$(read_version)
    local mode_file=".flow-kit/mode"
    local current_mode="autopilot"

    if [ -f "$mode_file" ]; then
        current_mode=$(cat "$mode_file")
    fi

    echo "flow-kit $ver — 执行模式状态"
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
    local ver
    ver=$(read_version)
    local project_name
    project_name=$(basename "$(pwd)")

    echo "flow-kit $ver — 团队共享安装指令"
    echo ""
    echo "新成员执行以下命令完成安装:"
    echo ""
    echo "# 1. 克隆项目（$project_name 可替换为实际项目名）"
    echo "git clone <repo-url> $project_name"
    echo "cd $project_name"
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
# Hooks 执行摘要（v1.12.4 P3 新增）
#------------------------------------------------------------------------------
show_hooks_summary() {
    local log_file=".flow-kit/logs/hooks-execution.log"

    echo "flow-kit v$(read_version) — Hooks 执行摘要"
    echo ""

    if [ ! -f "$log_file" ]; then
        echo "暂无 hooks 执行记录"
        return
    fi

    echo "最近 20 条执行记录："
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    tail -20 "$log_file"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 统计
    local total
    local ok_count
    local fail_count
    total=$(wc -l < "$log_file" 2>/dev/null || echo 0)
    ok_count=$(grep -c "\[OK\]" "$log_file" 2>/dev/null || echo 0)
    fail_count=$(grep -c "\[FAIL\]" "$log_file" 2>/dev/null || echo 0)

    echo ""
    echo "统计: 总执行 $total 次 | 成功 $ok_count | 失败 $fail_count"
}

#------------------------------------------------------------------------------
# 核心命令处理
#------------------------------------------------------------------------------
route_command() {
    local cmd="$1"
    shift

    case "$cmd" in
        health|scan|cost-report|estimate-tokens|check-expiry|update-context|p0)
            echo "[flow-kit] 路由到 $cmd..."
            echo "[flow-kit] 请在 Claude Code 中执行: /flow-kit:$cmd"
            ;;

        pr-description)
            local pr_desc_script="$(dirname "$0")/scripts/pr-description.sh"
            if [ -f "$pr_desc_script" ]; then
                bash "$pr_desc_script" "$@"
            else
                echo "[flow-kit] 错误: pr-description.sh 不存在"
                exit 1
            fi
            ;;

        offline)
            local offline_script="$(dirname "$0")/scripts/offline-mode.sh"
            if [ -f "$offline_script" ]; then
                bash "$offline_script" "$@"
            else
                echo "[flow-kit] 错误: offline-mode.sh 不存在"
                exit 1
            fi
            ;;

        online)
            local offline_script="$(dirname "$0")/scripts/offline-mode.sh"
            if [ -f "$offline_script" ]; then
                bash "$offline_script" off
            else
                echo "[flow-kit] 错误: offline-mode.sh 不存在"
                exit 1
            fi
            ;;

        hooks)
            local action="${1:-status}"
            echo "[flow-kit] hooks $action..."
            echo "[flow-kit] 请在 Claude Code 中执行: /flow-kit:hooks $action"
            ;;

        hooks-summary)
            show_hooks_summary
            exit 0
            ;;

        mode)
            local mode="${1:-}"
            if [ -z "$mode" ]; then
                echo "[flow-kit] 错误: mode 需要参数 (autopilot|team|ralph)"
                echo "[flow-kit] 示例: ./flow-kit.sh mode team"
                exit 1
            fi
            case "$mode" in
                autopilot|team|ralph)
                    ;;
                *)
                    echo "[flow-kit] 错误: 不支持的 mode: $mode"
                    echo "[flow-kit] 支持: autopilot|team|ralph"
                    exit 1
                    ;;
            esac
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
            if [[ ! "$n" =~ ^[1-9][0-9]*$ ]]; then
                echo "[flow-kit] 错误: executor 数量必须是正整数"
                exit 1
            fi
            # 直接调用 dispatch.sh 执行（--execute 模式）
            local dispatch_script="$(dirname "$0")/scripts/dispatch.sh"
            if [ ! -f "$dispatch_script" ]; then
                echo "[flow-kit] 错误: dispatch.sh 不存在"
                exit 1
            fi
            echo "[flow-kit] ⚡ Team 模式启动 ($n executors)..."
            "$dispatch_script" --execute "$n" "$task"
            exit $?
            ;;

        minimal)
            perform_minimal "$@"
            exit 0
            ;;

        register)
            echo "[flow-kit] 注册斜杠命令..."
            local gen_script="$(dirname "$0")/scripts/generate-commands.sh"
            if [ -f "$gen_script" ]; then
                bash "$gen_script" --force
                echo "[flow-kit] ✅ 斜杠命令注册完成"
            else
                echo "[flow-kit] ⚠️ generate-commands.sh 不存在，请在 Claude Code 中执行: /flow-kit:register-commands"
            fi
            ;;

        archive)
            echo "[flow-kit] 归档变更..."
            local archive_dir=".flow-kit/archive"
            local phases_dir=".planning/phases"
            mkdir -p "$archive_dir"
            if [ -d "$phases_dir" ]; then
                local archive_name="archive-$(date +%Y%m%d-%H%M%S).tar.gz"
                tar -czf "$archive_dir/$archive_name" "$phases_dir" 2>/dev/null && \
                    echo "[flow-kit] ✅ 已归档到 $archive_dir/$archive_name" || \
                    echo "[flow-kit] ⚠️ 归档失败"
            else
                echo "[flow-kit] ℹ️ .planning/phases 不存在，无需要归档的内容"
            fi
            ;;

        share)
            show_share
            exit 0
            ;;

        map-codebase)
            echo "[flow-kit] 代码库扫描..."
            echo "[flow-kit] 请在 Claude Code 中执行: /flow-kit:scan"
            ;;

        change)
            local action="${1:-init}"
            case "$action" in
                init)
                    local desc="${2:-}"
                    if [ -z "$desc" ]; then
                        echo "[flow-kit] 用法: ./flow-kit.sh change init \"变更描述\""
                        echo "[flow-kit] 示例: ./flow-kit.sh change init \"添加用户反馈中心\""
                        exit 1
                    fi
                    local init_script="$(dirname "$0")/scripts/init-change.sh"
                    if [ -f "$init_script" ]; then
                        bash "$init_script" "$desc"
                    else
                        echo "[flow-kit] 错误: init-change.sh 不存在"
                        exit 1
                    fi
                    ;;
                *)
                    echo "[flow-kit] 未知 change 操作: $action"
                    echo "[flow-kit] 支持: ./flow-kit.sh change init \"描述\""
                    exit 1
                    ;;
            esac
            ;;

        phase-*)
            local phase_num="${cmd#phase-}"
            local executor_script="$(dirname "$0")/scripts/phase-executor.sh"
            if [ -f "$executor_script" ]; then
                bash "$executor_script" "$phase_num"
            else
                echo "[flow-kit] 错误: phase-executor.sh 不存在"
                exit 1
            fi
            ;;

        next)
            local next_script="$(dirname "$0")/scripts/next-phase.sh"
            if [ -f "$next_script" ]; then
                bash "$next_script"
            else
                echo "[flow-kit] 错误: next-phase.sh 不存在"
                exit 1
            fi
            ;;

        status)
            show_status
            load_paths
            echo ""
            echo "=========================================="
            echo "flow-kit 项目状态"
            echo "=========================================="
            if [ -f "$CURRENT_PHASE_FILE" ]; then
                local phase
                phase=$(cat "$CURRENT_PHASE_FILE")
                echo "📍 当前阶段: Phase $phase"
            else
                echo "📍 当前阶段: 未初始化（请先运行 /flow-kit:init）"
            fi
            if [ -f "$PROJECT_TYPE_FILE" ]; then
                local ptype
                ptype=$(grep "^project_type:" "$PROJECT_TYPE_FILE" | cut -d' ' -f2)
                echo "📋 项目类型: $ptype"
            else
                echo "📋 项目类型: 未检测（请先运行 /flow-kit:health）"
            fi
            exit 0
            ;;

        uninstall)
            perform_uninstall
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
# 极简模式（v1.12.4 P0 新增）
#------------------------------------------------------------------------------
perform_minimal() {
    local task="${1:-}"

    if [ -z "$task" ]; then
        echo "[flow-kit] 错误: minimal 需要任务描述" >&2
        echo "[flow-kit] 示例: ./flow-kit.sh minimal \"修复登录 bug\"" >&2
        exit 1
    fi

    echo "[flow-kit] ⚡ L0 极简模式启动"
    echo "[flow-kit] 任务: $task"
    echo "[flow-kit] 限制: 最多修改 3 个文件，跳过 Phase 1-3"
    echo ""
    echo "[flow-kit] 请在 Claude Code 中执行:"
    echo "/flow-kit:minimal \"$task\""
}

#------------------------------------------------------------------------------
# 卸载 flow-kit（v1.12.10 新增）
#------------------------------------------------------------------------------
perform_uninstall() {
    local confirm="${1:-}"

    echo "flow-kit v$(read_version) — 卸载程序"
    echo ""

    if [ "$confirm" != "--force" ]; then
        # 非 TTY 检查：CI/管道环境下需要 --force 参数
        if [ ! -t 0 ]; then
            echo "[flow-kit] 错误：非交互式环境需要 --force 参数确认卸载" >&2
            exit 1
        fi
        echo "⚠️  警告：此操作将删除以下内容："
        echo "   • .git/hooks/*        — Git hooks"
        echo "   • .flow-kit/          — 配置和日志"
        echo "   • .claude/           — 斜杠命令"
        echo ""
        read -r -p "确认卸载? (输入 'yes' 确认): " confirm
        if [ "$confirm" != "yes" ]; then
            echo "[flow-kit] 取消卸载"
            exit 0
        fi
    fi

    echo "[flow-kit] 开始卸载..."

    # 删除 Git hooks（仅删除 flow-kit 安装的 hooks）
    if [ -d ".git/hooks" ]; then
        local hook_files=()
        for hook in .git/hooks/pre-commit .git/hooks/post-merge .git/hooks/post-checkout .git/hooks/pre-push; do
            if [ -f "$hook" ] && grep -q "flow-kit" "$hook" 2>/dev/null; then
                rm -f "$hook"
                hook_files+=("$hook")
            fi
        done
        if [ ${#hook_files[@]} -gt 0 ]; then
            echo "[flow-kit] ✓ 已删除 flow-kit 安装的 Git hooks"
        else
            echo "[flow-kit] ✓ 未发现 flow-kit 安装的 Git hooks"
        fi
    fi

    # 删除配置目录
    if [ -d ".flow-kit" ]; then
        rm -rf .flow-kit
        echo "[flow-kit] ✓ 已删除 .flow-kit/"
    fi

    # 删除斜杠命令（保留 .claude 目录本身）
    if [ -d ".claude/commands" ]; then
        rm -rf .claude/commands
        echo "[flow-kit] ✓ 已删除 .claude/commands/"
    fi

    # 删除 settings.json（如果存在）
    if [ -f ".claude/settings.json" ]; then
        rm -f .claude/settings.json
        echo "[flow-kit] ✓ 已删除 .claude/settings.json"
    fi

    echo ""
    echo "[flow-kit] ✅ 卸载完成"
    echo "[flow-kit] 如需完全清理，可手动删除 flow-kit/ 目录"
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

# v1.12.9 改进：仅在直接执行时运行 main，source 时不执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
