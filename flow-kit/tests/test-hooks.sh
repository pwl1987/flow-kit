#!/bin/bash
# test-hooks.sh — Hooks 集成测试
# v1.12.9 P1 新增
# 模拟 hooks 输入，验证拦截逻辑和错误处理

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(dirname "$SCRIPT_DIR")"

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
# 测试用例 - pre-tool-guard.sh
#------------------------------------------------------------------------------

test_pre_tool_guard_safe_command() {
    # 安全命令应放行
    local input='{"tool_name": "Bash", "tool_input": {"command": "ls -la"}}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/pre-tool-guard.sh" 2>&1)
    [ "$?" -eq 0 ]
}

test_pre_tool_guard_block_rm_rf() {
    # rm -rf 应被拦截
    local input='{"tool_name": "Bash", "tool_input": {"command": "rm -rf /tmp/test"}}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/pre-tool-guard.sh" 2>&1)
    local exit_code=$?
    [ "$exit_code" -eq 2 ]
}

test_pre_tool_guard_block_git_push_force() {
    # git push --force 应被拦截
    local input='{"tool_name": "Bash", "tool_input": {"command": "git push --force origin main"}}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/pre-tool-guard.sh" 2>&1)
    local exit_code=$?
    [ "$exit_code" -eq 2 ]
}

test_pre_tool_guard_block_drop_table() {
    # DROP TABLE 应被拦截
    local input='{"tool_name": "Bash", "tool_input": {"command": "DROP TABLE users"}}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/pre-tool-guard.sh" 2>&1)
    local exit_code=$?
    [ "$exit_code" -eq 2 ]
}

test_pre_tool_guard_block_ddl_rename() {
    # ALTER TABLE RENAME 应被拦截
    local input='{"tool_name": "Bash", "tool_input": {"command": "ALTER TABLE users RENAME TO customers"}}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/pre-tool-guard.sh" 2>&1)
    local exit_code=$?
    [ "$exit_code" -eq 2 ]
}

test_pre_tool_guard_block_drop_column() {
    # DROP COLUMN 应被拦截
    local input='{"tool_name": "Bash", "tool_input": {"command": "ALTER TABLE users DROP COLUMN email"}}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/pre-tool-guard.sh" 2>&1)
    local exit_code=$?
    [ "$exit_code" -eq 2 ]
}

test_pre_tool_guard_block_truncate() {
    # TRUNCATE TABLE 应被拦截
    local input='{"tool_name": "Bash", "tool_input": {"command": "TRUNCATE TABLE users"}}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/pre-tool-guard.sh" 2>&1)
    local exit_code=$?
    [ "$exit_code" -eq 2 ]
}

test_pre_tool_guard_select_statement() {
    # SELECT 语句应放行
    local input='{"tool_name": "Bash", "tool_input": {"command": "SELECT * FROM users"}}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/pre-tool-guard.sh" 2>&1)
    [ "$?" -eq 0 ]
}

test_pre_tool_guard_protected_file_env() {
    # .env 文件编辑应被拦截
    local input='{"tool_name": "Edit", "tool_input": {"file_path": ".env"}}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/pre-tool-guard.sh" 2>&1)
    local exit_code=$?
    [ "$exit_code" -eq 2 ]
}

test_pre_tool_guard_protected_file_git() {
    # .git/ 目录编辑应被拦截
    local input='{"tool_name": "Write", "tool_input": {"file_path": ".git/config"}}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/pre-tool-guard.sh" 2>&1)
    local exit_code=$?
    [ "$exit_code" -eq 2 ]
}

test_pre_tool_guard_non_json_input() {
    # 非 JSON 输入应优雅处理
    local input='some plain text input'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/pre-tool-guard.sh" 2>&1)
    [ "$?" -eq 0 ]
}

#------------------------------------------------------------------------------
# 测试用例 - post-edit-format.sh
#------------------------------------------------------------------------------

test_post_edit_format_non_edit_tool() {
    # 非 Edit/Write 工具应跳过
    local input='{"tool_name": "Bash", "tool_input": {"command": "ls"}}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/post-edit-format.sh" 2>&1)
    [ "$?" -eq 0 ]
}

test_post_edit_format_nonexistent_file() {
    # 不存在的文件应跳过
    local input='{"tool_name": "Edit", "tool_input": {"file_path": "/tmp/nonexistent_file_xyz_123.test"}}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/post-edit-format.sh" 2>&1)
    [ "$?" -eq 0 ]
}

#------------------------------------------------------------------------------
# 测试用例 - stop-quality-gate.sh
#------------------------------------------------------------------------------

test_stop_quality_gate_no_coverage_file() {
    # 无覆盖率文件应跳过
    local input='{"stop_hook_active": false}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/stop-quality-gate.sh" 2>&1)
    [ "$?" -eq 0 ]
}

test_stop_quality_gate_already_active() {
    # 已激活的 stop hook 应跳过
    local input='{"stop_hook_active": true}'
    local result
    result=$(echo "$input" | bash "$FLOW_KIT_DIR/hooks/stop-quality-gate.sh" 2>&1)
    [ "$?" -eq 0 ]
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Hooks 集成测试"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo ""
    echo "--- pre-tool-guard.sh ---"
    run_test "安全命令放行" test_pre_tool_guard_safe_command true
    run_test "拦截 rm -rf" test_pre_tool_guard_block_rm_rf true
    run_test "拦截 git push --force" test_pre_tool_guard_block_git_push_force true
    run_test "拦截 DROP TABLE" test_pre_tool_guard_block_drop_table true
    run_test "拦截 ALTER TABLE RENAME" test_pre_tool_guard_block_ddl_rename true
    run_test "拦截 DROP COLUMN" test_pre_tool_guard_block_drop_column true
    run_test "拦截 TRUNCATE TABLE" test_pre_tool_guard_block_truncate true
    run_test "SELECT 语句放行" test_pre_tool_guard_select_statement true
    run_test "保护 .env 文件" test_pre_tool_guard_protected_file_env true
    run_test "保护 .git/ 目录" test_pre_tool_guard_protected_file_git true
    run_test "非 JSON 输入处理" test_pre_tool_guard_non_json_input false

    echo ""
    echo "--- post-edit-format.sh ---"
    run_test "非 Edit 工具跳过" test_post_edit_format_non_edit_tool true
    run_test "不存在文件跳过" test_post_edit_format_nonexistent_file true

    echo ""
    echo "--- stop-quality-gate.sh ---"
    run_test "无覆盖率文件跳过" test_stop_quality_gate_no_coverage_file false
    run_test "已激活跳过" test_stop_quality_gate_already_active false

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "测试结果: 通过 $passed | 失败 $failed | 跳过 $skipped"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ "$failed" -gt 0 ]; then
        exit 1
    fi
}

main "$@"
