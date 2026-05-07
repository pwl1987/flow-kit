# tmux-orchestrator

> 【CLAUDE CODE INSTRUCTION 强制约束】

tmux 工作区编排命令，实现并行开发"导演"模式。

## 命令列表

### 1. `/flow-kit:tmux-init` — 初始化 tmux 工作区

```bash
# 初始化 tmux 工作区
/flow-kit:tmux-init [--name <session-name>] [--worktrees <count>]
```

**功能：**
- 为当前 change 创建 git worktrees
- 创建 tmux 会话布局（每个工作区一个窗格）
- 输出工作区状态报告

**参数：**
- `--name` — tmux 会话名称（默认：`flow-kit-{timestamp}`）
- `--worktrees` — 工作区数量（默认：CPU 核心数）

**输出：**
```
tmux 工作区初始化完成
├── 会话: flow-kit-20240101-120000
├── 工作区: 4
├── 主仓库: /data/Code/flow-kit
└── 状态: READY
```

---

### 2. `/flow-kit:tmux-run` — 启动并行任务

```bash
# 向所有窗格发送任务指令
/flow-kit:tmux-run [--tasks <task-file>] [--parallel]
```

**功能：**
- 向每个 tmux 窗格发送对应的任务指令
- 启动独立 Claude Code 会话
- 显示所有会话状态

**参数：**
- `--tasks` — 任务定义文件（YAML/JSON）
- `--parallel` — 强制并行模式

**任务文件格式：**

```yaml
tasks:
  - name: frontend
    pane: 0
    command: "cd worktree-1 && claude --task 'implement feature X'"
    wait_for: []

  - name: backend
    pane: 1
    command: "cd worktree-2 && claude --task 'implement API Y'"
    wait_for: []

  - name: tests
    pane: 2
    command: "cd worktree-3 && claude --task 'write integration tests'"
    wait_for: [backend]
```

---

### 3. `/flow-kit:tmux-aggregate` — 聚合结果

```bash
# 聚合所有工作区结果
/flow-kit:tmux-aggregate [--format <md|json|console>]
```

**功能：**
- 轮询所有窗格状态
- 收集 SUMMARY.md
- 生成聚合报告

**输出格式：**

```markdown
# 聚合报告 — 2024-01-01 12:00:00

## 工作区状态

| 工作区 | 状态 | 耗时 | 输出 |
|--------|------|------|------|
| frontend | ✅ DONE | 5m | worktree-1/SUMMARY.md |
| backend | ✅ DONE | 7m | worktree-2/SUMMARY.md |
| tests | ⏳ RUNNING | 3m | — |

## 聚合摘要

[从各工作区 SUMMARY.md 提取的关键信息]

## 下一步

[推荐的后续动作]
```

---

### 4. `/flow-kit:tmux-cleanup` — 清理工作区

```bash
# 清理 tmux 工作区
/flow-kit:tmux-cleanup [--force] [--keep-worktrees]
```

**功能：**
- 关闭所有 tmux 会话
- 清理 git worktrees
- 恢复主仓库状态

**参数：**
- `--force` — 强制清理（跳过确认）
- `--keep-worktrees` — 保留 worktrees 只清理 tmux

**警告：** 此操作不可逆，确保已完成聚合。

---

## 与 team-dispatch-parallel.md 联动

### 聚合协议

使用 `team-dispatch-parallel.md` 的聚合协议：

```yaml
aggregation:
  protocol: team-dispatch-parallel
  collect:
    - SUMMARY.md
    - *.log
    - artifacts/
  timeout: 10m
  retry: 3
```

### 依赖分析

借用 `dag-resolver` 的依赖分析：

```yaml
dependency_resolution:
  resolver: dag-resolver
  max_depth: 5
  parallel_branches: 4
  wait_for:
    - upstream_task
  block_on_failure: true
```

### 工作流集成

```
┌─────────────────────────────────────────────────────────┐
│  /flow-kit:tmux-init                                    │
│  └── 创建 worktrees + tmux 会话                         │
├─────────────────────────────────────────────────────────┤
│  /flow-kit:tmux-run                                    │
│  ├── 读取任务文件                                        │
│  ├── 解析 DAG 依赖                                      │
│  └── 并行调度到各窗格                                    │
├─────────────────────────────────────────────────────────┤
│  /flow-kit:tmux-aggregate                              │
│  ├── 轮询状态                                           │
│  ├── 收集 SUMMARY.md                                   │
│  └── 生成聚合报告                                       │
├─────────────────────────────────────────────────────────┤
│  /flow-kit:tmux-cleanup                                │
│  ├── 关闭 tmux 会话                                    │
│  └── 清理 worktrees（除非 --keep-worktrees）            │
└─────────────────────────────────────────────────────────┘
```

---

## 参考来源

- `team-dispatch-parallel.md` — 并行任务分发协议
- `dag-resolver.md` — DAG 依赖解析器
- `.planning/PROJECT.md` — 项目上下文