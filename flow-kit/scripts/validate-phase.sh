#!/bin/bash
# validate-phase.sh — 阶段产物 JSON Schema 验证
# v1.12.9 P0 修复：临时文件安全清理 + set -euo pipefail
# 验证 phase-0/1/2 产物是否符合 JSON Schema

set -euo pipefail

#------------------------------------------------------------------------------
# 依赖检查：jq 必须可用
#------------------------------------------------------------------------------
if ! command -v jq &>/dev/null; then
    printf '[错误] jq 未安装，无法执行 JSON Schema 验证。\n' >&2
    printf '请安装 jq 后重试：brew install jq 或 apt install jq\n' >&2
    exit 3
fi

# v1.12.10 改进：引入错误处理框架
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/error-handler.sh"

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
readonly SCHEMA_DIR="flow-kit/lib/validation/schemas"
readonly OUTPUT_DIR=".planning/outputs"

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
validate-phase.sh — 阶段产物 JSON Schema 验证

用法:
  validate-phase.sh <phase> [output_file]
  validate-phase.sh 0 [.planning/outputs/phase-0-output.json]
  validate-phase.sh 1 [.planning/outputs/phase-1-output.json]
  validate-phase.sh 2 [.planning/outputs/phase-2-output.json]
  validate-phase.sh --all

参数:
  phase          阶段号 (0, 1, 2)
  output_file    产物文件路径（可选，默认从 OUTPUT_DIR 读取）

示例:
  validate-phase.sh 0
  validate-phase.sh 1 .planning/outputs/phase-1-output.json
  validate-phase.sh --all

验证内容:
  - required 字段是否存在
  - 类型匹配
  - pattern 验证
  - enum 值验证
EOF
}

#------------------------------------------------------------------------------
# 验证 JSON 必填字段
#------------------------------------------------------------------------------
validate_required() {
    local json_file="$1"
    local schema_file="$2"
    local phase="$3"

    local errors=()

    # 获取 required 字段
    local required=$(jq -r '.required[]' "$schema_file" 2>/dev/null || echo "")

    for field in $required; do
        local value=$(jq -r ".$field" "$json_file" 2>/dev/null || echo "null")
        if [ "$value" = "null" ] || [ -z "$value" ]; then
            errors+=("缺少必填字段: $field")
        fi
    done

    printf '%s\n' "${errors[@]}"
}

#------------------------------------------------------------------------------
# 验证 JSON 类型
#------------------------------------------------------------------------------
validate_types() {
    local json_file="$1"
    local schema_file="$2"

    local errors=()
    local props=$(jq -r '.properties | keys[]' "$schema_file" 2>/dev/null || echo "")

    for prop in $props; do
        local expected_type=$(jq -r ".properties.\"$prop\".type" "$schema_file" 2>/dev/null)
        local actual_value=$(jq -r ".\"$prop\"" "$json_file" 2>/dev/null)
        local actual_type=$(jq -r ".\"$prop\" | type" "$json_file" 2>/dev/null || echo "null")

        if [ "$actual_value" != "null" ] && [ -n "$actual_value" ]; then
            case "$expected_type" in
                string)
                    if [ "$actual_type" != "string" ]; then
                        errors+=("字段 $prop: 期望 string，实际 $actual_type")
                    fi
                    ;;
                number|integer)
                    if [ "$actual_type" != "number" ] && [ "$actual_type" != "integer" ]; then
                        errors+=("字段 $prop: 期望 number，实际 $actual_type")
                    fi
                    ;;
                boolean)
                    if [ "$actual_type" != "boolean" ]; then
                        errors+=("字段 $prop: 期望 boolean，实际 $actual_type")
                    fi
                    ;;
                array)
                    if [ "$actual_type" != "array" ]; then
                        errors+=("字段 $prop: 期望 array，实际 $actual_type")
                    fi
                    ;;
                object)
                    if [ "$actual_type" != "object" ]; then
                        errors+=("字段 $prop: 期望 object，实际 $actual_type")
                    fi
                    ;;
            esac
        fi
    done

    printf '%s\n' "${errors[@]}"
}

#------------------------------------------------------------------------------
# 验证字符串长度（minLength/maxLength）
#------------------------------------------------------------------------------
validate_string_length() {
    local json_file="$1"
    local schema_file="$2"

    local errors=()
    local props=$(jq -r '.properties | keys[]' "$schema_file" 2>/dev/null || echo "")

    for prop in $props; do
        local actual_value=$(jq -r ".\"$prop\"" "$json_file" 2>/dev/null)
        local actual_type=$(jq -r ".\"$prop\" | type" "$json_file" 2>/dev/null || echo "null")

        if [ "$actual_type" = "string" ] && [ "$actual_value" != "null" ]; then
            local min_length=$(jq -r ".properties.\"$prop\".minLength // empty" "$schema_file" 2>/dev/null)
            local max_length=$(jq -r ".properties.\"$prop\".maxLength // empty" "$schema_file" 2>/dev/null)
            local str_length=${#actual_value}

            if [ -n "$min_length" ] && [ "$str_length" -lt "$min_length" ]; then
                errors+=("字段 $prop: 长度 $str_length 小于最小长度 $min_length")
            fi

            if [ -n "$max_length" ] && [ "$str_length" -gt "$max_length" ]; then
                errors+=("字段 $prop: 长度 $str_length 超过最大长度 $max_length")
            fi
        fi
    done

    printf '%s\n' "${errors[@]}"
}

#------------------------------------------------------------------------------
# 验证数字范围（minimum/maximum）
#------------------------------------------------------------------------------
validate_number_range() {
    local json_file="$1"
    local schema_file="$2"

    local errors=()
    local props=$(jq -r '.properties | keys[]' "$schema_file" 2>/dev/null || echo "")

    for prop in $props; do
        local actual_type=$(jq -r ".\"$prop\" | type" "$json_file" 2>/dev/null || echo "null")

        if [ "$actual_type" = "number" ] || [ "$actual_type" = "integer" ]; then
            local actual_value=$(jq -r ".\"$prop\"" "$json_file" 2>/dev/null)
            local minimum=$(jq -r ".properties.\"$prop\".minimum // empty" "$schema_file" 2>/dev/null)
            local maximum=$(jq -r ".properties.\"$prop\".maximum // empty" "$schema_file" 2>/dev/null)

            if [ -n "$minimum" ]; then
                local cmp_result
                cmp_result=$(jq -n --argjson val "$actual_value" --argjson min "$minimum" 'if $val < $min then "lt" else "ge" end' 2>/dev/null || echo "ge")
                if [ "$cmp_result" = "lt" ]; then
                    errors+=("字段 $prop: 值 $actual_value 小于最小值 $minimum")
                fi
            fi

            if [ -n "$maximum" ]; then
                local cmp_result
                cmp_result=$(jq -n --argjson val "$actual_value" --argjson max "$maximum" 'if $val > $max then "gt" else "le" end' 2>/dev/null || echo "le")
                if [ "$cmp_result" = "gt" ]; then
                    errors+=("字段 $prop: 值 $actual_value 超过最大值 $maximum")
                fi
            fi
        fi
    done

    printf '%s\n' "${errors[@]}"
}

#------------------------------------------------------------------------------
# 验证数组items类型
#------------------------------------------------------------------------------
validate_array_items() {
    local json_file="$1"
    local schema_file="$2"

    local errors=()
    local props=$(jq -r '.properties | keys[]' "$schema_file" 2>/dev/null || echo "")

    for prop in $props; do
        local actual_type=$(jq -r ".\"$prop\" | type" "$json_file" 2>/dev/null || echo "null")

        if [ "$actual_type" = "array" ]; then
            local items_type=$(jq -r ".properties.\"$prop\".items.type // empty" "$schema_file" 2>/dev/null)

            if [ -n "$items_type" ]; then
                local array_length=$(jq -r ".\"$prop\" | length" "$json_file" 2>/dev/null)

                for ((i=0; i<array_length; i++)); do
                    local item_type=$(jq -r ".\"$prop\"[$i] | type" "$json_file" 2>/dev/null)
                    local item_value=$(jq -r ".\"$prop\"[$i]" "$json_file" 2>/dev/null)

                    case "$items_type" in
                        string)
                            if [ "$item_type" != "string" ]; then
                                errors+=("字段 $prop[$i]: 期望 string，实际 $item_type (值: $item_value)")
                            fi
                            ;;
                        number|integer)
                            if [ "$item_type" != "number" ] && [ "$item_type" != "integer" ]; then
                                errors+=("字段 $prop[$i]: 期望 number，实际 $item_type (值: $item_value)")
                            fi
                            ;;
                        object)
                            if [ "$item_type" != "object" ]; then
                                errors+=("字段 $prop[$i]: 期望 object，实际 $item_type (值: $item_value)")
                            fi
                            ;;
                    esac
                done
            fi

            # 验证minItems/maxItems
            local min_items=$(jq -r ".properties.\"$prop\".minItems // empty" "$schema_file" 2>/dev/null)
            local max_items=$(jq -r ".properties.\"$prop\".maxItems // empty" "$schema_file" 2>/dev/null)
            local array_length=$(jq -r ".\"$prop\" | length" "$json_file" 2>/dev/null)

            if [ -n "$min_items" ] && [ "$array_length" -lt "$min_items" ]; then
                errors+=("字段 $prop: 数组长度 $array_length 小于最小项数 $min_items")
            fi

            if [ -n "$max_items" ] && [ "$array_length" -gt "$max_items" ]; then
                errors+=("字段 $prop: 数组长度 $array_length 超过最大项数 $max_items")
            fi
        fi
    done

    printf '%s\n' "${errors[@]}"
}

#------------------------------------------------------------------------------
# 验证嵌套对象（递归验证，v1.12.9 修复：临时文件安全清理）
#------------------------------------------------------------------------------
validate_nested_object() {
    local json_file="$1"
    local schema_file="$2"
    local prefix="${3:-}"

    # P0 修复：创建临时目录统一管理临时文件
    local tmp_dir
    tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'validate-nested-XXXX')
    trap 'rm -rf "$tmp_dir"' RETURN

    local errors=()
    local props=$(jq -r '.properties | keys[]' "$schema_file" 2>/dev/null || echo "")

    for prop in $props; do
        local full_prop="${prefix}${prefix:+.}$prop"
        local actual_type=$(jq -r ".\"$prop\" | type" "$json_file" 2>/dev/null || echo "null")
        local expected_type=$(jq -r ".properties.\"$prop\".type" "$schema_file" 2>/dev/null)

        # 验证类型
        if [ "$actual_type" != "$expected_type" ] && [ "$actual_type" != "null" ]; then
            errors+=("字段 $full_prop: 期望 $expected_type，实际 $actual_type")
            continue
        fi

        # 如果是object，递归验证
        if [ "$expected_type" = "object" ] && [ "$actual_type" = "object" ]; then
            local nested_schema=$(jq -c ".properties.\"$prop\"" "$schema_file" 2>/dev/null)
            local nested_json=$(jq -c ".\"$prop\"" "$json_file" 2>/dev/null)

            # 使用临时目录中的文件进行递归验证
            local tmp_schema="$tmp_dir/schema-${prop}.json"
            local tmp_json="$tmp_dir/json-${prop}.json"
            echo "$nested_schema" > "$tmp_schema"
            echo "$nested_json" > "$tmp_json"

            # 验证nested required
            local nested_required=$(jq -r '.required[]' "$tmp_schema" 2>/dev/null || echo "")
            for field in $nested_required; do
                local value=$(jq -r ".$field" "$tmp_json" 2>/dev/null || echo "null")
                if [ "$value" = "null" ] || [ -z "$value" ]; then
                    errors+=("字段 $full_prop.$field: 缺少必填字段")
                fi
            done
        fi
    done

    printf '%s\n' "${errors[@]}"
}

#------------------------------------------------------------------------------
# 验证 enum 值
#------------------------------------------------------------------------------
validate_enum() {
    local json_file="$1"
    local schema_file="$2"

    local errors=()
    local props=$(jq -r '.properties | keys[]' "$schema_file" 2>/dev/null || echo "")

    for prop in $props; do
        local has_enum=$(jq -r '.properties."'$prop'".enum != null' "$schema_file" 2>/dev/null)
        if [ "$has_enum" = "true" ]; then
            local actual_value=$(jq -c ".\"$prop\"" "$json_file" 2>/dev/null)
            local enum_count=$(jq -r '.properties."'$prop'".enum | length' "$schema_file" 2>/dev/null)
            local found=false

            for ((i=0; i<enum_count; i++)); do
                local enum_val=$(jq -c ".properties.\"$prop\".enum[$i]" "$schema_file" 2>/dev/null)
                if [ "$actual_value" = "$enum_val" ]; then
                    found=true
                    break
                fi
            done

            if [ "$found" = false ]; then
                local allowed=$(jq -r '.properties."'$prop'".enum | join(", ")' "$schema_file" 2>/dev/null)
                errors+=("字段 $prop: 值 '$actual_value' 不在允许的枚举值中 [$allowed]")
            fi
        fi
    done

    printf '%s\n' "${errors[@]}"
}

#------------------------------------------------------------------------------
# 验证 pattern（使用 jq test）
#------------------------------------------------------------------------------
validate_patterns() {
    local json_file="$1"
    local schema_file="$2"

    local errors=()
    local props=$(jq -r '.properties | keys[]' "$schema_file" 2>/dev/null || echo "")

    for prop in $props; do
        local pattern=$(jq -r ".properties.\"$prop\".pattern" "$schema_file" 2>/dev/null)
        if [ "$pattern" != "null" ] && [ -n "$pattern" ]; then
            local actual_value=$(jq -r ".\"$prop\"" "$json_file" 2>/dev/null)
            if [ -n "$actual_value" ] && [ "$actual_value" != "null" ]; then
                if ! echo "$actual_value" | jq -e --arg p "$pattern" 'test($p)' >/dev/null 2>&1; then
                    errors+=("字段 $prop: 值 '$actual_value' 不匹配 pattern: $pattern")
                fi
            fi
        fi
    done

    printf '%s\n' "${errors[@]}"
}

#------------------------------------------------------------------------------
# 验证单个 phase
#------------------------------------------------------------------------------
validate_phase() {
    local phase="$1"
    local json_file="${2:-}"

    local schema_file="$SCHEMA_DIR/phase-${phase}-output.schema.json"

    if [ ! -f "$schema_file" ]; then
        echo "[validate-phase] ❌ Schema 文件不存在: $schema_file"
        return 1
    fi

    if [ -z "$json_file" ]; then
        json_file="$OUTPUT_DIR/phase-${phase}-output.json"
    fi

    if [ ! -f "$json_file" ]; then
        echo "[validate-phase] ❌ 产物文件不存在: $json_file"
        return 1
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "验证 Phase $phase 产物"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Schema: $schema_file"
    echo "产物:   $json_file"
    echo ""

    local all_errors=()

    # 执行各类验证
    echo "检查必填字段..."
    while IFS= read -r error; do
        [ -n "$error" ] && all_errors+=("$error")
    done < <(validate_required "$json_file" "$schema_file" "$phase")

    echo "检查类型匹配..."
    while IFS= read -r error; do
        [ -n "$error" ] && all_errors+=("$error")
    done < <(validate_types "$json_file" "$schema_file")

    echo "检查字符串长度..."
    while IFS= read -r error; do
        [ -n "$error" ] && all_errors+=("$error")
    done < <(validate_string_length "$json_file" "$schema_file")

    echo "检查数字范围..."
    while IFS= read -r error; do
        [ -n "$error" ] && all_errors+=("$error")
    done < <(validate_number_range "$json_file" "$schema_file")

    echo "检查数组items..."
    while IFS= read -r error; do
        [ -n "$error" ] && all_errors+=("$error")
    done < <(validate_array_items "$json_file" "$schema_file")

    echo "检查嵌套对象..."
    while IFS= read -r error; do
        [ -n "$error" ] && all_errors+=("$error")
    done < <(validate_nested_object "$json_file" "$schema_file")

    echo "检查 enum 值..."
    while IFS= read -r error; do
        [ -n "$error" ] && all_errors+=("$error")
    done < <(validate_enum "$json_file" "$schema_file")

    echo "检查 pattern..."
    while IFS= read -r error; do
        [ -n "$error" ] && all_errors+=("$error")
    done < <(validate_patterns "$json_file" "$schema_file")

    if [ ${#all_errors[@]} -eq 0 ]; then
        echo ""
        echo "[validate-phase] ✅ Phase $phase 产物验证通过"
        return 0
    else
        echo ""
        echo "[validate-phase] ❌ Phase $phase 产物验证失败"
        echo ""
        echo "错误列表:"
        for error in "${all_errors[@]}"; do
            echo "  - $error"
        done
        return 1
    fi
}

#------------------------------------------------------------------------------
# 验证所有 phase
#------------------------------------------------------------------------------
validate_all() {
    echo "[validate-phase] 开始验证所有阶段产物..."

    local failed=0

    for phase in 0 1 2; do
        if ! validate_phase "$phase"; then
            failed=$((failed + 1))
        fi
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "验证结果汇总"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ $failed -eq 0 ]; then
        echo "[validate-phase] ✅ 所有阶段产物验证通过"
        return 0
    else
        echo "[validate-phase] ❌ $failed 个阶段产物验证失败"
        return 1
    fi
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi

    case "$1" in
        --all|-a)
            validate_all
            ;;
        0|1|2)
            validate_phase "$1" "${2:-}"
            ;;
        *)
            echo "[validate-phase] 错误: 未知的 phase '$1'" >&2
            show_help
            exit 1
            ;;
    esac
}

# v1.12.9 改进：仅在直接执行时运行 main，source 时不执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
