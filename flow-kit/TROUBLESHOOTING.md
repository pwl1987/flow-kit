# 常见问题解决方案

## 安装问题

### 命令注册失败

**原因**: generate-commands.sh 执行权限不足
**解决**: `chmod +x scripts/generate-commands.sh && ./scripts/generate-commands.sh --force`

### jq 未安装

**原因**: 缺少 JSON 处理工具
**解决**: `brew install jq` (macOS) / `apt install jq` (Linux)

### 命令未显示

**原因**: .claude/commands/ 未生成
**解决**: 运行 `/flow-kit:register-commands`

## 运行时问题

### session-state.json 损坏

**原因**: 并发写入或异常退出
**解决**: `rm .flow-kit/session-state.json`，重新 `/flow-kit:phase-0`

### hooks 不执行

**原因**: .claude/settings.json 配置错误
**解决**: 检查 settings.json 中 hooks 段，确认路径正确

### dispatch.sh 超时

**原因**: 子进程未正常退出
**解决**: 检查 CHILD_PIDS 清理逻辑，`kill $(cat .flow-kit/tmp/subagent-*.pid)`

### 护栏拦截合法操作

**原因**: pre-tool-guard 误判
**解决**: 检查 hooks/pre-tool-guard.sh 规则，临时用 `--no-verify`

## 测试问题

### 测试超时

**原因**: 子进程残留
**解决**: `pkill -f 'bash.*test-'` 清理

### 跨平台失败

**原因**: GNU/BSD 工具差异 (date/stat/find)
**解决**: 使用 time-utils.sh 兼容函数

### ShellCheck 误报

**原因**: readonly SCRIPT_DIR 模式
**解决**: .shellcheckrc 已全局禁用 SC2155
