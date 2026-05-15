# 常见问题解决方案

## 安装问题

### 命令注册失败
**原因**：generate-commands.sh 执行权限不足
**解决**：`chmod +x scripts/generate-commands.sh && ./scripts/generate-commands.sh --force`

### jq 未安装
**原因**：缺少 JSON 处理工具
**解决**：`brew install jq` (macOS) / `apt install jq` (Linux)

## 运行时问题

### hooks 不执行
**原因**：Claude Code hooks 配置错误
**解决**：检查 `.claude/settings.json` 中的 hooks 配置，参考 `flow-kit/hooks/hooks-guide.md`

### session-state.json 损坏
**原因**：并发写入导致 JSON 格式错误
**解决**：删除 `.flow-kit/session-state.json` 并重新初始化

## 测试问题

### 测试超时
**原因**：子进程未正常退出
**解决**：检查 `CHILD_PIDS` 清理逻辑，手动 kill 残留进程

### 跨平台测试失败
**原因**：GNU/BSD 工具差异
**解决**：使用 time-utils.sh 中的兼容函数