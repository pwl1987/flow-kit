# /flow-kit:tmux-aggregate

聚合 tmux 并行执行结果，检测文件冲突，生成报告。

## 执行步骤

1. 读取 manifest，遍历 worktrees
2. 收集各 worker 状态 + 修改文件
3. 检测跨 worker 文件冲突
4. 生成格式化报告

## 参数

- `--format console|md|json` — 输出格式（默认 console）
- `--session <名称>` — tmux 会话名称

---

**版本**: v3.3.0
**脚本**: `flow-kit/scripts/tmux-aggregate.sh`
