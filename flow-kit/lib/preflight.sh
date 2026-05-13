#!/bin/bash
# preflight.sh — 统一依赖预检
# v2.8.0 新增
# 在脚本入口调用 require_* 函数验证依赖可用性

set -euo pipefail

require_cmd() {
    local cmd="$1"
    local msg="${2:-依赖 $cmd 未安装}"
    if ! command -v "$cmd" &>/dev/null; then
        echo "[preflight] 错误: $msg" >&2
        return 1
    fi
}

require_jq() {
    require_cmd jq "jq 未安装。安装: brew install jq / apt install jq"
}

require_python3() {
    require_cmd python3 "python3 未安装。安装: brew install python3 / apt install python3"
}

require_pyyaml() {
    require_python3
    if ! python3 -c 'import yaml' 2>/dev/null; then
        echo "[preflight] 错误: PyYAML 未安装。安装: pip3 install pyyaml" >&2
        return 1
    fi
}

require_bash4() {
    local major="${BASH_VERSINFO[0]:-0}"
    if [ "$major" -lt 4 ]; then
        echo "[preflight] 错误: 需要 bash >= 4.0 (当前 $BASH_VERSION)" >&2
        echo "[preflight] macOS: brew install bash && 在脚本中添加 #!/usr/bin/env bash" >&2
        return 1
    fi
}

require_bc() {
    require_cmd bc "bc 未安装。安装: brew install bc / apt install bc"
}
