#!/bin/bash
# test-caveman-compress.sh — caveman-compress.sh 测试
# v3.5.0 新增

set -euo pipefail

FLOW_KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
passed=0
failed=0

assert_contains() {
    local haystack="$1" needle="$2" msg="$3"
    if echo "$haystack" | grep -qF "$needle"; then
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $msg"
        echo "  Expected: $needle"
        failed=$((failed + 1))
    fi
}

assert_not_contains() {
    local haystack="$1" needle="$2" msg="$3"
    if echo "$haystack" | grep -qF "$needle"; then
        echo -e "${RED}FAIL${NC}: $msg"
        echo "  Unexpected: $needle"
        failed=$((failed + 1))
    else
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    fi
}

assert_file_exists() {
    local file="$1" msg="$2"
    if [ -f "$file" ]; then
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $msg (file not found)"
        failed=$((failed + 1))
    fi
}

# === 静态检查 ===

test_caveman_script_exists() {
    echo "=== test_caveman_script_exists ==="
    [ -f "$FLOW_KIT_DIR/scripts/caveman-compress.sh" ]
    echo -e "${GREEN}PASS${NC}: caveman-compress.sh exists"
    passed=$((passed + 1))
}

test_caveman_has_set_eu() {
    echo "=== test_caveman_has_set_eu ==="
    local content
    content=$(cat "$FLOW_KIT_DIR/scripts/caveman-compress.sh")
    assert_contains "$content" "set -" "caveman-compress has set directive"
}

test_caveman_has_compress_output() {
    echo "=== test_caveman_has_compress_output ==="
    local content
    content=$(cat "$FLOW_KIT_DIR/scripts/caveman-compress.sh")
    assert_contains "$content" "Compressed" "caveman-compress produces compressed output"
}

test_caveman_has_max_lines() {
    echo "=== test_caveman_has_max_lines ==="
    local content
    content=$(cat "$FLOW_KIT_DIR/scripts/caveman-compress.sh")
    assert_contains "$content" "MAX_LINES" "caveman-compress has MAX_LINES config"
}

# === 功能测试：extract_decisions ===

test_extract_decisions_finds_decisions() {
    echo "=== test_extract_decisions_finds_decisions ==="
    local tmp_dir
    tmp_dir=$(mktemp -d "/tmp/test-caveman-$$-XXXXXX")
    mkdir -p "$tmp_dir/phases"

    cat > "$tmp_dir/phases/phase1.md" << 'EOF'
# Phase 1

Decision: 使用 SQLite 作为本地存储
一些描述文字
决定：采用分层架构
EOF

    # source 脚本获取函数
    source "$FLOW_KIT_DIR/scripts/caveman-compress.sh" 2>/dev/null || true

    local result
    result=$(extract_decisions "$tmp_dir/phases" 2>/dev/null || true)
    assert_contains "$result" "Key Decisions" "extract_decisions produces section header"
    assert_contains "$result" "SQLite" "extract_decisions finds decision line"

    rm -rf "$tmp_dir"
}

test_extract_decisions_ignores_templates() {
    echo "=== test_extract_decisions_ignores_templates ==="
    local tmp_dir
    tmp_dir=$(mktemp -d "/tmp/test-caveman-$$-XXXXXX")
    mkdir -p "$tmp_dir/phases"

    echo "Decision: 不应被提取" > "$tmp_dir/phases/TEMPLATE.md"
    echo "Decision: 应该被提取" > "$tmp_dir/phases/real.md"

    source "$FLOW_KIT_DIR/scripts/caveman-compress.sh" 2>/dev/null || true

    local result
    result=$(extract_decisions "$tmp_dir/phases" 2>/dev/null || true)
    assert_not_contains "$result" "不应被提取" "extract_decisions skips TEMPLATE files"
    assert_contains "$result" "应该被提取" "extract_decisions processes non-template files"

    rm -rf "$tmp_dir"
}

test_extract_decisions_empty_dir() {
    echo "=== test_extract_decisions_empty_dir ==="
    local tmp_dir
    tmp_dir=$(mktemp -d "/tmp/test-caveman-$$-XXXXXX")
    mkdir -p "$tmp_dir/phases"

    source "$FLOW_KIT_DIR/scripts/caveman-compress.sh" 2>/dev/null || true

    local result
    result=$(extract_decisions "$tmp_dir/phases" 2>/dev/null || echo "")
    # 空目录无决策 → 无输出
    assert_not_contains "$result" "Key Decisions" "extract_decisions empty dir no section header"

    rm -rf "$tmp_dir"
}

# === 功能测试：extract_todos ===

test_extract_todos_finds_todos() {
    echo "=== test_extract_todos_finds_todos ==="
    local tmp_dir
    tmp_dir=$(mktemp -d "/tmp/test-caveman-$$-XXXXXX")
    mkdir -p "$tmp_dir/phases"

    cat > "$tmp_dir/phases/tasks.md" << 'EOF'
# Tasks

- [ ] TODO: 完善错误处理
- [ ] FIXME: 内存泄漏
- 修复：登录超时问题
- 普通列表项
EOF

    source "$FLOW_KIT_DIR/scripts/caveman-compress.sh" 2>/dev/null || true

    local result
    result=$(extract_todos "$tmp_dir/phases" 2>/dev/null || true)
    assert_contains "$result" "Pending Items" "extract_todos produces section header"
    assert_contains "$result" "TODO" "extract_todos finds TODO item"

    rm -rf "$tmp_dir"
}

# === 功能测试：main 函数 ===

test_main_creates_output_file() {
    echo "=== test_main_creates_output_file ==="
    local tmp_dir
    tmp_dir=$(mktemp -d "/tmp/test-caveman-$$-XXXXXX")
    mkdir -p "$tmp_dir/phases"

    echo "# Phase 1" > "$tmp_dir/phases/phase1.md"
    echo "Decision: 使用 JSON 格式" >> "$tmp_dir/phases/phase1.md"

    local output_file="$tmp_dir/CONTEXT.md"

    source "$FLOW_KIT_DIR/scripts/caveman-compress.sh" 2>/dev/null || true

    main "$tmp_dir/phases" "$output_file" 2>/dev/null || true
    assert_file_exists "$output_file" "main creates output file"

    local content
    content=$(cat "$output_file" 2>/dev/null || echo "")
    assert_contains "$content" "Context Summary" "output has title"
    assert_contains "$content" "compressed" "output has compressed marker"

    rm -rf "$tmp_dir"
}

test_main_missing_input_dir() {
    echo "=== test_main_missing_input_dir ==="
    local tmp_dir
    tmp_dir=$(mktemp -d "/tmp/test-caveman-$$-XXXXXX")

    source "$FLOW_KIT_DIR/scripts/caveman-compress.sh" 2>/dev/null || true

    # 不存在的输入目录 → main 返回非零
    if main "$tmp_dir/nonexist" "$tmp_dir/out.md" 2>/dev/null; then
        echo -e "${RED}FAIL${NC}: main should fail for missing input dir"
        failed=$((failed + 1))
    else
        echo -e "${GREEN}PASS${NC}: main fails for missing input dir"
        passed=$((passed + 1))
    fi

    rm -rf "$tmp_dir"
}

main() {
    echo "=========================================="
    echo "Test: caveman-compress.sh"
    echo "=========================================="
    echo ""

    test_caveman_script_exists
    test_caveman_has_set_eu
    test_caveman_has_compress_output
    test_caveman_has_max_lines
    test_extract_decisions_finds_decisions
    test_extract_decisions_ignores_templates
    test_extract_decisions_empty_dir
    test_extract_todos_finds_todos
    test_main_creates_output_file
    test_main_missing_input_dir

    echo ""
    echo "=========================================="
    echo "Results: $passed passed, $failed failed"
    echo "=========================================="
    [ "$failed" -gt 0 ] && exit 1
    exit 0
}

main "$@"
