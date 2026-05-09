#!/bin/bash
# pr-generator.sh — PR 描述生成
# v1.12.10 新增：实现 /flow-kit:pr-description 命令

set -euo pipefail

#------------------------------------------------------------------------------
# 获取 git 仓库根目录
#------------------------------------------------------------------------------
get_git_root() {
    git rev-parse --show-toplevel 2>/dev/null || echo ""
}

#------------------------------------------------------------------------------
# 检查是否有未提交的更改
#------------------------------------------------------------------------------
has_uncommitted_changes() {
    [ -n "$(git status --porcelain 2>/dev/null)" ]
}

#------------------------------------------------------------------------------
# 验证分支名格式（防止命令注入）
#------------------------------------------------------------------------------
validate_branch_name() {
    local branch_name="$1"

    if [[ "$branch_name" =~ ^[a-zA-Z0-9/_.\-@]+$ ]]; then
        return 0
    fi
    return 1
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local base_branch="${1:-main}"
    local head_branch="${2:-HEAD}"

    local git_root
    git_root=$(get_git_root)

    if [ -z "$git_root" ]; then
        echo "[ERROR] 当前目录不是 git 仓库"
        return 1
    fi

    echo "=========================================="
    echo "PR Description Generator"
    echo "=========================================="
    echo "Base: $base_branch"
    echo "Head: $head_branch"
    echo ""

    # P0 修复：验证分支名格式
    if ! validate_branch_name "$base_branch"; then
        echo "[ERROR] 无效的分支名: $base_branch（只允许字母、数字、/、_、-、.、@）"
        return 1
    fi
    if ! validate_branch_name "$head_branch"; then
        echo "[ERROR] 无效的分支名: $head_branch（只允许字母、数字、/、_、-、.、@）"
        return 1
    fi

    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "detached")

    echo "## Summary"
    echo ""
    echo "**Branch**: $current_branch"
    echo ""
    echo "## What Changed"
    echo '```'
    if git diff --stat "$base_branch..$head_branch" 2>/dev/null; then
        :  # diff 输出在上方
    else
        echo "No changes detected between $base_branch and $head_branch"
    fi
    echo '```'
    echo ""
    echo "## Commits"
    echo '```'
    if git log --oneline "$base_branch..$head_branch" 2>/dev/null; then
        :  # log 输出在上方
    else
        echo "No commits in this range"
    fi
    echo '```'
    echo ""
    echo "## Test Results"
    echo ""
    echo "_Pending - run tests and update_"
    echo ""
    echo "## Rollback Plan"
    echo ""
    echo "To rollback this change, run:"
    echo '```bash'
    echo "# Find the commit to revert"
    echo "git log --oneline $base_branch..$head_branch | tail -1 || echo '无提交'"
    echo ""
    echo "# Revert the changes"
    echo "git revert <commit-hash>"
    echo '```'
    echo ""

    if has_uncommitted_changes; then
        echo "## Uncommitted Changes"
        echo '```'
        git status --short
        echo '```'
        echo ""
    fi

    echo "---"
    echo "*Generated at $(date '+%Y-%m-%d %H:%M:%S')*"
}

main "$@"