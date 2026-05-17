#!/bin/bash
# cleanup.sh — 临时文件统一管理
# v3.5.0 新增
# v3.7.0: 添加 with_cleanup wrapper，集成 setup_trap

_CLEANUP_FILES=()
_CLEANUP_DIRS=()
_CLEANUP_TRAP_SET=0

# 注册临时文件（trap EXIT 时自动删除）
register_cleanup() {
    _CLEANUP_FILES+=("$1")
    # 首次注册时自动设置 EXIT trap
    if [[ $_CLEANUP_TRAP_SET -eq 0 ]]; then
        with_cleanup
    fi
}

# 注册临时目录（trap EXIT 时删除）
register_cleanup_dir() {
    _CLEANUP_DIRS+=("$1")
    if [[ $_CLEANUP_TRAP_SET -eq 0 ]]; then
        with_cleanup
    fi
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

# v3.7.0: 初始化清理机制，注册 EXIT trap
# 调用后，EXIT 信号自动触发 do_cleanup
# 需先 source error-handler.sh
with_cleanup() {
    if [[ $_CLEANUP_TRAP_SET -eq 0 ]]; then
        _CLEANUP_TRAP_SET=1
        trap 'do_cleanup' EXIT
    fi
}
