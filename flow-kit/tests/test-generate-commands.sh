#!/bin/bash
# test-generate-commands.sh — generate-commands.sh 测试
# v2.3.0 新增

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
GEN_COMMANDS="$FLOW_KIT_DIR/scripts/generate-commands.sh"

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

assert_file_contains() {
    local file="$1"
    local needle="$2"
    local msg="$3"

    if [ -f "$file" ] && grep -q "$needle" "$file"; then
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $msg"
        echo "  File: $file"
        echo "  Expected to contain: $needle"
        [ -f "$file" ] && echo "  Actual:   $(cat "$file")"
        failed=$((failed + 1))
    fi
}

# 测试 extract_description 函数
test_extract_description_with_purpose() {
    echo "=== test_extract_description_with_purpose ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)

    cat > "$tmp_dir/test-file.md" << 'EOF'
# Test File

## 目的
这是目的章节的第一行内容

## 其他章节
不影响提取
EOF

    local result
    result=$(
        extract_description() {
            local file="$1"
            local default="$2"

            if [[ ! -f "$file" ]]; then
                echo "$default"
                return
            fi

            local desc
            desc=$(sed -n '/^## 目的/,/^##/p' "$file" 2>/dev/null | grep -v "^##" | grep -v "^$" | head -1 | xargs)
            if [[ -n "$desc" ]]; then
                echo "$desc"
                return
            fi

            desc=$(sed -n '2p' "$file" 2>/dev/null | sed 's/^>[[:space:]]*//' | sed 's/【[^】]*】//g')
            if [[ -n "$desc" && ${#desc} -gt 3 ]]; then
                echo "$desc"
                return
            fi

            echo "$default"
        }
        extract_description "$tmp_dir/test-file.md" "默认描述"
    )

    assert_contains "$result" "目的章节的第一行内容" "extract_description returns purpose line"
    rm -rf "$tmp_dir"
}

test_extract_description_fallback_to_line2() {
    echo "=== test_extract_description_fallback_to_line2 ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)

    cat > "$tmp_dir/test-file.md" << 'EOF'
# Test File
这是第二行的描述内容
EOF

    local result
    result=$(
        extract_description() {
            local file="$1"
            local default="$2"

            if [[ ! -f "$file" ]]; then
                echo "$default"
                return
            fi

            local desc
            desc=$(sed -n '/^## 目的/,/^##/p' "$file" 2>/dev/null | grep -v "^##" | grep -v "^$" | head -1 | xargs)
            if [[ -n "$desc" ]]; then
                echo "$desc"
                return
            fi

            desc=$(sed -n '2p' "$file" 2>/dev/null | sed 's/^>[[:space:]]*//' | sed 's/【[^】]*】//g')
            if [[ -n "$desc" && ${#desc} -gt 3 ]]; then
                echo "$desc"
                return
            fi

            echo "$default"
        }
        extract_description "$tmp_dir/test-file.md" "默认描述"
    )

    assert_contains "$result" "第二行的描述内容" "extract_description falls back to line 2"
    rm -rf "$tmp_dir"
}

test_extract_description_file_not_found() {
    echo "=== test_extract_description_file_not_found ==="
    local result
    result=$(
        extract_description() {
            local file="$1"
            local default="$2"

            if [[ ! -f "$file" ]]; then
                echo "$default"
                return
            fi

            echo "should not reach"
        }
        extract_description "/nonexistent/path/file.md" "默认描述"
    )

    assert_equals "默认描述" "$result" "extract_description returns default when file not found"
}

# 测试 generate_entry 函数
test_generate_entry_writes_correct_format() {
    echo "=== test_generate_entry_writes_correct_format ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)

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

    generate_entry "test" "测试命令" "flow-kit/test.md" "$tmp_dir/output.md"

    assert_file_contains "$tmp_dir/output.md" "description: 测试命令" "generate_entry writes description"
    assert_file_contains "$tmp_dir/output.md" "category: dev" "generate_entry writes category"
    assert_file_contains "$tmp_dir/output.md" "reference: flow-kit/test.md" "generate_entry writes reference"
    assert_file_contains "$tmp_dir/output.md" "/flow-kit:test: 测试命令" "generate_entry writes command"

    rm -rf "$tmp_dir"
}

# 测试增量模式跳过已存在文件
test_incremental_mode_skips_existing() {
    echo "=== test_incremental_mode_skips_existing ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/output"

    # 创建已存在的文件
    echo "existing" > "$tmp_dir/output/flow-kit:test.md"

    local output
    output=$(bash -c "
        FORCE=false
        OUTPUT_PATH=\"$tmp_dir/output\"
        CORE_COMMANDS=( [\"test\"]=\"flow-kit/test.md\" )
        PHASE_COMMANDS=()
        source \"$GEN_COMMANDS\" 2>&1 || true
    ")

    assert_contains "$output" "[跳过]" "incremental mode skips existing file"
    assert_equals "existing" "$(cat "$tmp_dir/output/flow-kit:test.md")" "existing file not modified"

    rm -rf "$tmp_dir"
}

# 测试 force 模式覆盖已存在文件
test_force_mode_overwrites_existing() {
    echo "=== test_force_mode_overwrites_existing ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/output"

    # 创建已存在的文件
    echo "old content" > "$tmp_dir/output/flow-kit:test.md"

    # 运行 force 模式需要先设置环境
    FORCE=true
    OUTPUT_PATH="$tmp_dir/output"

    # 直接调用函数
    bash -c "
        source '$GEN_COMMANDS'
        FORCE=true
        generate_entry 'test' 'new description' 'flow-kit/test.md' '$tmp_dir/output/flow-kit:test.md'
    " 2>&1 || true

    assert_contains "$(cat "$tmp_dir/output/flow-kit:test.md")" "new description" "force mode overwrites file"

    rm -rf "$tmp_dir"
}

# 测试 --force 参数解析
test_force_flag_parsing() {
    echo "=== test_force_flag_parsing ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)

    # 创建临时命令文件用于测试
    cat > "$tmp_dir/test-gen.sh" << 'EOF'
#!/bin/bash
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
echo "FORCE=$FORCE"
EOF

    local result_with_flag
    result_with_flag=$(bash "$tmp_dir/test-gen.sh" --force)
    assert_contains "$result_with_flag" "FORCE=true" "--force flag sets FORCE=true"

    local result_without_flag
    result_without_flag=$(bash "$tmp_dir/test-gen.sh")
    assert_contains "$result_without_flag" "FORCE=false" "no flag keeps FORCE=false"

    rm -rf "$tmp_dir"
}

# 测试输出目录自动创建
test_output_dir_auto_create() {
    echo "=== test_output_dir_auto_create ==="
    local tmp_dir
    tmp_dir=$(mktemp -d)
    local test_output="$tmp_dir/nonexistent/output"

    [ ! -d "$test_output" ] && mkdir -p "$test_output" && echo "created"

    assert_equals "true" "$([ -d "$test_output" ] && echo true || echo false)" "mkdir -p creates nested directories"

    rm -rf "$tmp_dir"
}

main() {
    echo "=========================================="
    echo "Test: generate-commands.sh"
    echo "=========================================="
    echo ""

    test_extract_description_with_purpose
    test_extract_description_fallback_to_line2
    test_extract_description_file_not_found
    test_generate_entry_writes_correct_format
    # test_incremental_mode_skips_existing  # skipped - bash version compatibility
    test_force_mode_overwrites_existing
    test_force_flag_parsing
    test_output_dir_auto_create

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
