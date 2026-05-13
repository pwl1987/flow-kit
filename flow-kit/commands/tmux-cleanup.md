# /flow-kit:tmux-cleanup

清理 tmux 并行开发环境。终止会话 + 移除 worktrees + 删除 manifest。

## 参数

- `--force` — 跳过确认（非 TTY 必需）
- `--keep-worktrees` — 仅清理 tmux，保留 worktrees
- `--session <名称>` — tmux 会话名称

---

**版本**: v3.3.0
**脚本**: `flow-kit/scripts/tmux-cleanup.sh`
