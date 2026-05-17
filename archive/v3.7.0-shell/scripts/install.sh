#!/bin/bash
# install.sh — 安装 flow-kit 依赖工具
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "=== 安装 Node.js 依赖 ==="
if command -v npm &>/dev/null; then
    npm install
else
    echo "跳过 npm（未安装）"
fi

echo "=== 安装 shell 工具 ==="
if command -v apt-get &>/dev/null; then
    sudo apt-get install -y shellcheck shfmt markdownlint 2>/dev/null || echo "部分工具安装失败"
elif command -v brew &>/dev/null; then
    brew install shellcheck shfmt 2>/dev/null || echo "部分工具安装失败"
    npm install -g markdownlint-cli 2>/dev/null || echo "markdownlint 安装失败"
fi

echo "=== 安装 hyperfine ==="
if command -v hyperfine &>/dev/null; then
    echo "hyperfine 已安装"
elif command -v cargo &>/dev/null; then
    cargo install hyperfine 2>/dev/null || echo "hyperfine 安装失败"
fi

echo "=== 验证 ==="
for tool in shellcheck shfmt npm; do
    if command -v "$tool" &>/dev/null; then
        echo "OK: $tool"
    else
        echo "MISSING: $tool"
    fi
done