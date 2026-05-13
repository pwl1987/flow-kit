#!/bin/bash
set -euo pipefail
# notification.sh — Notification hook: 桌面通知
# v1.8 新增
# v2.7.0 P1 修复: Windows 实现实际发送 Toast 通知 + set -euo pipefail
# Reference: Claude Code hooks 社区最佳实践

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# v2.7.0 修复: 跨平台毫秒时间戳
get_epoch_ms() {
    if date +%s%3N 2>/dev/null | grep -qE '^[0-9]+$'; then
        date +%s%3N
    elif python3 -c "import time; print(int(time.time() * 1000))" >/dev/null 2>&1; then
        python3 -c "import time; print(int(time.time() * 1000))"
    else
        perl -MTime::HiRes -e 'printf "%d\n", int(Time::HiRes::time() * 1000)'
    fi
}

START_TIME=$(get_epoch_ms)

TITLE="${1:-flow-kit}"
MESSAGE="${2:-Claude Code 需要你的关注}"

# v2.7.0 修复：声明变量（不能在函数外使用 local）
ps_script=""

# macOS — 用 -e [参数] 传递，避免字符串拼接注入
if command -v osascript &> /dev/null; then
    osascript -e 'display notification "'"${MESSAGE//\"/\\\"}"'" with title "'"${TITLE//\"/\\\"}"'"'
# Linux
elif command -v notify-send &> /dev/null; then
    notify-send "${TITLE}" "${MESSAGE}"
# Windows - P1 修复：实际发送 Toast 通知
elif command -v powershell &> /dev/null; then
    ps_script=$(mktemp /tmp/notify-XXXXXX.ps1)
    # v2.7.0 安全修复：限制临时文件权限，防止信息泄露
    chmod 600 "${ps_script}" 2>/dev/null || true
    cat > "${ps_script}" << 'PSEOF'
param(
    [string]$Title,
    [string]$Message
)

# 使用 BurntToast 模块（如果已安装）
if (Get-Module -ListAvailable -Name BurntToast) {
    Import-Module BurntToast
    New-BurntToastNotification -Text $Message, $Title -AppLogo "$PSScriptRoot\..\flow-kit-icon.png"
} else {
    # 回退：使用 Windows 原生 API
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    $template = @"
<toast>
    <visual>
        <binding template="ToastText02">
            <text id="1">$Title</text>
            <text id="2">$Message</text>
        </binding>
    </visual>
</toast>
"@
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($template)
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('flow-kit').Show($toast)
}
PSEOF

    if powershell -ExecutionPolicy Bypass -File "${ps_script}" -Title "${TITLE}" -Message "${MESSAGE}" 2>/dev/null; then
        echo "[notification] ✅ Windows Toast 通知已发送"
    else
        echo "[notification] ⚠️ Windows 通知失败，使用回退方案"
        # 回退：使用 PowerShell 弹窗（通过环境变量传递，避免注入）
        NOTIFY_MSG="${MESSAGE}" NOTIFY_TITLE="${TITLE}" \
            powershell -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show(\$env:NOTIFY_MSG, \$env:NOTIFY_TITLE)" 2>/dev/null || true
    fi

    rm -f "${ps_script}"
fi

# hooks 执行遥测
END_TIME=$(get_epoch_ms)
ELAPSED=$((END_TIME - START_TIME))
mkdir -p "${SCRIPT_DIR}/../../.flow-kit/logs"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [notification] [OK] [${ELAPSED}ms]" >> "${SCRIPT_DIR}/../../.flow-kit/logs/hooks-execution.log" 2>/dev/null || true

exit 0

# v2.7.0 修复：URL 放在 bash 注释中避免被解析
# 参考来源：
# - Claude Code Hooks 官方文档：https://docs.anthropic.com/en/docs/claude-code/hooks
# - garrytan/gstack：https://github.com/garrytan/gstack
# - BurntToast PowerShell：https://github.com/Windos/BurntToast
