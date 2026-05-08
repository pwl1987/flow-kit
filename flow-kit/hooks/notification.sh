#!/bin/bash
# notification.sh — Notification hook: 桌面通知
# v1.8 新增
# Reference: Claude Code hooks 社区最佳实践

TITLE="${1:-flow-kit}"
MESSAGE="${2:-Claude Code 需要你的关注}"

# macOS
if command -v osascript &> /dev/null; then
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
# Linux
elif command -v notify-send &> /dev/null; then
    notify-send "$TITLE" "$MESSAGE"
# Windows
elif command -v powershell &> /dev/null; then
    powershell -Command "[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null; [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('flow-kit').Show([Windows.UI.Notifications.ToastNotification]::new([Windows.Data.Xml.Dom.XmlDocument]::new()))" 2>/dev/null || true
fi

exit 0

## 参考来源
- [Claude Code Hooks 官方文档](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [garrytan/gstack](https://github.com/garrytan/gstack) — /careful 破坏性命令警告模式