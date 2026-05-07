# Phase 6: P1 功能补充 - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-07
**Phase:** 6-P1-supplement
**Areas discussed:** phases 文件棕地/绿地分支增强, phase-executor 自动清窗机制, GO.md 智能路由增强, skills 内容充实（7 个 skills）

---

## Area A: phases 文件棕地/绿地分支增强

| Option | Description | Selected |
|--------|-------------|----------|
| A: 内置检测逻辑 | phases 文件包含完整 project-type 检测代码 | |
| B: 外部依赖读取 | phases 文件只读取 `.flow-kit/project-type`，检测由独立模块完成 | |
| C: 混合模式 | 检查标记文件是否存在，存在则读取，不存在则触发检测 | ✓ |

**User's choice:** C（混合模式）
**Notes:** 现有 phases 文件结构下，混合模式最实用。检测逻辑独立维护，phases 文件仅负责读取。

---

## Area A-2: 增强版检测信号

| Option | Description | Selected |
|--------|-------------|----------|
| A: 追加新信号 | 依赖配置文件完整性 + 近期 commit 活跃度 | |
| B: 保留现有 4 信号，仅优化阈值与白名单 | 未来通过 `light-brownfield` 字段扩展，不影响现有逻辑 | ✓ |
| C: 新增过渡状态 | 区分纯绿地/轻度棕地/重度棕地，3档 | |

**User's choice:** B（保留现有 4 信号，仅优化阈值与白名单）
**Notes:** `light-brownfield` 作为扩展标记，不强制修改分支逻辑，用户可按需使用。

---

## Area A-3: Guardrails 联动方式

| Option | Description | Selected |
|--------|-------------|----------|
| A: 自动激活对应 guardrails | phases 文件自动注入对应 guardrail 检查项 | |
| B: 仅展示不注入 | phases 文件展示检测结果和推荐 guardrails，用户手动激活 | |
| C: 提示 + 快捷命令 | phases 文件输出检测结果 + 快捷命令，用户手动激活 | ✓ |

**User's choice:** C（提示 + 快捷命令）
**Notes:** 用户保留控制权，guardrails 激活是显式行为。

---

## Area B-1: 自动清窗触发机制

| Option | Description | Selected |
|--------|-------------|----------|
| A: 80% 立即触发 | 达到 80% 自动开始压缩，无需确认 | |
| B: 80% 提示，确认后执行 | 80% 时警告并询问，确认后执行 | |
| C: 渐进式压缩 | 80% 警告 → 90% 提示 → 100% 强制压缩 | ✓ |

**User's choice:** C（渐进式压缩）
**Notes:** 与 token 预算渐进式警告一致，用户有干预机会。

---

## Area B-2: 压缩粒度

| Option | Description | Selected |
|--------|-------------|----------|
| A: 清理临时标记 | 仅清理 `.flow-kit/` 下的临时文件 | |
| B: 清理 checkpoints + logs | 清理已完成 phase 的 checkpoint 和 logs，核心文档保留 | ✓ |
| C: 深度压缩 | 压缩已完成 phase 的 PLAN.md 为摘要 | |

**User's choice:** B（清理 checkpoints + logs）
**Notes:** 核心文档保留，归档而非删除。保持历史可追溯性。

---

## Area C-1: GO.md 启动时检测展示格式

| Option | Description | Selected |
|--------|-------------|----------|
| A: 简短 banner | 只显示 project_type，不干扰主流程 | |
| B: 详细诊断 | 显示检测信号列表 | |
| C: 摘要 + 快捷操作 | 显示 project-type + 推荐 actions + 快捷命令 | ✓ |

**User's choice:** C（摘要 + 快捷操作）
**Notes:** 用户需要足够信息做决策，快捷操作减少摩擦。

---

## Area C-2: 用户手动覆盖机制

| Option | Description | Selected |
|--------|-------------|----------|
| A: 命令覆盖 | `/flow-kit:project-type [type]` 显式设置 | |
| B: 配置文件覆盖 | `.flow-kit/user-config.md` 中设置 | |
| C: 两种都支持 | 命令行覆盖优先，配置文件为默认值 | ✓ |

**User's choice:** C（两种都支持）
**Notes:** 命令行覆盖优先，配置文件为默认值。兼顾灵活性和默认可控性。

---

## Area D: skills 内容充实（7 个 skills 全部讨论）

### D-1: code-review.md

| Option | Description | Selected |
|--------|-------------|----------|
| A: 增加执行步骤 | 从"检查什么"到"怎么检查" | |
| B: 增加自动化检测命令 | 每个检查项增加自动化命令，区分阻断/警告 | ✓ (A+B+C) |
| C: 增加 review 深度选项 | 根据代码规模和重要性提供不同模板 | ✓ |

**User's choice:** A+B+C 组合
**Notes:**
1. 核心：B 选项自动化命令增强，每个检查项对应自动化命令，区分阻断项和警告项
2. 流程：A 选项执行步骤串联（前置自动化 → 三层人工 → 补充自动化 → 输出报告）
3. 场景：C 选项三种模板（简化/标准/深度），P0 强制使用深度模板
4. 额外联动：棕地专用模板、token 预算预警、PR 描述自动填充

**Decisions D-13~D-18 captured.**

---

### D-2: debugging.md

| Option | Description | Selected |
|--------|-------------|----------|
| A: 增加常见错误模式库 | 针对 flow-kit 常见错误提供诊断流程图 | ✓ |
| B: 增加自动化检测脚本 | 日志收集/状态快照脚本 | ✓ |
| C: 多角色协作 debug 模式 | 多子代理并行排查 | |

**User's choice:** A+B 组合
**Notes:** C 作为远期扩展。当前聚焦单用户 debug 流程做扎实。
- 错误模式库联动 `/flow-kit:validate-phase` 和 `/flow-kit:reset-checkpoint`
- 自动化脚本支持棕地/绿地场景，棕地关联数据库状态快照

**Decisions D-19~D-20 captured.**

---

### D-3: verification.md

| Option | Description | Selected |
|--------|-------------|----------|
| A: 自动化验证流水线 | 可自动执行的验证命令序列，支持 CI/CD | ✓ (with B+C) |
| B: 分阶段验证门控 | 不同 phase 使用不同验证粒度 | ✓ (核心) |
| C: 验证失败恢复指南 | 常见验证失败的自动修复建议 | ✓ (with A+B) |

**User's choice:** 以 B 为核心，结合 A 和 C 做三层增强
**Notes:**
- 分阶段门控：Phase1-2 轻量、Phase3-4 基础、Phase5-6 全量
- 棕地自动启用历史兼容性检查，绿地启用标准检查
- 与 token 预算联动，深度检查前自动提示用户释放预算

**Decision D-21 captured.**

---

### D-4: requirement-clarify.md

| Option | Description | Selected |
|--------|-------------|----------|
| A: 验收标准自动生成 | 输入需求描述，自动输出验收标准 | ✓ (联动 C) |
| B: 优先级判断框架 | MoSCoW / Kano 模型 | 可选扩展 |
| C: 需求可测试性检查 | 识别模糊需求并建议量化指标 | ✓ (核心) |

**User's choice:** 以 C 为核心，结合 A，B 作为可选扩展
**Notes:**
- 模糊需求识别 → 量化建议 → 可测试性检查 → 验收标准自动生成
- 对接 verification.md 和 code-review.md

**Decision D-22 captured.**

---

### D-5: task-master.md

| Option | Description | Selected |
|--------|-------------|----------|
| A: 任务依赖关系图 | 自动分析依赖，支持并行任务识别 | ✓ (核心) |
| B: 任务耗时估算 | 基于历史数据估算任务耗时 | 远期扩展 |
| C: 任务状态跟踪 | 实时跟踪任务状态，支持看板视图 | ✓ (补充) |

**User's choice:** 以 A 为核心，结合 C，B 作为远期扩展
**Notes:**
- 依赖图自动识别 + 用户手动调整
- 与 subagent-execution 联动，自动调度并行任务
- 任务状态与 checkpoint 同步，blocked 触发断点续跑
- 可选看板视图，不强制默认开启

**Decisions D-23~D-25 captured.**

---

### D-6: subagent-execution.md

| Option | Description | Selected |
|--------|-------------|----------|
| A: 子代理调度策略 | 根据任务依赖决定启动顺序 | ✓ (核心) |
| B: 子代理资源限制 | 限制并发数量，避免 token 溢出 | ✓ (强制兜底) |
| C: 子代理执行日志 | 结构化记录结果、耗时、token 消耗 | ✓ (事后闭环) |

**User's choice:** A+B+C 完整闭环
**Notes:**
- 与 task-master 依赖图联动，依赖校验 → 自动调度
- 资源限制：80% 预算降为 1 并发，90% 强制串行
- 执行日志归档到 archive/，可导入成本报告

**Decision D-26 captured.**

---

### D-7: parallel-dispatch.md

| Option | Description | Selected |
|--------|-------------|----------|
| A: 任务分组策略 | 按任务类型分组，减少上下文切换 | ✓ (核心) |
| B: 优先级调度 | 高优先级任务优先分发，P0 插队 | ✓ (补充) |
| C: 分发监控仪表盘 | 实时显示任务状态、token 消耗 | ✓ (轻量扩展) |

**User's choice:** 以 A 为核心，结合 B，C 作为轻量文本扩展
**Notes:**
- 按前端/后端/测试分组，同类型任务分发到同一子代理
- P0 审批联动，仅对依赖已完成的任务允许插队
- 轻量 Markdown 表格形式，可选开启，不强制默认

**Decisions D-27~D-29 captured.**

---

## Claude's Discretion

- skills 各文件增强的具体实现细节（D-13~D-29）由 planner 和 executor 细化
- `light-brownfield` 字段的具体阈值和触发条件在实现阶段确定

---

## Deferred Ideas

- 多角色协作 debug 模式 — 依赖 subagent-execution 技能，远期扩展
- 任务耗时估算 — 依赖历史执行数据，后续对接
- MoSCoW/Kano 优先级框架 — 多需求排序场景可选扩展