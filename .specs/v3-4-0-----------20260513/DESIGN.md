# 架构设计

## 变更 ID

v3-4-0-----------20260513

## 技术方案

### R1: session-state.sh 双重 fallback 修复

**文件**: `lib/session-state.sh` `_ss_ensure()` 函数

合并为单路径：检查文件存在 → 尝试 migrate → 创建 skeleton。消除 `_ss_migrate` 冗余调用。

### R2: security-scanner.sh 日志覆盖修复

**文件**: `lib/security-scanner.sh` L27-30

命名空间前缀替代覆盖：`log_info` → `scan_info`、`log_warn` → `scan_warn`、`log_error` → `scan_error`、`log_debug` → `scan_debug`。全局替换 11 处内部调用。

### R3: paths.sh 路径重复消除

**文件**: `lib/paths.sh` `rotate_logs()` 函数

扩展为 5 参数：`rotate_logs <dir> <keep> <size_mb> <archive_subdir> <log_pattern>`。消除硬编码 `"archive"` 和 `"*.log"`。

### R4: dispatch.sh 职责拆分

**文件**: `scripts/dispatch.sh` → 3 文件

| 文件                | 行数 | 职责                         |
| ------------------- | ---- | ---------------------------- |
| `dispatch.sh`       | 867  | 编排入口 + 子进程管理 + 聚合 |
| `dispatch-parse.sh` | 90   | 参数解析 + 帮助              |
| `dispatch-lock.sh`  | 89   | 锁冲突检测 + 并发池控制      |

### R5: phase-executor.sh 函数提取

**文件**: `tests/test-phase-executor.sh`

`get_project_type()` 和 `load_workflow()` 已为独立函数。新增 `test_load_workflow_brownfield` 测试。

### R6: CODING-STANDARDS.md

**文件**: `CODING-STANDARDS.md`（新建）

覆盖命名/注释/架构/编码 4 类规范。

### R7: ShellCheck error 全量修复

**文件**: 全局 `.sh`

扫描 `shellcheck --format=json ./**/*.sh`，按 SC2086/SC2155/SC2034 模式批量修复。

### R8: jq 调用优化

**文件**: `scripts/dispatch.sh` `execute_subagents` + `collect_results`

一次 `cat "$file"` → 变量 `$data`，后续 `echo "$data" | jq` 复用。减少同文件 jq 调用从 3→2。

## 回滚方案

所有改动可通过 git revert 单文件回滚。拆分文件（dispatch-parse/lock）删除即回退。无数据迁移风险。
