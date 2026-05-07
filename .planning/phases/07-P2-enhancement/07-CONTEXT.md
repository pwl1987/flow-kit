# Phase 7: P2 体验增强 - Context

**Gathered:** 2026-05-07
**Status:** Ready for planning

<domain>
## Phase Boundary

增强用户体验 — 技术栈约束、审批流、破坏性变更检测、扫描规则。

**Requirements:** REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015

</domain>

<decisions>
## Implementation Decisions

### Area A: constitution TECH-01 技术栈约束

- **D-A01:** Constitution + 外部引用模式
  - Constitution.md 新增 `TEAM-01 TECH-01` 章节，引用外部 `tech-constraints.md` 约束文件
  - 约束文件路径：`flow-kit/config/tech-constraints.md`
  - 技术栈约束维度：语言 + 框架 + 工具链（npm/pnpm/yarn 等）

- **D-A02:** 角色定义方式
  - Architect/Reviewer/Ops 角色定义放在外部引用文件 `team-roles.md`
  - 路径：`flow-kit/config/team-roles.md`
  - Constitution 引用 team-roles.md 中的角色定义

### Area B: P0-approval 审批流

- **D-B01:** P0 变更定义
  - P0 变更 = 不可逆的破坏性操作（irreversible destructive operations）
  - 显式标记 + 自动检测组合
  - 触发条件：`BREAKING-CHANGE.md` 文件、*.sql 文件、migration/ 目录

- **D-B02:** APPROVAL.md.template 结构
  - 结构化审批记录 + 二元决策（批准/拒绝）+ Constitution 强制校验
  - 关键字段：变更内容、风险等级、审批人、审批时间、决策理由
  - 拒绝决策与 Phase5-6 交付验证联动，未批准变更无法进入交付环节

- **D-B03:** p0-approval 与 phase-executor 集成
  - 独立命令 + executor 检测模式
  - executor 检测到 P0 时提示用户执行 p0-approval，并阻止进入 Phase5-6

### Area C: 破坏性变更检测

- **D-C01:** 检测范围
  - API 接口签名变更
  - 数据库字段删除
  - 配置文件结构变更
  - 依赖版本不兼容（package.json/yarn.lock 等锁文件变更）

- **D-C02:** 技术实现
  - 混用 Pattern-based + AST-based 检测
  - Pattern-based 用于快速文件指纹检测（速度优先）
  - AST-based 用于精确的 API 接口签名变更检测（精确优先）

- **D-C03:** 多语言规格中检测模式存放
  - 混用模式：各自语言规格内 + 统一检测配置
  - 统一检测配置：`flow-kit/reference/breaking-change-rules.md`
  - 各语言规格（go.md/java.md/php.md/python.md/rust.md/typescript.md）引用统一规则

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

- `flow-kit/config/constitution.md` — Constitution 安全配置参考
- `flow-kit/commands/p0-approval.md` — P0-approval 命令实现
- `flow-kit/commands/I-intel-scan.md` — I-intel-scan 命令实现
- `flow-kit/commands/M-health.md` — M-health 命令实现
- `flow-kit/commands/sync-team-config.md` — sync-team-config 命令实现
- `flow-kit/reference/language-specs/` — 6 个语言规格（go/java/php/python/rust/typescript）
- `.planning/ROADMAP.md` §Phase 7 — Phase 7 范围和成功标准

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- p0-approval.md 已有 P0 定义和触发条件，可直接扩展
- I-intel-scan.md 和 M-health.md 已有 Stack Detection 模式，可复用
- sync-team-config.md 已有 Constitution Sync Rules

### Established Patterns
- Constitution.md 强制约束模式：不可覆盖的安全规则
- 显式标记 + 自动检测的 P0 检测模式

### Integration Points
- phase-executor 与 p0-approval 的 P0 检测触发集成
- Constitution 与外部约束文件（tech-constraints.md, team-roles.md）的引用关系

</code_context>

<specifics>
## Specific Ideas

- APPROVAL.md.template 需要支持自动归档到 archive/ 目录
- 棕地项目自动启用审批模板，绿地项目可通过 user-config.md 配置免审批

</specifics>

<deferred>
## Deferred Ideas

- M-health / I-intel-scan 扫描规则充实（Phase 7 后续讨论）
- sync-team-config.md 实现细节（Phase 7 后续讨论）

</deferred>

---

*Phase: 7-P2-enhancement*
*Context gathered: 2026-05-07*