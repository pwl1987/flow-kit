#!/bin/bash
# dispatch.sh — 多代理并行编排脚本
# v1.12.8 P0 修复：移除 set -e + 添加 trap 清理 + 锁冲突 blocking + result validation
# 用法: ./dispatch.sh [N] "任务描述"

# P0 修复：移除 set -e，改用显式错误处理
# set -e 与 jq 回退模式冲突，导致不可预测的脚本终止
# v1.12.9 改进：启用 -u（未定义变量检测）和 -o pipefail（管道错误传递）
set -uo pipefail

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# v1.12.9 改进：使用统一路径管理
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/error-handler.sh"
# 注意：LOCK_DIR 复用 paths.sh 中的 $LOCK_DIR 定义，无需重复定义
readonly TMP_DIR="$PROJECT_DIR/.flow-kit/tmp"
readonly AGENT_NAME="${AGENT_NAME:-agent-main}"

# P0 修复：添加 trap 清理子进程，防止提前退出时子进程 orphaned
CHILD_PIDS=(${CHILD_PIDS[@]:-})

# v1.12.9 改进：并发池控制 - 最大并行子代理数
MAX_CONCURRENT="${MAX_CONCURRENT:-5}"

#------------------------------------------------------------------------------
# 跨平台时间戳工具（v1.12.9 新增：macOS/Linux 兼容）
#------------------------------------------------------------------------------
get_epoch_ms() {
    # macOS: date 不支持 %3N，使用 python/perl 回退
    local epoch_ms
    epoch_ms=$(python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null)
    if [ -n "$epoch_ms" ] && [[ "$epoch_ms" =~ ^[0-9]+$ ]]; then
        echo "$epoch_ms"
        return 0
    fi
    epoch_ms=$(perl -MTime::HiRes -e 'printf("%d\n",Time::HiRes::time()*1000)' 2>/dev/null)
    if [ -n "$epoch_ms" ] && [[ "$epoch_ms" =~ ^[0-9]+$ ]]; then
        echo "$epoch_ms"
        return 0
    fi
    # 最终回退：date +%s 拼接 000
    echo "$(date +%s)000"
}

date_to_epoch() {
    local iso_date="$1"
    local epoch=0
    if [ -z "$iso_date" ] || [ "$iso_date" = "null" ] || [ "$iso_date" = "" ]; then
        echo "0"
        return 0
    fi
    if date -j -f "%Y-%m-%dT%H:%M:%SZ" "$iso_date" +%s >/dev/null 2>&1; then
        epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$iso_date" +%s 2>/dev/null || echo "0")
    elif date -d "$iso_date" +%s >/dev/null 2>&1; then
        epoch=$(date -d "$iso_date" +%s 2>/dev/null || echo "0")
    fi
    if [ "$epoch" = "0" ] || [ -z "$epoch" ]; then
        echo "0"
    else
        echo "$epoch"
    fi
}

cleanup_children() {
    local exit_code=$?
    if [ ${#CHILD_PIDS[@]} -gt 0 ]; then
        echo "[dispatch] 🛑 清理 ${#CHILD_PIDS[@]} 个子进程..."
        for pid in "${CHILD_PIDS[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                echo "[dispatch]    终止 PID $pid..."
                kill -TERM "$pid" 2>/dev/null || true
            fi
        done
        # P0 修复：循环等待而非固定 sleep 1
        local wait_elapsed=0
        while [ $wait_elapsed -lt 5 ]; do
            local all_dead=true
            for pid in "${CHILD_PIDS[@]}"; do
                if kill -0 "$pid" 2>/dev/null; then
                    all_dead=false
                    break
                fi
            done
            if [ "$all_dead" = true ]; then
                break
            fi
            sleep 0.5
            wait_elapsed=$((wait_elapsed + 1))
        done
        for pid in "${CHILD_PIDS[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid" 2>/dev/null || true
            fi
        done
    fi
    # v1.12.9 改进：清理临时文件
    if [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"/*.tmp "$TMP_DIR"/subagent-*-result.json "$TMP_DIR"/subagent-*-status.json "$TMP_DIR"/subagent-*.pid "$TMP_DIR"/subagent-*.log 2>/dev/null || true
    fi
    # v1.12.10 改进：清理 slot 锁文件
    if [ -d "$LOCK_DIR" ]; then
        rm -f "$LOCK_DIR"/slot-*.lock 2>/dev/null || true
    fi
    rm -f "$TMP_DIR"/slot-*.id "$TMP_DIR"/slot-*.fd 2>/dev/null || true
    exit $exit_code
}

trap cleanup_children EXIT INT TERM

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
show_help() {
    cat << 'EOF'
dispatch.sh — 多代理并行编排脚本

用法:
  ./dispatch.sh [N] "任务描述"
  ./dispatch.sh --wait [--timeout <秒>]
  ./dispatch.sh --aggregate

参数:
  N           并行 executor 数量（默认: 3）
  任务描述    要分解和执行的任务
  --wait      等待子代理完成并聚合结果
  --timeout   等待超时秒数（默认: 300，仅与 --wait 联用）
  --aggregate 聚合已有结果

示例:
  ./dispatch.sh 3 "实现用户认证系统"
  ./dispatch.sh "修复登录 bug"
  ./dispatch.sh --wait
  ./dispatch.sh --wait --timeout 600
  ./dispatch.sh --aggregate

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
    WAIT_MODE=false
    AGGREGATE_MODE=false
    WAIT_TIMEOUT=300

    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi

    # 收集所有参数（过滤掉 --execute, --wait, --aggregate, --timeout）
    local args=()
    local skip_next=false
    local timeout_next=false
    for arg in "$@"; do
        if [ "$skip_next" = true ]; then
            skip_next=false
            continue
        fi
        if [ "$timeout_next" = true ]; then
            WAIT_TIMEOUT="$arg"
            timeout_next=false
            continue
        fi
        case "$arg" in
            --execute)
                EXECUTE_MODE=true
                ;;
            --wait)
                WAIT_MODE=true
                ;;
            --aggregate)
                AGGREGATE_MODE=true
                ;;
            --timeout)
                timeout_next=true
                ;;
            *)
                args+=("$arg")
                ;;
        esac
    done

    # 如果是 aggregate 或 wait 模式，不需要任务描述
    if [ "$AGGREGATE_MODE" = true ] || [ "$WAIT_MODE" = true ]; then
        TASK_DESC=""
        PARALLEL_N=0
        return 0
    fi

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
    local CREATED_AT
    CREATED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)

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
# 锁冲突检测（v1.12.8 修复：改为 blocking 等待而非仅警告）
#------------------------------------------------------------------------------
check_lock_conflicts() {
    echo "[dispatch] 🔒 检查锁冲突..."

    local locks_count=0
    if [ -d "$LOCK_DIR" ]; then
        locks_count=$(find "$LOCK_DIR" -name "*.lock" -type d 2>/dev/null | wc -l)
    fi

    echo "[dispatch] 当前活跃锁数: $locks_count"

    if [ "$locks_count" -gt 0 ]; then
        echo "[dispatch] 🚫 检测到 $locks_count 个活跃锁，等待解锁..."

        local wait_timeout=30
        local wait_elapsed=0
        local wait_interval=2

        while [ $wait_elapsed -lt $wait_timeout ]; do
            local current_locks
            current_locks=$(find "$LOCK_DIR" -name "*.lock" -type d 2>/dev/null | wc -l)

            if [ "$current_locks" -eq 0 ]; then
                echo "[dispatch] ✅ 锁已释放，继续执行"
                return 0
            fi

            echo "[dispatch]    等待中... ($wait_elapsed/$wait_timeout 秒)"
            sleep $wait_interval
            wait_elapsed=$((wait_elapsed + wait_interval))
        done

        echo "[dispatch] ❌ 锁冲突超时 (${wait_timeout}s)，终止执行" >&2
        return 1
    else
        echo "[dispatch] ✅ 无锁冲突"
    fi
}

#------------------------------------------------------------------------------
# 执行单个子代理（后台进程函数，支持重试）
#------------------------------------------------------------------------------
run_single_agent() {
    local agent_id="$1"
    local role="$2"
    local prompt_file="$3"
    local task_desc="$4"
    local tmp_dir="$5"
    local max_retries="${6:-2}"
    local retry_interval="${7:-10}"
    local result_file="$tmp_dir/subagent-${agent_id}-result.json"
    local log_file="$tmp_dir/subagent-${agent_id}.log"

    # 记录PID
    echo $$ > "$tmp_dir/subagent-${agent_id}.pid"

    # v1.12.9 改进：确保退出时释放并发槽位
    trap 'release_slot' EXIT

    {
        echo "[agent-$agent_id] 开始执行 ($role)"
        echo "[agent-$agent_id] 最大重试次数: $max_retries"

        local attempt=0
        local success=false

        while [ $attempt -le $max_retries ] && [ "$success" = false ]; do
            if [ $attempt -gt 0 ]; then
                echo "[agent-$agent_id] 第 $attempt 次重试（等待 ${retry_interval}s）..."
                sleep $retry_interval
            fi

            attempt=$((attempt + 1))
            echo "[agent-$agent_id] 尝试执行 (第 $attempt 次)"

            # 验证prompt文件存在
            if [ ! -f "$prompt_file" ]; then
                echo "[agent-$agent_id] ❌ Prompt文件不存在: $prompt_file"
                cat > "$result_file" << EOF
{
  "id": "$agent_id",
  "role": "$role",
  "status": "FAILED",
  "summary": "Prompt文件不存在",
  "files_modified": [],
  "issues": ["Prompt文件不存在: $prompt_file"],
  "context_consumed_pct": "0%",
  "attempts": $attempt
}
EOF
                break
            fi

            # 读取prompt内容
            local prompt_content=$(cat "$prompt_file")

            # TODO: 模拟执行（实际环境中应替换为 Claude Code Task API 调用）
            echo "[agent-$agent_id] 正在执行任务..."
            sleep 2  # 模拟执行时间（占位代码）

            # 根据角色生成模拟结果
            local role_lower=$(echo "$role" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
            local simulated_status="SUCCESS"
            local simulated_files="[\"src/${role_lower}.ts\"]"

            # 写入结果文件（使用原子写入避免竞态）
            local tmp_result="$result_file.tmp"
            cat > "$tmp_result" << EOF
{
  "id": "$agent_id",
  "role": "$role",
  "status": "$simulated_status",
  "summary": "$role 执行完成",
  "files_modified": $simulated_files,
  "issues": [],
  "context_consumed_pct": "25%",
  "execution_time_seconds": 2,
  "attempts": $attempt
}
EOF
            mv "$tmp_result" "$result_file"

            echo "[agent-$agent_id] ✅ 执行完成: $simulated_status (尝试 $attempt 次)"
            success=true
        done

        if [ "$success" = false ]; then
            echo "[agent-$agent_id] ❌ 执行失败（已重试 $max_retries 次）"
        fi
    } >> "$log_file" 2>&1
}

#------------------------------------------------------------------------------
# 并发池控制（v1.12.10 改进：使用 flock 消除竞态 + 防止 FD/文件泄漏）
#------------------------------------------------------------------------------
acquire_slot() {
    local max_conc="$1"
    for ((i=0; i<max_conc; i++)); do
        local lockfile="$TMP_DIR/slot-$i.lock"
        # 打开 FD 200 指向锁文件（如果文件不存在会创建）
        exec 200>"$lockfile" 2>/dev/null || continue
        # 非阻塞获取排他锁
        if flock -n 200 2>/dev/null; then
            # 保存 slot 编号到临时文件（而非 FD）
            echo "$i" > "$TMP_DIR/slot-$$.id"
            return 0
        fi
        # 获取失败，关闭 FD 并尝试下一个 slot
        exec 200>&- 2>/dev/null
    done
    return 1
}

release_slot() {
    local slot_id_file="$TMP_DIR/slot-$$.id"
    if [[ -f "$slot_id_file" ]]; then
        local slot_num
        slot_num=$(cat "$slot_id_file" 2>/dev/null || echo "")
        if [[ -n "$slot_num" ]]; then
            local lockfile="$TMP_DIR/slot-$slot_num.lock"
            # 使用 FD 200 重新打开锁文件并释放锁
            exec 200>"$lockfile" 2>/dev/null || true
            flock -u 200 2>/dev/null || true
            exec 200>&- 2>/dev/null || true
            # 清理锁文件本身
            rm -f "$lockfile"
        fi
        rm -f "$slot_id_file"
    fi
}

#------------------------------------------------------------------------------
# 执行子代理（v1.12.7 真正并行执行引擎）
# v1.12.9 改进：并发池控制
#------------------------------------------------------------------------------
execute_subagents() {
    local summary_file="$TMP_DIR/dispatch-summary.json"

    if [ ! -f "$summary_file" ]; then
        echo "[dispatch] 错误: dispatch-summary.json 不存在，请先运行不带 --execute 的命令" >&2
        exit 1
    fi

    # 提前提取原始值
    local orig_task_id orig_task_desc orig_parallel_n orig_created_at
    orig_task_id=$(jq -r '.task_id' "$summary_file")
    orig_task_desc=$(jq -r '.task_desc' "$summary_file")
    orig_parallel_n=$(jq -r '.parallel_n' "$summary_file")
    orig_created_at=$(jq -r '.created_at' "$summary_file")

    echo ""
    echo "[dispatch] ⚡ 开始并行执行子代理..."
    echo "[dispatch] 📁 工作目录: $(pwd)"
    echo "[dispatch] 📁 临时目录: $TMP_DIR"
    echo "[dispatch] 🔧 执行模式: 真正并行 (后台进程)"

    # 生成launch manifest
    local launch_manifest="$TMP_DIR/launch-manifest.json"
    local agents_array=""
    local first=true
    local pids=()
    local agent_ids=()

    # 建立 PID 到 agent_id 的关联映射（O(1) 查找）
    declare -A PID_TO_AGENT=()

    # 启动所有子代理（后台并行执行）
    # v1.12.10 P0 修复：初始化 agents 构建变量
    local first=true
    local agents_array=""

    while IFS= read -r agent_json; do
        local agent_id role prompt_file
        read -r agent_id role prompt_file <<< "$(echo "$agent_json" | jq -r '[.id, .role, .prompt_file] | join(" ")')"

        echo "[dispatch]  启动子代理: $agent_id ($role)"

        # v1.12.9 改进：并发池控制 - 等待可用槽位
        acquire_slot "$MAX_CONCURRENT"

        # 在后台启动子代理
        run_single_agent "$agent_id" "$role" "$prompt_file" "$orig_task_desc" "$TMP_DIR" &
        local pid=$!
        pids+=($pid)
        agent_ids+=("$agent_id")
        CHILD_PIDS+=($pid)  # P0 修复：跟踪子进程用于 trap 清理

        echo "[dispatch]    PID: $pid (并发: $MAX_CONCURRENT)"
        PID_TO_AGENT[$pid]="$agent_id"

        # 构建agents数组
        if [ "$first" = true ]; then
            agents_array="\"$agent_id\""
            first=false
        else
            agents_array="$agents_array,\"$agent_id\""
        fi

        # 标记为RUNNING
        cat > "$TMP_DIR/subagent-${agent_id}-status.json" << EOF
{
  "id": "$agent_id",
  "role": "$role",
  "status": "RUNNING",
  "pid": $pid,
  "prompt_file": "$prompt_file",
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    done < <(jq -c '.agents[]' "$summary_file")

    # 生成launch manifest
    cat > "$launch_manifest" << EOF
{
  "task_id": "$orig_task_id",
  "task_desc": "$orig_task_desc",
  "parallel_n": $orig_parallel_n,
  "status": "RUNNING",
  "launched_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agents": [$agents_array],
  "pids": [$(IFS=,; echo "${pids[*]}")],
  "execution_mode": "PARALLEL",
  "timeout_seconds": 300,
  "retry_attempts": 2,
  "retry_interval_seconds": 10
}
EOF

    echo ""
    echo "[dispatch] 📊 已启动 ${#pids[@]} 个子代理（并行执行中）"
    echo "[dispatch] PIDs: ${pids[*]}"
    echo "[dispatch] ⏱️ 超时设置: 300秒/子代理"

    # 监控并等待所有后台进程完成（带超时控制）
    local timeout_seconds=300
    local all_success=true
    local timed_out_agents=()

    echo "[dispatch] ⏳ 等待子代理完成..."

    local start_epoch=$(date +%s)
    local remaining_pids=("${pids[@]}")
    local check_interval=2

    # v1.12.10 P0 修复：正确轮询子进程状态
    # wait -n 不返回 PID（仅返回退出码），不能用 $! 获取完成进程的 PID
    # 因此使用 kill -0 轮询方案，间隔 2 秒在精度与 CPU 之间权衡
    while [ ${#remaining_pids[@]} -gt 0 ]; do
        local now_epoch=$(date +%s)
        local elapsed=$((now_epoch - start_epoch))

        if [ $elapsed -ge $timeout_seconds ]; then
            echo "[dispatch] ⏱️ 整体执行超时 (${elapsed}s >= ${timeout_seconds}s)"
            for pid in "${remaining_pids[@]}"; do
                kill -TERM $pid 2>/dev/null || true
            done
            sleep 1
            for pid in "${remaining_pids[@]}"; do
                kill -9 $pid 2>/dev/null || true
            done
            for pid in "${remaining_pids[@]}"; do
                if [[ -n "${PID_TO_AGENT[$pid]+isset}" ]]; then
                    timed_out_agents+=("${PID_TO_AGENT[$pid]}")
                fi
            done
            all_success=false
            break
        fi

        local new_remaining=()
        for pid in "${remaining_pids[@]}"; do
            if kill -0 $pid 2>/dev/null; then
                # 进程仍在运行，使用关联数组 O(1) 查找 agent_id
                local timed_out=false
                if [[ -n "${PID_TO_AGENT[$pid]+isset}" ]]; then
                    local agent_id="${PID_TO_AGENT[$pid]}"
                    local status_file="$TMP_DIR/subagent-${agent_id}-status.json"
                    if [ -f "$status_file" ]; then
                        local started_at
                        started_at=$(jq -r '.started_at' "$status_file" 2>/dev/null)
                        if [ -n "$started_at" ] && [ "$started_at" != "null" ]; then
                            local start_epoch_agent
                            start_epoch_agent=$(date_to_epoch "$started_at")
                            local agent_elapsed=$((now_epoch - start_epoch_agent))
                            if [ $agent_elapsed -gt $timeout_seconds ]; then
                                echo "[dispatch] ⏱️ $agent_id 执行超时 (${agent_elapsed}s)"
                                kill -TERM $pid 2>/dev/null || true
                                sleep 1
                                kill -9 $pid 2>/dev/null || true
                                timed_out_agents+=("$agent_id")
                                timed_out=true
                                all_success=false
                            fi
                        fi
                    fi
                fi
                if [ "$timed_out" = false ]; then
                    new_remaining+=("$pid")
                fi
            else
                # 进程已完成，使用关联数组 O(1) 查找 agent_id
                if [[ -n "${PID_TO_AGENT[$pid]+isset}" ]]; then
                    local agent_id="${PID_TO_AGENT[$pid]}"
                    if ! wait $pid 2>/dev/null; then
                        local result_file="$TMP_DIR/subagent-${agent_id}-result.json"
                        if [ ! -f "$result_file" ]; then
                            echo "[dispatch] ❌ $agent_id 执行失败"
                            cat > "$result_file" << EOF
{
  "id": "$agent_id",
  "role": "unknown",
  "status": "FAILED",
  "summary": "子代理执行失败",
  "files_modified": [],
  "issues": ["子代理进程异常退出"],
  "context_consumed_pct": "0%",
  "attempts": 0
}
EOF
                            all_success=false
                        fi
                    fi
                fi
            fi
        done
        remaining_pids=(${new_remaining[@]+"${new_remaining[@]}"})
        if [ ${#remaining_pids[@]} -gt 0 ]; then
            sleep $check_interval
        fi
    done

    # v1.12.10 fix: 无超时代理时跳过提示
    if [ ${#timed_out_agents[@]} -gt 0 ]; then
        echo "[dispatch] ⚠️ 超时代理: ${timed_out_agents[*]}"
    fi

    # 更新summary
    local total=${#agent_ids[@]}
    local success=0
    local failed=0
    local partial=0

    for agent_id in "${agent_ids[@]}"; do
        local result_file="$TMP_DIR/subagent-${agent_id}-result.json"
        if [ -f "$result_file" ]; then
            # P0 修复：验证 result JSON 有效性
            if ! jq -e '.status' "$result_file" >/dev/null 2>&1; then
                echo "[dispatch] ❌ result JSON 无效: $result_file"
                failed=$((failed + 1))
                continue
            fi

            local status
            status=$(jq -r '.status' "$result_file" 2>/dev/null || echo "FAILED")
            case "$status" in
                SUCCESS) success=$((success + 1)) ;;
                FAILED) failed=$((failed + 1)) ;;
                PARTIAL) partial=$((partial + 1)) ;;
                *) failed=$((failed + 1)) ;;
            esac
        else
            failed=$((failed + 1))
        fi
    done

    # 构建agents JSON
    local agents_json=""
    local first=true
    for agent_id in "${agent_ids[@]}"; do
        local result_file="$TMP_DIR/subagent-${agent_id}-result.json"
        if [ -f "$result_file" ]; then
            local agent_data=$(jq -c '.' "$result_file")
            if [ "$first" = true ]; then
                agents_json="$agent_data"
                first=false
            else
                agents_json="$agents_json,$agent_data"
            fi
        fi
    done

    cat > "$summary_file" << EOF
{
  "task_id": "$orig_task_id",
  "task_desc": "$orig_task_desc",
  "parallel_n": $orig_parallel_n,
  "agents": [$agents_json],
  "created_at": "$orig_created_at",
  "executed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "COMPLETED",
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
    echo "[dispatch]    总计: $total | 成功: $success | 失败: $failed | 部分: $partial"
}

#------------------------------------------------------------------------------
# 等待子代理完成（v1.12.6 新增）
#------------------------------------------------------------------------------
wait_for_subagents() {
    local summary_file="$TMP_DIR/dispatch-summary.json"
    local launch_manifest="$TMP_DIR/launch-manifest.json"
    local timeout_seconds="${1:-300}"
    local check_interval=5
    local elapsed=0

    if [ ! -f "$launch_manifest" ]; then
        echo "[dispatch] 错误: launch-manifest.json 不存在，请先运行 --execute" >&2
        exit 1
    fi

    echo "[dispatch] ⏳ 等待子代理完成（超时: ${timeout_seconds}秒）..."

    local agents=$(jq -c '.agents[]' "$launch_manifest" 2>/dev/null || echo "")

    while [ $elapsed -lt $timeout_seconds ]; do
        local all_complete=true
        local completed=0
        local total=0

        for agent in $agents; do
            local agent_id=$(echo "$agent" | jq -r '.')
            local result_file="$TMP_DIR/subagent-${agent_id}-result.json"
            total=$((total + 1))

            if [ -f "$result_file" ]; then
                completed=$((completed + 1))
            else
                all_complete=false
            fi
        done

        if [ "$all_complete" = true ]; then
            echo "[dispatch] ✅ 所有子代理已完成"
            return 0
        fi

        echo "[dispatch]    已完成: $completed/$total (${elapsed}s)"
        sleep $check_interval
        elapsed=$((elapsed + check_interval))
    done

    echo "[dispatch] ⚠️ 等待超时，${timeout_seconds}秒内未全部完成"
    return 1
}

#------------------------------------------------------------------------------
# 收集结果（v1.12.6 增强：支持 result 文件聚合）
#------------------------------------------------------------------------------
collect_results() {
    local summary_file="$TMP_DIR/dispatch-summary.json"
    local launch_manifest="$TMP_DIR/launch-manifest.json"

    # 优先使用 launch-manifest
    if [ -f "$launch_manifest" ]; then
        local task_id=$(jq -r '.task_id' "$launch_manifest")
        local task_desc=$(jq -r '.task_desc' "$launch_manifest")
        local launched_at=$(jq -r '.launched_at' "$launch_manifest")
        local agents=$(jq -c '.agents[]' "$launch_manifest" 2>/dev/null || echo "")

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "多代理编排聚合报告"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "任务ID: $task_id"
        echo "任务描述: $task_desc"
        echo "启动时间: $launched_at"
        echo "完成时间: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""

        local total=0
        local success=0
        local failed=0
        local partial=0

        echo "执行统计:"
        echo "  总代理数: $total"
        echo "  成功: $success"
        echo "  失败: $failed"
        echo "  部分: $partial"
        echo ""

        echo "子代理状态:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        for agent_id in $agents; do
            local result_file="$TMP_DIR/subagent-${agent_id}-result.json"
            if [ -f "$result_file" ]; then
                local status=$(jq -r '.status' "$result_file" 2>/dev/null || echo "UNKNOWN")
                local role=$(jq -r '.role' "$result_file" 2>/dev/null || echo "Unknown")
                local status_icon="⚪"
                case "$status" in
                    SUCCESS) status_icon="✅"; success=$((success + 1)) ;;
                    FAILED) status_icon="❌"; failed=$((failed + 1)) ;;
                    PARTIAL) status_icon="⚠️"; partial=$((partial + 1)) ;;
                    *) status_icon="⚪" ;;
                esac
                echo "  $status_icon $agent_id ($role): $status"
                total=$((total + 1))
            else
                echo "  ⏳ $agent_id: 等待中..."
                total=$((total + 1))
            fi
        done
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        # 收集所有修改的文件（v1.12.10 优化：单次 jq 聚合，减少子 shell）
        echo ""
        echo "修改文件清单:"
        local all_files="[]"
        if [ -f "$TMP_DIR/subagent-agent-1-result.json" ]; then
            all_files=$(jq -s '[.[] | .files_modified // []] | add | unique' "$TMP_DIR"/subagent-*-result.json 2>/dev/null || echo "[]")
        fi
        if [ "$all_files" = "[]" ]; then
            echo "  (无)"
        else
            echo "$all_files" | jq -r '.[]' 2>/dev/null || echo "  (无)"
        fi

        # 更新 summary 文件
        local agents_json=""
        local first=true
        for agent_id in $agents; do
            local result_file="$TMP_DIR/subagent-${agent_id}-result.json"
            if [ -f "$result_file" ]; then
                if [ "$first" = true ]; then
                    agents_json=$(jq -c '.' "$result_file")
                    first=false
                else
                    agents_json="$agents_json,$(jq -c '.' "$result_file")"
                fi
            fi
        done

        cat > "$summary_file" << EOF
{
  "task_id": "$task_id",
  "task_desc": "$task_desc",
  "parallel_n": $(jq -r '.parallel_n' "$launch_manifest"),
  "agents": [$agents_json],
  "created_at": "$launched_at",
  "executed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "COMPLETED",
  "summary": {
    "total": $total,
    "successful": $success,
    "failed": $failed,
    "partial": $partial
  }
}
EOF

    elif [ -f "$summary_file" ]; then
        # 回退到旧的 summary 文件格式
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
    else
        echo "[dispatch] 错误: dispatch-summary.json 不存在" >&2
        exit 1
    fi

    echo ""
    echo "⏳ 使用 /flow-kit:dispatch-status 查看最新状态"
}

#------------------------------------------------------------------------------
# 主流程
#------------------------------------------------------------------------------
main() {
    parse_args "$@"

    # aggregate 和 wait 模式只需要初始化目录
    if [ "$AGGREGATE_MODE" = true ]; then
        init_dirs
        echo "[dispatch] 📊 聚合模式"
        collect_results
        return 0
    fi

    if [ "$WAIT_MODE" = true ]; then
        init_dirs
        echo "[dispatch] ⏳ 等待模式（超时: ${WAIT_TIMEOUT}s）"
        wait_for_subagents $WAIT_TIMEOUT
        collect_results
        return 0
    fi

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
        echo "⏳ 使用以下命令执行子代理:"
        echo "   bash flow-kit/scripts/dispatch.sh --execute"
    fi
}

# v1.12.9 改进：仅在直接执行时运行 main，source 时不执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
