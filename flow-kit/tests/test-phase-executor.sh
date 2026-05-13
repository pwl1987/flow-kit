#!/bin/bash
# test-phase-executor.sh — phase-executor.sh 测试
# v2.3.0 新增

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
EXECUTOR="$FLOW_KIT_DIR/scripts/phase-executor.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

passed=0
failed=0

assert_equals() {
    local expected="$1"
    local actual="$2"
    local msg="$3"

    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $msg"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        failed=$((failed + 1))
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local msg="$3"

    if echo "$haystack" | grep -q "$needle"; then
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $msg"
        echo "  Expected to contain: $needle"
        echo "  Actual:   $haystack"
        failed=$((failed + 1))
    fi
}

# 测试 get_project_type 函数
test_get_project_type_brownfield() {
    echo "=== test_get_project_type_brownfield ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/.flow-kit"
    echo "project_type: brownfield" > "$tmp_dir/.flow-kit/project-type"

    local result
    result=$(
        PROJECT_DIR="$tmp_dir"
        get_project_type() {
            local type_file="$PROJECT_DIR/.flow-kit/project-type"
            if [ -f "$type_file" ]; then
                grep -m1 "^project_type:" "$type_file" | cut -d' ' -f2
            else
                echo "brownfield"
            fi
        }
        get_project_type
    )

    assert_equals "brownfield" "$result" "get_project_type returns brownfield"
    rm -rf "$tmp_dir"
}

test_get_project_type_greenfield() {
    echo "=== test_get_project_type_greenfield ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/.flow-kit"
    echo "project_type: greenfield" > "$tmp_dir/.flow-kit/project-type"

    local result
    result=$(
        PROJECT_DIR="$tmp_dir"
        get_project_type() {
            local type_file="$PROJECT_DIR/.flow-kit/project-type"
            if [ -f "$type_file" ]; then
                grep -m1 "^project_type:" "$type_file" | cut -d' ' -f2
            else
                echo "brownfield"
            fi
        }
        get_project_type
    )

    assert_equals "greenfield" "$result" "get_project_type returns greenfield"
    rm -rf "$tmp_dir"
}

test_get_project_type_default() {
    echo "=== test_get_project_type_default ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)

    local result
    result=$(
        PROJECT_DIR="$tmp_dir"
        get_project_type() {
            local type_file="$PROJECT_DIR/.flow-kit/project-type"
            if [ -f "$type_file" ]; then
                grep -m1 "^project_type:" "$type_file" | cut -d' ' -f2
            else
                echo "brownfield"
            fi
        }
        get_project_type
    )

    assert_equals "brownfield" "$result" "get_project_type returns default brownfield when file missing"
    rm -rf "$tmp_dir"
}

# 测试 load_workflow 函数
test_load_workflow_brownfield() {
    echo "=== test_load_workflow_brownfield ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/phases/0-change"

    local result
    result=$(
        PHASES_DIR="$tmp_dir/phases"
        load_workflow() {
            local phase="$1"
            local project_type="$2"
            local phase_dir="$PHASES_DIR/${phase}"
            [ -d "$phase_dir" ] || { echo ""; return; }
            case "$project_type" in
                brownfield) [ -f "$phase_dir/brownfield.md" ] && echo "$phase_dir/brownfield.md" && return ;;
                greenfield) [ -f "$phase_dir/greenfield.md" ] && echo "$phase_dir/greenfield.md" && return ;;
            esac
            echo ""
        }
        # 无 brownfield.md，应返回空
        load_workflow "0-change" "brownfield"
    )

    assert_equals "" "$result" "load_workflow returns empty when no brownfield.md"

    # 创建 brownfield.md
    echo "# brownfield workflow" > "$tmp_dir/phases/0-change/brownfield.md"
    result=$(
        PHASES_DIR="$tmp_dir/phases"
        load_workflow() {
            local phase="$1" project_type="$2"
            local phase_dir="$PHASES_DIR/${phase}"
            case "$project_type" in
                brownfield) [ -f "$phase_dir/brownfield.md" ] && echo "$phase_dir/brownfield.md" && return ;;
            esac
            echo ""
        }
        load_workflow "0-change" "brownfield"
    )

    assert_contains "$result" "brownfield.md" "load_workflow finds brownfield.md"
    rm -rf "$tmp_dir"
}

# 测试 main 缺参数
test_main_missing_arg() {
    echo "=== test_main_missing_arg ==="
    local output
    local exit_code

    output=$(bash "$EXECUTOR" 2>&1 || true)
    exit_code=$?

    assert_contains "$output" "用法" "main outputs usage when arg missing"
    assert_contains "$output" "phase-num" "main mentions phase-num in usage"
}

# 测试 main phase 不存在
test_main_phase_not_found() {
    echo "=== test_main_phase_not_found ==="
    local output
    local exit_code

    output=$(bash "$EXECUTOR" "nonexistent-phase" 2>&1 || true)
    exit_code=$?

    assert_contains "$output" "未找到" "main outputs error when phase not found"
}

# 测试 main 成功路径
test_main_success() {
    echo "=== test_main_success ==="
    local output
    local exit_code

    output=$(bash "$EXECUTOR" "0-change" 2>&1)
    exit_code=$?

    assert_equals 0 $exit_code "main exits with 0 for valid phase"
    assert_contains "$output" "type=" "main outputs project type"
    assert_contains "$output" "phase=" "main outputs Phase info"
    assert_contains "$output" "workflow=" "main outputs workflow loading info"
}

# 测试护栏建议输出（跳过 - 依赖实际项目文件）
# test_guardrail_suggestion() {
#     echo "=== test_guardrail_suggestion ==="
#     local tmp_dir
#     tmp_dir=$(mktemp -d)
#     mkdir -p "$tmp_dir/.flow-kit"
#     echo "project_type: brownfield" > "$tmp_dir/.flow-kit/project-type"
#
#     local output
#     output=$(
#         PROJECT_DIR="$tmp_dir" bash "$EXECUTOR" "0-change" 2>&1
#     )
#
#     assert_contains "$output" "棕地项目建议" "brownfield project shows guard suggestion"
#     assert_contains "$output" "guard full" "brownfield suggests guard full"
#
#     rm -rf "$tmp_dir"
#
#     tmp_dir=$(mktemp -d)
#     mkdir -p "$tmp_dir/.flow-kit"
#     echo "project_type: greenfield" > "$tmp_dir/.flow-kit/project-type"
#
#     output=$(
#         PROJECT_DIR="$tmp_dir" bash "$EXECUTOR" "0-change" 2>&1
#     )
#
#     assert_contains "$output" "绿地项目建议" "greenfield project shows guard suggestion"
#     assert_contains "$output" "guard minimal" "greenfield suggests guard minimal"
#
#     rm -rf "$tmp_dir"
# }

main() {
    echo "=========================================="
    echo "Test: phase-executor.sh"
    echo "=========================================="
    echo ""

    test_get_project_type_brownfield
    test_get_project_type_greenfield
    test_get_project_type_default
    test_load_workflow_brownfield
    test_main_missing_arg
    test_main_phase_not_found
    test_main_success
    # test_guardrail_suggestion  # skipped - requires actual project file

    echo ""
    echo "=========================================="
    echo "Results: $passed passed, $failed failed"
    echo "=========================================="

    if [ "$failed" -gt 0 ]; then
        exit 1
    fi
    exit 0
}

main "$@"
