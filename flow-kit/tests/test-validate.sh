#!/bin/bash
# test-validate.sh — validate-phase.sh 单元测试
# v1.12.9 P1 新增
# 覆盖 validate-phase.sh 核心验证函数

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(dirname "$SCRIPT_DIR")"
SCHEMA_DIR="$FLOW_KIT_DIR/lib/validation/schemas"

# 检查依赖
JQ_AVAILABLE=false
if command -v jq &>/dev/null; then
    JQ_AVAILABLE=true
fi

passed=0
failed=0
skipped=0

run_test() {
    local test_name="$1"
    local test_func="$2"
    local requires_jq="${3:-false}"

    echo ""
    echo "[TEST] 运行: $test_name"

    if [ "$requires_jq" = true ] && [ "$JQ_AVAILABLE" = false ]; then
        echo "[TEST] ⏭️ $test_name - 跳过 (需要 jq)"
        skipped=$((skipped + 1))
        return 0
    fi

    if $test_func; then
        echo "[TEST] ✅ $test_name - 通过"
        passed=$((passed + 1))
        return 0
    else
        echo "[TEST] ❌ $test_name - 失败"
        failed=$((failed + 1))
        return 1
    fi
}

#------------------------------------------------------------------------------
# 辅助函数
#------------------------------------------------------------------------------
make_temp_dir() {
    mktemp -d 2>/dev/null || mktemp -d -t 'validate-test-XXXX'
}

#------------------------------------------------------------------------------
# 测试用例
#------------------------------------------------------------------------------

test_validate_required_pass() {
    local tmp_dir=$(make_temp_dir)
    echo '{"name": "test", "version": "1.0.0"}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"name": {"type": "string"}, "version": {"type": "string"}}, "required": ["name", "version"]}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_required "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'" "0"
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    [ -z "$result" ]
}

test_validate_required_fail() {
    local tmp_dir=$(make_temp_dir)
    echo '{"name": "test"}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"name": {"type": "string"}, "version": {"type": "string"}}, "required": ["name", "version"]}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_required "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'" "0"
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    echo "$result" | grep -q "缺少必填字段"
}

test_validate_types_string() {
    local tmp_dir=$(make_temp_dir)
    echo '{"name": "test"}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"name": {"type": "string"}}}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_types "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'"
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    [ -z "$result" ]
}

test_validate_types_mismatch() {
    local tmp_dir=$(make_temp_dir)
    echo '{"count": "not_a_number"}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"count": {"type": "number"}}}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_types "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'"
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    echo "$result" | grep -q "期望 number"
}

test_validate_string_length_min() {
    local tmp_dir=$(make_temp_dir)
    echo '{"name": "ab"}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"name": {"type": "string", "minLength": 5}}}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_string_length "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'"
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    echo "$result" | grep -q "小于最小长度"
}

test_validate_string_length_max() {
    local tmp_dir=$(make_temp_dir)
    echo '{"name": "too_long_name_here"}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"name": {"type": "string", "maxLength": 5}}}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_string_length "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'"
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    echo "$result" | grep -q "超过最大长度"
}

test_validate_enum_pass() {
    local tmp_dir=$(make_temp_dir)
    echo '{"level": "info"}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"level": {"type": "string", "enum": ["debug", "info", "warn", "error"]}}}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_enum "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'"
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    [ -z "$result" ]
}

test_validate_enum_fail() {
    local tmp_dir=$(make_temp_dir)
    echo '{"level": "critical"}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"level": {"type": "string", "enum": ["debug", "info", "warn", "error"]}}}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_enum "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'"
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    echo "$result" | grep -q "不在允许的枚举值"
}

test_validate_nested_object() {
    local tmp_dir=$(make_temp_dir)
    echo '{"metadata": {"author": "test", "version": 1}}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"metadata": {"type": "object", "properties": {"author": {"type": "string"}, "version": {"type": "integer"}}, "required": ["author"]}}}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_nested_object "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'" ""
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    [ -z "$result" ]
}

test_validate_nested_object_missing_required() {
    local tmp_dir=$(make_temp_dir)
    echo '{"metadata": {"version": 1}}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"metadata": {"type": "object", "properties": {"author": {"type": "string"}, "version": {"type": "integer"}}, "required": ["author"]}}}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_nested_object "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'" ""
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    echo "$result" | grep -q "缺少必填字段"
}

test_validate_array_items() {
    local tmp_dir=$(make_temp_dir)
    echo '{"tags": ["a", "b", "c"]}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"tags": {"type": "array", "items": {"type": "string"}, "minItems": 1, "maxItems": 5}}}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_array_items "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'"
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    [ -z "$result" ]
}

test_validate_array_items_type_mismatch() {
    local tmp_dir=$(make_temp_dir)
    echo '{"tags": ["a", 42, "c"]}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"tags": {"type": "array", "items": {"type": "string"}}}}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_array_items "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'"
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    echo "$result" | grep -q "期望 string"
}

test_validate_pattern() {
    local tmp_dir=$(make_temp_dir)
    echo '{"email": "user@example.com"}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"email": {"type": "string", "pattern": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"}}}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_patterns "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'"
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    [ -z "$result" ]
}

test_validate_number_range() {
    local tmp_dir=$(make_temp_dir)
    echo '{"score": 85}' > "$tmp_dir/input.json"
    echo '{"type": "object", "properties": {"score": {"type": "number", "minimum": 0, "maximum": 100}}}' > "$tmp_dir/schema.json"

    local result
    result=$(bash -c '
        source "'"$FLOW_KIT_DIR"'/scripts/validate-phase.sh"
        validate_number_range "'"$tmp_dir/input.json"'" "'"$tmp_dir/schema.json"'"
    ' 2>/dev/null)

    rm -rf "$tmp_dir"
    [ -z "$result" ]
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "validate-phase.sh 单元测试"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    run_test "必填字段验证 - 通过" test_validate_required_pass true
    run_test "必填字段验证 - 失败" test_validate_required_fail true
    run_test "类型验证 - 字符串匹配" test_validate_types_string true
    run_test "类型验证 - 类型不匹配" test_validate_types_mismatch true
    run_test "字符串长度 - 最小长度" test_validate_string_length_min true
    run_test "字符串长度 - 最大长度" test_validate_string_length_max true
    run_test "枚举值验证 - 通过" test_validate_enum_pass true
    run_test "枚举值验证 - 失败" test_validate_enum_fail true
    run_test "嵌套对象验证 - 通过" test_validate_nested_object true
    run_test "嵌套对象验证 - 缺少必填" test_validate_nested_object_missing_required true
    run_test "数组 items 验证 - 通过" test_validate_array_items true
    run_test "数组 items 验证 - 类型不匹配" test_validate_array_items_type_mismatch true
    run_test "Pattern 验证" test_validate_pattern true
    run_test "数字范围验证" test_validate_number_range true

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "测试结果: 通过 $passed | 失败 $failed | 跳过 $skipped"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ "$failed" -gt 0 ]; then
        exit 1
    fi
}

main "$@"
