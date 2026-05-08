# CHANGE.md — v1.12 Enhancement

## Change ID

flow-kit-v112

## 描述

增强 CLI 帮助与状态显示，固化 output-self-check 为可执行检查，agent-pipeline 交接验证失败自动修复，新增团队共享安装命令。

## 目标版本

v1.12

## 范围清单

### 修改文件（5个）

| 文件                                   | 变更                            |
| -------------------------------------- | ------------------------------- |
| `flow-kit/flow-kit.sh`                 | +help/status/share 子命令       |
| `flow-kit/GO.md`                       | /flow-kit:mode 确认提示         |
| `flow-kit/skills/output-self-check.md` | 6项检查增加可执行命令示例       |
| `flow-kit/skills/agent-pipeline.md`    | 验证失败自动修复循环（最多2轮） |
| `flow-kit/VERSION`                     | v1.12                           |
| `flow-kit/CLAUDE.md`                   | v1.12                           |
| `flow-kit/README.md`                   | +v1.12 changelog                |

### 新增文件（1个）

| 文件                                 | 描述             |
| ------------------------------------ | ---------------- |
| `flow-kit/commands/share-install.md` | 团队共享安装命令 |

## 验收标准

1. `flow-kit.sh help` 输出使用示例
2. `flow-kit.sh status` 显示当前模式
3. `/flow-kit:mode` 切换后有确认提示
4. `output-self-check.md` 含可执行命令示例
5. `agent-pipeline.md` 验证失败自动修复（最多2轮）
6. `/flow-kit:share-install` 输出团队安装指令
7. VERSION/CLAUDE.md/README.md 含 v1.12

## 执行策略

### Phase 1: 读取现状

- 读取 flow-kit.sh 现有命令结构
- 读取 agent-pipeline.md 验证逻辑

### Phase 2: 并行创建/修改

- share-install.md（新文件）
- flow-kit.sh（+help/status/share）
- output-self-check.md（+可执行命令）
- agent-pipeline.md（+自动修复循环）

### Phase 3: GO.md /flow-kit:mode 确认提示

### Phase 4: 版本号更新

- VERSION、CLAUDE.md、README.md

## 参考来源

- [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — CLI 帮助与状态显示
- [rihebty/flow-kit](https://github.com/rihebty/flow-kit) — 交接验证失败自动修复
