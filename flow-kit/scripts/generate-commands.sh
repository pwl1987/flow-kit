#!/bin/bash
# generate-commands.sh — flow-kit 斜杠命令生成器 (精简版 v2.0)
#
# 只生成 17 个核心命令，移除所有 dev-/meta-/team-/ops- 前缀变体

set -euo pipefail

FORCE=false
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly OUTPUT_PATH="$REPO_ROOT/.claude/commands"

declare -A CORE_COMMANDS=(
  ["init"]="flow-kit/commands/init-change.md"
  ["health"]="flow-kit/commands/M-health.md"
  ["scan"]="flow-kit/commands/I-intel-scan.md"
  ["next"]="flow-kit/GO.md"
  ["status"]="flow-kit/GO.md"
  ["guard"]="flow-kit/commands/careful.md"
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
  local output_file="$3"

  {
    printf '%s\n' '---'
    printf 'description: %s - %s\n' "$name" "$phase"
    printf '%s\n' 'category: dev'
    printf 'reference: flow-kit/phases/%s/\n' "$phase"
    printf 'execute: bash scripts/phase-executor.sh %s\n' "$phase"
    printf '%s\n' '---'
    printf '/flow-kit:%s: %s\n' "$phase" "$name"
  } > "$output_file"
}

main() {
  parse_args "$@"

  echo "=========================================="
  echo "flow-kit 斜杠命令生成器 v2.0 (精简版)"
  echo "=========================================="
  echo "输出目录: $OUTPUT_PATH"
  echo "模式: $([ "$FORCE" == "true" ] && echo "force" || echo "incremental")"
  echo "=========================================="
  echo ""

  mkdir -p "$OUTPUT_PATH"

  for cmd in "${!CORE_COMMANDS[@]}"; do
    local ref="${CORE_COMMANDS[$cmd]}"
    local source_file="$REPO_ROOT/$ref"
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

    generate_phase_entry "$phase" "$name" "$output_file"
    echo "[生成] flow-kit:${phase} -> $output_file"
  done

  echo ""
  echo "=========================================="
  echo "完成: 17 个核心命令已生成"
  echo "=========================================="
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
