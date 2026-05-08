#!/bin/bash
# validate-phase.sh — 阶段产物 JSON Schema 验证
# v1.12.6 P1 新增
# 验证 phase-0/1/2 产物是否符合 JSON Schema

set -e

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
# 验证 enum 值
#------------------------------------------------------------------------------
validate_enum() {
    local json_file="$1"
    local schema_file="$2"

    local errors=()
    local props=$(jq -r '.properties | keys[]' "$schema_file" 2>/dev/null || echo "")

    for prop in $props; do
        local enum_values=$(jq -c ".properties.\"$prop\".enum[]" "$schema_file" 2>/dev/null || echo "")
        if [ -n "$enum_values" ]; then
            local actual_value=$(jq -r ".\"$prop\"" "$json_file" 2>/dev/null)
            local found=false
            for enum_val in $enum_values; do
                if [ "\"$actual_value\"" = "$enum_val" ]; then
                    found=true
                    break
                fi
            done
            if [ "$found" = false ]; then
                errors+=("字段 $prop: 值 '$actual_value' 不在允许的 enum 列表中")
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

main "$@"
