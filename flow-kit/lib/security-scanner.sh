#!/bin/bash
# security-scanner.sh — 自动安全扫描
# v1.12.10 新增：扫描硬编码密钥、SQL注入等常见安全问题

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# v1.12.10 修复：复用统一错误处理框架
source "$SCRIPT_DIR/error-handler.sh"

#------------------------------------------------------------------------------
# 配置
#------------------------------------------------------------------------------
SCAN_DIR="${1:-.}"
SEVERITY_THRESHOLD="${SEVERITY_THRESHOLD:-medium}"

# 验证 SCAN_DIR
if [ ! -d "$SCAN_DIR" ]; then
    die "ERR_INVALID_ARGS" "扫描目录不存在: $SCAN_DIR"
fi

#------------------------------------------------------------------------------
# 颜色输出
#------------------------------------------------------------------------------
# 覆盖 error-handler.sh 的日志函数以支持彩色输出和 SCAN_DIR 前缀
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $(basename "$SCAN_DIR"): $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

#------------------------------------------------------------------------------
# 扫描硬编码密钥
#------------------------------------------------------------------------------
scan_hardcoded_secrets() {
    log_info "扫描硬编码密钥..."

    local found=0
    local patterns=(
        'api_key\s*=\s*["'"'"'][^"'"'"'\s]+["'"'"']'
        'secret\s*=\s*["'"'"'][^"'"'"'\s]+["'"'"']'
        'password\s*=\s*["'"'"'][^"'"'"'\s]+["'"'"']'
        'token\s*=\s*["'"'"'][^"'"'"'\s]+["'"'"']'
        'private_key\s*=\s*["'"'"'][^"'"'"'\s]+["'"'"']'
        'AWS_ACCESS_KEY'
        'AWS_SECRET_KEY'
        'sk-[0-9a-zA-Z]{20,}'
    )

    for pattern in "${patterns[@]}"; do
        while IFS= read -r file; do
            local line_num
            line_num=$(grep -n "$pattern" "$file" 2>/dev/null | head -1 | cut -d: -f1 || echo "?")
            log_error "发现疑似密钥: $file:$line_num"
            echo "  Pattern: $pattern"
            found=$((found + 1))
        done < <(grep -rlE "$pattern" --include="*.sh" --include="*.js" --include="*.ts" --include="*.py" --include="*.yaml" --include="*.yml" --include="*.json" "$SCAN_DIR" 2>/dev/null | grep -v node_modules | grep -v '.git' || true)
    done

    if [ "$found" -eq 0 ]; then
        log_info "未发现硬编码密钥"
    fi

    return $found
}

#------------------------------------------------------------------------------
# 扫描 SQL 注入风险
#------------------------------------------------------------------------------
scan_sql_injection() {
    log_info "扫描 SQL 注入风险..."

    local found=0
    local patterns=(
        'execute\s*\(\s*["'"'"'].*\$\{'
        'query\s*\(\s*["'"'"'].*\$\{'
        '\.exec\s*\(\s*["'"'"'].*\$\{'
        'mysql\.query\s*\([^)]*\+'
    )

    for pattern in "${patterns[@]}"; do
        while IFS= read -r file; do
            local matches
            matches=$(grep -n "$pattern" "$file" 2>/dev/null | wc -l || echo 0)
            if [ "$matches" -gt 0 ]; then
                log_warn "发现疑似 SQL 注入风险: $file ($matches 处)"
                found=$((found + 1))
            fi
        done < <(grep -rlE "${patterns[0]}" --include="*.js" --include="*.ts" --include="*.py" "$SCAN_DIR" 2>/dev/null | grep -v node_modules | grep -v '.git' || true)
    done

    if [ "$found" -eq 0 ]; then
        log_info "未发现 SQL 注入风险"
    fi

    return $found
}

#------------------------------------------------------------------------------
# 扫描 XSS 风险
#------------------------------------------------------------------------------
scan_xss() {
    log_info "扫描 XSS 风险..."

    local found=0
    local patterns=(
        'innerHTML\s*='
        'outerHTML\s*='
        'document\.write\s*\('
        'eval\s*\('
    )

    for pattern in "${patterns[@]}"; do
        while IFS= read -r file; do
            local matches
            matches=$(grep -n "$pattern" "$file" 2>/dev/null | wc -l || echo 0)
            if [ "$matches" -gt 0 ]; then
                log_warn "发现疑似 XSS 风险: $file ($matches 处)"
                found=$((found + 1))
            fi
        done < <(grep -rlE "$pattern" --include="*.js" --include="*.ts" --include="*.html" "$SCAN_DIR" 2>/dev/null | grep -v node_modules | grep -v '.git' || true)
    done

    if [ "$found" -eq 0 ]; then
        log_info "未发现 XSS 风险"
    fi

    return $found
}

#------------------------------------------------------------------------------
# 扫描危险 shell 命令
#------------------------------------------------------------------------------
scan_dangerous_shell() {
    log_info "扫描危险 shell 命令..."

    local found=0
    local patterns=(
        'rm\s+-rf\s+/\s*\#'
        ':\(\)\{\s*:\|\:&\s*\}\s*;'
        '>\s*/dev/sda'
        'dd\s+if=.*of=/dev/'
    )

    for pattern in "${patterns[@]}"; do
        while IFS= read -r file; do
            log_error "发现危险命令: $file"
            grep -n "$pattern" "$file" 2>/dev/null | head -3
            found=$((found + 1))
        done < <(grep -rlE "$pattern" --include="*.sh" "$SCAN_DIR" 2>/dev/null | grep -v '.git' || true)
    done

    if [ "$found" -eq 0 ]; then
        log_info "未发现危险 shell 命令"
    fi

    return $found
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    echo "=========================================="
    echo "Security Scanner"
    echo "=========================================="
    echo "Scan directory: $SCAN_DIR"
    echo ""

    local total_issues=0

    scan_hardcoded_secrets || total_issues=$((total_issues + $?))
    scan_sql_injection || total_issues=$((total_issues + $?))
    scan_xss || total_issues=$((total_issues + $?))
    scan_dangerous_shell || total_issues=$((total_issues + $?))

    echo ""
    echo "=========================================="
    if [ "$total_issues" -gt 0 ]; then
        log_error "发现 $total_issues 个安全问题"
        return 1
    else
        log_info "未发现安全问题"
        return 0
    fi
}

main "$@"