> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本命令管理 Claude Code 原生 hooks 的安装、配置和调试。

## 执行 /flow-kit:hooks

### 什么是 hooks？

Hooks 是 Claude Code 的原生扩展机制，在特定生命周期事件上自动执行：

- **PreToolUse**：工具调用执行前（可阻断）
- **PostToolUse**：工具调用成功后
- **Stop**：主代理完成响应前（可阻断）
- **SessionStart**：会话开始/恢复/压缩后
- **Notification**：需要用户关注时

### flow-kit 内置的 5 个 hooks

| Hook         | 文件                   | 功能                           |
| ------------ | ---------------------- | ------------------------------ |
| PreToolUse   | `pre-tool-guard.sh`    | 阻止危险命令和敏感文件编辑     |
| PostToolUse  | `post-edit-format.sh`  | 自动格式化代码                 |
| Stop         | `stop-quality-gate.sh` | 质量门禁（测试不通过阻止停止） |
| SessionStart | `session-start.sh`     | 自动注册斜杠命令               |
| Notification | `notification.sh`      | 桌面通知                       |

### 安装方式

#### 自动安装（推荐）

```bash
# 赋予脚本执行权限
chmod +x flow-kit/hooks/*.sh

# 在 Claude Code 中执行
/flow-kit:hooks install
```

#### 手动安装

1. 复制 `flow-kit/hooks/` 目录到项目根目录
2. 复制 `.claude/settings.json` 到项目根目录的 `.claude/` 目录
3. 重启 Claude Code

### 调试命令

```bash
# 查看已注册的 hooks
/hooks

# 查看 hooks 状态
/flow-kit:hooks status

# 单独测试某个 hook
./flow-kit/hooks/pre-tool-guard.sh
```

### 团队共享

将以下文件提交到 Git 仓库：

- `flow-kit/hooks/` 目录（所有 .sh 脚本）
- `.claude/settings.json`

团队成员 clone 后自动继承相同的 hooks 保护。

### FAQ

**Q: Stop hook 造成无限循环？**
A: 确保 `stop-quality-gate.sh` 中检查了 `stop_hook_active` 字段，为 `true` 时直接 `exit 0`。

**Q: hooks 不生效？**
A: 检查 `.claude/settings.json` 路径是否正确，以及脚本是否有执行权限（`chmod +x`）。

**Q: 如何禁用某个 hook？**
A: 在 `.claude/settings.json` 中注释掉对应的 hook 配置，或删除其 hook 条目。

---

## 参考来源

- [Claude Code Hooks 官方文档](https://docs.anthropic.com/en/docs/claude-code/hooks) — hooks 机制
- [garrytan/gstack](https://github.com/garrytan/gstack) — /careful 破坏性命令警告模式
- [smallnest/autoresearch](https://github.com/smallnest/autoresearch) — PASSING_SCORE 质量门禁思想
