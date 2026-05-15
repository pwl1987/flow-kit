#!/bin/bash
# install.sh — flow-kit 自动化安装部署脚本
# v3.3.0 P0 新增
# 功能：OS 检测、依赖检查、自动安装、命令注册、Hooks 验证、功能测试

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载依赖
source "$SCRIPT_DIR/../lib/preflight.sh"
source "$SCRIPT_DIR/../lib/paths.sh"

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
INTERACTIVE=true
SILENT=false

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
install.sh — flow-kit 自动化安装部署脚本

用法:
  ./install.sh [选项]

选项:
  --interactive    交互式安装（默认）
  --silent         静默安装，自动批准所有操作
  -h, --help       显示帮助信息

功能:
  1. OS 检测（Linux/macOS/WSL）
  2. 依赖检查（bash/jq/python3/git）
  3. 自动安装提示
  4. 斜杠命令注册
  5. Hooks 配置验证
  6. 功能测试

示例:
  ./install.sh                # 交互式安装
  ./install.sh --silent       # 静默安装
EOF
}

#------------------------------------------------------------------------------
# 日志函数
#------------------------------------------------------------------------------
log_info() {
    echo "[install] $*"
}

log_success() {
    echo "[install] ✅ $*"
}

log_error() {
    echo "[install] ❌ $*" >&2
}

log_warn() {
    echo "[install] ⚠️  $*"
}

#------------------------------------------------------------------------------
# OS 检测
#------------------------------------------------------------------------------
detect_os() {
    local os_type
    os_type=$(uname -s)

    case "$os_type" in
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "WSL"
            else
                echo "Linux"
            fi
            ;;
        Darwin)
            echo "macOS"
            ;;
        *)
            echo "Unknown"
            ;;
    esac
}

#------------------------------------------------------------------------------
# 获取包管理器
#------------------------------------------------------------------------------
get_package_manager() {
    local os="$1"

    case "$os" in
        Linux|WSL)
            if command -v apt-get &>/dev/null; then
                echo "apt-get"
            elif command -v yum &>/dev/null; then
                echo "yum"
            elif command -v dnf &>/dev/null; then
                echo "dnf"
            else
                echo "unknown"
            fi
            ;;
        macOS)
            if command -v brew &>/dev/null; then
                echo "brew"
            else
                echo "none"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

#------------------------------------------------------------------------------
# 依赖检查
#------------------------------------------------------------------------------
check_dependency() {
    local cmd="$1"
    local os="$2"
    local pkg_mgr="$3"

    if command -v "$cmd" &>/dev/null; then
        log_success "$cmd 已安装"
        return 0
    fi

    log_warn "$cmd 未安装"

    # 生成安装命令
    local install_cmd=""
    case "$os" in
        Linux|WSL)
            case "$pkg_mgr" in
                apt-get)
                    install_cmd="sudo apt-get update && sudo apt-get install -y $cmd"
                    ;;
                yum)
                    install_cmd="sudo yum install -y $cmd"
                    ;;
                dnf)
                    install_cmd="sudo dnf install -y $cmd"
                    ;;
            esac
            ;;
        macOS)
            if [[ "$pkg_mgr" == "brew" ]]; then
                install_cmd="brew install $cmd"
            else
                log_error "Homebrew 未安装。请访问 https://brew.sh 安装 Homebrew"
                return 1
            fi
            ;;
    esac

    if [[ -z "$install_cmd" ]]; then
        log_error "无法确定 $cmd 的安装命令"
        return 1
    fi

    if [[ "$INTERACTIVE" == true ]]; then
        echo ""
        echo "安装 $cmd:"
        echo "  $install_cmd"
        echo ""
        read -p "是否执行安装？(y/n): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            eval "$install_cmd"
        else
            log_warn "跳过 $cmd 安装"
            return 1
        fi
    else
        log_info "自动安装 $cmd: $install_cmd"
        eval "$install_cmd"
    fi

    # 验证安装
    if command -v "$cmd" &>/dev/null; then
        log_success "$cmd 安装成功"
        return 0
    else
        log_error "$cmd 安装失败"
        return 1
    fi
}

#------------------------------------------------------------------------------
# 检查所有依赖
#------------------------------------------------------------------------------
check_all_dependencies() {
    local os="$1"
    local pkg_mgr="$2"
    local failed=0

    log_info "检查依赖..."
    echo ""

    # bash 版本检查
    local bash_major="${BASH_VERSINFO[0]:-0}"
    if [[ "$bash_major" -ge 4 ]]; then
        log_success "bash $BASH_VERSION (>= 4.0)"
    else
        log_error "bash 版本过低: $BASH_VERSION (需要 >= 4.0)"
        if [[ "$os" == "macOS" ]]; then
            log_info "macOS 安装: brew install bash"
        fi
        failed=$((failed + 1))
    fi

    # 核心依赖
    for cmd in jq git; do
        if ! check_dependency "$cmd" "$os" "$pkg_mgr"; then
            failed=$((failed + 1))
        fi
    done

    # python3（可选）
    if command -v python3 &>/dev/null; then
        log_success "python3 已安装（可选）"
    else
        log_warn "python3 未安装（可选依赖，部分功能可能不可用）"
    fi

    echo ""

    if [[ $failed -gt 0 ]]; then
        log_error "$failed 个依赖缺失或安装失败"
        return 1
    fi

    log_success "所有依赖检查通过"
    return 0
}

#------------------------------------------------------------------------------
# 注册斜杠命令
#------------------------------------------------------------------------------
register_commands() {
    log_info "注册斜杠命令..."

    if [[ ! -f "$SCRIPTS_DIR/generate-commands.sh" ]]; then
        log_error "generate-commands.sh 不存在"
        return 1
    fi

    if bash "$SCRIPTS_DIR/generate-commands.sh" --force; then
        log_success "斜杠命令注册成功"
        return 0
    else
        log_error "斜杠命令注册失败"
        return 1
    fi
}

#------------------------------------------------------------------------------
# 验证 Hooks 配置
#------------------------------------------------------------------------------
verify_hooks() {
    log_info "验证 Hooks 配置..."

    local settings_file="${CLAUDE_PROJECT_DIR:-$PROJECT_DIR}/.claude/settings.json"

    if [[ ! -f "$settings_file" ]]; then
        log_warn "settings.json 不存在: $settings_file"
        log_info "Hooks 配置需要手动设置"
        return 0
    fi

    # 检查是否包含 flow-kit hooks
    if grep -q "flow-kit" "$settings_file" 2>/dev/null; then
        log_success "Hooks 配置已存在"
        return 0
    else
        log_warn "未检测到 flow-kit Hooks 配置"
        log_info "运行 /flow-kit:hooks 查看配置指南"
        return 0
    fi
}

#------------------------------------------------------------------------------
# 运行功能测试
#------------------------------------------------------------------------------
run_tests() {
    log_info "运行功能测试..."
    echo ""

    if [[ ! -f "$FLOW_KIT_DIR/tests/run-tests.sh" ]]; then
        log_error "run-tests.sh 不存在"
        return 1
    fi

    if bash "$FLOW_KIT_DIR/tests/run-tests.sh"; then
        echo ""
        log_success "功能测试通过"
        return 0
    else
        echo ""
        log_error "功能测试失败"
        return 1
    fi
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --interactive)
                INTERACTIVE=true
                SILENT=false
                shift
                ;;
            --silent)
                INTERACTIVE=false
                SILENT=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done

    echo ""
    echo "=========================================="
    echo "  flow-kit 自动化安装"
    echo "=========================================="
    echo ""

    # 1. OS 检测
    log_info "检测操作系统..."
    local os
    os=$(detect_os)
    log_info "OS: $os"

    local pkg_mgr
    pkg_mgr=$(get_package_manager "$os")
    log_info "包管理器: $pkg_mgr"
    echo ""

    # 2. 依赖检查
    if ! check_all_dependencies "$os" "$pkg_mgr"; then
        log_error "依赖检查失败，安装中止"
        exit 1
    fi

    # 3. 注册斜杠命令
    if ! register_commands; then
        log_error "命令注册失败，安装中止"
        exit 1
    fi
    echo ""

    # 4. 验证 Hooks
    verify_hooks
    echo ""

    # 5. 运行测试
    if [[ "$INTERACTIVE" == true ]]; then
        read -p "是否运行功能测试？(y/n): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if ! run_tests; then
                log_warn "测试失败，但安装已完成"
            fi
        else
            log_info "跳过功能测试"
        fi
    elif [[ "$SILENT" == false ]]; then
        if ! run_tests; then
            log_warn "测试失败，但安装已完成"
        fi
    fi

    echo ""
    echo "=========================================="
    log_success "flow-kit 安装完成"
    echo "=========================================="
    echo ""
    log_info "下一步:"
    echo "  1. 运行 /flow-kit:init \"变更描述\" 开始第一个变更"
    echo "  2. 运行 /flow-kit:hooks 查看 Hooks 配置指南"
    echo "  3. 运行 /flow-kit:status 查看当前状态"
    echo ""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
