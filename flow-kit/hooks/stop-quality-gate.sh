#!/bin/bash
set -euo pipefail

# === CLI ===
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat << 'EOHELP'
stop-quality-gate — Stop hook: 质量门禁

用法: stop-quality-gate

无参数运行，hook 自动生效。

-h, --help  显示此帮助
EOHELP
    exit 0
fi

# stop-quality-gate.sh — Stop hook: 质量门禁
# v2.7.0 P0 修复：除零错误 + set -euo pipefail
# Reference: smallnest/autoresearch PASSING_SCORE + Claude Code Stop hook

INPUT=$(cat)

if [[ -z "$INPUT" ]]; then
    exit 0
fi

if command -v jq >/dev/null 2>&1; then
    if ! echo "$INPUT" | jq -e . >/dev/null 2>&1; then
        exit 0
    fi
else
    exit 0
fi

# 防止无限循环
if [[ "$(echo "$INPUT" | jq -r '.stop_hook_active // false')" == "true" ]]; then
    exit 0
fi

#------------------------------------------------------------------------------
# B6 测试覆盖率检测（v2.7.0 新增，v2.7.0 修复除零错误）
#------------------------------------------------------------------------------
check_test_coverage() {
    # 使用 paths.sh 常量而非相对路径
    local SCRIPT_DIR
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/../lib/paths.sh" 2>/dev/null || true
    local coverage_file="${COVERAGE_DIR:-.flow-kit/coverage}/lcov.info"
    local threshold=80

    if [[ ! -f "$coverage_file" ]]; then
        # 无覆盖率文件，跳过 B6 检查
        return 0
    fi

    # 提取增量覆盖率
    local incremental_lines
    incremental_lines=$(grep "incremental.lines" "$coverage_file" 2>/dev/null | cut -d: -f2 || echo "0")
    local incremental_covered
    incremental_covered=$(grep "incremental.covered" "$coverage_file" 2>/dev/null | cut -d: -f2 || echo "0")

    # 校验数字
    [[ "$incremental_lines" =~ ^[0-9]+$ ]] || incremental_lines=0
    [[ "$incremental_covered" =~ ^[0-9]+$ ]] || incremental_covered=0

    # P0 修复：防止除零错误
    if [[ "$incremental_lines" -eq 0 ]]; then
        echo "[stop-quality-gate] ⚠️  无新增代码，跳过覆盖率检查"
        return 0
    fi

    local coverage_pct=$((incremental_covered * 100 / incremental_lines))

    if [[ "$coverage_pct" -lt "$threshold" ]]; then
        echo "[B6] 增量覆盖率 ${coverage_pct}% < ${threshold}%，未通过质量门禁" >&2
        echo "[B6] 请增加测试覆盖后重试" >&2
        exit 2
    fi

    return 0
}

#------------------------------------------------------------------------------
# B5/B6 联动检测
#------------------------------------------------------------------------------
if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
    # v2.7.0 P1 修复: 添加 120s 超时避免挂起
    if command -v timeout &>/dev/null; then
        timeout 120 npm test 2>&1 || {
            exit_code=$?
            if [[ $exit_code -eq 124 ]]; then
                echo "[stop-quality-gate] ⏱️  测试超时（120s），请优化测试套件" >&2
            fi
            echo "测试未通过。请修复后再结束。" >&2
            exit 2
        }
    elif ! npm test 2>&1; then
        echo "测试未通过。请修复后再结束。" >&2
        exit 2
    fi
fi

check_test_coverage

#------------------------------------------------------------------------------
# 产出物检查（v3.6.0）
#------------------------------------------------------------------------------
check_artifacts() {
    local project_dir="${CLAUDE_PROJECT_DIR:-}"
    if [[ -z "$project_dir" ]]; then
        project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    fi
    local session_file="$project_dir/.flow-kit/session-state.json"
    if [[ ! -f "$session_file" ]]; then
        return 0
    fi

    command -v jq &>/dev/null || return 0
    local current_phase
    current_phase=$(jq -r '.phase // empty' "$session_file" 2>/dev/null || echo "")
    if [[ -z "$current_phase" ]]; then
        return 0
    fi

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local phases_dir="$script_dir/../phases"
    local phase_file
    phase_file=$(find "$phases_dir" -name "*.md" -path "*$current_phase*" 2>/dev/null | head -1)
    if [[ -z "$phase_file" ]]; then
        return 0
    fi

    local script_dir2
    script_dir2="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$script_dir2/../lib/front-matter.sh" 2>/dev/null || return 0
    local artifacts_json
    artifacts_json=$(parse_front_matter "$phase_file" | jq -r '.expected_artifacts // []' 2>/dev/null || echo "[]")

    local count
    count=$(echo "$artifacts_json" | jq 'length' 2>/dev/null || echo "0")
    local i=0
    while (( i < count )); do
        local artifact
        artifact=$(echo "$artifacts_json" | jq -r ".[$i]" 2>/dev/null)
        if [[ -n "$artifact" && ! -f "$project_dir/$artifact" ]]; then
            echo "[quality-gate] 产出物缺失：$artifact" >&2
        fi
        i=$((i + 1))
    done

    return 0
}

check_artifacts

exit 0

# v2.7.0 修复：URL 放在 bash 注释中避免被解析
# 参考来源：
# - Claude Code Hooks 官方文档：https://docs.anthropic.com/en/docs/claude-code/hooks
# - garrytan/gstack：https://github.com/garrytan/gstack
# - smallnest/autoresearch：https://github.com/smallnest/autoresearch
# - Jest Coverage：https://jestjs.io/docs/coverage
