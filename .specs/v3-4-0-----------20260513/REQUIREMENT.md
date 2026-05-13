# 需求文档

## 变更 ID

v3-4-0-----------20260513

## 需求背景

基于 DEVELOPMENT-IMPROVEMENT-PLAN.md v2.0，对 flow-kit v3.3.0 进行系统化代码质量优化与架构重构。目标：ShellCheck error 清零、代码重复率 <5%、核心脚本性能提升 50%+。

## 功能需求

### R1: session-state.sh 双重 fallback 修复 [P0]

**描述**：`_ss_ensure()` 中 `_ss_migrate` 被调用两次，且 fallback 路径冗余
**验收标准**：

- Given session-state.json 不存在
- When 调用 session_get
- Then \_ss_migrate 仅执行一次，无重复调用

### R2: error-handler.sh 日志覆盖检测 [P0]

**描述**：security-scanner.sh 覆盖 log_info/log_warn/log_error/log_debug 4 个函数
**验收标准**：

- Given source error-handler.sh 后 source security-scanner.sh
- When type log_info
- Then 指向 error-handler.sh 的原始实现

### R3: paths.sh 路径重复消除 [P0]

**描述**：路径解析有 2 处独立实现，rotate_logs 函数路径硬编码
**验收标准**：

- Given grep -r 路径定义 lib/
- When 检查重复
- Then 无重复路径定义

### R4: dispatch.sh 职责拆分 [P0]

**描述**：dispatch.sh ~300 行，参数解析+子进程+聚合+锁管理混合
**验收标准**：

- Given dispatch.sh 拆分为 dispatch-core.sh + dispatch-lock.sh + dispatch-parse.sh
- When run-tests.sh
- Then 全部通过，dispatch.sh 行数 <150

### R5: phase-executor.sh 函数提取 [P1]

**描述**：get_project_type() 和 load_workflow() 内联在 main() 中，无法单元测试
**验收标准**：

- Given 提取为独立函数
- When 运行 test-phase-executor.sh
- Then 覆盖 get_project_type() 和 load_workflow()

### R6: CODING-STANDARDS.md [P1]

**描述**：无统一编码规范文档
**验收标准**：

- Given CODING-STANDARDS.md 存在
- When 检查内容
- Then 覆盖命名/注释/架构/编码 4 类规范

### R7: ShellCheck error 全量修复 [P1]

**描述**：约 15 处 ShellCheck error 级别问题
**验收标准**：

- Given find . -name '\*.sh' | xargs shellcheck
- When 检查输出
- Then 无 error 级别输出

### R8: jq 调用优化 [P2]

**描述**：dispatch.sh 中同一 JSON 文件被 jq 解析 5+ 次
**验收标准**：

- Given dispatch.sh 执行路径
- When 统计 jq 调用次数
- Then 同一文件 jq 调用 ≤2 次

## 非功能需求

- 性能：phase-executor.sh <300ms，dispatch.sh <1s/agent
- 安全：无日志函数覆盖，临时文件全部 trap 清理
- 兼容性：macOS (BSD) + Linux (GNU) 双平台

## 边界条件

- 向后兼容：29 个斜杠命令行为不变
- 增量交付：每阶段独立可测试
- 测试门禁：每次提交 run-tests.sh 通过
