# Phase 5: P0 缺陷修复 - Context

**Gathered:** 2026-05-06
**Status:** Ready for planning

## Phase Boundary

修复影响核心能力的缺陷：棕地/绿地自动检测、断点续跑机制、数据库类型自动识别、skills 内容验证。

**Requirements:** REQ-001, REQ-002, REQ-003, REQ-004

---

## Implementation Decisions

### D-01: 棕地/绿地检测 — A3 增强版方案

**Decision:** 组合指纹检测 + 业务代码行数阈值（排除配置白名单）

Detection Logic:
1. **文件指纹** — `.git/` + 锁文件（package-lock.json / yarn.lock / pnpm-lock.yaml）→ 棕地
2. **Git remote 检查** — `.git/config` 中有 remote.origin.url → 棕地（已关联远程）
3. **业务代码行数** — 统计非白名单的代码行数，> 1000 行 → 棕地
4. **绿地判定** — 无 `.git/` 或 空仓库 或仅有配置文件无业务代码

**白名单（不纳入业务代码统计）：**
- tsconfig.json, jsconfig.json, .gitignore, .eslintrc*, .prettierrc*
- package.json, requirements.txt, Pipfile, pyproject.toml
- README.md, LICENSE, CHANGELOG.md
- *.config.js, *.config.ts, *.config.json, *.yaml, *.yml

**Detection Output:** 写入 `.flow-kit/project-type` 标记文件

### D-02: 棕地/绿地检测 — 路由机制

**Decision:** 独立标记文件，`.flow-kit/project-type`


**文件格式：**
```
project_type: brownfield|greenfield
detected_at: {ISO date}
detection_signals: [list of signals found]
business_code_lines: {count}
```

**读取方:** phases 文件启动时主动读取，决定激活哪些 guardrails

### D-03: 断点续跑 — .STATE 文件格式

**Decision:** Plan 级别记录 + Task 跳转支持

**文件:** `.flow-kit/checkpoint-state.json`


**格式：**
```json
{
  "phase": "05",
  "last_completed_plan": "05-1",
  "last_completed_task": "check-expiry",
  "task_index": 3,
  "paused_at": "{ISO date}",
  "next_action": "continue from 05-1 task 4"
}
```

**恢复行为:** 跳过已完成的 plan/task，从 next_action 继续执行

### D-04: 断点续跑 — 触发机制


**Decision:** 混合模式（自动检测 + 用户确认）

**流程:**
1. phase-executor 执行时检测 `.flow-kit/checkpoint-state.json` 是否存在
2. 存在则提示: "发现断点（Phase N, Plan M, Task K）。是否恢复？"
3. 用户选择后执行 Resume 或 新建/覆盖

**Resume 入口:** `/gsd-execute-phase 5 --resume` 或 自动检测

### D-05: 断点续跑 — 清理时机


**Decision:** 阶段完成 + 新阶段开始 + 用户主动重置


**清理时机（H2 + H3 组合）：**
- **H2:** 用户主动执行 `/gsd-reset-phase 5` 显式重置
- **H3:** Phase 6 开始时自动清除 Phase 5 的 checkpoint
- 阶段完成时（all plans done）自动清理

### D-06: 数据库类型自动检测 — 检测策略


**Decision:** 静态优先（E1）— 先配置文件，再连接字符串


**检测优先级:**
1. **配置文件扫描** — 读取 prisma/schema.prisma、sequelize config、typeorm config、knexfile 等
2. **连接字符串解析** — 分析 database URL（mysql://, postgresql://, mongodb://, sqlite://, redis://）
3. **文件扩展名** — 检测 .sqlite、.db 文件

**识别的数据库类型（MySQL + PostgreSQL + MongoDB + SQLite + Elasticsearch）:**
- MySQL / MariaDB
- PostgreSQL
- MongoDB
- SQLite
- Elasticsearch

### D-07: 数据库类型检测 — 输出机制

**Decision:** 独立标记文件 K1，与 project-type 一致


**文件:** `.flow-kit/database-type`

**格式：**
```
database_type: mysql|postgresql|mongodb|sqlite|elasticsearch
detected_at: {ISO date}
detection_method: config-file|connection-string|file-extension
confidence: high|medium|low
```

**读取方:** database-guardrails 的 DDL/DML 校验逻辑

### D-08: Skills 验证 — 通过标准

**Decision:** 4/4 全满足标准 + 分类处理

**每个 skill 的 SKILL.md 必须满足：**

| 标准 | 说明 |
|------|------|
| **L1: 使用场景** | 明确 when to use（什么情况下用这个 skill） |
| **L2: 输入/输出** | 有输入格式说明 + 期望输出格式 |
| **L3: 示例** | 至少一个示例对话或任务片段 |
| **L4: 限制说明** | 有边界说明（什么情况不适用） |

**4/4 全满足** — 最严格，质量有保障

### D-09: Skills 验证 — 分类处理

**Decision:** F3 方案 — 关键 skill 阻止，辅助 skill 警告

**Skill 分类：**

| 类别 | Skills | 验证失败行为 |
|------|--------|-------------|
| **关键 skill** | requirement-clarify, subagent-execution, verification-before-completion | 验证不通过则 abort，提示修复 |
| **辅助 skill** | task-master, code-review, debugging, parallel-dispatch | 验证失败输出警告，继续执行 |

### D-10: Skills 验证 — 执行方式

**Decision:** M2 + M3 组合 — 结构化检查 + 实战测试

**执行流程:**
1. **M2: 自动化脚本** — 正则匹配检查 L1-L4 结构化字段存在性（基础检查）
2. **M3: 实战测试** — 模拟实际任务场景调用 skill（如果 skill 有执行逻辑）

---

## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 已有决策（Phase 1-4）
- `.planning/phases/04-integration/04-CONTEXT.md` — Phase 4 集成决策
- `.planning/phases/02-guardrails/02-CONTEXT.md` — Phase 2 guardrails 决策
- `.planning/phases/01-core-skeleton/01-CONTEXT.md` — Phase 1 目录结构决策
- `flow-kit/guardrails/brownfield-guardrails.md` — 棕地护轨框架（B1-B6）
- `flow-kit/guardrails/database-guardrails.md` — 数据库安全规范（B2）

### v1.1 需求
- `.planning/REQUIREMENTS.md` — REQ-001~004 P0 需求定义
- `.planning/ROADMAP.md` — Phase 5 goal and success criteria

---

## Existing Code Insights

### Reusable Assets
- **brownfield-guardrails.md** — B1-B6 框架已存在，REQ-001 在此基础上增加自动检测
- **database-guardrails.md** — B2 DDL/DML 规范已存在，REQ-003 增加类型识别
- **phase-executor.md** — 阶段执行器已存在，REQ-002 增加断点续跑

### Established Patterns
- **Trigger/Behavior/Boundary/Output** — 护栏文件格式，phase 文件复用
- **.flow-kit/ 管理目录** — project-type、database-type 等标记文件统一放此

### Integration Points
- **phases/ 文件** — 读取 project-type 决定激活哪些 guardrails
- **database-guardrails** — 读取 database-type 匹配推荐工具
- **phase-executor** — 写入/读取 checkpoint-state.json

---

## Specific Ideas

- **业务代码行数统计白名单** — 参考 .gitignore 模式，方便扩展
- **断点续跑 Resume 提示** — 显示 "Phase N, Plan M, Task K" 便于用户确认

---

## Deferred Ideas

**Phase 6/7 会处理:**
- GO.md 增加棕地/绿地自动路由（REQ-005，P1）
- phase-executor 增加自动清窗（REQ-006，P1）
- 技术栈约束写入 Constitution（REQ-010，P2）

---

## Carried Forward from Phase 1-4

- `.flow-kit/` 作为 flow-kit 管理目录
- Trigger/Behavior/Boundary 结构
- 棕地护栏 B1-B6 框架
- DDL/DML 安全规范
- phase-executor 阶段执行模式

---

*Phase: 5-P0-bugfix*
*Context gathered: 2026-05-06*
