#!/bin/bash
# offline-mode.sh — 离线模式控制
# v1.12.17 新增：实现 /flow-kit:offline 命令

set -euo pipefail

readonly OFFLINE_FLAG_DIR=".flow-kit"
readonly OFFLINE_FLAG="$OFFLINE_FLAG_DIR/.offline-mode"

#------------------------------------------------------------------------------
# 获取当前离线状态（仅输出 true/false）
#------------------------------------------------------------------------------
is_offline() {
    if [ -f "$OFFLINE_FLAG" ]; then
        echo "true"
    else
        echo "false"
    fi
}

#------------------------------------------------------------------------------
# 设置离线模式
#------------------------------------------------------------------------------
activate_offline() {
    local reason="${1:-manual}"
    mkdir -p "$OFFLINE_FLAG_DIR"
    echo "$reason" > "$OFFLINE_FLAG"
    echo "[INFO] Offline mode activated. Using built-in lint adapter."
}

#------------------------------------------------------------------------------
# 关闭离线模式
#------------------------------------------------------------------------------
deactivate_offline() {
    rm -f "$OFFLINE_FLAG"
    echo "[INFO] Online mode restored."
}

#------------------------------------------------------------------------------
# 内置 Lint: 检查占位符完整性
#------------------------------------------------------------------------------
lint_placeholder_completeness() {
    local files=("$@")
    local issues=()

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            while IFS= read -r line; do
                if [[ "$line" =~ \{\{[A-Za-z0-9_]+\}\} ]]; then
                    issues+=("文件 $file 包含未填充占位符: $line")
                fi
            done < "$file"
        fi
    done

    if [ ${#issues[@]} -eq 0 ]; then
        echo "valid: true"
    else
        echo "valid: false"
        echo "issues: ${issues[*]}"
    fi
}

#------------------------------------------------------------------------------
# 内置 Lint: 检查必需文件
#------------------------------------------------------------------------------
lint_required_files() {
    local phase="$1"
    shift
    local files=("$@")
    local missing=()

    # 检查阶段必需文件
    case "$phase" in
        0)
            [ -f ".planning/PROJECT.md" ] || missing+=(".planning/PROJECT.md")
            ;;
        1)
            [ -f ".planning/REQUIREMENTS.md" ] || missing+=(".planning/REQUIREMENTS.md")
            ;;
        2)
            [ -f ".planning/ARCHITECTURE.md" ] || missing+=(".planning/ARCHITECTURE.md")
            ;;
    esac

    if [ ${#missing[@]} -eq 0 ]; then
        echo "valid: true"
    else
        echo "valid: false"
        echo "missing: ${missing[*]}"
    fi
}

#------------------------------------------------------------------------------
# 内置 Lint: YAML/JSON 格式验证
#------------------------------------------------------------------------------
lint_yaml_json_format() {
    local files=("$@")
    local errors=()

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            continue
        fi
        case "$file" in
            *.json)
                if ! jq . "$file" >/dev/null 2>&1; then
                    errors+=("JSON 语法错误: $file")
                fi
                ;;
            *.yaml|*.yml)
                if ! command -v python3 >/dev/null 2>&1; then
                    errors+=("YAML 验证需要 python3: $file")
                elif ! python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
                    errors+=("YAML 语法错误: $file")
                fi
                ;;
        esac
    done

    if [ ${#errors[@]} -eq 0 ]; then
        echo "valid: true"
    else
        echo "valid: false"
        echo "errors: ${errors[*]}"
    fi
}

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
offline-mode.sh — 离线模式控制

用法:
  ./offline-mode.sh status      查看当前离线状态
  ./offline-mode.sh on          激活离线模式
  ./offline-mode.sh off         关闭离线模式
  ./offline-mode.sh lint <files...>  运行内置 lint 检查

示例:
  ./offline-mode.sh status
  ./offline-mode.sh on
  ./offline-mode.sh lint file1.md file2.json
EOF
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    local action="${1:-status}"

    case "$action" in
        status)
            local status=$(is_offline)
            local reason=$(cat "$OFFLINE_FLAG" 2>/dev/null || echo "unknown")
            echo "Offline: $status"
            echo "Reason: $reason"
            ;;
        on|activate)
            activate_offline "manual"
            ;;
        off|deactivate)
            deactivate_offline
            ;;
        lint)
            shift
            if [ $# -eq 0 ]; then
                echo "[ERROR] lint 需要文件参数"
                exit 1
            fi
            lint_placeholder_completeness "$@"
            ;;
        lint-required)
            local phase="${2:-0}"
            shift 2
            lint_required_files "$phase" "$@"
            ;;
        lint-format)
            shift
            lint_yaml_json_format "$@"
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "[ERROR] 未知操作: $action"
            show_help
            exit 1
            ;;
    esac
}

main "$@"