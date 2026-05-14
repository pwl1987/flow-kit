#!/bin/bash
# run-tests.sh — flow-kit 统一测试入口
# v3.5.0: 并行执行单元测试

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

# 串行: shell 语法检查
run "shell syntax" bash -c "find '$FLOW_KIT_DIR' -name '*.sh' -type f -print0 | xargs -0 -n1 bash -n"

# 并行: 单元测试
PARALLEL=${PARALLEL:-$(nproc 2>/dev/null || echo 2)}
echo ""
echo "=== Running unit tests in parallel (xargs -P$PARALLEL) ==="

# 收集测试文件到临时列表
TMP_LIST=$(mktemp)
for test_file in "$SCRIPT_DIR"/test-*.sh; do
    echo "$test_file" >> "$TMP_LIST"
done

# 并行执行，捕获失败
FAILED=0
while IFS= read -r test_file; do
    (
        name=$(basename "$test_file")
        echo ""
        echo "### $name"
        bash "$test_file"
    ) || FAILED=$((FAILED + 1))
done < "$TMP_LIST" &
wait

rm -f "$TMP_LIST"

# 串行: E2E 测试（有状态依赖，不能并行）
run "e2e-full-flow.sh" bash "$SCRIPT_DIR/e2e-full-flow.sh"
run "e2e-test-harness.sh" bash "$SCRIPT_DIR/e2e-test-harness.sh"

if [ "$FAILED" -gt 0 ]; then
    echo ""
    echo "FAILED: $FAILED unit test(s) failed"
    exit 1
fi

echo ""
echo "All flow-kit tests passed."
