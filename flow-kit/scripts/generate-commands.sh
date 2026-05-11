#!/bin/bash
# generate-commands.sh — flow-kit 斜杠命令生成器 v1.13
#
# 用法：
#   ./generate-commands.sh [--dry-run] [--force] [--user-level]
#
# 功能：
#   1. 扫描 flow-kit/commands/、skills/、hooks/ 目录
#   2. 解析每个文件的 description（从第2行 > 块或标题提取）
#   3. 生成 .claude/commands/ 目录下的分类斜杠命令入口文件
#   4. 支持 --dry-run 只展示不写入，--force 覆盖，--user-level 输出到用户级目录
#
# 输出格式：
#   文件名：flow-kit:{category}-{command}.md
#   命令格式：/flow-kit:{category}-{command}
#
# Reference: pwl1987/flow-kit

set -euo pipefail

# 默认配置
DRY_RUN=false
FORCE=false
USER_LEVEL=false
COMMANDS_DIR="commands"
SKILLS_DIR="skills"
HOOKS_DIR="hooks"
OUTPUT_DIR=".claude/commands"

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --user-level)
      USER_LEVEL=true
      OUTPUT_DIR="$HOME/.claude/commands"
      shift
      ;;
    *)
      echo "未知参数: $1" >&2
      echo "用法: $0 [--dry-run] [--force] [--user-level]" >&2
      exit 1
      ;;
  esac
done

# 确定目录路径
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMMANDS_PATH="$REPO_ROOT/$COMMANDS_DIR"
SKILLS_PATH="$REPO_ROOT/$SKILLS_DIR"
HOOKS_PATH="$REPO_ROOT/$HOOKS_DIR"

# 确定输出目录
if [[ "$USER_LEVEL" == "true" ]]; then
  OUTPUT_DIR="$HOME/.claude/commands"
fi
OUTPUT_PATH="$REPO_ROOT/$OUTPUT_DIR"

# 检查 commands 目录是否存在
if [[ ! -d "$COMMANDS_PATH" ]]; then
  echo "错误: commands 目录不存在: $COMMANDS_PATH" >&2
  exit 1
fi

# 创建输出目录（如果不是 dry-run）
if [[ "$DRY_RUN" == "false" ]]; then
  mkdir -p "$OUTPUT_PATH"
fi

# ============================================================================
# 命令分类映射表
# ============================================================================

# dev: 开发流程命令
declare -A DEV_COMMANDS=(
  ["health"]="M-health"
  ["scan"]="I-intel-scan"
  ["update-context"]="update-context"
  ["sync-config"]="sync-team-config"
  ["archive"]="archive"
  ["minimal"]="minimal-mode"
  ["offline"]="offline-mode"
  ["check-expiry"]="check-expiry"
  ["estimate-tokens"]="estimate-tokens"
  ["cost-report"]="cost-report"
  ["pr-description"]="pr-description"
  ["skill-audit"]="skill-audit"
  ["scale"]="scale-level"
  ["project-type"]="project-type"
  ["search-lessons"]="cross-session-search"
  ["recovery"]="check-expiry"
  ["change"]="init-change"
)

# meta: 管理命令
declare -A META_COMMANDS=(
  ["mode"]=""
  ["hooks"]="hooks-guide"
  ["hooks-summary"]=""
  ["status"]=""
  ["share-install"]="share-install"
  ["register"]="register-commands"
  ["generate"]="generate-commands"
  ["uninstall"]=""
)

# team: 多代理编排命令
declare -A TEAM_COMMANDS=(
  ["dispatch"]="team-dispatch"
  ["team"]="team-roles"
  ["strategy"]="strategy-first"
  ["tmux-init"]="tmux-orchestrator"
  ["tmux-run"]="tmux-orchestrator"
  ["tmux-aggregate"]="tmux-orchestrator"
)

# ops: 运维护栏命令
declare -A OPS_COMMANDS=(
  ["careful"]="careful"
  ["freeze"]="careful"
  ["unfreeze"]="careful"
  ["guard"]="careful"
  ["lock"]="careful"
  ["unlock"]="careful"
  ["rollback"]="rollback"
  ["p0-approval"]="p0-approval"
)

# ============================================================================
# 描述提取函数
# ============================================================================

# 从源文件提取中文描述
extract_description() {
  local file="$1"
  local default_desc="$2"

  if [[ ! -f "$file" ]]; then
    echo "$default_desc"
    return
  fi

  # 跳过 CLAUDE CODE INSTRUCTION 行和标题行，找实际内容
  local content
  content=$(sed '1,/^#/d' "$file" 2>/dev/null | grep -v "【CLAUDE CODE INSTRUCTION")

  # 方法1: 找 ## 目的 后面的第一段非空行
  local purpose
  purpose=$(sed -n '/^## 目的/,/^##/p' "$file" 2>/dev/null | grep -v "^##" | grep -v "^$" | head -1)
  if [[ -n "$purpose" ]]; then
    echo "$purpose"
    return
  fi

  # 方法2: 找 ## 命令 后面的第一行（通常是斜杠命令本身，跳过）
  local cmd_usage
  cmd_usage=$(sed -n '/^## 命令/,/^##/p' "$file" 2>/dev/null | grep -v "^##" | grep -v "^$" | grep -v "^/flow-kit:" | head -1)
  if [[ -n "$cmd_usage" ]]; then
    echo "$cmd_usage"
    return
  fi

  # 方法3: 第2行 > 块中描述（去除标记）
  local line2
  line2=$(sed -n '2p' "$file" 2>/dev/null || echo "")
  if [[ "$line2" =~ ^\>[[:space:]]*(.+) ]]; then
    local desc="${BASH_REMATCH[1]}"
    desc=$(echo "$desc" | sed 's/【CLAUDE CODE INSTRUCTION[^】]*】//g' | sed 's/本文件实现//g' | sed 's/本命令//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [[ -n "$desc" && ${#desc} -gt 3 ]]; then
      echo "$desc"
      return
    fi
  fi

  # 方法4: 第一个 # 标题（作为最后回退）
  local h1
  h1=$(grep -m1 '^#' "$file" 2>/dev/null | sed 's/^#[[:space:]]*//' | sed 's/^[^a-zA-Z0-9一-龥]*//' | cut -d'[' -f1 | cut -d'(' -f1 | xargs)
  if [[ -n "$h1" ]]; then
    echo "$h1"
    return
  fi

  # 回退
  echo "$default_desc"
}

# ============================================================================
# 生成 entry 文件函数
# ============================================================================

generate_entry() {
  local category="$1"
  local cmd_name="$2"
  local description="$3"
  local reference="$4"
  local output_file="$5"

  local full_cmd="${category}-${cmd_name}"
  # 无 category 前缀的命令（如 health）直接用 /flow-kit:xxx
  if [[ -n "$category" ]]; then
    local slash_cmd="/flow-kit:${category}-${cmd_name}"
  else
    local slash_cmd="/flow-kit:${cmd_name}"
  fi

  cat > "$output_file" << EOF
---
description: ${description}
category: ${category}
reference: ${reference}
---
${slash_cmd}: ${description}
EOF
}

# ============================================================================
# 生成 phase 命令
# ============================================================================

generate_phase_commands() {
  local phases=("0" "1" "2" "3" "4" "5" "6" "7" "8")
  local phase_names=("变更立项" "需求澄清" "架构设计" "任务拆解" "开发执行" "测试验证" "代码审查" "集成归档" "变更回滚")

  for i in "${!phases[@]}"; do
    local phase="${phases[$i]}"
    local phase_name="${phase_names[$i]}"
    local output_file="$OUTPUT_PATH/flow-kit:dev-phase-${phase}.md"

    if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
      echo "[跳过] flow-kit:dev-phase-${phase} (已存在)"
      continue
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
      echo "[dry-run] 将生成: $output_file"
    else
      cat > "$output_file" << EOF
---
description: ${phase_name} - Phase ${phase}
category: dev
reference: flow-kit/phases/${phase}-*/
---
/flow-kit:phase-${phase}: ${phase_name}
EOF
      echo "[生成] flow-kit:dev-phase-${phase} -> $output_file"
    fi
  done
}

# ============================================================================
# 生成 next 命令
# ============================================================================

generate_next_command() {
  local output_file="$OUTPUT_PATH/flow-kit:dev-next.md"

  if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
    echo "[跳过] flow-kit:dev-next (已存在)"
    return
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] 将生成: $output_file"
    return
  fi

  cat > "$output_file" << 'EOF'
---
description: 推进到下一个工作流步骤（读取 .planning/phases/ 判断进度）
category: dev
reference: flow-kit/GO.md
---
/flow-kit:next: 读取 .planning/phases/ 目录，自动判断当前阶段并推进到下一步骤
EOF
  echo "[生成] flow-kit:dev-next -> $output_file"
}

# ============================================================================
# 主流程
# ============================================================================

total=0
generated=0
skipped=0

echo "=========================================="
echo "flow-kit 斜杠命令生成器 v1.13"
echo "=========================================="
echo "源目录: $COMMANDS_PATH"
echo "输出目录: $OUTPUT_PATH"
echo "模式: $([ "$DRY_RUN" == "true" ] && echo "dry-run" || echo "live")$([ "$FORCE" == "true" ] && echo " (force)")"
echo "=========================================="
echo ""

# ---- dev 命令扫描 ----
echo "--- dev 开发流程命令 ---"
for cmd in "${!DEV_COMMANDS[@]}"; do
  target="${DEV_COMMANDS[$cmd]}"
  source_file=""
  description=""

  if [[ -n "$target" ]]; then
    source_file="$COMMANDS_PATH/${target}.md"
  else
    source_file="$COMMANDS_PATH/${cmd}.md"
  fi

  if [[ -f "$source_file" ]]; then
    description=$(extract_description "$source_file" "flow-kit ${cmd} 命令")
  else
    description="flow-kit ${cmd} 命令"
  fi

  ref_path=""
  [[ -n "$target" ]] && ref_path="flow-kit/commands/${target}.md" || ref_path="flow-kit/commands/${cmd}.md"

  output_file="$OUTPUT_PATH/flow-kit:dev-${cmd}.md"

  if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
    echo "[跳过] flow-kit:dev-${cmd} (已存在)"
    skipped=$((skipped + 1))
    continue
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] 将生成: $output_file"
    echo "  描述: $description"
  else
    generate_entry "dev" "$cmd" "$description" "$ref_path" "$output_file"
    echo "[生成] flow-kit:dev-${cmd} -> $output_file"
    generated=$((generated + 1))
  fi
  total=$((total + 1))
done

# ---- meta 命令扫描 ----
echo ""
echo "--- meta 管理命令 ---"
for cmd in "${!META_COMMANDS[@]}"; do
  target="${META_COMMANDS[$cmd]}"
  source_file=""
  description=""

  if [[ -n "$target" ]]; then
    source_file="$COMMANDS_PATH/${target}.md"
    if [[ -f "$source_file" ]]; then
      description=$(extract_description "$source_file" "flow-kit ${cmd} 命令")
    else
      description="flow-kit ${cmd} 命令"
    fi
  else
    # 内建命令，无独立文件
    case "$cmd" in
      "mode") description="切换执行模式 (autopilot|team|ralph)" ;;
      "hooks-summary") description="显示 hooks 执行摘要" ;;
      "status") description="显示当前执行模式" ;;
      "uninstall") description="卸载 flow-kit" ;;
      *) description="flow-kit ${cmd} 命令" ;;
    esac
  fi

  ref_path=""
  if [[ -n "$target" ]]; then
    ref_path="flow-kit/commands/${target}.md"
  else
    ref_path="flow-kit/GO.md"
  fi

  output_file="$OUTPUT_PATH/flow-kit:meta-${cmd}.md"

  if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
    echo "[跳过] flow-kit:meta-${cmd} (已存在)"
    skipped=$((skipped + 1))
    continue
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] 将生成: $output_file"
    echo "  描述: $description"
  else
    generate_entry "meta" "$cmd" "$description" "$ref_path" "$output_file"
    echo "[生成] flow-kit:meta-${cmd} -> $output_file"
    generated=$((generated + 1))
  fi
  total=$((total + 1))
done

# ---- team 命令扫描 ----
echo ""
echo "--- team 多代理编排命令 ---"
for cmd in "${!TEAM_COMMANDS[@]}"; do
  target="${TEAM_COMMANDS[$cmd]}"
  source_file="$COMMANDS_PATH/${target}.md"
  description=""

  if [[ -f "$source_file" ]]; then
    description=$(extract_description "$source_file" "flow-kit ${cmd} 命令")
  else
    description="flow-kit ${cmd} 命令"
  fi

  ref_path="flow-kit/commands/${target}.md"
  output_file="$OUTPUT_PATH/flow-kit:team-${cmd}.md"

  if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
    echo "[跳过] flow-kit:team-${cmd} (已存在)"
    skipped=$((skipped + 1))
    continue
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] 将生成: $output_file"
    echo "  描述: $description"
  else
    generate_entry "team" "$cmd" "$description" "$ref_path" "$output_file"
    echo "[生成] flow-kit:team-${cmd} -> $output_file"
    generated=$((generated + 1))
  fi
  total=$((total + 1))
done

# ---- ops 命令扫描 ----
echo ""
echo "--- ops 运维护栏命令 ---"
for cmd in "${!OPS_COMMANDS[@]}"; do
  target="${OPS_COMMANDS[$cmd]}"
  source_file="$COMMANDS_PATH/${target}.md"
  description=""

  if [[ -f "$source_file" ]]; then
    description=$(extract_description "$source_file" "flow-kit ${cmd} 命令")
  else
    description="flow-kit ${cmd} 命令"
  fi

  ref_path="flow-kit/commands/${target}.md"
  output_file="$OUTPUT_PATH/flow-kit:ops-${cmd}.md"

  if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
    echo "[跳过] flow-kit:ops-${cmd} (已存在)"
    skipped=$((skipped + 1))
    continue
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] 将生成: $output_file"
    echo "  描述: $description"
  else
    generate_entry "ops" "$cmd" "$description" "$ref_path" "$output_file"
    echo "[生成] flow-kit:ops-${cmd} -> $output_file"
    generated=$((generated + 1))
  fi
  total=$((total + 1))
done

# ---- skills 扫描 ----
echo ""
echo "--- skills 技能扫描 ---"
if [[ -d "$SKILLS_PATH" ]]; then
  # 使用 process substitution 避免子shell变量修改丢失
  while IFS= read -r -d '' file; do
    skill_name="$(basename "${file}" .md)"
    description=$(extract_description "$file" "flow-kit skill: ${skill_name}")
    output_file="$OUTPUT_PATH/flow-kit:skill-${skill_name}.md"

    if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
      echo "[跳过] flow-kit:skill-${skill_name} (已存在)"
      skipped=$((skipped + 1))
      continue
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
      echo "[dry-run] 将生成: $output_file"
      echo "  描述: $description"
    else
      generate_entry "skill" "$skill_name" "$description" "flow-kit/skills/${skill_name}.md" "$output_file"
      echo "[生成] flow-kit:skill-${skill_name} -> $output_file"
      generated=$((generated + 1))
    fi
    total=$((total + 1))
  done < <(find "$SKILLS_PATH" -name "*.md" -print0 | sort -z)
fi

# ---- hooks 扫描 ----
echo ""
echo "--- hooks 自动化钩子 ---"
if [[ -d "$HOOKS_PATH" ]]; then
  # 使用 process substitution 避免子shell变量修改丢失
  while IFS= read -r -d '' file; do
    hook_name="$(basename "${file}" .sh)"
    description="flow-kit hooks ${hook_name} 钩子"
    output_file="$OUTPUT_PATH/flow-kit:hooks-${hook_name}.md"

    if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
      echo "[跳过] flow-kit:hooks-${hook_name} (已存在)"
      skipped=$((skipped + 1))
      continue
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
      echo "[dry-run] 将生成: $output_file"
      echo "  描述: $description"
    else
      generate_entry "hooks" "$hook_name" "$description" "flow-kit/hooks/${hook_name}.sh" "$output_file"
      echo "[生成] flow-kit:hooks-${hook_name} -> $output_file"
      generated=$((generated + 1))
    fi
    total=$((total + 1))
  done < <(find "$HOOKS_PATH" -name "*.sh" -print0 | sort -z)
fi

# ---- GO.md 直接路由命令（无 category 前缀）----
# 处理 GO.md 中 Available Commands 表格里的命令
# 这些命令路由到 /flow-kit:xxx（无 category 前缀）
echo ""
echo "--- GO.md 直接路由命令 ---"
GO_MD="$REPO_ROOT/GO.md"
if [[ -f "$GO_MD" ]]; then
  # 解析 GO.md 中的 Available Commands 表格
  # 格式: | `/flow-kit:xxx` | `@flow-kit/commands/xxx.md` |
  while IFS= read -r line; do
    # 提取命令名（使用 grep -oP 避免正则转义问题）
    cmd_name=$(echo "$line" | grep -oP '(?<=/flow-kit:)[a-zA-Z0-9_-]+' | head -1)
    if [[ -z "$cmd_name" ]]; then
      continue
    fi

    # 从 line 中提取 target_path（@flow-kit/xxx.md 格式）
    # 使用 grep -oP 提取，然后处理
    target_path=$(echo "$line" | grep -oP '@flow-kit/\K[^`]+(?=\.md)' | sed 's/^commands\///' 2>/dev/null || echo "")

    # 如果没有 target_path，尝试从描述中提取（适用于"解除 freeze 限制"等）
    if [[ -z "$target_path" ]]; then
      # 提取第三列作为描述
      description=$(echo "$line" | awk -F'|' '{gsub(/^[ \t]+/,"",$3); gsub(/[ \t]+$/,"",$3); print $3}')
      if [[ -n "$description" ]]; then
        # 生成无引用的命令
        output_file="$OUTPUT_PATH/flow-kit:${cmd_name}.md"
        if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
          echo "[跳过] flow-kit:${cmd_name} (已存在)"
          skipped=$((skipped + 1))
          continue
        fi
        if [[ "$DRY_RUN" == "true" ]]; then
          echo "[dry-run] 将生成: $output_file"
          echo "  描述: $description"
        else
          generate_entry "" "$cmd_name" "$description" "" "$output_file"
          echo "[生成] flow-kit:${cmd_name} -> $output_file"
          generated=$((generated + 1))
        fi
        total=$((total + 1))
        continue
      fi
      continue
    fi

    # 跳过已带 category 前缀的命令（已在其他数组中处理）
    if [[ "$cmd_name" =~ ^(dev-|meta-|team-|ops-|skill-|hooks-) ]]; then
      continue
    fi

    # 构建源文件路径
    source_file="$REPO_ROOT/commands/${target_path}.md"

    # 提取描述
    if [[ -f "$source_file" ]]; then
      description=$(extract_description "$source_file" "flow-kit ${cmd_name} 命令")
    else
      description="flow-kit ${cmd_name} 命令"
    fi

    output_file="$OUTPUT_PATH/flow-kit:${cmd_name}.md"

    if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
      echo "[跳过] flow-kit:${cmd_name} (已存在)"
      skipped=$((skipped + 1))
      continue
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
      echo "[dry-run] 将生成: $output_file"
      echo "  描述: $description"
    else
      generate_entry "" "$cmd_name" "$description" "flow-kit/commands/${target_path}.md" "$output_file"
      echo "[生成] flow-kit:${cmd_name} -> $output_file"
      generated=$((generated + 1))
    fi
    total=$((total + 1))
  done < <(grep -E '\| `/flow-kit:' "$GO_MD" | grep -v -- ' -- ' | grep -v 'mode autopilot\|mode team\|mode ralph')
fi

# ---- phase 命令生成 ----
echo ""
echo "--- Phase 工作流命令 ---"
generate_phase_commands
generate_next_command

echo ""
echo "=========================================="
echo "完成: $generated 生成, $skipped 跳过 (共 $total 个命令)"
echo "=========================================="

exit 0