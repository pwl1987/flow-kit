---
title: "Claude Code 钩子 | 技术文档"
source: "https://api.leagsoft.ai/aicodex-docs/ai-cli/claude/hooks.html"
author:
published:
created: 2026-05-15
description: "技术文档网站"
tags:
  - "clippings"
---
## Claude Code 钩子

Claude Code 钩子是用户定义的 shell 命令，在 Claude Code 生命周期的各个点执行。钩子提供对 Claude Code 行为的确定性控制。

## 钩子的示例用例

- 在编辑后自动格式化代码
- 记录 Claude 运行的命令
- 阻止对敏感文件的编辑
- 发送通知

## 钩子事件概述

| 事件 | 描述 |
| --- | --- |
| PreToolUse | 在工具调用之前运行 |
| PostToolUse | 在工具成功完成后运行 |
| Notification | 在 Claude Code 发送通知时运行 |
| UserPromptSubmit | 在用户提交提示时运行 |
| Stop | 在主 Claude Code 代理完成响应时运行 |
| SubagentStop | 在子代理完成响应时运行 |
| PreCompact | 在压缩操作之前运行 |
| SessionStart | 在会话启动时运行 |
| SessionEnd | 在会话结束时运行 |

## 快速入门

### 步骤 1：打开钩子配置

运行 `/hooks` 斜杠命令并选择 `PreToolUse` 钩子事件。

### 步骤 2：添加匹配器

选择 `+ Add new matcher…` 并输入 `Bash` 。

### 步骤 3：添加钩子

选择 `+ Add new hook…` 并输入命令：

```bash
jq -r '.tool_input.command' >> ~/claude-commands.log
```

### 步骤 4：保存您的配置

选择 `User settings` 作为存储位置。

### 步骤 5：验证您的钩子

运行 `/hooks` 或检查 `~/.claude/settings.json` ：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' >> ~/claude-commands.log"
          }
        ]
      }
    ]
  }
}
```

## 更多示例

### 代码格式化钩子

在编辑后自动格式化 TypeScript 文件：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write \"$CLAUDE_FILE_PATH\""
          }
        ]
      }
    ]
  }
}
```

### 自定义通知钩子

当 Claude 需要输入时获得桌面通知：

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude needs input\"'"
          }
        ]
      }
    ]
  }
}
```

### 文件保护钩子

阻止对敏感文件的编辑：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_FILE_PATH\" | grep -q '.env'; then exit 2; fi"
          }
        ]
      }
    ]
  }
}
```

## 钩子输入

钩子通过 stdin 接收包含会话信息和事件特定数据的 JSON 数据。

### PreToolUse 输入

```json
{
  "session_id": "abc123",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test"
  }
}
```

## 钩子输出

### 简单：退出代码

- 退出代码 0：成功，继续
- 退出代码 2：阻止操作，向 Claude 显示 stderr
- 其他退出代码：失败，继续

### 高级：JSON 输出

```json
{
  "decision": "block",
  "reason": "Cannot edit .env files"
}
```

## 安全考虑

- 在将任何 hook 命令添加到您的配置之前，始终审查并理解它们
- 验证和清理输入
- 始终引用 shell 变量
- 使用绝对路径
- 跳过敏感文件

## 调试

```bash
# 使用调试模式运行
claude --debug
```