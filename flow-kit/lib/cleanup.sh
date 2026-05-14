#!/bin/bash
# cleanup.sh — 临时文件统一管理
# v3.5.0 新增

_CLEANUP_FILES=()
_CLEANUP_DIRS=()

# 注册临时文件（trap EXIT 时自动删除）
register_cleanup() {
    _CLEANUP_FILES+=("$1")
}

# 注册临时目录（trap EXIT 时 rmdir）
register_cleanup_dir() {
    _CLEANUP_DIRS+=("$1")
}

# 执行清理（绑定到 trap EXIT）
do_cleanup() {
    for f in "${_CLEANUP_FILES[@]}"; do
        rm -f "$f" 2>/dev/null || true
    done
    for d in "${_CLEANUP_DIRS[@]}"; do
        rm -rf "$d" 2>/dev/null || true
    done
    _CLEANUP_FILES=()
    _CLEANUP_DIRS=()
}
