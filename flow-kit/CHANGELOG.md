# Changelog

All notable changes to flow-kit will be documented in this file.

## [3.7.0] - 2026-05-16

### Phase 1: 基础设施

- **lib/error-handler.sh** — 新增 setup_trap() 统一信号处理
- **lib/cleanup.sh** — 新增 with_cleanup() 自动清理 wrapper
- **scripts/dispatch-lock.sh** — 新增 acquire_lock/release_lock/is_lock_stale，300s 默认超时
- **hooks/** — 验证全部 hook 含 set -uo pipefail

### Phase 2: 核心功能

- **lib/metrics-logger.sh** — JSONL 指标日志库（metrics_log_event/metrics_query/metrics_summary）
- **scripts/metrics.sh** — /metrics CLI 命令（--summary/--detail/--clear）
- **scripts/recall.sh** — /recall 项目上下文摘要（5 分钟缓存）
- **commands/ralph.md** — /ralph 命令模板
- **scripts/generate-commands.sh** — 注册 /ralph、/metrics、/recall

### Phase 3: 质量 P1

- **phase-executor** — 20 个测试（含指标埋点验证）
- **auto-pilot** — 12 个测试（含指标埋点验证）
- **flow-kit.sh** — 7 个 stub 命令修复（health/scan/cost-report/estimate-tokens/check-expiry/update-context/p0）

### Phase 4: 质量 P2+P3

- **lib/README.md** — 7 个分组文档
- **scripts/README.md** — 8 个分组文档 + v3.8.0 迁移计划
- **scripts/shellcheck-all.sh** — 并行 ShellCheck 检查
- **scripts/generate-api-docs.sh** — API 文档生成器

### Phase 5: 集成

- **tests/e2e/** — 3 个 E2E 测试骨架（recall-flow、metrics-flow、command-routing）
- **213 个测试全部通过**（从 138 基线增长）

## [3.6.0] - 2026-05-16

### 迭代 1：YAML Front Matter 体系

- **lib/front-matter.sh** — YAML front matter 解析器
  - `parse_front_matter <file>` → JSON 输出
  - `get_front_matter_field <file> <field>` → 单字段提取
  - 无 front matter 文件返回 `{"phase":-1}`
- **phases/**/*.md** — 29 个 phase 文件全部添加 YAML front matter
  - phase/name/stage/allowed_operations/forbidden_operations/expected_artifacts/next_phase
- **hooks/post-edit-format.sh** — 新增边界警告（boundary warning）
  - 思考阶段编辑非 .flow-kit/ 文件 → `[boundary]` 警告
- **hooks/stop-quality-gate.sh** — 新增产出物检查
  - 读取 phase front matter 的 `expected_artifacts`，缺少 → `[quality-gate]` 警告
- **lib/security-scanner.sh** — Secrets 检测增强（18 种模式）
  - GitHub PAT/OAuth/User-Server/Server-Server/Refresh、OpenAI、AWS、JWT、SSH、Slack 等

### 迭代 2：Auto-pilot 状态机

- **scripts/auto-pilot.sh** — 半自动执行状态机
  - `--next` 推进阶段，`--status` 查看状态，`--depth` 选择执行深度
  - auto-plan.json + session-state.json 双文件架构
- **scripts/validate-phase.sh** — 产出物增强
  - `validate_artifacts()` 检查产出物完整性
  - `record_evidence()` 原子写入证据到 auto-plan.json
- **hooks 集成验证** — post-edit + stop-quality-gate 联动测试

### 迭代 3：PRD 预处理 + 回滚增强

- **scripts/prd-parser.sh** — PRD 文件格式检测和解析
  - 支持 Markdown 和 JSON 格式
  - awk 单次遍历提取 headings/lists/tables
- **phases/8-rollback/** — 增强回滚工作流
  - 三档分级判定（P0/P1/P2）
  - RCA 事故报告模板（5 Whys + 事后 5 件事）
  - 棕地/绿地差异化回滚策略

### 迭代 4：测试 + 文档

- **138 项测试全通过**（单元 97 + 集成 19 + 边界 22）
- **GO.md** — 新增 auto-pilot 和 prd-parser 使用说明
- **CHANGELOG.md** — v3.6.0 变更记录

---

## [3.4.0] - 2026-05-14

### P0: 架构重构

- **dispatch.sh** — 拆分为 3 文件：dispatch.sh(889) + dispatch-parse.sh(90) + dispatch-lock.sh(89)
- **session-state.sh** — `_ss_ensure()` 单路径化，消除 `_ss_migrate` 冗余调用
- **security-scanner.sh** — `log_*` → `scan_*` 命名空间，消除 error-handler.sh 日志覆盖
- **paths.sh** — `rotate_logs()` 参数化（5 参数），消除硬编码

### P1: 代码质量

- **CODING-STANDARDS.md** — 新建编码规范文档（命名/注释/架构/编码 4 类）
- **.shellcheckrc** — 新建 ShellCheck 全局配置
- **session-start.sh** — 修复 `local` 在函数外使用（SC2168）
- **validate-phase.sh** — 修复数组展开 SC1087（3 处）
- **code-review.sh** — 修复 shellcheck 指令解析 SC1072/1073
- **flow-kit.sh** — SC2155 批量修复（12 处 local+命令替换分离）
- **dispatch.sh** — SC2155 批量修复（15 处）

### P2: 性能优化

- **dispatch.sh** — jq 调用优化：`cat` 一次 + `echo "$data" | jq` 复用

### 测试

- **test-phase-executor.sh** — 新增 `test_load_workflow_brownfield` 测试
- **test-session-state.sh** — 新增 v2 schema 测试（36 项）
- **test-validate.sh** — SC2155 修复
- **e2e-full-flow.sh** — dispatch-lock.sh 拆分适配

### 验证

- 63 测试全通过，0 失败
- 0 ShellCheck error（50 warning/note）
- 三层代码审查通过（0 P0/P1 问题）

## [3.2.0] - 2026-05-13

### P0: 功能修复

- **GO.md** — 版本声明 v2.x → v3.x，命令数 21 → 22，添加 `/flow-kit:resume`
- **.claude/commands/** — 9/22 命令补全 `execute` 字段（archive/health/hooks/mode/register-commands/generate-commands/resume/scan/scale）
- **dispatch.sh** — 删除残留 `━━━` 分隔线

### P1: Token 深度优化

- **dispatch.sh** — 删除版本号注释（~15 处）、压缩 show_help（30→15行）、分隔线→标签
- **init-change.sh** — 输出从 25 行 emoji → 4 行 caveman 风格
- **flow-kit.sh** — hooks-summary 删分隔线、status 去重输出
- **error-handler.sh** — 删除示例代码（14行）和参考来源（4行）
- **paths.sh** — 删除使用示例（7行）
- **test-session-state.sh** — 删除 ━━ 分隔线

### P2: 代码质量

- **session-state.sh** — `_ss_now` 简化：删除双重相同 fallback
- **paths.sh** — `rotate_logs` 纳秒 `%N` → 秒级 `%Y%m%d%H%M%S`（macOS 兼容）
- **phase-executor.sh** — `find` → `ls -d` 替代，减少子进程开销

---

## [3.1.0] - 2026-05-13

### P0: session-state.sh 修复

- **session-state.sh** — `_ss_migrate` 用 `ls -1t` 替代 `find -printf`（macOS/BSD 兼容）
- **session-state.sh** — `session_set` 添加 key 白名单校验，防止 jq path 注入
- **`.claude/commands/flow-kit:resume.md`** — 新建，resume 命令可被发现

### P1: Token 优化

- **next-phase.sh** — 输出从 7 行精简为 2 行
- **dispatch.sh** — 分隔线从 `━━━` 缩短为 `───`
- **phase-executor.sh** — 输出精简为单行 `[phase-exec] type=X phase=Y`
- **flow-kit.sh** — 版本 fallback 从 `v2.7.0` 改为 `unknown`
- **命令 execute** — init/status/guard 添加 execute 字段
- **phase 文档** — 4-dev/5-test/6-review 接入 session-state 指引

### P2: 测试补全 + Schema

- **tests/test-session-state.sh** — 新建 22 项单元测试（init/set/get/task/migrate/注入防护）
- **validate-phase.sh** — help 文本 `phase (0, 1, 2)` → `phase (0-8)`
- **dispatch.sh** — source session-state.sh，完成时 `session_set status done`
- **9 个 schema** — 全部添加 `additionalProperties: false`

---

## [3.0.0] - 2026-05-13

### P0: Bug 修复 (8 项)

- **dispatch.sh** — `jq -c '.agents[]'` → `jq -r`，修复带引号 agent id 导致文件名错误
- **init-change.sh** — 碰撞检查路径从插件相对路径改为 `$PROJECT_DIR/.specs`
- **phase-executor.sh** — 提取 `${PHASE_NUM%%-*}` 纯数字，防止写入非数字 phase
- **p0-check.sh** — 审批命令名 `p0-approve` → `p0-approval`
- **hooks/pre-tool-guard.sh, notification.sh** — 日志路径改用 `$LOGS_DIR`（source paths.sh）
- **offline-mode.sh** — 状态文件改用 `$PROJECT_DIR/.flow-kit`（source paths.sh）
- **stop-quality-gate.sh** — 覆盖率路径改用 `$COVERAGE_DIR`（source paths.sh）
- **dispatch.sh** — collect_results 从 agent-1 硬依赖改为 glob 检查

### P1: 会话记忆系统 (核心功能)

- **lib/session-state.sh** — 新建会话状态管理库
  - `session_init/set/get/task_set/next/block/resume_prompt` API
  - caveman 压缩风格：极简 JSON（~120 token）、`id:status` 逗号串
  - 原子写入（tmp+mv）、自动时间戳
  - graceful fallback：缺 session-state.json 时从旧文件自动迁移
- **`.flow-kit/session-state.json`** — 核心状态文件
  - 存储: change-id、phase、status、ptype、mode、tasks、next、blockers、ts
- **init-change.sh** — 创建变更时初始化 session-state
- **phase-executor.sh** — 进入 phase 时更新 session-state
- **next-phase.sh** — 推进 phase 时更新 session-state
- **session-start.sh** — 重写：`/clear` 后恢复完整上下文（~30 token caveman 摘要）
- **flow-kit.sh status** — 从 session-state.json 读取状态
- **`/flow-kit:resume`** — 新命令，显式恢复完整状态
- **generate-commands.sh** — 注册 resume 命令
- **lib/paths.sh** — 添加 `SESSION_STATE_FILE` 常量
- **.flow-kit/.gitignore** — 补全运行时状态忽略规则

---

## [2.9.0] - 2026-05-13

### P0: Phase 状态持久化

- **phase-executor.sh** — 执行 phase 时写入 `.flow-kit/current-phase`
  - `/flow-kit:phase-N` 执行后持久化当前阶段，`/clear` 后 `/flow-kit:next` 可正确恢复
- **generate-commands.sh** — `/flow-kit:next` 斜杠命令添加 `execute` 字段
  - 斜杠命令现在实际执行 `next-phase.sh`，而非仅显示文本
- **session-start.sh** — 恢复阶段上下文提示
  - `/clear` 后自动输出当前阶段提示，让 Claude 知道上次停在哪个 phase

### P1: Schema 扩展 + 代码集成

- **Phase 3-8 validation schema** — 新增 6 个 JSON Schema
  - `phase-{3,4,5,6,7,8}-output.schema.json`
  - `validate-phase.sh` 扩展到支持全部 9 个阶段
- **dispatch.sh** — source `lib/time-utils.sh`，提取 `date_to_epoch` 到共享库
  - 消除 dispatch.sh 中 `get_epoch_ms` 和 `date_to_epoch` 的内联重复
- **preflight.sh** — 集成到各脚本入口
  - `dispatch.sh` 添加 `require_jq`
  - `generate-commands.sh` 添加 `require_bash4`
  - `offline-mode.sh` 添加 `require_jq`
- **phase-0-output.schema.json** — 更新 `change_id` pattern 兼容碰撞后缀
  - `^[a-z0-9-]+-[0-9]{8}(-[0-9]+)?$`

---

## [2.8.0] - 2026-05-13

### P0: 核心稳定性修复

- **dispatch.sh** — 僵尸进程双重检测
  - `kill -0` + 结果文件存在性双重检测，解决僵尸进程导致假超时
- **dispatch.sh** — 锁清理 mismatch 修复
  - `cleanup_children` 改用 `rmdir` + `rm -rf` 回退清理 mkdir 创建的锁目录
- **dispatch.sh** — `--timeout` 参数透传
  - `execute_subagents` 和 manifest JSON 使用 `$WAIT_TIMEOUT` 替代硬编码 300s
- **plugin.json** — 版本号 2.6.1 → 2.8.0 与 VERSION 同步
- **e2e-full-flow.sh** — 重写 flock 测试为 mkdir/rmdir 锁机制验证

### P1: 功能修复

- **p0-check.sh** — 实现 `--force` 参数，跳过 P0 检测
- **pr-description.sh** — `gh` 从硬依赖改为可选，模板生成无需 `gh`
- **init-change.sh** — 同日同 slug 碰撞时追加 `-N` 序号
- **next-phase.sh** — 原子写入（tmp + mv）防并发竞态
- **offline-mode.sh** — 添加 PyYAML 可用性预检
- **session-start.sh** — 使用 `CLAUDE_PROJECT_DIR` 环境变量

### P2: 代码质量

- **lib/time-utils.sh** — 新建共享时间工具，`get_epoch_ms` 去重（3 hooks）
- **lib/preflight.sh** — 新建统一依赖预检库
- **caveman-compress.sh** — TODO 正则修复匹配 `- TODO` / `- [ ] TODO`
- **CLAUDE.md** — 命令数更新为 21（12 核心 + 9 阶段）

---

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
