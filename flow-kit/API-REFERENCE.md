# API Reference

> 自动生成: 2026-05-15
> 版本: v3.5.3

---

## lib/ 模块

### cleanup

cleanup.sh — 临时文件统一管理

- `register_cleanup()`
- `register_cleanup_dir()`
- `do_cleanup()`

### conflict-detector

conflict-detector.sh — v3.3.0 P1 需求冲突检测与决策引导

- `classify_requirement()`
- `detect_conflict()`
- `detect_file_conflicts()`
- `_extract_change_files()`
- `detect_dependency_conflicts()`
- `handle_conflict_decision()`
- `interactive_conflict_resolution()`

### context-budget

context-budget.sh — 上下文预算管理

- `is_number()`
- `is_cmp_op()`
- `float_cmp()`
- `float_mul()`
- `float_scale()`
- `get_model_params()`
- `detect_language_type()`
- `detect_content_type()`
- `estimate_tokens()`
- `estimate_file_tokens()`
- `estimate_dir_tokens()`
- `check_budget()`
- `get_budget_status()`
- `trigger_compress()`
- `budget_warn()`
- `show_help()`
- `main()`

### context-updater

context-updater.sh — 上下文增量更新

- `init_context_file()`
- `has_change_log_header()`
- `main()`

### cost-reporter

cost-reporter.sh — 成本报告生成

- `check_dependencies()`
- `main()`

### error-handler

error-handler.sh — 统一错误处理框架

- `get_timestamp()`
- `log_info()`
- `log_warn()`
- `log_error()`
- `log_debug()`
- `die()`
- `check_result()`
- `create_error_context()`
- `get_error_recovery_suggestion()`
- `safe_exit()`
- `aggregate_errors()`

### expiry-checker

expiry-checker.sh — 上下文过期检测

- `get_newest_mtime()`
- `main()`

### health-rotation

health-rotation.sh — 健康历史轮转脚本

- `get_file_size_bytes()`
- `main()`

### paths

paths.sh — 统一路径管理

- `init_runtime_dirs()`
- `rotate_logs()`

### preflight

preflight.sh — 统一依赖预检

- `require_cmd()`
- `require_jq()`
- `require_python3()`
- `require_pyyaml()`
- `require_bash4()`
- `require_bc()`

### pr-generator

pr-generator.sh — PR 描述生成

- `get_git_root()`
- `has_uncommitted_changes()`
- `validate_branch_name()`
- `main()`

### project-info

project-info.sh — 项目信息获取库

- `get_project_type()`
- `_pi_detect_project_dir()`
- `load_workflow()`
- `_pi_get_phases_dir()`

### security-scanner

security-scanner.sh — 自动安全扫描

- `scan_info()`
- `scan_warn()`
- `scan_error()`
- `scan_debug()`
- `scan_hardcoded_secrets()`
- `scan_sql_injection()`
- `scan_xss()`
- `scan_dangerous_shell()`
- `main()`

### session-state

session-state.sh — v3.3.0 记忆系统核心库

- `_ss_now()`
- `_ss_skeleton()`
- `_ss_ensure()`
- `_ss_migrate()`
- `session_get()`
- `session_set()`
- `session_init()`
- `session_task_set()`
- `session_next()`
- `session_block()`
- `session_resume_prompt()`
- `session_history_add()`
- `session_decision_add()`
- `session_interaction_set()`
- `session_history_get()`

### time-utils

time-utils.sh — 共享时间工具函数

- `get_epoch_ms()`
- `date_to_epoch()`

### token-estimator

token-estimator.sh — 基于 LOC 的 Token 估算

- `check_dependencies()`
- `count_loc_in_dir()`
- `main()`

## scripts/ 模块

### caveman-compress

caveman-compress.sh — 上下文压缩脚本


### code-review

code-review.sh — v3.3.0 P2 自动化代码评审

`bash code-review --help` 查看用法


### dispatch

dispatch.sh — 多代理并行编排脚本


### doc-extractor

doc-extractor.sh — API 文档自动提取

`bash doc-extractor --help` 查看用法


### generate-commands

generate-commands.sh — flow-kit 斜杠命令生成器 (精简版 v2.7.0)

`bash generate-commands --help` 查看用法


### health-scheduler

health-scheduler.sh — 自动化健康巡检


### init-change

init-change.sh — flow-kit 变更初始化脚本 v2.7.0

`bash init-change --help` 查看用法


### install

install.sh — 安装 flow-kit 依赖工具


### log-aggregator

log-aggregator.sh — hooks 执行日志聚合分析器

`bash log-aggregator --help` 查看用法


### next-phase


`bash next-phase --help` 查看用法


### offline-mode

offline-mode.sh — 离线模式控制

`bash offline-mode --help` 查看用法


### p0-check

p0-check.sh — P0 变更自动检测


### performance-regression

performance-regression.sh — 性能退化检测


### phase-executor

phase-executor.sh — 条件路由脚本 v1.0

`bash phase-executor --help` 查看用法


### plan-generate

plan-generate.sh — v3.3.0 P2 基于评审结果生成开发方案

`bash plan-generate --help` 查看用法


### pr-description

pr-description.sh — PR 描述自动生成

`bash pr-description --help` 查看用法


### validate-phase

validate-phase.sh — 阶段产物 JSON Schema 验证

`bash validate-phase --help` 查看用法


## hooks/ 模块

### notification


### post-edit-format

post-edit-format.sh — PostToolUse hook: 自动格式化代码

### pre-tool-guard

pre-tool-guard.sh — PreToolUse hook: 阻止危险命令和敏感文件编辑

### session-start


### stop-quality-gate


文档生成完成
