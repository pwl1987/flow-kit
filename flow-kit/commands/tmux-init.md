# /flow-kit:tmux-init

创建 tmux 并行开发环境。初始化 git worktrees + tmux 会话。

## 使用场景

- 多模块并行开发
- 隔离的开发环境
- 大型功能分 worker 并行

## 执行步骤

1. 前置检查（tmux ≥ 2.0、git）
2. 创建 N 个 git worktrees（隔离文件系统）
3. 创建 tmux 会话（每个 worker 一个窗口）
4. 写入 manifest 文件

## 参数

- `--name <名称>` — tmux 会话名称
- `--worktrees <N>` — worktree 数量（默认 2）
- `--base <分支>` — 基础分支（默认 HEAD）

---

**版本**: v3.3.0
**脚本**: `flow-kit/scripts/tmux-init.sh`
