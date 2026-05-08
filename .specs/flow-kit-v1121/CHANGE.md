# CHANGE.md — v1.12.1 Enhancement

## Change ID

flow-kit-v1121

## 描述

v1.12 工程完善版本：修复 6 个弱点，专注于标准化与一致性补齐。

## 目标版本

v1.12.1

## 范围清单

### 修改文件（6个）

| 文件                                             | 变更                                  |
| ------------------------------------------------ | ------------------------------------- |
| `flow-kit/phases/7-integration/7-integration.md` | +交接验证门 +回滚命令提示 +占位符说明 |
| `flow-kit/phases/0-change/0-change.md`           | change-id格式统一 +占位符说明         |
| `flow-kit/flow-kit.sh`                           | help输出增加map-codebase和share示例   |
| `flow-kit/VERSION`                               | v1.12.1                               |
| `flow-kit/CLAUDE.md`                             | v1.12.1                               |
| `flow-kit/README.md`                             | v1.12.1                               |

## 验收标准

1. 7-integration.md 包含交接验证门触发指令和回滚命令提示
2. 0-change.md change-id 格式为 slugified-function-YYYYMMDD
3. flow-kit.sh help 输出含 map-codebase 和 share 示例
4. 0-change.md 和 7-integration.md 含占位符填充说明
5. VERSION 内容为 v1.12.1
6. CLAUDE.md 第一行含 v1.12.1
7. README.md 版本号更新为 v1.12.1

## 执行策略

L0 极简模式：小修改直接执行，无需完整流程。

1. 修改 7-integration.md（+交接验证门 +回滚提示 +占位符说明）
2. 修改 0-change.md（change-id格式 +占位符说明）
3. 修改 flow-kit.sh（help示例）
4. 更新版本号
