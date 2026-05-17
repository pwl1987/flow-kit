# 架构设计

## 变更 ID

v3-5-1-batch34-20260514

## 范围

A1-A8 (P0/P1 核心模块修复+基础增强) + B1-B6 (P2 智能增强+性能优化)

---

## A 组: 核心模块修复

### A1: session-state.sh 双重 fallback 消除

**现状**: `_ss_ensure()` 被每个公共函数调用 (session_get/set/init 等 8 处)，每次都调 `_ss_migrate`。migrate 检查 v1→v2 格式转换。

**方案**: 添加 `_ss_initialized=false` 标志，`_ss_ensure` 仅首次执行 migrate + init。后续调用跳过。

**文件**: `flow-kit/lib/session-state.sh`
**改动**: ~15 行

```
_ss_initialized=false
_ss_ensure() {
    if $_ss_initialized; then return 0; fi
    _ss_migrate 2>/dev/null || true
    if [ ! -f "$SESSION_STATE_FILE" ]; then
        echo '{"v":2,...}' > "$SESSION_STATE_FILE"
    fi
    _ss_initialized=true
}
```

### A2: paths.sh 路径去重

**现状**: paths.sh 定义 25+ readonly 变量。dispatch.sh、code-review.sh 等有独立 `SCRIPT_DIR` 计算。无冲突。

**方案**: paths.sh 已是唯一路径定义点，cleanup.sh 已处理 TMP。本轮只需:

- 确认所有脚本通过 paths.sh 获取路径（已基本完成）
- 添加 `ensure_dirs()` 函数统一目录创建

**文件**: `flow-kit/lib/paths.sh`
**改动**: ~5 行

### A3: error-handler override 检测

**现状**: security-scanner.sh 定义了自己的 `log_info/log_warn/log_error/log_debug`（10 处调用）。error-handler.sh 定义了同名函数。source 顺序决定哪个生效。

**方案**: 在 error-handler.sh 末尾添加检测:

```bash
# 检测日志函数是否被覆盖
_check_log_override() {
    local orig_file="${BASH_SOURCE[-1]}"
    # 对比函数定义来源文件
    if type log_info 2>/dev/null | grep -qv "error-handler"; then
        echo "[error-handler] ⚠️ 日志函数被覆盖" >&2
    fi
}
```

同时在 security-scanner.sh 中移除重复定义，改用 error-handler 的函数。

**文件**: `flow-kit/lib/error-handler.sh`, `flow-kit/hooks/security-scanner.sh`
**改动**: error-handler +10 行, security-scanner -14 行

### A4: phase-executor 函数提取

**现状**: `get_project_type()` 和 `load_workflow()` 定义在 phase-executor.sh 内，无法被其他脚本复用。

**方案**: 提取到 `flow-kit/lib/project-info.sh`，phase-executor.sh source 引用。

**文件**: `flow-kit/lib/project-info.sh` (新建), `flow-kit/scripts/phase-executor.sh` (删除内联定义)
**改动**: +40 行新文件, phase-executor 减少对应行

### A5: 命令使用统计

**现状**: session-state v2 有 `history` 字段存储逗号分隔的命令记录。无聚合/统计。

**方案**:

1. `session-state.sh` 添加 `session_cmd_count <cmd>` — 计数某命令出现次数
2. `scripts/cmd-stats.sh` (新建) — 聚合统计，输出 Top 10 命令 + 使用频率
3. 添加 `/flow-kit:cmd-stats` 命令

**文件**: `flow-kit/lib/session-state.sh` (+10 行), `flow-kit/scripts/cmd-stats.sh` (新建 ~60 行)

### A6: 按 change-id 回滚

**现状**: 无 rollback 技能。session-state 存 change 名称但无历史快照。

**方案**:

1. `session-state.sh` 添加 `session_snapshot()` — 保存当前状态到 `.flow-kit/archive/<change>-<timestamp>.json`
2. `skills/rollback.md` (新建) — 查询历史 + 恢复指定 change
3. init-change 时自动 snapshot 当前状态

**文件**: `flow-kit/lib/session-state.sh` (+15 行), `flow-kit/skills/rollback.md` (新建 ~30 行)

### A7: CI 性能基准

**现状**: `.github/workflows/test.yml` 存在。Makefile 有空 `benchmark` 目标。

**方案**:

1. 创建 `benchmarks/run-benchmarks.sh` — hyperfine 测量核心脚本
2. Makefile benchmark 目标调用它
3. CI 添加 benchmark job（可选，手动触发）

**文件**: `benchmarks/run-benchmarks.sh` (新建 ~40 行), `Makefile` (修改 ~5 行)

### A8: 错误日志聚合

**现状**: error-handler.sh 写错误到 `$LOGS_DIR/` 下 JSON 文件。无聚合。

**方案**: `scripts/log-aggregator.sh` (新建) — 扫描日志文件，按错误类型/模块/频率聚合，输出报告。

**文件**: `flow-kit/scripts/log-aggregator.sh` (新建 ~80 行)

---

## B 组: 智能增强

### B1: find→glob + jq 去重

**现状**: 8 个脚本使用 `find` 命令（共 13 处调用）。caveman-compress.sh 同一目录 find 3 次。

**方案**:

1. caveman-compress.sh: 缓存 find 结果到变量，3 次复用
2. dispatch-lock.sh: `find | wc -l` → `ls -d *.lock 2>/dev/null | wc -l`
3. code-review.sh: 2 次 find 可合并
4. 不改: generate-commands.sh (需 -print0 安全处理)

**文件**: caveman-compress.sh, dispatch-lock.sh, code-review.sh
**改动**: ~20 行

### B2: Token 消耗预测

**现状**: context-budget.sh 有 `estimate_tokens()` (按字符估算) 和 `check_budget()` (阈值检查)。无历史数据。

**方案**:

1. session-state 添加 `token_usage` 字段记录每 phase 消耗
2. context-budget.sh 添加 `predict_remaining()` — 基于已消耗 + phase 权重预测
3. 3 种模式: linear (当前平均), weighted (近期加权), conservative (×1.5 安全系数)

**文件**: `flow-kit/lib/context-budget.sh` (+30 行), `flow-kit/lib/session-state.sh` (+5 行)

### B3: 自动 checkpoint

**现状**: checkpoint.js 手动触发。

**方案**: bash 端添加 checkpoint 触发:

1. 在 phase-executor.sh 中，每完成一个 phase 自动创建快照（复用 A6 的 session_snapshot）
2. 阈值配置: 每 N 个文件变更（默认 5）

**文件**: `flow-kit/scripts/phase-executor.sh` (+10 行)
**依赖**: A6 (session_snapshot)

### B4: 性能退化检测

**现状**: 无。

**方案**: 在 `benchmarks/run-benchmarks.sh` 中:

1. 将结果写入 `.flow-kit/benchmarks/<version>.json`
2. 新增 `--compare <prev_version>` 对比
3. 超过 20% 退化则 exit 1

**文件**: `benchmarks/run-benchmarks.sh` (+20 行)
**依赖**: A7

### B5: 自动错误恢复建议

**现状**: error-handler.sh 有错误码分类 (8 种 error_type) 和固定恢复建议。

**方案**: 扩展 error-handler.sh:

1. 错误模式库: 常见 bash 错误 → 建议映射
2. `suggest_recovery()` 函数: 基于错误类型 + 上下文生成建议
3. 集成到 safe_exit 流程

**文件**: `flow-kit/lib/error-handler.sh` (+30 行)

### B6: 技能热加载

**现状**: generate-commands.sh 一次性扫描 skills/ 生成命令。新技能需重新注册。

**方案**:

1. `scripts/skill-loader.sh` (新建) — 检测 skills/ 变更，增量注册
2. `.flow-kit/skill-registry.json` — 记录已加载技能及时间戳
3. 对比 skills/ 目录 vs 注册表，新增的自动注册

**文件**: `flow-kit/scripts/skill-loader.sh` (新建 ~60 行)

---

## 依赖图

```
A1 ─┐
A2 ─┤
A3 ─┤
A4 ─┤────────────────────────┐
A5 ─┤                        │
A6 ─┤──→ B3 ──┐              │
A7 ─┤──→ B4 ──┤              │
A8 ─┤         │              │
B1 ─┤         │              │
B2 ─┤         │              │
B5 ─┤         │              │
B6 ─┘         │              │
              ├──→ T18 ──────┘
```

## 并行分组

**Group A** (无依赖，全并行): A1, A2, A3, A4, A5, A6, A7, A8, B1, B2, B5, B6
**Group B** (依赖 A 组): B3 (after A6), B4 (after A7)
**Group C**: 集成验证
