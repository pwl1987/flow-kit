#!/bin/bash
# tmux-aggregate.sh — v3.3.0 P3 tmux 并行结果聚合
# 收集各 worktree 输出，检测冲突，生成报告

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/preflight.sh"
source "$SCRIPT_DIR/../lib/session-state.sh"

require_cmd tmux "tmux 未安装"
require_jq

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
FORMAT="console"
SESSION_NAME=""

#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
tmux-aggregate.sh — 聚合 tmux 并行执行结果

用法:
  ./tmux-aggregate.sh [选项]

选项:
  --format <格式>    输出格式: console|md|json（默认: console）
  --session <名称>   tmux 会话名称（默认: 从 manifest 读取）
  -h, --help         显示帮助信息

示例:
  ./tmux-aggregate.sh
  ./tmux-aggregate.sh --format md
  ./tmux-aggregate.sh --format json --session my-session
EOF
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --format)   FORMAT="$2"; shift 2 ;;
            --session)  SESSION_NAME="$2"; shift 2 ;;
            -h|--help)  show_help; exit 0 ;;
            *)          echo "[tmux-aggregate] 未知选项: $1" >&2; exit 1 ;;
        esac
    done
}

#------------------------------------------------------------------------------
# 读取 manifest
#------------------------------------------------------------------------------
read_manifest() {
    local manifest_file="$TMP_DIR/tmux-manifest.json"

    if [ ! -f "$manifest_file" ]; then
        echo "[tmux-aggregate] 错误: manifest 不存在" >&2
        exit 1
    fi

    if [ -z "$SESSION_NAME" ]; then
        SESSION_NAME=$(jq -r '.session_name' "$manifest_file")
    fi

    cat "$manifest_file"
}

#------------------------------------------------------------------------------
# 收集单个 worktree 输出
#------------------------------------------------------------------------------
collect_worktree_output() {
    local wt_path="$1"
    local wt_index="$2"

    local status="unknown"
    local files_modified="[]"
    local summary=""

    # 检查完成标记文件
    local done_file="$wt_path/.flow-kit-done"
    if [ -f "$done_file" ]; then
        status=$(cat "$done_file" 2>/dev/null || echo "done")
    fi

    # 检查 SUMMARY.md
    if [ -f "$wt_path/SUMMARY.md" ]; then
        summary=$(head -5 "$wt_path/SUMMARY.md" | tr '\n' ' ' | cut -c1-200)
    fi

    # 检查修改的文件
    if git -C "$wt_path" diff --name-only HEAD 2>/dev/null | head -20 > /dev/null; then
        files_modified=$(git -C "$wt_path" diff --name-only HEAD 2>/dev/null | jq -R -s 'split("\n") | map(select(length > 0))' 2>/dev/null || echo "[]")
    fi

    jq -n \
        --argjson index "$wt_index" \
        --arg path "$wt_path" \
        --arg status "$status" \
        --arg summary "$summary" \
        --argjson files "$files_modified" \
        '{index: $index, path: $path, status: $status, summary: $summary, files_modified: $files}'
}

#------------------------------------------------------------------------------
# 检测文件冲突
#------------------------------------------------------------------------------
detect_file_conflicts() {
    local results="$1"
    local conflicts="[]"

    local total
    total=$(echo "$results" | jq 'length')

    for ((i=0; i<total; i++)); do
        for ((j=i+1; j<total; j++)); do
            local files_i files_j
            files_i=$(echo "$results" | jq -r ".[$i].files_modified[]")
            files_j=$(echo "$results" | jq -r ".[$j].files_modified[]")

            # 找交集
            local overlap
            overlap=$(comm -12 <(echo "$files_i" | sort) <(echo "$files_j" | sort) 2>/dev/null || echo "")

            if [ -n "$overlap" ]; then
                while IFS= read -r file; do
                    [ -z "$file" ] && continue
                    local tmp
                    tmp=$(jq --arg file "$file" \
                        --argjson a "$i" --argjson b "$j" \
                        '. + [{file: $file, worktree_a: $a, worktree_b: $b}]' \
                        <<< "$conflicts")
                    conflicts="$tmp"
                done <<< "$overlap"
            fi
        done
    done

    echo "$conflicts"
}

#------------------------------------------------------------------------------
# 生成报告
#------------------------------------------------------------------------------
generate_report() {
    local results="$1"
    local conflicts="$2"
    local format="$3"

    local total successful failed
    total=$(echo "$results" | jq 'length')
    successful=$(echo "$results" | jq '[.[] | select(.status == "done" or .status == "SUCCESS")] | length')
    failed=$(echo "$results" | jq '[.[] | select(.status == "error" or .status == "FAILED")] | length')

    case "$format" in
        json)
            jq -n \
                --argjson results "$results" \
                --argjson conflicts "$conflicts" \
                --argjson total "$total" \
                --argjson ok "$successful" \
                --argjson fail "$failed" \
                --arg session "$SESSION_NAME" \
                '{session: $session, total: $total, successful: $ok, failed: $fail, results: $results, conflicts: $conflicts}'
            ;;
        md)
            echo "# tmux 并行执行报告"
            echo ""
            echo "会话: $SESSION_NAME | 成功: $successful | 失败: $failed | 总计: $total"
            echo ""
            echo "## 结果"
            echo ""
            echo "| Worker | 状态 | 修改文件 | 摘要 |"
            echo "|--------|------|----------|------|"
            echo "$results" | jq -c '.[]' | while IFS= read -r r; do
                local idx status file_count summary
                idx=$(echo "$r" | jq -r '.index')
                status=$(echo "$r" | jq -r '.status')
                file_count=$(echo "$r" | jq '.files_modified | length')
                summary=$(echo "$r" | jq -r '.summary' | cut -c1-40)
                echo "| $idx | $status | $file_count | $summary |"
            done

            local conflict_count
            conflict_count=$(echo "$conflicts" | jq 'length')
            if [ "$conflict_count" -gt 0 ]; then
                echo ""
                echo "## 冲突 ($conflict_count)"
                echo ""
                echo "$conflicts" | jq -c '.[]' | while IFS= read -r c; do
                    local file a b
                    file=$(echo "$c" | jq -r '.file')
                    a=$(echo "$c" | jq -r '.worktree_a')
                    b=$(echo "$c" | jq -r '.worktree_b')
                    echo "- \`$file\`: worker-$a ↔ worker-$b"
                done
            fi
            ;;
        console)
            echo "[aggregate] session=$SESSION_NAME total=$total ok=$successful fail=$failed"

            echo "$results" | jq -c '.[]' | while IFS= read -r r; do
                local idx status file_count
                idx=$(echo "$r" | jq -r '.index')
                status=$(echo "$r" | jq -r '.status')
                file_count=$(echo "$r" | jq '.files_modified | length')
                echo "  worker-$idx: $status ($file_count files)"
            done

            local conflict_count
            conflict_count=$(echo "$conflicts" | jq 'length')
            if [ "$conflict_count" -gt 0 ]; then
                echo "[aggregate] ⚠️  $conflict_count 个文件冲突"
            fi
            ;;
    esac
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    parse_args "$@"

    local manifest
    manifest=$(read_manifest)

    local worktree_count
    worktree_count=$(echo "$manifest" | jq '.worktree_count')

    echo "[aggregate] 收集 $worktree_count 个 worktree 结果..."

    # 收集结果
    local results="["
    local first=true

    for ((i=1; i<=worktree_count; i++)); do
        local wt_path
        wt_path=$(echo "$manifest" | jq -r ".worktrees[$((i-1))].path")

        if [ ! -d "$wt_path" ]; then
            continue
        fi

        local wt_result
        wt_result=$(collect_worktree_output "$wt_path" "$i")

        if [ "$first" = true ]; then
            results+="$wt_result"
            first=false
        else
            results+=",$wt_result"
        fi
    done
    results+="]"

    # 检测冲突
    local conflicts
    conflicts=$(detect_file_conflicts "$results")

    # 生成报告
    echo ""
    generate_report "$results" "$conflicts" "$FORMAT"

    session_history_add "tmux-aggregate" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
