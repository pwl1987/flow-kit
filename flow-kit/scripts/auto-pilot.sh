#!/usr/bin/env bash
# auto-pilot.sh — 半自动执行状态机
# v3.6.0 新增：编排 phase 执行 + 产出物验证 + 推荐下一步
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/paths.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../lib/session-state.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../lib/front-matter.sh" 2>/dev/null || true
# v3.7.0: 指标埋点（静默降级）
_METRICS_AVAILABLE=0
if [[ -f "${LIB_DIR:-$SCRIPT_DIR/../lib}/metrics-logger.sh" ]]; then
    source "${LIB_DIR:-$SCRIPT_DIR/../lib}/metrics-logger.sh" 2>/dev/null && _METRICS_AVAILABLE=1 || _METRICS_AVAILABLE=0
fi

# === CLI ===
ACTION=""
DEPTH="campaign"

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --next)   ACTION="next"; shift ;;
            --status) ACTION="status"; shift ;;
            --depth)  DEPTH="${2:-campaign}"; shift 2 ;;
            -h|--help)
                echo "auto-pilot — 半自动执行状态机"
                echo "用法: auto-pilot [--next|--status|--depth quick|campaign|deep]"
                exit 0
                ;;
            *) shift ;;
        esac
    done
}

# === 路径 ===
_plan_file() { echo "${PATHS_PROJECT_DIR:-$CLAUDE_PROJECT_DIR}/.flow-kit/auto-plan.json"; }
_session_file() { echo "${PATHS_PROJECT_DIR:-$CLAUDE_PROJECT_DIR}/.flow-kit/session-state.json"; }

# === 加载 session-state ===
load_session_state() {
    local sf
    sf=$(_session_file)
    if [[ ! -f "$sf" ]]; then
        echo "[auto-pilot] 错误：无 session-state.json" >&2
        return 1
    fi
    command -v jq &>/dev/null || { echo "[auto-pilot] 错误：需要 jq" >&2; return 1; }
}

# === 获取当前 phase 数字 ===
_current_phase_num() {
    local sf=$(_session_file)
    local phase_str
    phase_str=$(jq -r '.phase // empty' "$sf" 2>/dev/null || echo "")
    if [[ -z "$phase_str" ]]; then
        echo "0"
        return
    fi
    # 提取数字部分（0-change → 0, 2a-ui-design → 2）
    echo "$phase_str" | grep -oE '^[0-9]+' || echo "0"
}

# === 生成初始 plan ===
create_plan() {
    local pf=$(_plan_file)
    local phase_num
    phase_num=$(_current_phase_num)
    local depth="$DEPTH"

    # quick 模式跳到 phase 4
    if [[ "$depth" == "quick" ]]; then
        phase_num=4
    fi

    local now
    now=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")

    local plan
    plan=$(jq -n \
        --arg desc "" \
        --arg depth "$depth" \
        --argjson phase "$phase_num" \
        --arg now "$now" \
        '{
            description: $desc,
            task_depth: $depth,
            current_phase: $phase,
            created_at: $now,
            updated_at: $now,
            phases: []
        }')

    local tmp
    tmp=$(mktemp)
    echo "$plan" > "$tmp"
    mv "$tmp" "$pf"
}

# === 加载或创建 plan ===
load_or_create_plan() {
    local pf=$(_plan_file)
    if [[ ! -f "$pf" ]]; then
        create_plan
    fi
}

# === 验证当前 phase 产出物 ===
validate_current_phase() {
    local pf=$(_plan_file)
    local sf=$(_session_file)
    local phase_str
    phase_str=$(jq -r '.phase // empty' "$sf" 2>/dev/null || echo "")
    if [[ -z "$phase_str" ]]; then
        return 0
    fi

    local phases_dir="${PATHS_FLOW_KIT_DIR:-$SCRIPT_DIR/..}/phases"
    local phase_file
    phase_file=$(find "$phases_dir" -name "*.md" -path "*$phase_str*" 2>/dev/null | head -1)
    if [[ -z "$phase_file" ]]; then
        return 0
    fi

    local artifacts_json
    artifacts_json=$(parse_front_matter "$phase_file" 2>/dev/null | jq -r '.expected_artifacts // []' 2>/dev/null || echo "[]")
    local count
    count=$(echo "$artifacts_json" | jq 'length' 2>/dev/null || echo 0)

    local evidence="[]"
    local i=0
    local project_dir="${PATHS_PROJECT_DIR:-$CLAUDE_PROJECT_DIR}"
    while (( i < count )); do
        local artifact
        artifact=$(echo "$artifacts_json" | jq -r ".[$i]" 2>/dev/null)
        local result="fail"
        if [[ -f "$project_dir/$artifact" ]]; then
            result="pass"
        fi
        evidence=$(echo "$evidence" | jq --arg check "file_exists" --arg art "$artifact" --arg res "$result" \
            '. + [{"check": $check, "artifact": $art, "result": $res}]')
        i=$((i + 1))
    done

    # 写入 evidence
    local phase_num
    phase_num=$(_current_phase_num)
    local has_phase
    has_phase=$(jq --argjson pid "$phase_num" '.phases | map(select(.id == $pid)) | length' "$pf" 2>/dev/null || echo 0)

    if [[ "$has_phase" == "0" ]]; then
        # 添加 phase 记录
        local now
        now=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")
        jq --argjson pid "$phase_num" --arg name "$phase_str" --argjson ev "$evidence" --arg now "$now" \
            '.phases += [{"id": $pid, "name": $name, "status": "in_progress", "evidence": $ev, "ts": $now}]' "$pf" > "$pf.tmp" && mv "$pf.tmp" "$pf"
    else
        # 更新已有 phase
        jq --argjson pid "$phase_num" --argjson ev "$evidence" \
            '(.phases[] | select(.id == $pid)).evidence = $ev' "$pf" > "$pf.tmp" && mv "$pf.tmp" "$pf"
    fi
}

# === 推荐下一步 ===
recommend_next_step() {
    local pf=$(_plan_file)
    local phase_num
    phase_num=$(jq -r '.current_phase // 0' "$pf" 2>/dev/null || echo 0)
    local next=$((phase_num + 1))
    if [[ "$next" -gt 8 ]]; then
        next=8
    fi
    echo "[auto-pilot] Phase $phase_num 完成 | 推荐使用 --next 推进到 Phase $next"
}

# === --next 推进 ===
do_next() {
    local pf=$(_plan_file)
    local sf=$(_session_file)
    local phase_num
    phase_num=$(jq -r '.current_phase // 0' "$pf" 2>/dev/null || echo 0)

    # 标记当前 phase 为 completed
    jq --argjson pid "$phase_num" '(.phases[] | select(.id == $pid)).status = "completed"' "$pf" > "$pf.tmp" 2>/dev/null && mv "$pf.tmp" "$pf" || true

    local next=$((phase_num + 1))
    if [[ "$next" -gt 8 ]]; then
        echo "[auto-pilot] 已到达最终 Phase"
        return 0
    fi

    # 更新 plan
    local now
    now=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")
    jq --argjson next "$next" --arg now "$now" '.current_phase = $next | .updated_at = $now' "$pf" > "$pf.tmp" && mv "$pf.tmp" "$pf"

    # 更新 session-state
    # 找到对应的 phase 目录名
    local phases_dir="${PATHS_FLOW_KIT_DIR:-$SCRIPT_DIR/..}/phases"
    local next_dir
    next_dir=$(find "$phases_dir" -maxdepth 1 -type d -name "${next}-*" 2>/dev/null | head -1)
    if [[ -n "$next_dir" ]]; then
        local next_name
        next_name=$(basename "$next_dir")
        jq --arg pn "$next_name" '.phase = $pn' "$sf" > "$sf.tmp" && mv "$sf.tmp" "$sf"
    fi

    echo "[auto-pilot] 推进到 Phase $next"
}

# === --status 显示 ===
do_status() {
    local pf=$(_plan_file)
    local sf=$(_session_file)
    if [[ ! -f "$pf" ]]; then
        echo "[auto-pilot] 无 auto-plan.json"
        return 0
    fi
    local current
    current=$(jq -r '.current_phase // "unknown"' "$pf")
    local depth
    depth=$(jq -r '.task_depth // "campaign"' "$pf")
    local phase_str
    phase_str=$(jq -r '.phase // "unknown"' "$sf" 2>/dev/null || echo "unknown")
    local completed
    completed=$(jq '[.phases[] | select(.status == "completed")] | length' "$pf" 2>/dev/null || echo 0)
    echo "[auto-pilot] Phase $current ($phase_str) | 深度: $depth | 已完成: $completed phases"
}

# === 主函数 ===
main() {
    local _ap_start=$SECONDS
    parse_args "$@"

    case "$ACTION" in
        status)
            do_status
            return 0
            ;;
    esac

    load_session_state || return 1
    load_or_create_plan

    case "$ACTION" in
        next)
            do_next
            ;;
        *)
            validate_current_phase
            recommend_next_step
            ;;
    esac

    # v3.7.0: 指标埋点
    if [[ $_METRICS_AVAILABLE -eq 1 ]]; then
        local _ap_elapsed=$(( SECONDS - _ap_start ))
        metrics_log_event "auto_pilot" "action=$ACTION elapsed=${_ap_elapsed}s"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
