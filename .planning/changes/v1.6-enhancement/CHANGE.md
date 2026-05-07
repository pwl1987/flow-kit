# CHANGE.md — v1.6 Enhancement

## Change ID
v1.6-enhancement

## 描述
flow-kit 从"个人利器"升级为"团队协作智能工厂"：
- **Claude Code 斜杠命令闪速注册**：原生 `/命令` 体系支持，`.claude/commands/` 入口文件生成
- **tmux 并行团队作战**：基于 tmux + git worktrees 的并行开发能力深度整合

## 目标版本
v1.6

## 范围清单

### 新增文件（5个）

| 文件 | 描述 | 来源 |
|------|------|------|
| `flow-kit/commands/register-commands.md` | 一键注册斜杠命令，支持 --force/--list | rihebty/flow-kit |
| `flow-kit/commands/generate-commands.md` | 命令生成器底层实现 | alirezarezvani/claude-skills |
| `flow-kit/skills/team-dispatch-parallel.md` | 分治模式+竞争模式+冲突域预检 | agent-of-empires + gstack |
| `flow-kit/commands/tmux-orchestrator.md` | tmux 会话编排（init/run/aggregate） | agent-of-empires |
| `flow-kit/scripts/generate-commands.sh` | Shell 脚本自动扫描生成命令 | rihebty/flow-kit |

### 修改文件（3个）

| 文件 | 变更 |
|------|------|
| `flow-kit/commands/careful.md` | +并发文件锁检测（并行模式下自动全局锁） |
| `flow-kit/GO.md` | +6个新命令路由 + 启动时命令注册状态探测 |
| `flow-kit/commands/skill-audit.md` | +斜杠命令注册状态审计 + benchmark 评分 |
| `flow-kit/CLAUDE.md` | +首次启动引导（提示执行 register-commands） |

## 验收标准

1. `flow-kit/commands/register-commands.md` 存在且支持 --force/--list 参数
2. `flow-kit/commands/generate-commands.md` 存在且支持项目级/用户级输出
3. `flow-kit/skills/team-dispatch-parallel.md` 存在且包含分治模式+竞争模式+冲突域预检
4. `flow-kit/commands/tmux-orchestrator.md` 存在且包含 tmux-init/run/aggregate
5. `flow-kit/commands/careful.md` 包含并发文件锁检测和 /lock /unlock 子命令
6. `flow-kit/GO.md` 包含所有新命令路由
7. `flow-kit/commands/skill-audit.md` 包含斜杠命令注册状态审计
8. `flow-kit/CLAUDE.md` 包含首次启动引导
9. `flow-kit/scripts/generate-commands.sh` 存在且可执行
10. 所有新文件含「参考来源」段落

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit) — 多 IDE 无缝衔接 + 命令快捷方式
- [agent-of-empires](https://github.com/agent-of-empires/agent-of-empires) — tmux + git worktrees 并行开发
- [garrytan/gstack](https://github.com/garrytan/gstack) — Conductor 并行协调
- [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) — SKILL.md 标准化格式
- [yknothing/skills-refiner](https://github.com/yknothing/skills-refiner) — 技能基准评分系统