#!/bin/bash
# ide-adapter.sh — 多 IDE 适配层

detect_ide() {
    # 检测当前 IDE：CLAUDE_CODE / CURSOR / WINDSURF / UNKNOWN
    if [[ -n "${CLAUDE_CODE:-}" ]]; then
        echo "CLAUDE_CODE"
    elif command -v cursor &>/dev/null; then
        echo "CURSOR"
    elif command -v windsurf &>/dev/null; then
        echo "WINDSURF"
    else
        echo "UNKNOWN"
    fi
}

register_commands() {
    local ide="${1:-UNKNOWN}"
    # IDE 特定命令注册
    echo "[ide-adapter] registered for $ide"
}

get_ide_config() {
    local ide="${1:-UNKNOWN}"
    case "$ide" in
        CLAUDE_CODE) echo "$HOME/.claude/settings.json" ;;
        CURSOR) echo "$HOME/.cursor/settings.json" ;;
        WINDSURF) echo "$HOME/.windsurf/settings.json" ;;
        *) echo "" ;;
    esac
}