# 任务列表

## 变更 ID

v3-4-0-----------20260513

## 任务概览

R1-R5、R8 已在 Phase 2 实施完成。剩余 R6、R7 及验证任务。

---

## 已完成任务

### T1: R1 session-state.sh fallback 修复 ✅

**文件**: `lib/session-state.sh`
**描述**: `_ss_ensure()` 单路径化，消除 `_ss_migrate` 冗余调用
**验收**: `session_get` 在无 session-state.json 时正确初始化

### T2: R2 security-scanner.sh 日志覆盖修复 ✅

**文件**: `lib/security-scanner.sh`
**描述**: `log_info/log_warn/log_error/log_debug` → `scan_info/scan_warn/scan_error/scan_debug`
**验收**: `source lib/security-scanner.sh && type log_info` 指向 error-handler.sh

### T3: R3 paths.sh rotate_logs 参数化 ✅

**文件**: `lib/paths.sh`
**描述**: `rotate_logs` 扩展为 5 参数，archive 子目录和日志模式可配置
**验收**: `rotate_logs /tmp/logs 5 2 archive "*.log"` 无报错

### T4: R4 dispatch.sh 职责拆分 ✅

**文件**: `scripts/dispatch.sh`, `scripts/dispatch-parse.sh`(新), `scripts/dispatch-lock.sh`(新)
**描述**: 拆分参数解析(90行) + 锁管理(89行)，dispatch.sh 1041→867行
**验收**: `run-tests.sh` 全通过

### T5: R5 phase-executor 测试覆盖 ✅

**文件**: `tests/test-phase-executor.sh`
**描述**: 新增 `load_workflow` 测试用例
**验收**: 8 项测试全通过

### T6: R8 jq 调用优化 ✅

**文件**: `scripts/dispatch.sh`
**描述**: 同一 JSON 文件 `cat` 一次，后续 `echo "$data" | jq` 复用
**验收**: 同文件 jq 调用 ≤2 次

---

## 待执行任务

### T7: R6 CODING-STANDARDS.md [P1]

**模块**: 文档
**描述**: 创建 `CODING-STANDARDS.md`，覆盖命名/注释/架构/编码 4 类规范
**估计**: 15 分钟
**依赖**: 无
**可并行**: [P]
**验收**: 文件存在，包含 4 类规范章节

### T8: R7 ShellCheck error 全量修复 [P1]

**模块**: 全局 `.sh` 文件
**描述**: `shellcheck --format=json ./**/*.sh` 扫描并修复所有 error 级别问题
**估计**: 45 分钟
**依赖**: 需安装 shellcheck
**可并行**: 否（前置：安装 shellcheck）
**验收**: `find . -name '*.sh' | xargs shellcheck` 无 error
**常见修复模式**:

- SC2086: 双引号变量
- SC2155: `local var=$(cmd)` 分开声明
- SC2034: 未使用变量删除

### T9: 验证 — R4 验收标准修正 [P0]

**模块**: scripts/
**描述**: R4 验收标准要求 dispatch.sh <150 行，当前 867 行。需确认原始需求是否有误（实际拆出了 parse+lock 但核心 867 行含子进程管理和聚合逻辑，无法进一步压缩到 150）
**估计**: 5 分钟
**依赖**: 无
**可并行**: [P]
**决策**: 调整验收标准为 "总代码分 3 文件，主入口 <900 行" 或继续拆分

### T10: 集成验证 — 全量测试 [P0]

**模块**: tests/
**描述**: 完整运行 `bash tests/run-tests.sh`，确认 61+ 测试全通过
**估计**: 5 分钟
**依赖**: T7, T8, T9
**可并行**: 否
**验收**: 0 failures

### T11: DESIGN.md 填充 [P1]

**模块**: .specs/
**描述**: 将 plan 文件中的架构方案写入 DESIGN.md
**估计**: 10 分钟
**依赖**: 无
**可并行**: [P]
**验收**: DESIGN.md 包含 R1-R8 技术方案

### T12: 版本更新 [P0]

**模块**: VERSION, CLAUDE.md
**描述**: VERSION → v3.4.0，CLAUDE.md 更新版本号和变更日志
**估计**: 5 分钟
**依赖**: T10
**可并行**: 否
**验收**: `cat flow-kit/VERSION` 显示 3.4.0

---

## 任务依赖图

```
T7 ─────────────────┐
T8 ─────────────────┤
T9 ─────────────────┼──→ T10 ──→ T12
T11 ────────────────┘
```

## 关键路径

T8 (ShellCheck 修复) → T10 (集成验证) → T12 (版本更新)

## 并行组

**组 A** (可同时执行): T7, T8, T9, T11
**组 B** (串行): T10 → T12

## 风险标记

- **T8**: 高风险 — shellcheck 修复可能引入新 bug，需逐个验证
- **T9**: 中风险 — 验收标准调整需确认利益相关方意图
