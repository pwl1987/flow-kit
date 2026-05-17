#!/bin/bash
# dispatch.sh — 多代理并行编排脚本
# 用法: ./dispatch.sh [N] "任务描述"

set -uo pipefail

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/error-handler.sh"
source "$SCRIPT_DIR/../lib/session-state.sh" 2>/dev/null || true

CHILD_PIDS=(${CHILD_PIDS[@]:-})

MAX_CONCURRENT="${MAX_CONCURRENT:-5}"

# 模拟模式：设 SIMULATION_MODE=false 启用真实执行
SIMULATION_MODE="${SIMULATION_MODE:-true}"

source "$SCRIPT_DIR/../lib/time-utils.sh"
source "$SCRIPT_DIR/../lib/preflight.sh"
source "$SCRIPT_DIR/dispatch-parse.sh"
source "$SCRIPT_DIR/dispatch-lock.sh"
source "$SCRIPT_DIR/dispatch-aggregate.sh"
require_jq

cleanup_children() {
    local exit_code=$?
    if [[ ${#CHILD_PIDS[@]} -gt 0 ]]; then
        echo "[dispatch] 🛑 清理 ${#CHILD_PIDS[@]} 个子进程..."
        for pid in "${CHILD_PIDS[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                echo "[dispatch]    终止 PID $pid..."
                kill -TERM "$pid" 2>/dev/null || true
            fi
        done
        # P0 修复：循环等待而非固定 sleep 1
        local wait_elapsed=0
        while [[ $wait_elapsed -lt 5 ]]; do
            local all_dead=true
            for pid in "${CHILD_PIDS[@]}"; do
                if kill -0 "$pid" 2>/dev/null; then
                    all_dead=false
                    break
                fi
            done
            if [[ "$all_dead" == true ]]; then
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
    # v2.7.0 改进：清理临时文件（仅在错误退出时删除结果文件）
    if [[ "$exit_code" -ne 0 ]]; then
        # 错误退出：清理所有临时文件包括结果文件
        if [[ -d "$TMP_DIR" ]]; then
            rm -rf "$TMP_DIR"/*.tmp "$TMP_DIR"/subagent-*-result.json "$TMP_DIR"/subagent-*-status.json "$TMP_DIR"/subagent-*.pid "$TMP_DIR"/subagent-*.log 2>/dev/null || true
        fi
    else
        # 成功退出：仅清理临时文件，保留结果文件供后续聚合
        if [[ -d "$TMP_DIR" ]]; then
            rm -rf "$TMP_DIR"/*.tmp "$TMP_DIR"/subagent-*.pid "$TMP_DIR"/subagent-*.log 2>/dev/null || true
        fi
    fi
    # v2.8.0 修复：slot 锁是目录（mkdir 创建），必须用 rmdir 或 rm -rf 清理
    for lockdir in "$TMP_DIR"/slot-*.lock; do
        [[ -d "$lockdir" ]] && rmdir "$lockdir" 2>/dev/null || rm -rf "$lockdir" 2>/dev/null || true
    done
    rm -f "$TMP_DIR"/slot-*.id "$TMP_DIR"/slot-*.fd 2>/dev/null || true
    exit $exit_code
}

trap cleanup_children EXIT INT TERM

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

    local TASK_ID
    TASK_ID="task-$(date +%Y%m%d%H%M%S)"
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

        local subtask_json
        subtask_json=$(jq -n \
            --arg id "$AGENT_ID" \
            --arg role "$ROLE" \
            --arg status "QUEUED" \
            --arg prompt_file "$PROMPT_FILE" \
            '{id: $id, role: $role, status: $status, prompt_file: $prompt_file}')
        SUBTASKS+=("$subtask_json")
    done

    # 生成汇总 JSON
    local SUMMARY_FILE="$TMP_DIR/dispatch-summary.json"
    local agents_json
    agents_json=$(printf '%s\n' "${SUBTASKS[@]}" | jq -s '.')
    jq -n \
        --arg task_id "$TASK_ID" \
        --arg task_desc "$task" \
        --argjson parallel_n "$n" \
        --argjson agents "$agents_json" \
        --arg created_at "$CREATED_AT" \
        '{task_id: $task_id, task_desc: $task_desc, parallel_n: $parallel_n, agents: $agents, created_at: $created_at}' \
        > "$SUMMARY_FILE"

    echo "[dispatch] ✅ 汇总已生成: $SUMMARY_FILE"
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
    local slot_num="${8:-}"  # v2.7.0: slot number passed explicitly
    local result_file="$tmp_dir/subagent-${agent_id}-result.json"
    local log_file="$tmp_dir/subagent-${agent_id}.log"

    # 记录PID（使用 $BASHPID 而非 $$，因为当前在子进程中）
    echo $BASHPID > "$tmp_dir/subagent-${agent_id}.pid"

    # v2.7.0 修复: 直接传递 slot 编号，不依赖文件查找
    if [[ -n "$slot_num" ]]; then
        echo "$slot_num" > "$tmp_dir/slot-$BASHPID.id"
    fi

    # v2.7.0 改进：确保退出时释放并发槽位
    trap 'release_slot_from_trap' EXIT

    {
        echo "[agent-$agent_id] 开始执行 ($role)"
        echo "[agent-$agent_id] 最大重试次数: $max_retries"

        local attempt=0
        local success=false

        while [[ $attempt -le $max_retries && "$success" == false ]]; do
            if [[ $attempt -gt 0 ]]; then
                echo "[agent-$agent_id] 第 $attempt 次重试（等待 ${retry_interval}s）..."
                sleep $retry_interval
            fi

            attempt=$((attempt + 1))
            echo "[agent-$agent_id] 尝试执行 (第 $attempt 次)"

            # 验证prompt文件存在
            if [[ ! -f "$prompt_file" ]]; then
                echo "[agent-$agent_id] ❌ Prompt文件不存在: $prompt_file"
                jq -n --arg id "$agent_id" --arg role "$role" --arg pf "$prompt_file" --argjson att "$attempt" \
                  '{id: $id, role: $role, status: "FAILED", summary: "Prompt文件不存在", files_modified: [], issues: ["Prompt文件不存在: \($pf)"], context_consumed_pct: "0%", attempts: $att}' \
                  > "$result_file"
                break
            fi

            # 读取prompt内容
            local prompt_content
            prompt_content=$(cat "$prompt_file")

            # v2.7.0 P0 修复：模拟模式警告
            if [[ "$SIMULATION_MODE" == "true" ]]; then
                echo "[agent-$agent_id] ⚠️  [SIMULATION] 模拟执行，调用 sleep 2 代替真实 API"
            fi
            echo "[agent-$agent_id] 正在执行任务..."
            sleep 2  # 模拟执行时间（占位代码）

            # 根据角色生成模拟结果
            local role_lower
            role_lower=$(echo "$role" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
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

        if [[ "$success" == false ]]; then
            echo "[agent-$agent_id] ❌ 执行失败（已重试 $max_retries 次）"
        fi
    } >> "$log_file" 2>&1
}

#------------------------------------------------------------------------------
# 执行子代理（v2.7.0 真正并行执行引擎）
# v2.7.0 改进：并发池控制
#------------------------------------------------------------------------------
execute_subagents() {
    local summary_file="$TMP_DIR/dispatch-summary.json"

    if [[ ! -f "$summary_file" ]]; then
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
    if [[ "$SIMULATION_MODE" == "true" ]]; then
        echo "[dispatch] $SIMULATION_WARNING"
    fi

    # 生成launch manifest
    local launch_manifest="$TMP_DIR/launch-manifest.json"
    local pids=()
    local agent_ids=()

    # 建立 PID 到 agent_id 的关联映射（O(1) 查找）
    declare -A PID_TO_AGENT=()

    # 启动所有子代理（后台并行执行）
    local agents_array=""
    local first=true
    while IFS= read -r agent_json; do
        local agent_id role prompt_file
        IFS=$'\t' read -r agent_id role prompt_file <<< "$(echo "$agent_json" | jq -r '[.id, .role, .prompt_file] | join("\t")')"

        echo "[dispatch]  启动子代理: $agent_id ($role)"

        # v2.7.0 修复: 获取槽位号并传递给子代理
        local acquired_slot=""
        if acquire_slot "$MAX_CONCURRENT"; then
            acquired_slot=$(cat "$TMP_DIR/slot-$$.id" 2>/dev/null || echo "")
        else
            echo "[dispatch]  ⚠️  获取并发槽位失败，等待释放..."
            local slot_wait=0
            while [[ $slot_wait -lt 30 ]] && ! acquire_slot "$MAX_CONCURRENT"; do
                sleep 1
                slot_wait=$((slot_wait + 1))
            done
            if [[ $slot_wait -ge 30 ]]; then
                echo "[dispatch]  ❌ 获取槽位超时，跳过 agent: $agent_id" >&2
                continue
            fi
            acquired_slot=$(cat "$TMP_DIR/slot-$$.id" 2>/dev/null || echo "")
        fi

        # 在后台启动子代理，传递 slot 编号
        run_single_agent "$agent_id" "$role" "$prompt_file" "$orig_task_desc" "$TMP_DIR" 2 10 "$acquired_slot" &
        local pid=$!
        pids+=($pid)
        agent_ids+=("$agent_id")
        CHILD_PIDS+=($pid)  # P0 修复：跟踪子进程用于 trap 清理

        echo "[dispatch]    PID: $pid (并发: $MAX_CONCURRENT)"
        PID_TO_AGENT[$pid]="$agent_id"

        # 构建agents数组
        if [[ "$first" == true ]]; then
            agents_array="\"$agent_id\""
            first=false
        else
            agents_array="$agents_array,\"$agent_id\""
        fi

        # 标记为RUNNING
        jq -n \
            --arg id "$agent_id" \
            --arg role "$role" \
            --arg status "RUNNING" \
            --argjson pid "$pid" \
            --arg prompt_file "$prompt_file" \
            --arg started_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
            '{id: $id, role: $role, status: $status, pid: $pid, prompt_file: $prompt_file, started_at: $started_at}' \
            > "$TMP_DIR/subagent-${agent_id}-status.json"
    done < <(jq -c '.agents[]' "$summary_file")

    # 生成launch manifest
    local pids_json
    pids_json=$(printf '%s\n' "${pids[@]}" | jq -R 'tonumber' | jq -s '.')
    jq -n \
        --arg task_id "$orig_task_id" \
        --arg task_desc "$orig_task_desc" \
        --argjson parallel_n "$orig_parallel_n" \
        --arg status "RUNNING" \
        --arg launched_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --argjson agents "[$agents_array]" \
        --argjson pids "$pids_json" \
        --arg execution_mode "PARALLEL" \
        --argjson timeout_seconds "$WAIT_TIMEOUT" \
        --argjson retry_attempts 2 \
        --argjson retry_interval_seconds 10 \
        '{task_id: $task_id, task_desc: $task_desc, parallel_n: $parallel_n, status: $status, launched_at: $launched_at, agents: $agents, pids: $pids, execution_mode: $execution_mode, timeout_seconds: $timeout_seconds, retry_attempts: $retry_attempts, retry_interval_seconds: $retry_interval_seconds}' \
        > "$launch_manifest"

    echo ""
    echo "[dispatch] 📊 已启动 ${#pids[@]} 个子代理（并行执行中）"
    echo "[dispatch] PIDs: ${pids[*]}"
    echo "[dispatch] ⏱️ 超时设置: ${WAIT_TIMEOUT}秒/子代理"

    # 监控并等待所有后台进程完成（带超时控制）
    local timeout_seconds="$WAIT_TIMEOUT"
    local all_success=true
    local timed_out_agents=()

    echo "[dispatch] ⏳ 等待子代理完成..."

    local start_epoch
    start_epoch=$(date +%s)
    local remaining_pids=("${pids[@]}")
    local check_interval=2

    # v2.8.0 P0 修复：正确处理僵尸进程
    # kill -0 对僵尸进程返回 true（进程条目仍存在），导致假超时
    # 修复：双重检测 — kill -0 + 结果文件存在性。子进程完成时会写入 result 文件。
    # 如果 result 文件已存在但 kill -0 仍为 true（僵尸），视为完成并回收。
    while [[ ${#remaining_pids[@]} -gt 0 ]]; do
        local now_epoch
        now_epoch=$(date +%s)
        local elapsed=$((now_epoch - start_epoch))

        if [[ $elapsed -ge $timeout_seconds ]]; then
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
            local agent_id="${PID_TO_AGENT[$pid]:-}"
            local result_file="$TMP_DIR/subagent-${agent_id}-result.json"
            local alive=false
            kill -0 "$pid" 2>/dev/null && alive=true

            # 双重检测：进程已死 OR 结果文件已生成（即使进程是僵尸）
            local completed=false
            if [[ "$alive" == false ]]; then
                completed=true
            elif [[ -n "$agent_id" && -f "$result_file" ]]; then
                # 僵尸进程：仍存活但结果文件已生成
                completed=true
            fi

            if [[ "$completed" == true ]]; then
                # 进程已完成或结果已就绪，回收僵尸
                if [[ "$alive" == true ]]; then
                    kill -TERM "$pid" 2>/dev/null || true
                    sleep 0.1 2>/dev/null || true
                    kill -9 "$pid" 2>/dev/null || true
                fi
                wait "$pid" 2>/dev/null || true

                if [[ -n "$agent_id" ]]; then
                    if [[ ! -f "$result_file" ]]; then
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
            else
                # 进程仍在运行，检查单代理超时
                local timed_out=false
                if [[ -n "$agent_id" ]]; then
                    local status_file="$TMP_DIR/subagent-${agent_id}-status.json"
                    if [[ -f "$status_file" ]]; then
                        local started_at
                        started_at=$(jq -r '.started_at' "$status_file" 2>/dev/null)
                        if [[ -n "$started_at" && "$started_at" != "null" ]]; then
                            local start_epoch_agent
                            start_epoch_agent=$(date_to_epoch "$started_at")
                            local agent_elapsed=$((now_epoch - start_epoch_agent))
                            if [[ $agent_elapsed -gt $timeout_seconds ]]; then
                                echo "[dispatch] ⏱️ $agent_id 执行超时 (${agent_elapsed}s)"
                                kill -TERM $pid 2>/dev/null || true
                                sleep 1
                                kill -9 $pid 2>/dev/null || true
                                wait "$pid" 2>/dev/null || true
                                timed_out_agents+=("$agent_id")
                                timed_out=true
                                all_success=false
                            fi
                        fi
                    fi
                fi
                if [[ "$timed_out" == false ]]; then
                    new_remaining+=("$pid")
                fi
            fi
        done
        remaining_pids=(${new_remaining[@]+"${new_remaining[@]}"})
        if [[ ${#remaining_pids[@]} -gt 0 ]]; then
            sleep $check_interval
        fi
    done

    # v2.7.0 fix: 无超时代理时跳过提示
    if [[ ${#timed_out_agents[@]} -gt 0 ]]; then
        echo "[dispatch] ⚠️ 超时代理: ${timed_out_agents[*]}"
    fi

    # 更新summary
    local total=${#agent_ids[@]}
    local success=0
    local failed=0
    local partial=0

    for agent_id in "${agent_ids[@]}"; do
        local result_file="$TMP_DIR/subagent-${agent_id}-result.json"
        if [[ -f "$result_file" ]]; then
            local data
            data=$(cat "$result_file")
            local status
            status=$(echo "$data" | jq -r '.status' 2>/dev/null || echo "FAILED")
            if [[ -z "$status" || "$status" == "null" ]]; then
                echo "[dispatch] ❌ result JSON 无效: $result_file"
                failed=$((failed + 1))
                continue
            fi

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
        if [[ -f "$result_file" ]]; then
            local agent_data
            agent_data=$(jq -c '.' "$result_file")
            if [[ "$first" == true ]]; then
                agents_json="$agent_data"
                first=false
            else
                agents_json="$agents_json,$agent_data"
            fi
        fi
    done

    local executed_at
    executed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    jq -n --arg tid "$orig_task_id" --arg tdesc "$orig_task_desc" \
         --argjson pn "$orig_parallel_n" --argjson aj "[$agents_json]" \
         --arg ca "$orig_created_at" --arg ea "$executed_at" \
         --argjson tot "$total" --argjson suc "$success" \
         --argjson fail "$failed" --argjson part "$partial" \
         '{task_id: $tid, task_desc: $tdesc, parallel_n: $pn, agents: $aj, created_at: $ca, executed_at: $ea, status: "COMPLETED", summary: {total: $tot, successful: $suc, failed: $fail, partial: $part}}' \
         > "$summary_file"

    echo ""
    echo "[dispatch] 📊 执行摘要:"
    echo "[dispatch]    总计: $total | 成功: $success | 失败: $failed | 部分: $partial"
}

#------------------------------------------------------------------------------
# 等待子代理完成（v2.7.0 新增）
#------------------------------------------------------------------------------
wait_for_subagents() {
    local summary_file="$TMP_DIR/dispatch-summary.json"
    local launch_manifest="$TMP_DIR/launch-manifest.json"
    local timeout_seconds="${1:-300}"
    local check_interval=5
    local elapsed=0

    if [[ ! -f "$launch_manifest" ]]; then
        echo "[dispatch] 错误: launch-manifest.json 不存在，请先运行 --execute" >&2
        exit 1
    fi

    echo "[dispatch] ⏳ 等待子代理完成（超时: ${timeout_seconds}秒）..."

    local agents
    agents=$(jq -r '.agents[]' "$launch_manifest" 2>/dev/null || echo "")

    while [[ $elapsed -lt $timeout_seconds ]]; do
        local all_complete=true
        local completed=0
        local total=0

        for agent_id in $agents; do
            local result_file="$TMP_DIR/subagent-${agent_id}-result.json"
            total=$((total + 1))

            if [[ -f "$result_file" ]]; then
                completed=$((completed + 1))
            else
                all_complete=false
            fi
        done

        if [[ "$all_complete" == true ]]; then
            echo "[dispatch] ✅ 所有子代理已完成"
            command -v session_set >/dev/null 2>&1 && session_set status done 2>/dev/null || true
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
# 收集结果（v2.7.0 增强：支持 result 文件聚合）
#------------------------------------------------------------------------------
collect_results() {
    local summary_file="$TMP_DIR/dispatch-summary.json"
    local launch_manifest="$TMP_DIR/launch-manifest.json"

    # 优先使用 launch-manifest
    if [[ -f "$launch_manifest" ]]; then
        local task_id
        task_id=$(jq -r '.task_id' "$launch_manifest")
        local task_desc
        task_desc=$(jq -r '.task_desc' "$launch_manifest")
        local launched_at
        launched_at=$(jq -r '.launched_at' "$launch_manifest")
        local agents
        agents=$(jq -r '.agents[]' "$launch_manifest" 2>/dev/null || echo "")

        echo ""
        echo "[dispatch] 聚合报告"
        echo "task=$task_id desc=$task_desc"
        echo "start=$launched_at end=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""

        local total=0
        local success=0
        local failed=0
        local partial=0

        echo "子代理状态:"

        for agent_id in $agents; do
            local result_file="$TMP_DIR/subagent-${agent_id}-result.json"
            if [[ -f "$result_file" ]]; then
                local data
                data=$(cat "$result_file")
                local status
                status=$(echo "$data" | jq -r '.status' 2>/dev/null || echo "UNKNOWN")
                local role
                role=$(echo "$data" | jq -r '.role' 2>/dev/null || echo "Unknown")
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

        echo ""
        echo "total=$total ok=$success fail=$failed partial=$partial"

        # 收集所有修改的文件
        echo ""
        echo "修改文件清单:"
        local all_files="[]"
        local result_files=("$TMP_DIR"/subagent-*-result.json)
        if [[ ${#result_files[@]} -gt 0 && -f "${result_files[0]}" ]]; then
            all_files=$(jq -s '[.[] | .files_modified // []] | add | unique' "${result_files[@]}" 2>/dev/null || echo "[]")
        fi
        if [[ "$all_files" == "[]" ]]; then
            echo "  (无)"
        else
            echo "$all_files" | jq -r '.[]' 2>/dev/null || echo "  (无)"
        fi

        # 更新 summary 文件
        local agents_json=""
        local first=true
        for agent_id in $agents; do
            local result_file="$TMP_DIR/subagent-${agent_id}-result.json"
            if [[ -f "$result_file" ]]; then
                if [[ "$first" == true ]]; then
                    agents_json=$(jq -c '.' "$result_file")
                    first=false
                else
                    agents_json="$agents_json,$(jq -c '.' "$result_file")"
                fi
            fi
        done

        local executed_at_ts
        executed_at_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        local parallel_n_val
        parallel_n_val=$(jq -r '.parallel_n' "$launch_manifest")
        jq -n \
            --arg tid "$task_id" \
            --arg tdesc "$task_desc" \
            --argjson pn "$parallel_n_val" \
            --argjson aj "[$agents_json]" \
            --arg ca "$launched_at" \
            --arg ea "$executed_at_ts" \
            --argjson tot "$total" \
            --argjson suc "$success" \
            --argjson fail "$failed" \
            --argjson part "$partial" \
            '{task_id: $tid, task_desc: $tdesc, parallel_n: $pn, agents: $aj, created_at: $ca, executed_at: $ea, status: "COMPLETED", summary: {total: $tot, successful: $suc, failed: $fail, partial: $part}}' \
            > "$summary_file"

    elif [[ -f "$summary_file" ]]; then
        echo ""
        echo "[dispatch] 聚合报告(summary)"
        echo "task=$(jq -r '.task_id' "$summary_file")"
        echo "desc=$(jq -r '.task_desc' "$summary_file")"
        echo "exec=$(jq -r '.executed_at // "未执行"' "$summary_file")"
        echo ""

        local total
        total=$(jq -r '.summary.total // 0' "$summary_file")
        local successful
        successful=$(jq -r '.summary.successful // 0' "$summary_file")
        local failed
        failed=$(jq -r '.summary.failed // 0' "$summary_file")
        local partial
        partial=$(jq -r '.summary.partial // 0' "$summary_file")

        echo "total=$total ok=$successful fail=$failed partial=$partial"
        echo ""

        echo "子代理状态:"
        local has_agents=false
        while read -r agent_json; do
            has_agents=true
            local id
            id=$(echo "$agent_json" | jq -r '.id')
            local role
            role=$(echo "$agent_json" | jq -r '.role')
            local status
            status=$(echo "$agent_json" | jq -r '.status')
            local status_icon="⚪"
            case "$status" in
                SUCCESS) status_icon="✅" ;;
                FAILED) status_icon="❌" ;;
                PARTIAL) status_icon="⚠️" ;;
                QUEUED) status_icon="⏳" ;;
            esac
            echo "  $status_icon $id ($role): $status"
        done < <(jq -c '.agents[]' "$summary_file" 2>/dev/null)

        if [[ "$has_agents" != true ]]; then
            echo "  (尚未执行，请使用 --execute 运行)"
        fi

        # 收集所有修改的文件
        echo ""
        echo "修改文件清单:"
        local all_files="[]"
        for result_file in "$TMP_DIR"/subagent-*-result.json; do
            if [[ -f "$result_file" ]]; then
                local files
                files=$(jq -r '.files_modified // []' "$result_file" 2>/dev/null)
                all_files=$(jq -s '.[0] + .[1] | unique' <(echo "$all_files") <(echo "$files") 2>/dev/null || echo "$all_files")
            fi
        done
        echo "$all_files" | jq -r '.[]' 2>/dev/null || echo "  (无)"
    else
        echo "[dispatch] 错误: dispatch-summary.json 不存在" >&2
        exit 1
    fi

    echo ""
    echo "[dispatch] /flow-kit:dispatch-status 查看最新状态"
}

#------------------------------------------------------------------------------
# 主流程
#------------------------------------------------------------------------------
main() {
    parse_args "$@"

    # aggregate 和 wait 模式只需要初始化目录
    if [[ "$AGGREGATE_MODE" == true ]]; then
        init_dirs
        echo "[dispatch] 📊 聚合模式"
        collect_results
        return 0
    fi

    if [[ "$WAIT_MODE" == true ]]; then
        init_dirs
        echo "[dispatch] ⏳ 等待模式（超时: ${WAIT_TIMEOUT}s）"
        wait_for_subagents $WAIT_TIMEOUT
        collect_results
        return 0
    fi

    init_dirs

    echo ""
    echo "[dispatch] start: $TASK_DESC parallel=$PARALLEL_N"
    echo ""

    split_task "$TASK_DESC" "$PARALLEL_N"
    check_lock_conflicts

    if [[ "$EXECUTE_MODE" == true ]]; then
        execute_subagents
        collect_results
        # v3.3.0: 追加执行历史
        command -v session_history_add >/dev/null 2>&1 && session_history_add "dispatch-done" 2>/dev/null || true
    else
        echo ""
        echo "[dispatch] subtasks:"
        jq '.agents' "$TMP_DIR/dispatch-summary.json"
        echo ""
        echo "[dispatch] run: bash flow-kit/scripts/dispatch.sh --execute"
    fi
}
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
