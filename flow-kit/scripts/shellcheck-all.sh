#!/bin/bash
# shellcheck-all.sh — 并行 ShellCheck 检查
# v3.7.0 新增

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

FIX_MODE=0

usage() {
    cat << 'EOF'
shellcheck-all.sh — 并行 ShellCheck 检查

用法:
  shellcheck-all.sh          检查全部 .sh
  shellcheck-all.sh --fix    自动修复
  shellcheck-all.sh -h       显示帮助
EOF
}

for arg in "$@"; do
    case "$arg" in
        --fix) FIX_MODE=1 ;;
        -h|--help) usage; exit 0 ;;
    esac
done

if ! command -v shellcheck &>/dev/null; then
    echo "[shellcheck-all] shellcheck 未安装"
    echo "[shellcheck-all] 安装: apt install shellcheck 或 brew install shellcheck"
    exit 0
fi

# 查找 .sh 文件
sh_files=()
while IFS= read -r -d '' f; do
    sh_files+=("$f")
done < <(find "$ROOT_DIR" -name "*.sh" -not -path "*/node_modules/*" -print0 2>/dev/null)

if [[ ${#sh_files[@]} -eq 0 ]]; then
    echo "[shellcheck-all] 无 .sh 文件"
    exit 0
fi

echo "[shellcheck-all] 检查 ${#sh_files[@]} 个文件..."

SC_OPTS=(--color=always --severity=warning)
if [[ $FIX_MODE -eq 1 ]]; then
    SC_OPTS=(--fix)
fi

# 并行检查
errors=0
if [[ $FIX_MODE -eq 1 ]]; then
    for f in "${sh_files[@]}"; do
        shellcheck --fix "$f" 2>/dev/null || true
    done
    echo "[shellcheck-all] 修复完成"
else
    printf '%s\0' "${sh_files[@]}" | xargs -0 -P$(nproc 2>/dev/null || echo 4) shellcheck "${SC_OPTS[@]}" 2>&1 || errors=1
    if [[ $errors -eq 0 ]]; then
        echo "[shellcheck-all] ✅ 全部通过"
    else
        echo "[shellcheck-all] ❌ 存在问题"
    fi
fi

exit $errors
