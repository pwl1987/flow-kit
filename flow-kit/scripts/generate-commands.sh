#!/bin/bash
# generate-commands.sh — flow-kit 斜杠命令生成器
#
# 用法：
#   ./generate-commands.sh [--dry-run] [--force] [--user-level]
#
# 功能：
#   1. 扫描 flow-kit/commands/ 目录下所有 .md 文件
#   2. 解析每个文件的 name/description（从 YAML frontmatter 或首行）
#   3. 生成 .claude/commands/ 目录下的斜杠命令入口文件
#   4. 支持 --dry-run 只展示不写入，--force 覆盖，--user-level 输出到用户级目录
#
# 输出：
#   每个命令生成一个 .md 文件，格式：
#   ---
#   description: 命令描述
#   reference: flow-kit/commands/xxx.md
#   ---
#   [简要功能说明]
#
# Reference: rihebty/flow-kit

set -euo pipefail

# 默认配置
DRY_RUN=false
FORCE=false
USER_LEVEL=false
COMMANDS_DIR="commands"
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

# 确定 commands 目录路径
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMMANDS_PATH="$REPO_ROOT/$COMMANDS_DIR"

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

# 解析 YAML frontmatter 或提取命令信息
parse_command_info() {
  local file="$1"
  local name=""
  local description=""
  local content=""

  # 尝试从 YAML frontmatter 提取
  if [[ -f "$file" ]]; then
    # 读取文件内容
    content=$(cat "$file")

    # 检查是否有 YAML frontmatter
    if [[ "$content" =~ ^---[[:space:]]*$ ]]; then
      # 提取 frontmatter 块
      local frontmatter=""
      local in_frontmatter=false
      local line_num=0

      while IFS= read -r line; do
        ((line_num++))
        if [[ "$line" =~ ^---$ ]] && [[ $line_num -eq 1 ]]; then
          in_frontmatter=true
          continue
        fi
        if [[ "$in_frontmatter" == "true" ]]; then
          if [[ "$line" =~ ^---$ ]]; then
            break
          fi
          frontmatter="$frontmatter"$'\n'"$line"
        fi
      done <<< "$content"

      # 解析 frontmatter 中的 name 和 description
      if [[ "$frontmatter" =~ name:[[:space:]]*[\"']?([^"'"'\n]+)[\"']? ]]; then
        name="${BASH_REMATCH[1]}"
      fi
      if [[ "$frontmatter" =~ description:[[:space:]]*[\"']?([^"'"'\n]+)[\"']? ]]; then
        description="${BASH_REMATCH[1]}"
      fi
    fi

    # 如果没有 frontmatter，尝试从首行提取 ## commandname 格式
    if [[ -z "$name" ]]; then
      local first_line
      first_line=$(head -n 1 "$file")
      if [[ "$first_line" =~ ^##[[:space:]]+(.+)$ ]]; then
        name="${BASH_REMATCH[1]}"
        # 去除可能的尾随说明
        name=$(echo "$name" | sed 's/[[:space:]]*-.*$//')
      fi
    fi

    # 如果没有 description，尝试从第二行或第三行提取
    if [[ -z "$description" ]]; then
      local lines
      lines=$(tail -n +2 "$file" | head -n 2)
      if [[ "$lines" =~ ^[[:space:]]*-[[:space:]]+(.+)$ ]]; then
        description="${BASH_REMATCH[1]}"
      fi
    fi
  fi

  # 返回结果
  echo "$name|$description"
}

# 生成命令入口文件
generate_entry() {
  local cmd_name="$1"
  local description="$2"
  local source_file="$3"
  local output_file="$4"

  # 生成 entry 文件内容
  cat > "$output_file" << EOF
---
description: ${description}
reference: ${source_file}
---
$(basename "$source_file" .md): ${description}
EOF
}

# 统计信息
total=0
generated=0
skipped=0

echo "=========================================="
echo "flow-kit 斜杠命令生成器"
echo "=========================================="
echo "源目录: $COMMANDS_PATH"
echo "输出目录: $OUTPUT_PATH"
echo "模式: $([ "$DRY_RUN" == "true" ] && echo "dry-run" || echo "live")$([ "$FORCE" == "true" ] && echo " (force)")"
echo "=========================================="
echo ""

# 扫描所有 .md 文件
while IFS= read -r -d '' file; do
  ((total++))

  # 获取相对于 commands 目录的路径
  rel_path="${file#$COMMANDS_PATH/}"
  cmd_name="${rel_path%.md}"

  # 解析命令信息
  IFS='|' read -r name description <<< "$(parse_command_info "$file")"

  # 如果没有从文件解析到名称，使用文件名
  if [[ -z "$name" ]]; then
    name="$cmd_name"
  fi
  if [[ -z "$description" ]]; then
    description="flow-kit 命令: $name"
  fi

  # 确定输出文件路径
  output_file="$OUTPUT_PATH/${name}.md"

  # 检查文件是否已存在
  if [[ -f "$output_file" ]] && [[ "$FORCE" == "false" ]]; then
    echo "[跳过] $name (已存在, 使用 --force 覆盖)"
    ((skipped++))
    continue
  fi

  # 生成 entry 文件
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] 将生成: $output_file"
    echo "  描述: $description"
    echo "  来源: $rel_path"
  else
    generate_entry "$name" "$description" "$rel_path" "$output_file"
    echo "[生成] $name -> $OUTPUT_PATH/${name}.md"
  fi

  ((generated++))

done < <(find "$COMMANDS_PATH" -name "*.md" -print0 | sort -z)

echo ""
echo "=========================================="
echo "完成: $generated 生成, $skipped 跳过 (共 $total 个命令)"
echo "=========================================="

exit 0
