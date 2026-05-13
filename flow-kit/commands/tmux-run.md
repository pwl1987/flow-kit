# /flow-kit:tmux-run

在 tmux 会话中按 DAG 顺序并行执行任务。

## 执行步骤

1. 读取 manifest + 任务文件
2. DAG 拓扑排序（依赖解析 + 环检测）
3. 按层级并行发送命令到 tmux panes
4. 轮询检测完成状态

## 任务文件格式

```json
[
  { "name": "task1", "pane": 1, "command": "echo hello", "wait_for": [] },
  { "name": "task2", "pane": 2, "command": "echo world", "wait_for": ["task1"] }
]
```

## 参数

- `--tasks <文件>` — 任务文件（JSON）
- `--timeout <秒>` — 超时（默认 600）
- `--session <名称>` — tmux 会话名称

---

**版本**: v3.3.0
**脚本**: `flow-kit/scripts/tmux-run.sh`
