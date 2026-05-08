# CHANGE.md — v1.11 Enhancement

## Change ID

flow-kit-v111

## 描述

v1.10 五个薄弱环节修复 + rihebty R8.3 产物自检 + OMC 模式切换命令 + GSD 返回重索引 + CLI 脚本入口。

## 目标版本

v1.11

## 范围清单

### 修改文件（10个）

| 文件                                     | 变更                                                                     |
| ---------------------------------------- | ------------------------------------------------------------------------ |
| `flow-kit/commands/hooks-guide.md`       | 参考来源替换为 Anthropic 官方 + garrytan/gstack + smallnest/autoresearch |
| `flow-kit/phases/4-dev.md`               | 阶段切换处嵌入交接验证门触发指令                                         |
| `flow-kit/phases/5-test.md`              | 阶段切换处嵌入交接验证门触发指令                                         |
| `flow-kit/phases/6-review.md`            | 阶段切换处嵌入交接验证门触发指令                                         |
| `flow-kit/GO.md`                         | +/flow-kit:mode 命令路由 (autopilot/team/ralph)                          |
| `flow-kit/lib/phase-executor.md`         | 阶段完成后触发 output-self-check 自检                                    |
| `flow-kit/commands/register-commands.md` | map-codebase 增强：返回重索引逻辑                                        |
| `flow-kit/VERSION`                       | v1.11                                                                    |
| `flow-kit/CLAUDE.md`                     | v1.11                                                                    |
| `flow-kit/README.md`                     | +v1.11 changelog                                                         |

### 新增文件（2个）

| 文件                                   | 描述                          |
| -------------------------------------- | ----------------------------- |
| `flow-kit/skills/output-self-check.md` | R8.3 产物自检清单（6 项检查） |
| `flow-kit/flow-kit.sh`                 | CLI 入口脚本                  |

## 验收标准

1. hooks-guide.md 参考来源完整（非占位符，含 Anthropic 官方链接）
2. 4-dev/5-test/6-review 阶段切换处嵌入交接验证门触发指令
3. GO.md 含 /flow-kit:mode 命令路由
4. output-self-check.md 含 6 项自检清单
5. phase-executor.md 含 output-self-check 触发逻辑
6. map-codebase 含返回重索引逻辑
7. flow-kit.sh 可执行且含命令路由映射
8. VERSION/CLAUDE.md/README.md 含 v1.11

## 执行策略

### Phase 1: 策略分析（读取现状）

- 读取 4-dev.md、5-test.md、6-review.md 阶段切换点
- 读取 phase-executor.md 阶段完成逻辑
- 读取 register-commands.md map-codebase 实现

### Phase 2: 并行创建新文件

- output-self-check.md（6 项自检清单）
- flow-kit.sh（CLI 入口脚本）

### Phase 3: 修改现有文件

- hooks-guide.md 参考来源
- 4-dev/5-test/6-review 交接验证门
- GO.md /flow-kit:mode
- phase-executor.md 自检触发
- register-commands.md 重索引

### Phase 4: 版本号更新

- VERSION、CLAUDE.md、README.md

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit) — R8.3 产物自检清单
- [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — CLI 双入口 + 8 种编排模式
- [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) — /gsd-map-codebase 返回重索引
- [garrytan/gstack](https://github.com/garrytan/gstack) — /careful 破坏性命令警告
- [smallnest/autoresearch](https://github.com/smallnest/autoresearch) — PASSING_SCORE 质量门禁
