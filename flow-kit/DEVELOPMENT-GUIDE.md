# flow-kit 开发指南

## 1. 环境配置

### 1.1 系统要求

- macOS >= 12 / Ubuntu >= 22.04 / WSL2
- bash >= 4.0
- jq >= 1.6
- git >= 2.30

### 1.2 安装

```bash
git clone <repo>
cd plugins
/flow-kit:install
```

### 1.3 开发工具

| 工具         | 安装                        | 用途     |
| ------------ | --------------------------- | -------- |
| ShellCheck   | `brew install shellcheck`   | 静态分析 |
| shfmt        | `brew install shfmt`        | 格式化   |
| markdownlint | `npm i -g markdownlint-cli` | 文档检查 |

## 2. 开发规范

遵循 `CODING-STANDARDS.md`：

- 函数 `snake_case`，常量 `UPPER_SNAKE_CASE readonly`
- 仅 WHY 注释
- 必须 source error-handler.sh
- 禁止覆盖日志函数
- `set -euo pipefail`

## 3. 项目结构

```
flow-kit/
├── lib/         # 核心库 (paths, session-state, error-handler, cleanup)
├── scripts/     # 可执行脚本 (dispatch, phase-executor, init-change)
├── hooks/       # Claude Code hooks
├── phases/      # Phase 0-8 工作流
├── skills/      # 技能包
├── guardrails/  # 护栏
├── commands/    # 斜杠命令定义
├── tests/       # 测试
└── config/      # 配置
```

## 4. 调试技巧

### bash -x 追踪

```bash
bash -x flow-kit/scripts/dispatch.sh 3 "test task"
```

### 单元测试

```bash
bash flow-kit/tests/run-tests.sh
```

### ShellCheck

```bash
shellcheck -s bash flow-kit/scripts/my-script.sh
```

### 查看 session 状态

```bash
cat .flow-kit/session-state.json | jq .
```

## 5. Make 命令

```bash
make lint          # ShellCheck 全量扫描
make lint-md       # Markdown 检查
make test          # 运行测试
make format        # shfmt 格式化
make format-check  # 检查格式
```
