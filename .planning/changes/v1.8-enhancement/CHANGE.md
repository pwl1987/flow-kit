# CHANGE.md — v1.8 Enhancement

## Change ID
v1.8-enhancement

## 描述
补齐 rihebty/flow-kit 新增的 R4.5-R4.6 生产安全规则，同时将 flow-kit 现有自动化能力封装为 Claude Code 原生 hooks，实现从"AI 自觉遵守规则"到"系统层强制约束"的跃迁。

## 目标版本
v1.8

## 范围清单

### 新增文件（6个）

| 文件 | 描述 | 来源 |
|------|------|------|
| `flow-kit/hooks/pre-tool-guard.sh` | PreToolUse hook：阻止危险命令和敏感文件编辑 | gstack + Morph |
| `flow-kit/hooks/post-edit-format.sh` | PostToolUse hook：自动格式化代码 | Claude Code hooks 社区 |
| `flow-kit/hooks/stop-quality-gate.sh` | Stop hook：质量门禁（测试不通过阻止停止） | autoresearch |
| `flow-kit/hooks/session-start.sh` | SessionStart hook：自动注册斜杠命令 | flow-kit register-commands |
| `flow-kit/hooks/notification.sh` | Notification hook：桌面通知 | Claude Code hooks 社区 |
| `flow-kit/commands/hooks-guide.md` | Hooks 完整使用指南 | — |

### 修改文件（2个）

| 文件 | 变更 |
|------|------|
| `config/system-rules.md` | +R4.5 Schema变更必伴随迁移文件 +R4.6 破坏性变更高门槛 |
| `GO.md` | +/flow-kit:hooks 命令路由 + 启动时 hooks 安装检测 |

### 新增配置（1个）

| 文件 | 描述 |
|------|------|
| `.claude/settings.json` | 注册 5 个 hooks 的完整配置 |

## 验收标准

1. `config/system-rules.md` 包含 R4.5 和 R4.6
2. `flow-kit/hooks/` 目录存在且 5 个脚本可执行
3. `.claude/settings.json` 注册了 5 个 hook（PreToolUse/PostToolUse/Stop/SessionStart/Notification）
4. `commands/hooks-guide.md` 存在
5. `GO.md` 包含 /flow-kit:hooks 命令路由
6. 所有新增文件含「参考来源」段落

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit/blob/main/RULES.md) — R4.5 Schema变更必伴随迁移文件 + R4.6 破坏性变更高门槛
- [Claude Code Hooks 官方文档](https://docs.anthropic.com/en/docs/claude-code/hooks) — hooks 机制
- [Morph: Claude Code Hooks](https://www.morphllm.com/claude-code-hooks) — 最佳实践
- [garrytan/gstack](https://github.com/garrytan/gstack) — /careful 破坏性命令警告
- [smallnest/autoresearch](https://github.com/smallnest/autoresearch) — PASSING_SCORE 质量门禁