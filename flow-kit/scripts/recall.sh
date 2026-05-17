#!/bin/bash
# recall.sh — /recall 命令：项目上下文摘要
# v3.7.0 新增

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh" 2>/dev/null || true

CACHE_FILE="${PATHS_PROJECT_DIR:-$CLAUDE_PROJECT_DIR}/.flow-kit/recall-cache.md"
CACHE_TTL=300

usage() {
    cat << 'EOF'
/recall — 项目上下文摘要

用法:
  /recall           显示项目摘要（缓存 5 分钟）
  /recall --refresh 强制刷新
  /recall --help    显示帮助
EOF
}

# 检查缓存是否有效
_is_cache_valid() {
    local cache="$1"
    if [[ ! -f "$cache" ]]; then
        return 1
    fi
    local cache_ts
    cache_ts=$(stat -c %Y "$cache" 2>/dev/null || stat -f %m "$cache" 2>/dev/null || echo 0)
    local now
    now=$(date +%s 2>/dev/null || echo 0)
    local elapsed=$((now - cache_ts))
    [[ $elapsed -lt $CACHE_TTL ]]
}

# 生成摘要
_generate_summary() {
    local project_dir="${PATHS_PROJECT_DIR:-$CLAUDE_PROJECT_DIR}"
    local version_file="$project_dir/../flow-kit/VERSION"
    local session_file="$project_dir/.flow-kit/session-state.json"
    local plan_file="$project_dir/.flow-kit/auto-plan.json"
    local changelog="$project_dir/../flow-kit/CHANGELOG.md"

    echo "# 项目上下文摘要"
    echo "_生成时间: $(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date)_"
    echo ""

    # 版本
    if [[ -f "$version_file" ]]; then
        echo "**版本**: $(head -1 "$version_file")"
    fi

    # 当前阶段
    if command -v jq &>/dev/null && [[ -f "$session_file" ]]; then
        local phase status
        phase=$(jq -r '.phase // "未知"' "$session_file" 2>/dev/null)
        status=$(jq -r '.status // "未知"' "$session_file" 2>/dev/null)
        echo "**当前阶段**: $phase ($status)"
    fi

    # 最近 git 提交
    echo ""
    echo "### 最近提交"
    if git -C "$project_dir" log --oneline -5 2>/dev/null; then
        :
    else
        echo "_无 git 历史_"
    fi

    # CHANGELOG 最新
    if [[ -f "$changelog" ]]; then
        echo ""
        echo "### 最新变更"
        head -10 "$changelog"
    fi
}

# 原子写入缓存
_write_cache() {
    local cache="$1"
    local content="$2"
    local tmp
    tmp=$(mktemp "${cache}.XXXXXX")
    echo "$content" > "$tmp"
    mv "$tmp" "$cache"
}

main() {
    local force_refresh=0

    case "${1:---recall}" in
        --refresh)  force_refresh=1 ;;
        --help|-h)  usage; return 0 ;;
    esac

    mkdir -p "$(dirname "$CACHE_FILE")" 2>/dev/null || true

    if [[ $force_refresh -eq 0 ]] && _is_cache_valid "$CACHE_FILE"; then
        cat "$CACHE_FILE"
        return 0
    fi

    local summary
    summary=$(_generate_summary)
    _write_cache "$CACHE_FILE" "$summary"
    echo "$summary"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
