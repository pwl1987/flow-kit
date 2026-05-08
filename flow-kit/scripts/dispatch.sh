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
    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi

    # 第一个参数是否为数字
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        PARALLEL_N="$1"
        shift
    else
        PARALLEL_N=3
    fi

    TASK_DESC="$*"
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

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 子任务拆分结果:"
    cat "$TMP_DIR/dispatch-summary.json" | jq '.agents'
    echo ""
    echo "⏳ 等待子代理完成后使用 /flow-kit:dispatch-status 查看进度"
}

main "$@"

---

## 参考来源

- [multi-agent-orchestration-patterns](https://github.com/anthropic/multi-agent-patterns) — 多代理编排最佳实践
- [task-executor-agent](https://github.com/anthropic/task-executor-agent) — 任务执行代理模式
