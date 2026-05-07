# CHANGE.md — v1.9 Enhancement

## Change ID

v1.9-enhancement

## 描述

v1.8 查漏补缺 + 吸收 rihebty/GSD/OMC 极简模式：

- 补 v1.8 PRD 遗漏（hooks 路由注册、启动检测、参考来源、版本号）
- 吸收 rihebty 整链路预算 + LESSONS 提名剪枝机制
- 吸收 GSD 存量代码索引 + OMC 一键启动极简配置

## 目标版本

v1.9

## 范围清单

### 修改文件（8个）

| 文件                            | 变更                                                             |
| ------------------------------- | ---------------------------------------------------------------- |
| `GO.md`                         | +/flow-kit:hooks 路由 + hooks 启动检测 + 整链路预算 + 三路线选择 |
| `CLAUDE.md`                     | 版本号更新为 v1.9                                                |
| `hooks/pre-tool-guard.sh`       | +参考来源段落                                                    |
| `hooks/post-edit-format.sh`     | +参考来源段落                                                    |
| `hooks/stop-quality-gate.sh`    | +参考来源段落                                                    |
| `hooks/session-start.sh`        | +参考来源段落                                                    |
| `hooks/notification.sh`         | +参考来源段落                                                    |
| `templates/LESSONS.md.template` | +提名条件与复核剪枝机制                                          |
| `skills/team-dispatch.md`       | +一键启动说明                                                    |
| `commands/register-commands.md` | +/flow-kit:map-codebase 子命令                                   |
| `README.md`                     | +v1.9 changelog                                                  |

## 验收标准

1. GO.md 包含 /flow-kit:hooks 路由和 hooks 安装状态启动检测
2. GO.md 包含整链路预算 + 三路线选择输出模板
3. GO.md 版本标注为 v1.9
4. 5 个 .sh 文件末尾含 ## 参考来源段落
5. CLAUDE.md 版本号为 v1.9
6. LESSONS.md.template 含提名条件与复核剪枝机制
7. team-dispatch.md 含一键启动说明
8. register-commands.md 含 /flow-kit:map-codebase 子命令
9. README.md 含 v1.9 changelog

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit) — 整链路预算 + LESSONS 提名剪枝
- [gsd-build/get-shit-done](https://github.com/gsd-build/get-shit-done) — 存量代码索引
- [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — 一键启动极简配置
