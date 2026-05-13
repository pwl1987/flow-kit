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

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "session-state.sh 单元测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

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

# --- 结果 ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "session-state 测试: 通过 $PASS | 失败 $FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
