#!/bin/bash
# session-state.sh — v3.0.0 记忆系统核心库
# caveman 压缩风格：极简 JSON，id:status 逗号串，省虚词
# 设计参考 cavemem：原子写入、graceful fallback、渐进披露

set -euo pipefail

readonly _SS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_SS_SCRIPT_DIR/error-handler.sh" 2>/dev/null || true
source "$_SS_SCRIPT_DIR/paths.sh" 2>/dev/null || {
    # fallback: paths.sh 未加载时手动定义
    _PROJECT_DIR="$(cd "$_SS_SCRIPT_DIR/../.." && pwd)"
    SESSION_STATE_FILE="$_PROJECT_DIR/.flow-kit/session-state.json"
    CURRENT_PHASE_FILE="$_PROJECT_DIR/.flow-kit/current-phase"
    PROJECT_TYPE_FILE="$_PROJECT_DIR/.flow-kit/project-type"
    MODE_FILE="$_PROJECT_DIR/.flow-kit/mode"
}

#------------------------------------------------------------------------------
# 内部函数
#------------------------------------------------------------------------------

_ss_now() { date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ"; }

_ss_skeleton() {
    jq -n --arg ts "$(_ss_now)" '{
        v: 1,
        change: "",
        phase: 0,
        status: "init",
        ptype: "green",
        mode: "auto",
        tasks: "",
        next: "",
        blockers: "",
        ts: $ts
    }'
}

_ss_ensure() {
    if [ ! -f "$SESSION_STATE_FILE" ]; then
        _ss_migrate || true
    fi
    if [ ! -f "$SESSION_STATE_FILE" ]; then
        mkdir -p "$(dirname "$SESSION_STATE_FILE")"
        _ss_skeleton > "$SESSION_STATE_FILE"
    fi
}

# 从旧文件迁移
_ss_migrate() {
    local phase="" ptype="green" mode="auto"

    [ -f "$CURRENT_PHASE_FILE" ] && phase=$(head -1 "$CURRENT_PHASE_FILE" 2>/dev/null || echo "")
    [[ ! "$phase" =~ ^[0-9]+$ ]] && phase="0"

    if [ -f "$PROJECT_TYPE_FILE" ]; then
        grep -q "brownfield" "$PROJECT_TYPE_FILE" 2>/dev/null && ptype="brown"
    fi

    [ -f "$MODE_FILE" ] && mode=$(head -1 "$MODE_FILE" 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo "auto")
    case "$mode" in
        team|ralph) ;;
        *) mode="auto" ;;
    esac

    # 从 .specs/ 推断 current change（兼容 macOS/BSD，不用 find -printf）
    local change=""
    local specs_dir
    specs_dir="$(cd "$_SS_SCRIPT_DIR/../.." && pwd)/.specs"
    if [ -d "$specs_dir" ]; then
        change=$(ls -1t "$specs_dir" 2>/dev/null | head -1 || true)
    fi

    mkdir -p "$(dirname "$SESSION_STATE_FILE")"
    jq -n \
        --arg change "${change:-}" \
        --argjson phase "${phase:-0}" \
        --arg ptype "$ptype" \
        --arg mode "$mode" \
        --arg ts "$(_ss_now)" \
        '{
            v: 1,
            change: $change,
            phase: $phase,
            status: (if $phase > 0 then "wip" else "init" end),
            ptype: $ptype,
            mode: $mode,
            tasks: "",
            next: "",
            blockers: "",
            ts: $ts
        }' > "$SESSION_STATE_FILE"
}

#------------------------------------------------------------------------------
# 公开 API
#------------------------------------------------------------------------------

# 读字段: session_get "phase"
session_get() {
    local key="${1:-}"
    [ -z "$key" ] && return 1
    _ss_ensure
    jq -r ".$key // empty" "$SESSION_STATE_FILE" 2>/dev/null || echo ""
}

# 写字段（原子）: session_set "phase" "4"
session_set() {
    local key="${1:-}"
    local val="${2:-}"
    [ -z "$key" ] && return 1
    # 防止 jq path 注入：只允许字母下划线
    [[ ! "$key" =~ ^[a-z_]+$ ]] && return 1
    _ss_ensure
    local tmp="${SESSION_STATE_FILE}.tmp.$$"
    local ts
    ts=$(_ss_now)
    # 数字字段用 --argjson，其他用 --arg
    if [[ "$val" =~ ^[0-9]+$ ]] && [[ "$key" =~ ^(phase|v)$ ]]; then
        jq --argjson v "$val" --arg ts "$ts" \
            ".${key} = \$v | .ts = \$ts" \
            "$SESSION_STATE_FILE" > "$tmp" && mv "$tmp" "$SESSION_STATE_FILE"
    else
        jq --arg v "$val" --arg ts "$ts" \
            ".${key} = \$v | .ts = \$ts" \
            "$SESSION_STATE_FILE" > "$tmp" && mv "$tmp" "$SESSION_STATE_FILE"
    fi
}

# 初始化: session_init "change-id" "brown"
session_init() {
    local change="${1:-}"
    local ptype="${2:-green}"
    [ -z "$change" ] && return 1
    mkdir -p "$(dirname "$SESSION_STATE_FILE")"
    local tmp="${SESSION_STATE_FILE}.tmp.$$"
    jq -n \
        --arg change "$change" \
        --arg ptype "$ptype" \
        --arg ts "$(_ss_now)" \
        '{
            v: 1,
            change: $change,
            phase: 0,
            status: "init",
            ptype: $ptype,
            mode: "auto",
            tasks: "",
            next: "run /flow-kit:phase-0",
            blockers: "",
            ts: $ts
        }' > "$tmp" && mv "$tmp" "$SESSION_STATE_FILE"

    # 兼容旧文件
    printf '%s\n' "0" > "$CURRENT_PHASE_FILE"
}

# 更新任务: session_task_set "T1" "wip"
session_task_set() {
    local tid="${1:-}"
    local status="${2:-todo}"
    [ -z "$tid" ] && return 1
    _ss_ensure
    local current
    current=$(session_get tasks)

    # 移除旧条目
    local updated=""
    if [ -n "$current" ]; then
        updated=$(echo "$current" | tr ',' '\n' | grep -v "^${tid}:" | tr '\n' ',' | sed 's/,$//')
    fi

    # 添加新条目
    if [ -n "$updated" ]; then
        updated="${updated},${tid}:${status}"
    else
        updated="${tid}:${status}"
    fi

    session_set tasks "$updated"
}

# 更新下一步: session_next "impl POST /api/feedback"
session_next() {
    session_set next "${1:-}"
}

# 更新阻塞项: session_block "missing API key,db locked"
session_block() {
    session_set blockers "${1:-}"
}

# 恢复提示（caveman 风格，~30 token）
session_resume_prompt() {
    _ss_ensure
    local change phase status ptype tasks blockers next
    change=$(session_get change)
    phase=$(session_get phase)
    status=$(session_get status)
    ptype=$(session_get ptype)
    tasks=$(session_get tasks)
    blockers=$(session_get blockers)
    next=$(session_get next)

    local tasks_summary=""
    if [ -n "$tasks" ]; then
        local done=0 wip=0 todo=0
        for entry in $(echo "$tasks" | tr ',' ' '); do
            local s="${entry##*:}"
            case "$s" in
                done) done=$((done + 1)) ;;
                wip)  wip=$((wip + 1)) ;;
                *)    todo=$((todo + 1)) ;;
            esac
        done
        tasks_summary="${done}d/${wip}w/${todo}t"
    fi

    local blocker_count=0
    [ -n "$blockers" ] && blocker_count=$(echo "$blockers" | tr ',' '\n' | wc -l | tr -d ' ')

    echo "[flow-kit] change=${change:-(none)} phase=${phase}(${status}) ptype=${ptype} tasks=${tasks_summary:--} blockers=${blocker_count} next=${next:-(not set)}"
}
