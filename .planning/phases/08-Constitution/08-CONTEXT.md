# Phase 8: Constitution 四原则 - Context

**Gathered:** 2026-05-07
**Status:** Ready for planning

<domain>
## Phase Boundary

将 Karpathy 四原则融入 `flow-kit/config/constitution.md`，作为最高行为约束（优先级高于其他所有规则）。

**Requirements:** CONST-01, GUARD-01

</domain>

<decisions>
## Implementation Decisions

### Area A: BEHAVIORAL PRINCIPLES 插入位置

- **D-A01:** 四原则作为独立章节
  - 在 UNOVERRIDABLE RULES 之后新建 `BEHAVIORAL PRINCIPLES` 章节
  - 四原则与安全规则平级并行，定位不同：安全规则 = 不可覆盖的红线，四原则 = 最高优先级行为准则
  - 四原则优先级高于其他所有规则（包括 TECH-01/02 等外部引用）

### Area B: 四原则具体措辞

- **D-B01:** Think Before Coding
  - 「首先理解问题域，再探索方案，最后才实现」
  - 强调理解优先于实现

- **D-B02:** Simplicity First
  - 「每增加一个抽象必须证明其必要性」
  - 提供具体判断标准：必要性证明

- **D-B03:** Surgical Changes
  - 「最小变更集——只改必要的，零顺手修改」
  - 最符合 "surgical" 本意

- **D-B04:** Goal-Driven Execution
  - 「完成标志 = 目标达成，不是任务列表走完」
  - 结果导向而非活动导向

### Area C: ROLE-01 集成方式

- **D-C01:** Constitution.md 新增 ROLE-01 条目
  - 在 UNOVERRIDABLE RULES 的 Technology Stack 之后（或单独章节）新增 ROLE-01
  - ROLE-01 内容：「角色定义详见 `flow-kit/config/team-roles.md`」
  - 在 ROLE-01 条目后立即补充声明：「All role-based approvals must respect the BEHAVIORAL PRINCIPLES」
  - 声明位置紧跟 ROLE-01，而非散落在其他章节

### Area D: GUARD-01 与四原则的关系

- **D-D01:** dependency-map.md 生成过程遵循原则约束
  - **Simplicity First** 约束：只记录必要的依赖信息，不追求全面覆盖
  - **Surgical Changes** 约束：变更时最小化 dependency-map.md 的更新范围，只更新受影响的模块条目
  - 这两条约束体现在 brownfield-guardrails.md 的 B1 入场扫描逻辑中，而非直接写入 dependency-map.md 格式

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

- `flow-kit/config/constitution.md` — Constitution 安全配置参考，Phase 8 直接修改此文件
- `flow-kit/config/team-roles.md` — Architect/Reviewer/Ops 角色定义，ROLE-01 指向此文件
- `flow-kit/config/tech-constraints.md` — Technology Stack 约束（TECH-01 引用）
- `flow-kit/guardrails/brownfield-guardrails.md` — 棕地护轨，B1 入场扫描需要增加 dependency-map.md 生成
- `.planning/ROADMAP.md` §Phase 8 — Phase 8 范围和成功标准
- `.planning/ROADMAP.md` §Phase 9-11 — Phase 9-11 的上下文参考
- `prd1.2.md` — v1.2 增量升级规格，CONST-01 和 GUARD-01 的原始需求来源

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- constitution.md 已有完整的 UNOVERRIDABLE RULES 结构，新 BEHAVIORAL PRINCIPLES 章节可复用现有表格格式
- team-roles.md 已有角色定义结构，ROLE-01 只需引用而非复制内容

### Established Patterns
- Constitution.md 强制约束模式：不可覆盖的安全规则 → 四原则是同类模式的行为准则
- 外部引用模式（TECH-01/02 指向外部文件）→ ROLE-01 复用此模式

### Integration Points
- BEHAVIORAL PRINCIPLES 章节与 UNOVERRIDABLE RULES 并列，都在 Priority Statement 覆盖范围内
- ROLE-01 与 TECH-01/02 在同一区域（Technology Stack 附近），保持结构一致性

</code_context>

<specifics>
## Specific Ideas

- 四原则在 constitution.md 中的条款编号建议：BP-01（Think Before Coding）、BP-02（Simplicity First）、BP-03（Surgical Changes）、BP-04（Goal-Driven Execution）
- BEHAVIORAL PRINCIPLES 章节标题建议：`## BEHAVIORAL PRINCIPLES（最高优先级）`

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 08-Constitution*
*Context gathered: 2026-05-07*
