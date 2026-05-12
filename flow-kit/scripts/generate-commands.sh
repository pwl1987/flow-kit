#!/bin/bash
# generate-commands.sh — flow-kit 斜杠命令生成器 (精简版 v2.0)
#
# 只生成 17 个核心命令，移除所有 dev-/meta-/team-/ops- 前缀变体
#
# 核心命令：
#   init, health, scan - 初始化和扫描
#   phase-0 ~ phase-8  - 9 个阶段命令
#   next, status       - 状态推进
#   guard, archive     - 护栏和归档
#   scale              - 扩展级别

set -euo pipefail

FORCE=false
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly OUTPUT_PATH="$REPO_ROOT/.claude/commands"

# 解析参数
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

# ============================================================================
# 核心命令定义
# ============================================================================

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

# ============================================================================
# 描述提取
# ============================================================================

extract_description() {
  local file="$1"
  local default="$2"

  if [[ ! -f "$file" ]]; then
    echo "$default"
    return
  fi

  # 优先从 ## 目的 提取
  local desc
  desc=$(sed -n '/^## 目的/,/^##/p' "$file" 2>/dev/null | grep -v "^##" | grep -v "^$" | head -1 | xargs)
  if [[ -n "$desc" ]]; then
    echo "$desc"
    return
  fi

  # 回退到第2行
  desc=$(sed -n '2p' "$file" 2>/dev/null | sed 's/^>[[:space:]]*//' | sed 's/【[^】]*】//g')
  if [[ -n "$desc" && ${#desc} -gt 3 ]]; then
    echo "$desc"
    return
  fi

  echo "$default"
}

# ============================================================================
# 生成入口文件
# ============================================================================

generate_entry() {
  local cmd_name="$1"
  local description="$2"
  local reference="$3"
  local output_file="$4"

  cat > "$output_file" << EOF
---
description: ${description}
category: dev
reference: ${reference}
---
/flow-kit:${cmd_name}: ${description}
EOF
}

# ============================================================================
# 主流程
# ============================================================================

echo "=========================================="
echo "flow-kit 斜杠命令生成器 v2.0 (精简版)"
echo "=========================================="
echo "输出目录: $OUTPUT_PATH"
echo "模式: $([ "$FORCE" == "true" ] && echo "force" || echo "incremental")"
echo "=========================================="
echo ""

mkdir -p "$OUTPUT_PATH"

# 生成核心命令
for cmd in "${!CORE_COMMANDS[@]}"; do
  ref="${CORE_COMMANDS[$cmd]}"
  source_file="$REPO_ROOT/$ref"
  description=$(extract_description "$source_file" "flow-kit ${cmd} 命令")
  output_file="$OUTPUT_PATH/flow-kit:${cmd}.md"

  if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
    echo "[跳过] flow-kit:${cmd} (已存在)"
    continue
  fi

  generate_entry "$cmd" "$description" "$ref" "$output_file"
  echo "[生成] flow-kit:${cmd} -> $output_file"
done

# 生成 phase 命令
echo ""
echo "--- Phase 工作流命令 ---"
for phase in "${!PHASE_COMMANDS[@]}"; do
  name="${PHASE_COMMANDS[$phase]}"
  output_file="$OUTPUT_PATH/flow-kit:${phase}.md"

  if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
    echo "[跳过] flow-kit:${phase} (已存在)"
    continue
  fi

  cat > "$output_file" << EOF
---
description: ${name} - ${phase}
category: dev
reference: flow-kit/phases/${phase}/
execute: bash scripts/phase-executor.sh ${phase}
---
/flow-kit:${phase}: ${name}
EOF
  echo "[生成] flow-kit:${phase} -> $output_file"
done

echo ""
echo "=========================================="
echo "完成: 17 个核心命令已生成"
echo "=========================================="