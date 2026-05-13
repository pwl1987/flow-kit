#!/bin/bash
# dispatch-parse.sh — dispatch.sh 参数解析模块
# v3.4.0 从 dispatch.sh 拆分

set -uo pipefail

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------
dispatch_show_help() {
    cat << 'EOF'
用法: ./dispatch.sh [N] "任务" | --wait [--timeout S] | --aggregate
  N           并行数(默认3)
  --wait      等待完成
  --timeout   超时秒(默认300)
  --aggregate 聚合结果
EOF
}

#------------------------------------------------------------------------------
# 参数解析
#------------------------------------------------------------------------------
parse_args() {
    EXECUTE_MODE=false
    WAIT_MODE=false
    AGGREGATE_MODE=false
    WAIT_TIMEOUT=300

    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        dispatch_show_help
        exit 0
    fi

    local args=()
    local skip_next=false
    local timeout_next=false
    for arg in "$@"; do
        if [ "$skip_next" = true ]; then
            skip_next=false
            continue
        fi
        if [ "$timeout_next" = true ]; then
            WAIT_TIMEOUT="$arg"
            timeout_next=false
            continue
        fi
        case "$arg" in
            --execute)
                EXECUTE_MODE=true
                ;;
            --wait)
                WAIT_MODE=true
                ;;
            --aggregate)
                AGGREGATE_MODE=true
                ;;
            --timeout)
                timeout_next=true
                ;;
            *)
                args+=("$arg")
                ;;
        esac
    done

    if [ "$AGGREGATE_MODE" = true ] || [ "$WAIT_MODE" = true ]; then
        TASK_DESC=""
        PARALLEL_N=0
        return 0
    fi

    if [ ${#args[@]} -eq 0 ]; then
        echo "[dispatch] 错误: 缺少任务描述参数" >&2
        return 1
    fi

    if [[ "${args[0]}" =~ ^[0-9]+$ ]]; then
        PARALLEL_N="${args[0]}"
        args=("${args[@]:1}")
    else
        PARALLEL_N=3
    fi

    TASK_DESC="${args[*]}"

    if [ -z "$TASK_DESC" ]; then
        echo "[dispatch] 错误: 任务描述不能为空" >&2
        exit 1
    fi
}
