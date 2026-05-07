# CHANGE.md — v1.10 Enhancement

## Change ID

v1.10-enhancement

## 描述

v1.9 三个薄弱环节补齐 + rihebty 精度升级 + OMC 双模式入口：

- W1: hooks-guide.md 参考来源占位符 → 补全
- W2: R1.7 增加 rihebty 式强制执行语句
- W3: agent-pipeline 增加三阶段 Agent 交接验证门
- OMC: Autopilot/Team 双模式自动切换入口

## 目标版本

v1.10

## 范围清单

### 修改文件（7个）

| 文件                                | 变更                          |
| ----------------------------------- | ----------------------------- |
| `flow-kit/commands/hooks-guide.md`  | 补全参考来源段落              |
| `flow-kit/config/system-rules.md`   | R1.7 + rihebty 式强制执行语句 |
| `flow-kit/skills/agent-pipeline.md` | +三阶段 Agent 交接验证门      |
| `flow-kit/skills/team-dispatch.md`  | +Task-PRD 对齐检查 + 追责链   |
| `flow-kit/GO.md`                    | +执行模式自动检测             |
| `flow-kit/CLAUDE.md`                | 版本号更新为 v1.10            |
| `flow-kit/README.md`                | +v1.10 changelog              |

### 新增文件（1个）

| 文件               | 描述         |
| ------------------ | ------------ |
| `flow-kit/VERSION` | 版本号 v1.10 |

## 验收标准

1. hooks-guide.md 末尾参考来源完整（非占位符）
2. system-rules.md R1.7 含 rihebty 式强制执行语句
3. agent-pipeline.md 含三阶段 Agent 交接验证门
4. team-dispatch.md 含 Task-PRD 对齐检查与追责链
5. GO.md 含执行模式自动检测（Autopilot/Team）
6. VERSION 内容为 v1.10
7. CLAUDE.md 标注 v1.10
8. README.md 含 v1.10 changelog

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit) — R1.7 任务过大早期信号 + 阶段仲裁验证 + R8.2 追责链
- [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — Autopilot/Team 双模式
- [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) — 三阶段验证门
