#!/bin/bash
set -euo pipefail
# test-session-state.sh — v3.1.0 会话记忆系统单元测试

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$TEST_DIR/.." && pwd)"

# 计数器
PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); echo "✅ $1"; }
fail() { FAIL=$((FAIL + 1)); echo "❌ $1"; }

# 设置临时目录
TMP_TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_TEST_DIR"' EXIT

# 模拟项目环境
mkdir -p "$TMP_TEST_DIR/.flow-kit"
mkdir -p "$TMP_TEST_DIR/.specs"

# 覆盖路径变量
export SESSION_STATE_FILE="$TMP_TEST_DIR/.flow-kit/session-state.json"
export CURRENT_PHASE_FILE="$TMP_TEST_DIR/.flow-kit/current-phase"
export PROJECT_TYPE_FILE="$TMP_TEST_DIR/.flow-kit/project-type"
export MODE_FILE="$TMP_TEST_DIR/.flow-kit/mode"

source "$PROJECT_DIR/lib/session-state.sh"

echo "session-state.sh 单元测试"

# --- session_init ---
session_init "test-change-20260513" "brown"
[ -f "$SESSION_STATE_FILE" ] && pass "init creates session-state.json" || fail "init: file missing"

change=$(session_get change)
[ "$change" = "test-change-20260513" ] && pass "init sets change" || fail "init change: got '$change'"

ptype=$(session_get ptype)
[ "$ptype" = "brown" ] && pass "init sets ptype" || fail "init ptype: got '$ptype'"

phase=$(session_get phase)
[ "$phase" = "0" ] && pass "init sets phase=0" || fail "init phase: got '$phase'"

[ -f "$CURRENT_PHASE_FILE" ] && pass "init creates current-phase" || fail "init current-phase missing"

# --- session_set ---
session_set phase 4
phase=$(session_get phase)
[ "$phase" = "4" ] && pass "set phase=4 (numeric)" || fail "set phase: got '$phase'"

session_set status wip
status=$(session_get status)
[ "$status" = "wip" ] && pass "set status=wip" || fail "set status: got '$status'"

# --- key 注入防护 ---
session_set "foo.bar" "evil" 2>/dev/null && fail "key injection accepted" || pass "key injection blocked"
session_set "tasks|" "evil" 2>/dev/null && fail "pipe key accepted" || pass "pipe key blocked"

# --- session_task_set ---
session_task_set T1 done
session_task_set T2 wip
session_task_set T3 todo
tasks=$(session_get tasks)
echo "$tasks" | grep -q "T1:done" && pass "task T1:done" || fail "task T1: missing"
echo "$tasks" | grep -q "T2:wip" && pass "task T2:wip" || fail "task T2: missing"
echo "$tasks" | grep -q "T3:todo" && pass "task T3:todo" || fail "task T3: missing"

# task update
session_task_set T2 done
tasks=$(session_get tasks)
echo "$tasks" | grep -q "T2:done" && pass "task T2 updated to done" || fail "task T2 update failed"
! echo "$tasks" | grep -q "T2:wip" && pass "old T2:wip removed" || fail "old T2:wip still present"

# --- session_next ---
session_next "impl POST /api/feedback"
next=$(session_get next)
[ "$next" = "impl POST /api/feedback" ] && pass "next set" || fail "next: got '$next'"

# --- session_block ---
session_block "missing API key,db locked"
blockers=$(session_get blockers)
[ "$blockers" = "missing API key,db locked" ] && pass "blockers set" || fail "blockers: got '$blockers'"

# --- session_resume_prompt ---
prompt=$(session_resume_prompt)
echo "$prompt" | grep -q "phase=4" && pass "resume shows phase" || fail "resume missing phase"
echo "$prompt" | grep -q "change=test-change" && pass "resume shows change" || fail "resume missing change"
echo "$prompt" | grep -q "blockers=2" && pass "resume shows blockers" || fail "resume blockers count wrong"

# --- 迁移测试 ---
rm -f "$SESSION_STATE_FILE"
printf '%s\n' "2" > "$CURRENT_PHASE_FILE"
printf 'project_type: brownfield\n' > "$PROJECT_TYPE_FILE"
printf 'team\n' > "$MODE_FILE"
mkdir -p "$TMP_TEST_DIR/.specs/old-change-20260512"

# 触发迁移（session_get 内部调用 _ss_ensure）
ptype=$(session_get ptype)
[ "$ptype" = "brown" ] && pass "migrate reads ptype" || fail "migrate ptype: got '$ptype'"

phase=$(session_get phase)
[ "$phase" = "2" ] && pass "migrate reads phase" || fail "migrate phase: got '$phase'"

# --- 空状态 fallback ---
rm -f "$SESSION_STATE_FILE" "$CURRENT_PHASE_FILE" "$PROJECT_TYPE_FILE" "$MODE_FILE"
rm -rf "$TMP_TEST_DIR/.specs"
phase=$(session_get phase)
[ "$phase" = "0" ] && pass "empty fallback phase=0" || fail "empty fallback: got '$phase'"

# ============================================================================
# v3.3.0 P1: session-state v2 测试
# ============================================================================

# 重新初始化干净的 v2 状态
rm -f "$SESSION_STATE_FILE" "$CURRENT_PHASE_FILE"
session_init "v2-test-20260513" "green"

# --- v2 schema ---
version=$(session_get v)
[ "$version" = "2" ] && pass "v2 schema version" || fail "v2 version: got '$version'"

history=$(session_get history)
[ "$history" = "" ] && pass "v2 history empty on init" || fail "v2 history init: got '$history'"

decisions=$(session_get decisions)
[ "$decisions" = "" ] && pass "v2 decisions empty on init" || fail "v2 decisions init: got '$decisions'"

interactions=$(session_get interactions)
[ "$interactions" = "" ] && pass "v2 interactions empty on init" || fail "v2 interactions init: got '$interactions'"

# --- session_history_add ---
session_history_add "phase-0"
history=$(session_get history)
echo "$history" | grep -q "phase-0" && pass "history_add appends action" || fail "history_add: got '$history'"

session_history_add "phase-1"
history=$(session_get history)
echo "$history" | grep -q "phase-0" && echo "$history" | grep -q "phase-1" && pass "history_add multiple entries" || fail "history_add multiple: got '$history'"

# --- session_history_get ---
history_lines=$(session_history_get | wc -l)
[ "$history_lines" -ge 2 ] && pass "history_get returns entries" || fail "history_get: got $history_lines lines"

# --- session_decision_add ---
session_decision_add "d1" "y"
decisions=$(session_get decisions)
echo "$decisions" | grep -q "d1:y" && pass "decision_add appends decision" || fail "decision_add: got '$decisions'"

session_decision_add "d2" "n"
decisions=$(session_get decisions)
echo "$decisions" | grep -q "d1:y" && echo "$decisions" | grep -q "d2:n" && pass "decision_add multiple" || fail "decision_add multiple: got '$decisions'"

# --- session_interaction_set ---
session_interaction_set "用户确认使用 JWT 认证方案"
interactions=$(session_get interactions)
[ "$interactions" = "用户确认使用 JWT 认证方案" ] && pass "interaction_set stores summary" || fail "interaction_set: got '$interactions'"

# --- session_interaction_set 截断 ---
long_summary=$(printf 'A%.0s' {1..120})
session_interaction_set "$long_summary"
interactions=$(session_get interactions)
[ ${#interactions} -le 100 ] && pass "interaction_set truncates to 100" || fail "interaction_set truncation: len=${#interactions}"

# --- v1 → v2 自动迁移 ---
rm -f "$SESSION_STATE_FILE"
# 创建 v1 格式文件
jq -n '{
    v: 1,
    change: "legacy-change",
    phase: 3,
    status: "wip",
    ptype: "brown",
    mode: "auto",
    tasks: "T1:done,T2:wip",
    next: "",
    blockers: "",
    ts: "2026-05-13T00:00:00Z"
}' > "$SESSION_STATE_FILE"

# 触发 v1→v2 迁移
session_history_add "phase-3"
version=$(session_get v)
[ "$version" = "2" ] && pass "v1 migrate to v2" || fail "v1 migrate: got v=$version"

history=$(session_get history)
echo "$history" | grep -q "phase-3" && pass "v1 migrate preserves new history" || fail "v1 migrate history: got '$history'"

# v1 原有字段保持不变
change=$(session_get change)
[ "$change" = "legacy-change" ] && pass "v1 migrate preserves change" || fail "v1 migrate change: got '$change'"

# --- 结果 ---
echo ""
echo "session-state 测试: 通过 $PASS | 失败 $FAIL"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
