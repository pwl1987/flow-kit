#!/bin/bash
# generate-commands.sh — flow-kit 斜杠命令生成器 (精简版 v2.6.1)
#
# 生成 21 个核心命令，移除所有 dev-/meta-/team-/ops- 前缀变体

set -euo pipefail

FORCE=false
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# REPO_ROOT: flow-kit 根目录（scripts/ → flow-kit/）
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# OUTPUT_PATH: 项目根目录 .claude/commands/（优先 CLAUDE_PROJECT_DIR，回退向上两级）
# CLAUDE_PROJECT_DIR 由 Claude Code 设置，总是指向项目根目录
# 向上查找项目根目录（优先 CLAUDE_PROJECT_DIR，回退查找 .git）
_find_project_root() {
    local dir="$REPO_ROOT"
    while [ "$dir" != "/" ]; do
        [ -d "$dir/.git" ] && echo "$dir" && return
        dir="$(dirname "$dir")"
    done
    cd "$REPO_ROOT/../.." && pwd
}
readonly OUTPUT_PATH="${CLAUDE_PROJECT_DIR:-$(_find_project_root)}/.claude/commands"

declare -A CORE_COMMANDS=(
  ["init"]="flow-kit/commands/init-change.md"
  ["health"]="flow-kit/commands/M-health.md"
  ["scan"]="flow-kit/commands/I-intel-scan.md"
  ["next"]="flow-kit/GO.md"
  ["status"]="flow-kit/GO.md"
  ["mode"]="flow-kit/GO.md"
  ["guard"]="flow-kit/commands/careful.md"
  ["hooks"]="flow-kit/commands/hooks-guide.md"
  ["register-commands"]="flow-kit/commands/register-commands.md"
  ["generate-commands"]="flow-kit/commands/generate-commands.md"
  ["archive"]="flow-kit/commands/archive.md"
  ["scale"]="flow-kit/commands/scale-level.md"
)

declare -A PHASE_COMMANDS=(
  ["phase-0"]="变更立项"
  ["phase-1"]="需求澄清"
  ["phase-2"]="架构设计"
  ["phase-3"]="任务拆解"
  ["phase-4"]="开发执行"
  ["phase-5"]="测试验证"
  ["phase-6"]="代码审查"
  ["phase-7"]="集成归档"
  ["phase-8"]="变更回滚"
)

declare -A PHASE_DIRS=(
  ["phase-0"]="0-change"
  ["phase-1"]="1-requirement"
  ["phase-2"]="2-design"
  ["phase-3"]="3-task"
  ["phase-4"]="4-dev"
  ["phase-5"]="5-test"
  ["phase-6"]="6-review"
  ["phase-7"]="7-integration"
  ["phase-8"]="8-rollback"
)

parse_args() {
  FORCE=false
  while [[ $# -gt 0 ]]; do
    case $1 in
      --force)
        FORCE=true
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
}

extract_description() {
  local file="$1"
  local default="$2"

  if [[ ! -f "$file" ]]; then
    printf '%s\n' "$default"
    return
  fi

  local desc
  desc=$(sed -n '/^## 目的/,/^##/p' "$file" 2>/dev/null | grep -v "^##" | grep -v "^$" | head -1 | xargs)
  if [[ -n "$desc" ]]; then
    printf '%s\n' "$desc"
    return
  fi

  desc=$(sed -n '2p' "$file" 2>/dev/null | sed 's/^>[[:space:]]*//' | sed 's/【[^】]*】//g')
  if [[ -n "$desc" && ${#desc} -gt 3 ]]; then
    printf '%s\n' "$desc"
    return
  fi

  printf '%s\n' "$default"
}

generate_entry() {
  local cmd_name="$1"
  local description="$2"
  local reference="$3"
  local output_file="$4"

  {
    printf '%s\n' '---'
    printf 'description: %s\n' "$description"
    printf '%s\n' 'category: dev'
    printf 'reference: %s\n' "$reference"
    printf '%s\n' '---'
    printf '/flow-kit:%s: %s\n' "$cmd_name" "$description"
  } > "$output_file"
}

generate_phase_entry() {
  local phase="$1"
  local name="$2"
  local phase_dir="$3"
  local output_file="$4"
  local phase_num="${phase#phase-}"

  {
    printf '%s\n' '---'
    printf 'description: %s - %s\n' "$name" "$phase"
    printf '%s\n' 'category: dev'
    printf 'reference: flow-kit/phases/%s/\n' "$phase_dir"
    printf 'execute: bash flow-kit/scripts/phase-executor.sh %s\n' "$phase_num"
    printf '%s\n' '---'
    printf '/flow-kit:%s: %s\n' "$phase" "$name"
  } > "$output_file"
}

main() {
  parse_args "$@"

  echo "=========================================="
  echo "flow-kit 斜杠命令生成器 v2.6.1 (精简版)"
  echo "=========================================="
  echo "输出目录: $OUTPUT_PATH"
  echo "模式: $([ "$FORCE" == "true" ] && echo "force" || echo "incremental")"
  echo "=========================================="
  echo ""

  mkdir -p "$OUTPUT_PATH"

  # Phase 2: 清理旧格式命令（dash 前缀 + 无前缀重复）
  echo ""
  echo "--- 清理旧格式命令 ---"
  local cleaned=0

  # 删除 dash 前缀旧格式（flow-kit-scan.md → 已有 flow-kit:scan.md）
  while IFS= read -r -d '' f; do
    rm -f "$f"
    echo "[清理] $(basename "$f")"
    cleaned=$((cleaned + 1))
  done < <(find "$OUTPUT_PATH" -maxdepth 1 -name "flow-kit-*.md" ! -name "flow-kit:*" -print0 2>/dev/null || true)

  # 删除旧命名空间变体（flow-kit:dev-*, flow-kit:team-*, flow-kit:meta-*, flow-kit:ops-*）
  while IFS= read -r -d '' f; do
    rm -f "$f"
    echo "[清理] $(basename "$f")"
    cleaned=$((cleaned + 1))
  done < <(find "$OUTPUT_PATH" -maxdepth 1 \( -name "flow-kit:dev-*.md" -o -name "flow-kit:team-*.md" -o -name "flow-kit:meta-*.md" -o -name "flow-kit:ops-*.md" \) -print0 2>/dev/null || true)

  # 删除无前缀重复命令（careful.md → 已有 flow-kit:careful.md）
  declare -a LEGACY_NAMES=(
    "careful" "health" "scan" "guard" "mode" "archive" "scale" "next" "status"
    "check-expiry" "cost-report" "cross-session-search" "estimate-tokens"
    "freeze" "generate-commands" "hooks-guide" "lock" "minimal" "minimal-mode"
    "offline-mode" "online" "p0" "p0-approval" "pr-description" "project-type"
    "recovery" "register-commands" "rollback" "scale-level" "share-install"
    "strategy" "strategy-first" "sync-team-config" "team" "team-roles"
    "tmux-aggregate" "tmux-init" "tmux-orchestrator" "tmux-run"
    "unfreeze" "unlock" "update-context"
  )
  for name in "${LEGACY_NAMES[@]}"; do
    if [[ -f "$OUTPUT_PATH/${name}.md" ]] && [[ -f "$OUTPUT_PATH/flow-kit:${name}.md" ]]; then
      rm -f "$OUTPUT_PATH/${name}.md"
      echo "[清理] ${name}.md (已有 flow-kit:${name}.md)"
      cleaned=$((cleaned + 1))
    fi
  done

  [[ "$cleaned" -gt 0 ]] && echo "共清理 $cleaned 个旧命令"
  echo ""

  for cmd in "${!CORE_COMMANDS[@]}"; do
    local ref="${CORE_COMMANDS[$cmd]}"
    local source_file
    if [[ "$ref" == flow-kit/* ]]; then
        source_file="$REPO_ROOT/${ref#flow-kit/}"
    else
        source_file="$REPO_ROOT/$ref"
    fi
    local description
    description=$(extract_description "$source_file" "flow-kit ${cmd} 命令")
    local output_file="$OUTPUT_PATH/flow-kit:${cmd}.md"

    if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
      echo "[跳过] flow-kit:${cmd} (已存在)"
      continue
    fi

    generate_entry "$cmd" "$description" "$ref" "$output_file"
    echo "[生成] flow-kit:${cmd} -> $output_file"
  done

  echo ""
  echo "--- Phase 工作流命令 ---"
  for phase in "${!PHASE_COMMANDS[@]}"; do
    local name="${PHASE_COMMANDS[$phase]}"
    local output_file="$OUTPUT_PATH/flow-kit:${phase}.md"

    if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
      echo "[跳过] flow-kit:${phase} (已存在)"
      continue
    fi

    local phase_dir="${PHASE_DIRS[$phase]}"
    generate_phase_entry "$phase" "$name" "$phase_dir" "$output_file"
    echo "[生成] flow-kit:${phase} -> $output_file"
  done

  echo ""
  echo "=========================================="
  local total_commands=$((${#CORE_COMMANDS[@]} + ${#PHASE_COMMANDS[@]}))
  echo "完成: $total_commands 个核心命令已生成"
  echo "=========================================="
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
