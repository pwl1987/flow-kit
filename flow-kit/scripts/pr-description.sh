#!/bin/bash
# pr-description.sh — PR 描述自动生成
# v2.7.0 新增：实现 /flow-kit:pr-description 命令

set -euo pipefail

#------------------------------------------------------------------------------
# 依赖检查
#------------------------------------------------------------------------------
if ! command -v gh &>/dev/null; then
    echo "[ERROR] gh CLI 未安装，无法生成 PR 描述" >&2
    echo "[INFO] 安装: brew install gh" >&2
    exit 1
fi

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
pr-description.sh — PR 描述自动生成

用法:
  ./pr-description.sh                    生成当前分支的 PR 描述
  ./pr-description.sh --branch <name>    生成指定分支的 PR 描述
  ./pr-description.sh --preview           仅预览，不创建 PR

示例:
  ./pr-description.sh
  ./pr-description.sh --branch feature-x
  ./pr-description.sh --preview
EOF
}

#------------------------------------------------------------------------------
# 获取 git 历史信息
#------------------------------------------------------------------------------
get_git_info() {
    local branch="${1:-}"

    local commits
    local changed_files
    if [ -n "$branch" ]; then
        commits=$(git log --oneline -20 "$branch" 2>/dev/null || echo "")
        changed_files=$(git diff --stat "origin/main..$branch" 2>/dev/null || echo "")
    else
        commits=$(git log --oneline -20 2>/dev/null || echo "")
        changed_files=$(git diff --stat HEAD~5..HEAD 2>/dev/null || echo "")
    fi

    echo "$commits"
    echo "---"
    echo "$changed_files"
}

#------------------------------------------------------------------------------
# 生成 PR 描述
#------------------------------------------------------------------------------
generate_pr_description() {
    local branch="${1:-}"
    local preview="${2:-false}"

    echo "=========================================="
    echo "PR Description Generator"
    echo "=========================================="

    # 获取当前分支
    if [ -z "$branch" ]; then
        branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    fi

    echo "Branch: $branch"
    echo ""

    # 检查是否有 git 历史
    if ! git log --oneline -1 >/dev/null 2>&1; then
        echo "[INFO] No git history available. PR description requires committed changes."
        return 1
    fi

    # 获取提交信息
    local git_info
    git_info=$(get_git_info "$branch")

    local commits
    local changed_files
    commits=$(printf '%s\n' "$git_info" | sed '/^---$/,$d')
    changed_files=$(printf '%s\n' "$git_info" | sed '1,/^---$/d')

    echo "Recent Commits:"
    echo "$commits" | head -10
    echo ""

    echo "Changed Files:"
    echo "$changed_files"
    echo ""

    # 生成 PR 描述
    cat << 'EOF'
## Summary
{Fill from template}

## What Changed
EOF

    echo "$changed_files"
    echo ""

    cat << 'EOF'

## Motivation
{AI-generated: Why this change was needed}

## Technical Details
{AI-generated: Key decisions and trade-offs}

## Test Results
{Phase 5 verification summary}

## Rollback Plan
{Command or reference}
EOF

    # 如果不是 preview，创建 PR
    if [ "$preview" = "false" ]; then
        echo ""
        echo "[INFO] 使用 --preview 查看完整输出，或重定向到文件"
        echo "[INFO] gh pr create 时会自动打开编辑器填写描述"
    fi
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local branch=""
    local preview="false"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --branch)
                branch="$2"
                shift 2
                ;;
            --preview)
                preview="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "[ERROR] 未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done

    generate_pr_description "$branch" "$preview"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi