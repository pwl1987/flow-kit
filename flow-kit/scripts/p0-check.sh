#!/bin/bash
# p0-check.sh — P0 变更自动检测
# v1.12.10 新增：检测 P0 变更并强制执行审批流程

set -euo pipefail

# v1.12.10 P1 修复：引入统一错误处理框架
P0_CHECK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$P0_CHECK_DIR/../lib/error-handler.sh"

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

#------------------------------------------------------------------------------
# 日志函数（覆盖 error-handler.sh 的实现以支持彩色输出和单参数接口）
#------------------------------------------------------------------------------
log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

#------------------------------------------------------------------------------
# 检查文件是否为 P0
#------------------------------------------------------------------------------
is_p0_file() {
    local file="$1"
    local basename=$(basename "$file")

    if [[ "$basename" =~ BREAKING-CHANGE|breaking-change|BREAKING\.CHANGE ]]; then
        return 0
    fi

    if [[ "$file" =~ migration/|migrations/|\.sql$ ]]; then
        return 0
    fi

    return 1
}

#------------------------------------------------------------------------------
# 检测变更列表中的 P0 项
#------------------------------------------------------------------------------
check_p0_files() {
    local files="$1"
    local p0_files=()
    local p0_reasons=()

    while IFS= read -r file; do
        if [ -z "$file" ]; then
            continue
        fi

        if is_p0_file "$file"; then
            local reason=""
            if [[ "$file" =~ BREAKING|breaking ]]; then
                reason="Breaking change detected"
            elif [[ "$file" =~ migration|sql ]]; then
                reason="Database schema change detected"
            else
                reason="P0 file detected"
            fi
            p0_files+=("$file")
            p0_reasons+=("$reason")
        fi
    done <<< "$files"

    if [ ${#p0_files[@]} -gt 0 ]; then
        echo "P0_BLOCK"
        return 1
    fi

    echo "OK"
    return 0
}

#------------------------------------------------------------------------------
# 获取变更文件列表
#------------------------------------------------------------------------------
get_changed_files() {
    local base_branch="${1:-origin/main}"

    if git rev-parse "$base_branch" >/dev/null 2>&1; then
        git diff --name-only "$base_branch...HEAD" 2>/dev/null || echo ""
    else
        git status --porcelain 2>/dev/null | awk '{print $2}' || echo ""
    fi
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local files="${1:-}"
    local base_branch="${2:-origin/main}"

    echo "=========================================="
    echo "P0 Change Detector"
    echo "=========================================="
    echo ""

    if [ -z "$files" ]; then
        log_info "未指定文件列表，从 git diff 获取..."
        files=$(get_changed_files "$base_branch")
    fi

    if [ -z "$files" ]; then
        log_info "未检测到任何文件变更"
        exit 0
    fi

    echo "检测到的文件变更:"
    echo "$files" | head -20
    echo ""

    local result
    result=$(check_p0_files "$files") || result="P0_BLOCK"

    if [ "$result" = "P0_BLOCK" ]; then
        log_error "=========================================="
        log_error "P0 变更检测阻断"
        log_error "=========================================="
        echo ""
        echo "检测到高风险变更，需要审批后才能继续。"
        echo ""
        echo "请执行以下步骤:"
        echo "  1. 确认变更必要性"
        echo "  2. 获取 admin 或 reviewer 角色审批"
        echo "  3. 执行: /flow-kit:p0-approve"
        echo ""
        echo "或使用 --force 跳过检查（危险）:"
        echo "  /flow-kit:p0 --force"
        echo ""
        exit 1
    else
        log_info "未检测到 P0 变更，可以继续执行"
        exit 0
    fi
}

main "$@"