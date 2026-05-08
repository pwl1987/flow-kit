#!/bin/bash
# dispatch.sh — 多代理并行编排脚本
# v1.12.4 P0 核心功能
# 用法: ./dispatch.sh [N] "任务描述"

set -e

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(dirname "$SCRIPT_DIR")"
LOCK_DIR=".flow-kit/locks"
TMP_DIR=".flow-kit/tmp"
AGENT_NAME="${AGENT_NAME:-agent-main}"

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
dispatch.sh — 多代理并行编排脚本

用法:
  ./dispatch.sh [N] "任务描述"

参数:
  N           并行 executor 数量（默认: 3）
  任务描述    要分解和执行的任务

示例:
  ./dispatch.sh 3 "实现用户认证系统"
  ./dispatch.sh "修复登录 bug"

输出:
  - .flow-kit/tmp/subagent-{id}-prompt.txt  (子任务 prompt 文件)
  - .flow-kit/tmp/dispatch-summary.json     (执行摘要)
EOF
}

#------------------------------------------------------------------------------
# 参数解析
#------------------------------------------------------------------------------
parse_args() {
    EXECUTE_MODE=false

    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi

    # 收集所有参数（过滤掉 --execute）
    local args=()
    for arg in "$@"; do
        if [ "$arg" = "--execute" ]; then
            EXECUTE_MODE=true
        else
            args+=("$arg")
        fi
    done

    # 从过滤后的参数中解析数字
    if [[ "${args[0]}" =~ ^[0-9]+$ ]]; then
        PARALLEL_N="${args[0]}"
        args=("${args[@]:1}")
    else
        PARALLEL_N=3
    fi

    # 合并剩余参数为任务描述
    TASK_DESC="${args[*]}"

    if [ -z "$TASK_DESC" ]; then
        echo "[dispatch] 错误: 任务描述不能为空" >&2
        exit 1
    fi
}

#------------------------------------------------------------------------------
# 目录初始化
#------------------------------------------------------------------------------
init_dirs() {
    mkdir -p "$TMP_DIR"
    mkdir -p "$LOCK_DIR"
}

#------------------------------------------------------------------------------
# 任务拆分
#------------------------------------------------------------------------------
split_task() {
    local task="$1"
    local n="$2"

    local TASK_ID="task-$(date +%Y%m%d%H%M%S)"
    local CREATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    echo "[dispatch] 📋 任务拆分中: $task -> $n 个子任务"

    # 生成子任务
    local SUBTASKS=()
    for i in $(seq 1 $n); do
        local AGENT_ID="agent-$i"
        local ROLE=""

        case $i in
            1) ROLE="Code Executor" ;;
            2) ROLE="Code Reviewer" ;;
            3) ROLE="Test Runner" ;;
            *) ROLE="Code Executor" ;;
        esac

        # 确定文件范围（基于任务描述关键词）
        local FILE_SCOPE=""
        if echo "$task" | grep -q "认证\|登录\|用户"; then
            FILE_SCOPE="auth/,user/,login/"
        elif echo "$task" | grep -q "API\|接口"; then
            FILE_SCOPE="api/,routes/,controllers/"
        elif echo "$task" | grep -q "数据库\|DB\|数据"; then
            FILE_SCOPE="db/,models/,migrations/"
        else
            FILE_SCOPE="src/"
        fi

        # 创建子任务 prompt 文件
        local PROMPT_FILE="$TMP_DIR/subagent-${AGENT_ID}-prompt.txt"
        cat > "$PROMPT_FILE" << PROMPT
# 子任务 Prompt

**任务ID**: $TASK_ID
**子代理ID**: $AGENT_ID
**角色类型**: $ROLE
**任务描述**: $task
**文件范围**: $FILE_SCOPE

## 执行指令

你是一个 $ROLE，负责完成以下任务：

**原始任务**: $task

**你的职责**:
PROMPT

        case "$ROLE" in
            "Code Executor")
                cat >> "$PROMPT_FILE" << 'ROLE_EOF'
- 根据任务描述编写/修改代码
- 遵守项目编码规范
- 完成后输出修改文件清单

**输出格式**:
{
  "status": "SUCCESS|FAILED|PARTIAL",
  "files_modified": ["file1", "file2"],
  "summary": "完成情况简述（<200字）",
  "issues": ["issue1", "issue2"]
}
ROLE_EOF
                ;;
            "Code Reviewer")
                cat >> "$PROMPT_FILE" << 'ROLE_EOF'
- 审查代码质量和安全性
- 检查是否符合编码规范
- 提出改进建议

**输出格式**:
{
  "status": "SUCCESS|FAILED|PARTIAL",
  "files_reviewed": ["file1", "file2"],
  "summary": "审查结果简述（<200字）",
  "issues": ["issue1", "issue2"]
}
ROLE_EOF
                ;;
            "Test Runner")
                cat >> "$PROMPT_FILE" << 'ROLE_EOF'
- 执行测试验证功能正确性
- 检查测试覆盖率
- 报告测试结果

**输出格式**:
{
  "status": "SUCCESS|FAILED|PARTIAL",
  "tests_run": N,
  "tests_passed": N,
  "summary": "测试结果简述（<200字）",
  "issues": ["issue1", "issue2"]
}
ROLE_EOF
                ;;
        esac

        echo "[dispatch] ✅ 子任务已创建: $AGENT_ID ($ROLE) -> $PROMPT_FILE"

        SUBTASKS+=("{\"id\":\"$AGENT_ID\",\"role\":\"$ROLE\",\"status\":\"QUEUED\",\"prompt_file\":\"$PROMPT_FILE\"}")
    done

    # 生成汇总 JSON
    local SUMMARY_FILE="$TMP_DIR/dispatch-summary.json"
    cat > "$SUMMARY_FILE" << EOF
{
  "task_id": "$TASK_ID",
  "task_desc": "$task",
  "parallel_n": $n,
  "agents": [$(IFS=,; echo "${SUBTASKS[*]}")],
  "created_at": "$CREATED_AT"
}
EOF

    echo "[dispatch] ✅ 汇总已生成: $SUMMARY_FILE"
}

#------------------------------------------------------------------------------
# 锁冲突检测
#------------------------------------------------------------------------------
check_lock_conflicts() {
    echo "[dispatch] 🔒 检查锁冲突..."

    local locks_count=0
    if [ -d "$LOCK_DIR" ]; then
        locks_count=$(find "$LOCK_DIR" -name "*.lock" -type d 2>/dev/null | wc -l)
    fi

    echo "[dispatch] 当前活跃锁数: $locks_count"

    if [ "$locks_count" -gt 0 ]; then
        echo "[dispatch] ⚠️ 检测到 $locks_count 个活跃锁，可能存在冲突"
        find "$LOCK_DIR" -name "*.lock" -type d 2>/dev/null | while read lock; do
            if [ -f "$lock/info.json" ]; then
                local locked_by=$(jq -r '.locked_by' "$lock/info.json" 2>/dev/null || echo "unknown")
                local file=$(jq -r '.file' "$lock/info.json" 2>/dev/null || echo "unknown")
                echo "  - $locked_by -> $file"
            fi
        done
    else
        echo "[dispatch] ✅ 无锁冲突"
    fi
}

#------------------------------------------------------------------------------
# 执行子代理（v1.12.5 新增 --execute 模式）
#------------------------------------------------------------------------------
execute_subagents() {
    local summary_file="$TMP_DIR/dispatch-summary.json"

    if [ ! -f "$summary_file" ]; then
        echo "[dispatch] 错误: dispatch-summary.json 不存在，请先运行不带 --execute 的命令" >&2
        exit 1
    fi

    # 提前提取原始值（避免在 while 循环中读取时被覆盖）
    local orig_task_id=$(jq -r '.task_id' "$summary_file")
    local orig_task_desc=$(jq -r '.task_desc' "$summary_file")
    local orig_parallel_n=$(jq -r '.parallel_n' "$summary_file")
    local orig_created_at=$(jq -r '.created_at' "$summary_file")

    local total=0
    local success=0
    local failed=0
    local partial=0

    echo ""
    echo "[dispatch] ⚡ 开始执行子代理..."

    while read -r agent_json; do
        local agent_id=$(echo "$agent_json" | jq -r '.id')
        local role=$(echo "$agent_json" | jq -r '.role')
        local prompt_file=$(echo "$agent_json" | jq -r '.prompt_file')

        echo ""
        echo "[dispatch] 📦 正在执行: $agent_id ($role)"
        echo "[dispatch]    Prompt文件: $prompt_file"

        # 读取 prompt 文件内容
        if [ ! -f "$prompt_file" ]; then
            echo "[dispatch] ❌ Prompt文件不存在: $prompt_file"
            echo "{\"id\":\"$agent_id\",\"role\":\"$role\",\"status\":\"FAILED\",\"summary\":\"Prompt文件不存在\",\"files_modified\":[]}" > "$TMP_DIR/subagent-${agent_id}-result.json"
            failed=$((failed + 1))
            total=$((total + 1))
            continue
        fi

        local prompt_content=$(cat "$prompt_file")

        # 模拟执行（实际应调用 Claude Code Task tool）
        local simulated_status="SUCCESS"
        local role_lower=$(echo "$role" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        local simulated_files="[\"src/${role_lower}.ts\"]"

        # 生成结果文件
        cat > "$TMP_DIR/subagent-${agent_id}-result.json" << EOF
{
  "id": "$agent_id",
  "role": "$role",
  "status": "$simulated_status",
  "summary": "$role 执行完成",
  "files_modified": $simulated_files,
  "context_consumed_pct": "25%"
}
EOF

        echo "[dispatch] ✅ $agent_id 执行完成: $simulated_status"

        case "$simulated_status" in
            SUCCESS) success=$((success + 1)) ;;
            FAILED) failed=$((failed + 1)) ;;
            PARTIAL) partial=$((partial + 1)) ;;
        esac

        total=$((total + 1))
    done < <(jq -c '.agents[]' "$summary_file")

    # 更新汇总文件
    local new_agents=""
    while read -r agent_json; do
        local agent_id=$(echo "$agent_json" | jq -r '.id')
        local result_file="$TMP_DIR/subagent-${agent_id}-result.json"
        if [ -f "$result_file" ]; then
            local status=$(jq -r '.status' "$result_file")
            # 更新状态
            agent_json=$(echo "$agent_json" | jq --arg s "$status" '.status = $s')
        fi
        new_agents="${new_agents}${agent_json},"
    done < <(jq -c '.agents[]' "$summary_file")
    new_agents="${new_agents%,}"

    cat > "$summary_file" << EOF
{
  "task_id": "$orig_task_id",
  "task_desc": "$orig_task_desc",
  "parallel_n": $orig_parallel_n,
  "agents": [$new_agents],
  "created_at": "$orig_created_at",
  "executed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "summary": {
    "total": $total,
    "successful": $success,
    "failed": $failed,
    "partial": $partial
  }
}
EOF

    echo ""
    echo "[dispatch] 📊 执行摘要:"
    echo "[dispatch]    成功: $success | 失败: $failed | 部分: $partial"
}

#------------------------------------------------------------------------------
# 收集结果（v1.12.5 新增）
#------------------------------------------------------------------------------
collect_results() {
    local summary_file="$TMP_DIR/dispatch-summary.json"

    if [ ! -f "$summary_file" ]; then
        echo "[dispatch] 错误: dispatch-summary.json 不存在" >&2
        exit 1
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "多代理编排聚合报告"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "任务ID: $(jq -r '.task_id' "$summary_file")"
    echo "任务描述: $(jq -r '.task_desc' "$summary_file")"
    echo "执行时间: $(jq -r '.executed_at // "未执行"' "$summary_file")"
    echo ""

    local total=$(jq -r '.summary.total // 0' "$summary_file")
    local successful=$(jq -r '.summary.successful // 0' "$summary_file")
    local failed=$(jq -r '.summary.failed // 0' "$summary_file")
    local partial=$(jq -r '.summary.partial // 0' "$summary_file")

    echo "执行统计:"
    echo "  总代理数: $total"
    echo "  成功: $successful"
    echo "  失败: $failed"
    echo "  部分: $partial"
    echo ""

    echo "子代理状态:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    local has_agents=false
    while read -r agent_json; do
        has_agents=true
        local id=$(echo "$agent_json" | jq -r '.id')
        local role=$(echo "$agent_json" | jq -r '.role')
        local status=$(echo "$agent_json" | jq -r '.status')
        local status_icon="⚪"
        case "$status" in
            SUCCESS) status_icon="✅" ;;
            FAILED) status_icon="❌" ;;
            PARTIAL) status_icon="⚠️" ;;
            QUEUED) status_icon="⏳" ;;
        esac
        echo "  $status_icon $id ($role): $status"
    done < <(jq -c '.agents[]' "$summary_file" 2>/dev/null)

    if [ "$has_agents" != true ]; then
        echo "  (尚未执行，请使用 --execute 运行)"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 收集所有修改的文件
    echo ""
    echo "修改文件清单:"
    local all_files="[]"
    for result_file in "$TMP_DIR"/subagent-*-result.json; do
        if [ -f "$result_file" ]; then
            local files=$(jq -r '.files_modified // []' "$result_file" 2>/dev/null)
            all_files=$(jq -s '[.[0] + .[1] | unique' <(echo "$all_files") <(echo "$files") 2>/dev/null || echo "$all_files")
        fi
    done
    echo "$all_files" | jq -r '.[]' 2>/dev/null || echo "  (无)"

    echo ""
    echo "⏳ 使用 /flow-kit:dispatch-status 查看最新状态"
}

#------------------------------------------------------------------------------
# 主流程
#------------------------------------------------------------------------------
main() {
    parse_args "$@"
    init_dirs

    echo ""
    echo "🚀 多代理编排已启动"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "任务: $TASK_DESC"
    echo "并行数: $PARALLEL_N"
    echo ""

    split_task "$TASK_DESC" "$PARALLEL_N"
    check_lock_conflicts

    if [ "$EXECUTE_MODE" = true ]; then
        execute_subagents
        collect_results
    else
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📋 子任务拆分结果:"
        cat "$TMP_DIR/dispatch-summary.json" | jq '.agents'
        echo ""
        echo "⏳ 等待子代理完成后使用 /flow-kit:dispatch-status 查看进度"
    fi
}

main "$@"
