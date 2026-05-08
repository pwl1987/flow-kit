# CHANGE.md — v1.12.3 Enhancement

## Change ID

flow-kit-v1123

## 描述

v1.12.3 修复 v1.12.2 薄弱环节 + 中文界面升级

## 目标版本

v1.12.3

## 范围清单

### 修改文件（5个）

| 文件                        | 变更                  |
| --------------------------- | --------------------- |
| `CLAUDE.md`                 | 版本号统一为 v1.12.3  |
| `flow-kit.sh`               | 补全 share 命令占位符 |
| `hooks/pre-tool-guard.sh`   | +参考来源段落         |
| `hooks/post-edit-format.sh` | +参考来源段落         |
| `hooks/notification.sh`     | +参考来源段落         |
| `GO.md`                     | 中文界面升级          |
| `VERSION`                   | v1.12.3               |
| `README.md`                 | v1.12.3               |

### 新增文件（5个）

| 文件                                        | 描述         |
| ------------------------------------------- | ------------ |
| `flow-kit/hooks/session-start.sh`           | 会话启动脚本 |
| `flow-kit/hooks/stop-quality-gate.sh`       | 质量门禁脚本 |
| `flow-kit/config/tech-constraints.md`       | 技术栈约束   |
| `flow-kit/config/team-roles.md`             | 团队角色定义 |
| `flow-kit/guardrails/security-checklist.md` | 安全检查清单 |

## 验收标准

1. CLAUDE.md 版本号统一为 v1.12.3
2. hooks/session-start.sh 存在且可执行
3. hooks/stop-quality-gate.sh 存在且可执行
4. config/tech-constraints.md 存在
5. config/team-roles.md 存在
6. guardrails/security-checklist.md 存在且含 YAML 检查清单
7. flow-kit.sh share 输出完整可用
8. 全部 5 个 hooks 脚本均含 ## 参考来源 段落
9. GO.md 启动信息中文化
10. VERSION 内容为 v1.12.3

## 执行策略

L0 极简模式，并行执行。

### Phase 1: 新增文件

- session-start.sh
- stop-quality-gate.sh
- tech-constraints.md
- team-roles.md
- security-checklist.md

### Phase 2: 修改现有文件

- CLAUDE.md
- flow-kit.sh
- hooks/\*.sh 参考来源
- GO.md 中文升级
- VERSION/README.md
