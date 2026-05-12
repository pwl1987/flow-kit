#!/bin/bash
# run-tests.sh — flow-kit 统一测试入口

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOW_KIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

run() {
    local name="$1"
    shift
    echo ""
    echo "### $name"
    "$@"
}

run "shell syntax" bash -c "find '$FLOW_KIT_DIR' -name '*.sh' -type f -print0 | xargs -0 -n1 bash -n"

for test_file in "$SCRIPT_DIR"/test-*.sh; do
    run "$(basename "$test_file")" bash "$test_file"
done

run "e2e-full-flow.sh" bash "$SCRIPT_DIR/e2e-full-flow.sh"
run "e2e-test-harness.sh" bash "$SCRIPT_DIR/e2e-test-harness.sh"

echo ""
echo "All flow-kit tests passed."
