# lib/ — 库模块目录

flow-kit 核心 Shell 库，按职责分为 7 个分组。

## 错误处理

| 文件 | 职责 |
|------|------|
| `error-handler.sh` | 统一错误码、日志函数、trap 信号处理 |
| `cleanup.sh` | 临时文件/目录注册与清理 |
| `preflight.sh` | 运行环境预检 |

## 会话管理

| 文件 | 职责 |
|------|------|
| `session-state.sh` | 会话状态 JSON 读写 |
| `paths.sh` | 统一路径常量 |
| `front-matter.sh` | YAML front matter 解析 |

## 验证

| 文件 | 职责 |
|------|------|
| `conflict-detector.sh` | 冲突检测逻辑 |
| `context-budget.sh` | 上下文预算管理 |
| `token-estimator.sh` | Token 用量估算 |

## 检测

| 文件 | 职责 |
|------|------|
| `project-info.sh` | 项目类型检测（棕地/绿地） |
| `security-scanner.sh` | 安全风险扫描 |
| `expiry-checker.sh` | 上下文过期检测 |

## 质量

| 文件 | 职责 |
|------|------|
| `metrics-logger.sh` | JSONL 指标日志（v3.7.0） |
| `health-rotation.sh` | 健康检查与日志轮转 |
| `cost-reporter.sh` | 成本报告生成 |

## 格式化

| 文件 | 职责 |
|------|------|
| `context-updater.sh` | 上下文变更日志更新 |
| `pr-generator.sh` | PR 描述生成 |
| `time-utils.sh` | 时间工具函数 |

## 依赖关系

```
paths.sh ← (所有模块)
error-handler.sh ← cleanup.sh, preflight.sh
session-state.sh ← front-matter.sh
metrics-logger.sh ← (独立，仅依赖 paths.sh 的 LOGS_DIR)
```
