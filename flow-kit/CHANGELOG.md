# Changelog

All notable changes to flow-kit will be documented in this file.

## [1.12.17] - 2026-05-10

### P0: 核心脚本修复

- **generate-commands.sh** — 修复 bash 语法错误
  - 修复 `[^"'"'\n]` 字符类语法错误，改为 `[^"'"$'\n']`
  - 修复 `set -euo pipefail` 下 `((x++))` 导致退出码非零问题，改为 `x=$((x + 1))`
  - 现在正确生成全部 24 个斜杠命令

### P1: 命令注册完善

- **斜杠命令注册** — 修复注册流程
  - 修复 generate-commands.sh 退出码问题
  - 成功生成全部 24 个命令文件到 `.claude/commands/`

## [1.12.8] - 2026-05-08

### P0: 核心稳定性修复

- **dispatch.sh** — 移除 set -e + 添加 trap 清理 + 锁冲突 blocking + result validation
  - 移除 set -e 避免与 jq 回退模式冲突
  - 新增 trap EXIT INT TERM 清理子进程，防止 orphaned 进程
  - 锁冲突从警告改为 blocking 等待（30秒超时）
  - 新增 result JSON 有效性验证，避免无效结果导致统计错误
  - 跟踪 CHILD_PIDS 数组用于 trap 清理

- **stop-quality-gate.sh** — 修复除零错误
  - 新增 incremental_lines 为零检查
  - 无新增代码时跳过覆盖率检查并输出提示

- **context-budget.sh** — 修复 grep -oP 移植性问题
  - 使用 awk 替代 grep -oP 实现 POSIX 兼容
  - 支持 Linux/macOS/BSD 多平台

### P1: 跨平台兼容性增强

- **post-edit-format.sh** — prettier 错误写入日志而非丢弃
  - 新增 prettier-errors.log 记录详细错误信息
  - 使用 log_warn 替代 stderr 直接输出

- **notification.sh** — Windows 实际发送 Toast 通知
  - 新增 BurntToast 模块支持（如果已安装）
  - 回退使用 Windows 原生 API 发送 Toast
  - 最终回退使用 PowerShell 弹窗

- **pre-tool-guard.sh** — DDL 正则补全 RENAME TO 格式
  - 支持 ALTER TABLE ... RENAME / RENAME TO / RENAME COLUMN

- **health-rotation.sh** — stat 命令 Linux/BSD 兼容
  - 新增 get_file_size_kb 函数统一处理
  - 检测 stat --version 区分 GNU/BSD 实现

- **error-handler.sh** — POSIX date 回退格式
  - 新增 get_timestamp 函数
  - 支持 GNU date 和 BSD date 两种格式

### P2: 代码规范强化

- **所有 hooks** — 添加 set -euo pipefail
  - post-edit-format.sh / notification.sh / pre-tool-guard.sh / session-start.sh / error-handler.sh

- **所有 hooks** — 变量引用加引号
  - 修复所有 $variable 为 "${variable}" 避免空格问题

- **dispatch.sh** — 更新版本头为 v1.12.8

### 技术细节

- trap 清理使用两阶段终止：TERM -> 等待1秒 -> KILL
- blocking 锁等待使用 2 秒间隔轮询，30 秒超时
- POSIX 兼容使用 awk 替代 GNU 特有命令
- 所有错误处理遵循 fail-fast 原则

---

## [1.12.7] - 2026-05-08

### P0: 并行执行引擎强化

- **dispatch.sh** — 实现真正并行执行（后台进程+wait等待）
  - 新增run_single_agent函数在后台执行子代理
  - 使用&启动所有子代理实现真正并行
  - 使用wait等待所有后台进程完成
  - 记录PID支持超时终止
  - 原子写入结果文件避免竞态

- **validate-phase.sh** — 完善JSON Schema验证
  - 新增validate_string_length支持minLength/maxLength
  - 新增validate_number_range支持minimum/maximum
  - 新增validate_array_items支持数组items类型验证
  - 新增validate_nested_object支持嵌套对象递归验证
  - 改进validate_enum使用jq -c精确匹配

- **context-budget.sh** — 提升token估算精度
  - 新增多模型配置（claude/gpt4/gemini）
  - 中英文分别估算（中文1字符≈1.5-2 token）
  - 代码/文本/注释分别使用不同系数
  - 新增--model和--list-models命令
  - 误差从25%降低到<15%

### P1: 可靠性增强

- **dispatch.sh** — 子代理重试机制
  - 新增max_retries参数（默认2次）
  - 新增retry_interval参数（默认10秒）
  - 失败自动重试并记录尝试次数
  - 结果JSON新增attempts字段

- **dispatch.sh** — 超时终止机制
  - 新增timeout_seconds配置（默认300秒）
  - 每5秒检查一次子代理状态
  - 超时自动发送TERM信号终止进程
  - 超时结果自动写入JSON文件
  - 显示实时进度（完成数/运行中/已用时）

- **dispatch.sh** — 竞态条件修复
  - 所有结果文件使用原子写入（先写.tmp再mv）
  - 状态文件独立存储避免覆盖
  - PID文件独立存储避免冲突

### 技术细节

- 并行执行使用bash后台进程（&）和wait命令
- 超时控制使用kill -0检测进程状态
- 原子写入使用tmp文件+mv命令保证一致性
- 多模型配置支持claude/gpt4/gemini三种模型
- token估算使用语言检测和内容类型识别

---

## [1.12.6] - 2026-05-08

### P0: 多代理编排引擎

- **dispatch.sh** — 多代理并行编排脚本，支持 N 并行、任务拆分、锁冲突检测
- **subagent-task.md** — 子代理任务模板（Code Executor/Reviewer/Test Runner 三种角色）
- **agent-orchestrator.md** — 多代理编排技能，决策树、上下文预算管理、失败处理策略
- **minimal 命令** — L0 极简模式，跳过 Phase 1-3，最多改 3 文件

### P1: 高危修复

- **pre-tool-guard.sh** — jq 精确提取 JSON，新增 DROP COLUMN/ALTER TABLE RENAME/TRUNCATE TABLE 拦截，放行 COMMENT/SELECT/SHOW/DESCRIBE
- **post-edit-format.sh** — 去掉异步 `&`，改为同步执行 + timeout 3 保护
- **flow-kit.sh** — 版本号从 flow-kit/VERSION 动态读取（read_version 函数）
- **careful.md** — 并发锁改为 mkdir 原子文件锁，含 info.json、过期检测、死锁清理

### P1: 全量中文化

- **config/constitution.md** — SEC/DATA/DEPLOY/GIT 规则表 + BP 原则 + 技术栈规则全量汉化
- **skills/code-review.md** — 三层审查名称汉化（架构师审查/设计审查/工程审查）
- **commands/M-health.md** — 代码健康扫描全量汉化
- **commands/I-intel-scan.md** — 技术情报扫描全量汉化

### P2: 阶段契约验证 + 护栏补全

- **lib/validation/schemas/phase-0-output.schema.json** — 变更分类产物 JSON Schema
- **lib/validation/schemas/phase-1-output.schema.json** — 需求分析产物 JSON Schema
- **lib/validation/schemas/phase-2-output.schema.json** — 设计文档产物 JSON Schema
- **guardrails/performance-guardrails.md** — B5 性能护栏（O(n²)嵌套循环/N+1查询/缺失索引/同步大IO）
- **guardrails/testing-coverage-gate.md** — B6 测试覆盖率门禁（<60%阻断/60-80%警告/>80%通过）

### P3: 优化项

- **lib/error-handler.sh** — 统一错误处理框架（log_info/log_warn/log_error + 错误码常量）
- **hooks 遥测** — pre-tool-guard/post-edit-format/notification hooks 执行日志
- **flow-kit.sh hooks summary** — 查看最近 20 条 hooks 执行记录
- **skills/caveman-compress.md** — 中文压缩策略（标准/极限两级、虚词省略规则）

### 技术细节

- hooks 参考来源统一为 Anthropic 官方 + garrytan/gstack + smallnest/autoresearch
- dispatch.sh 生成 .flow-kit/tmp/dispatch-summary.json 和 subagent-\*-prompt.txt
- mkdir 原子锁路径：.flow-kit/locks/{filepath_hash}.lock/info.json
- 增量覆盖率要求：新增代码 >= 80%

---

## [1.12.6] - 2026-05-08

- dispatch.sh: --execute/--wait/--aggregate 三模式真正并行执行引擎
- context-budget.sh: 上下文预算管理（token估算/预算检查/自动压缩）
- validate-phase.sh: Phase 0/1/2 产物 JSON Schema 验证
- e2e-test-harness.sh: 16项E2E测试覆盖所有v1.12.6功能

## [1.12.3] - 2026-05-08

- CLAUDE.md: 版本号统一为 v1.12.3
- hooks/\*.sh: 全部 5 个 hooks 补全参考来源段落
- flow-kit/VERSION: v1.12.3

## [1.12.2] - 2026-05-08

- skills/output-self-check.md: +动态$CHANGE_ID变量+回退逻辑
- flow-kit.sh: show_share()自动提取PROJECT_NAME
- VERSION/CLAUDE.md: v1.12.2

## [1.12.1] - 2026-05-08

- flow-kit.sh: +help/status/share子命令
- GO.md: /flow-kit:mode切换后确认提示（保存到.flow-kit/mode）
- skills/output-self-check.md: +6项可执行检查命令示例
- skills/agent-pipeline.md: +交接验证失败自动修复循环（最多2轮）
- commands/share-install.md: +团队共享安装命令

## [1.12] - 2026-05-08

- GO.md: +/flow-kit:mode切换后确认提示（保存到.flow-kit/mode）
- skills/output-self-check.md: +R8.3产物自检清单（6项检查）
- lib/phase-executor.md: +阶段完成后触发output-self-check自检
- commands/register-commands.md: +map-codebase返回重索引逻辑
- flow-kit.sh: +CLI入口脚本（环境检测+命令路由映射）

## [1.11] - 2026-05-08

- commands/hooks-guide.md: 参考来源替换为Anthropic官方+garrytan/gstack+smallnest/autoresearch
- phases/4-dev.md,5-test.md,6-review.md: +阶段切换交接验证门触发指令
- GO.md: +/flow-kit:mode显式模式切换命令 (autopilot/team/ralph)
- skills/output-self-check.md: +R8.3产物自检清单（6项检查）
- lib/phase-executor.md: +阶段完成后触发output-self-check自检
- commands/register-commands.md: +map-codebase返回重索引逻辑
- flow-kit.sh: +CLI入口脚本（环境检测+命令路由映射）

## [1.10] - 2026-05-08

- config/system-rules.md: +R1.7 任务过大早期信号检测 + v1.10补充恢复后第一动作规范
- skills/agent-pipeline.md: +三阶段Agent交接验证门（含Handler覆盖矩阵）
- skills/team-dispatch.md: +Task-PRD对齐检查 + 追责链机制
- GO.md: +执行模式自动检测（L0极简/L1标准/L2-L3团队并行）
