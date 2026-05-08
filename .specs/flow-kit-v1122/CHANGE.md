# CHANGE.md — v1.12.2 Enhancement

## Change ID

flow-kit-v1122

## 描述

v1.12.2 精度微调版本：动态 change-id 路径 + 项目名自动提取。

## 目标版本

v1.12.2

## 范围清单

### 修改文件（4个）

| 文件                                   | 变更                               |
| -------------------------------------- | ---------------------------------- |
| `flow-kit/skills/output-self-check.md` | 自检命令使用 `$CHANGE_ID` 动态变量 |
| `flow-kit/flow-kit.sh`                 | show_share() 输出自动填充项目名    |
| `flow-kit/VERSION`                     | v1.12.2                            |
| `flow-kit/CLAUDE.md`                   | v1.12.2                            |

## 验收标准

1. output-self-check.md 使用 `$CHANGE_ID` 动态变量
2. flow-kit.sh share 输出自动填充项目名
3. VERSION 内容为 v1.12.2
4. CLAUDE.md 第一行含 v1.12.2

## 执行策略

L0 极简模式，直接执行。

1. 修改 output-self-check.md（动态 change-id）
2. 修改 flow-kit.sh（项目名自动提取）
3. 更新版本号
