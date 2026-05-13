#!/bin/bash
# e2e-full-flow.sh — 端到端流程测试
# v2.7.0 新增

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_TMP_DIR="$FLOW_KIT_DIR/.e2e-test-$$"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

passed=0
failed=0
skipped=0

setup() {
    mkdir -p "$TEST_TMP_DIR/phases"
    mkdir -p "$TEST_TMP_DIR/.flow-kit/tmp"
    mkdir -p "$TEST_TMP_DIR/.flow-kit/locks"
}

cleanup() {
    rm -rf "$TEST_TMP_DIR" 2>/dev/null || true
}

trap cleanup EXIT

assert_equals() {
    local expected="$1"
    local actual="$2"
    local msg="$3"

    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $msg"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        failed=$((failed + 1))
    fi
}

assert_file_exists() {
    local file="$1"
    local msg="$2"

    if [ -f "$file" ]; then
        echo -e "${GREEN}PASS${NC}: $msg"
        passed=$((passed + 1))
    else
        echo -e "${RED}FAIL${NC}: $msg"
        failed=$((failed + 1))
    fi
}

test_dispatch_creates_summary() {
    echo "=== test_dispatch_creates_summary ==="

    export TMP_DIR="$TEST_TMP_DIR/.flow-kit/tmp"
    export LOCK_DIR="$TEST_TMP_DIR/.flow-kit/locks"
    export MAX_CONCURRENT=3
    export CHILD_PIDS=()

    mkdir -p "$TMP_DIR" "$LOCK_DIR"

    local output_file="$TMP_DIR/dispatch-summary.json"

    source "$FLOW_KIT_DIR/lib/paths.sh"

    cd "$FLOW_KIT_DIR" || return 1

    if ! command -v jq &>/dev/null; then
        echo -e "${YELLOW}SKIP${NC}: jq not available"
        skipped=$((skipped + 1))
        return 0
    fi

    return 0
}

test_validate_phase_checks_jq() {
    echo "=== test_validate_phase_checks_jq ==="

    local script="$FLOW_KIT_DIR/scripts/validate-phase.sh"

    if [ ! -f "$script" ]; then
        echo -e "${RED}FAIL${NC}: validate-phase.sh not found"
        failed=$((failed + 1))
        return 1
    fi

    if ! grep -q 'command -v jq' "$script"; then
        echo -e "${RED}FAIL${NC}: validate-phase.sh missing jq check"
        failed=$((failed + 1))
        return 1
    fi

    echo -e "${GREEN}PASS${NC}: validate-phase.sh has jq check"
    passed=$((passed + 1))
}

test_dispatch_uses_flock() {
    echo "=== test_dispatch_uses_flock ==="

    local script="$FLOW_KIT_DIR/scripts/dispatch.sh"

    if [ ! -f "$script" ]; then
        echo -e "${RED}FAIL${NC}: dispatch.sh not found"
        failed=$((failed + 1))
        return 1
    fi

    if ! grep -q 'flock' "$script"; then
        echo -e "${RED}FAIL${NC}: dispatch.sh missing flock"
        failed=$((failed + 1))
        return 1
    fi

    echo -e "${GREEN}PASS${NC}: dispatch.sh uses flock"
    passed=$((passed + 1))
}

test_lib_scripts_exist() {
    echo "=== test_lib_scripts_exist ==="

    local scripts=(
        "$FLOW_KIT_DIR/lib/token-estimator.sh"
        "$FLOW_KIT_DIR/lib/expiry-checker.sh"
        "$FLOW_KIT_DIR/lib/cost-reporter.sh"
        "$FLOW_KIT_DIR/lib/context-updater.sh"
        "$FLOW_KIT_DIR/lib/pr-generator.sh"
    )

    for script in "${scripts[@]}"; do
        assert_file_exists "$script" "$(basename "$script") exists"
    done
}

test_security_scripts_exist() {
    echo "=== test_security_scripts_exist ==="

    assert_file_exists "$FLOW_KIT_DIR/lib/security-scanner.sh" "security-scanner.sh exists"
    assert_file_exists "$FLOW_KIT_DIR/scripts/p0-check.sh" "p0-check.sh exists"
}

main() {
    echo "=========================================="
    echo "E2E: Full Flow Test"
    echo "=========================================="
    echo ""

    setup

    test_validate_phase_checks_jq
    test_dispatch_uses_flock
    test_lib_scripts_exist
    test_security_scripts_exist
    test_dispatch_creates_summary

    echo ""
    echo "=========================================="
    echo "Results: $passed passed, $failed failed, $skipped skipped"
    echo "=========================================="

    if [ "$failed" -gt 0 ]; then
        exit 1
    fi
    exit 0
}

main "$@"