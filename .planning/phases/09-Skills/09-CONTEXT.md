# Phase 9: Skills 质量升级 - Context

**Gathered:** 2026-05-07
**Status:** Ready for planning

<domain>
## Phase Boundary

重写 `flow-kit/skills/requirement-clarify.md`（三阶段结构）+ 新增 `flow-kit/skills/ubiquitous-language.md`（术语冲突检测流程）+ 维护 `flow-kit/config/GLOSSARY.md`（全局术语权威）。

**Requirements:** SKILL-01, SKILL-02

</domain>

<decisions>
## Implementation Decisions

### Phase Structure（三阶段结构设计）

- **D-Phase-01:** 三阶段执行模型 = 有条件循环（B）
  - Alignment Check → Deep Dive：严格顺序，不可跳过
  - Deep Dive 发现歧义影响整体目标 → 退回 Alignment Check 重新对齐
  - Deep Dive 发现歧义仅影响局部细节 → 当前阶段补充澄清，不回溯
  - Deep Dive → Verification & Documentation：顺序执行
  - Verification 失败 → 退回 Deep Dive 补充澄清，不回 Alignment Check

- **D-Phase-02:** 三阶段退出标准 = 「用户确认 + 客观检查」双条件模式
  - Alignment Check：目标/范围/约束已梳理 + 术语无冲突（触发 GLOSSARY 扫描）+ 用户确认「理解一致」
  - Deep Dive：所有需求点「一次一问」完成 + 术语冲突已解决 + 用户确认「细节无异议」
  - Verification & Documentation：完整文档（含可验证验收标准）+ 用户确认「可作后续依据」
  - 回退触发 = 退出标准的反面，逻辑闭环

### Ubiquitous Language 与 GLOSSARY（三阶段退出标准与术语系统联动）

- **D-UL-01:** GLOSSARY.md 路径 = `flow-kit/config/GLOSSARY.md`（项目级全局权威，与 Constitution 并列）
- **D-UL-02:** ubiquitous-language.md 路径 = `skills/ubiquitous-language.md`（流程工具，附属需求澄清技能）
- **D-UL-03:** 职责分离原则 = GLOSSARY = 静态权威文档（仅存储术语定义），ubiquitous-language = 动态流程工具（定义如何使用/更新 GLOSSARY）
- **D-UL-04:** 初始建立 = 半自动（自动提取候选术语 + 人工审核确认）
- **D-UL-05:** 维护机制 = 触发变更 → 产品负责人审批 → 仅更新 GLOSSARY（版本号+1）
- **D-UL-06:** Constitution 引用 GLOSSARY.md 作为所有术语的唯一权威来源，冲突仲裁按 BP 原则

### Conflict Detection（术语冲突检测机制）

- **D-CD-01:** 冲突检测触发方式 = 双模式结合
  - 自动扫描（主流程，强制触发）：Alignment Check 结束前 / 设计初稿评审前 / 代码提交前（CI/CD）/ 评审文档提交前
  - 显式调用（辅助）：用户可手动按需触发（临时新增术语、跨部门协作、批量对齐）

- **D-CD-02:** 冲突定义与分级 = 两级处理
  - 高优先级（阻断流程）：同名不同义 → 必须暂停，走术语变更流程
  - 中优先级（警告提示）：同义不同名 → 输出警告+推荐标准术语，不强制阻断

- **D-CD-03:** 冲突处理流程：冲突报告 → 按优先级处理 → 更新 GLOSSARY（版本号+1）→ 重新扫描 → 流程继续 + 记录到维护日志

- **D-CD-04:** 与三阶段对齐：Alignment Check 的「术语无冲突」退出标准由自动扫描提供支撑，未通过无法进入 Deep Dive

### Clear Window（强制清窗规则）

- **D-CW-01:** 清窗触发条件 = 可量化双模式
  - 自动预警：Alignment Check（目标/范围失败>2次 或 高优先级术语冲突连续2次）/ Deep Dive（同一需求点反复澄清>2次 或 未解决歧义积累>3个）/ 全流程通用（偏离目标>2次 或 模糊表述>30%）
  - 用户主动触发：任意阶段可手动触发

- **D-CW-02:** 清窗分级 = 两级
  - 软清窗（默认）：退回 Alignment Check 重新对齐，保留已澄清内容
  - 硬清窗（极端）：终止当前流程，标记「无法达成共识」，需重新发起

- **D-CW-03:** 决策机制 = 自动预警 + 用户确认（skill 输出原因报告，用户选择执行哪种）

- **D-CW-04:** 联动闭环 = 三阶段流程（退回后需重新通过退出标准）+ 术语冲突检测（清窗后自动重新扫描）+ 维护日志

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

- `flow-kit/skills/requirement-clarify.md` — 现有技能文件，Phase 9 重写目标
- `flow-kit/config/constitution.md` — Constitution 四原则（BP-01~BP-04），为所有技能行为约束
- `flow-kit/config/GLOSSARY.md` — Phase 9 新增，全局术语权威来源（路径待创建）
- `flow-kit/config/team-roles.md` — 角色定义，术语变更审批规则参考
- `.planning/ROADMAP.md` §Phase 9 — Phase 9 范围和成功标准
- `.planning/phases/08-Constitution/08-CONTEXT.md` — Phase 8 四原则决策，carry-forward 参考

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- requirement-clarify.md 现有 GRILL-ME 模板：扩展为三阶段时保留，置于 Alignment Check 阶段
- Constitution 优先级覆盖模式：GLOSSARY.md 作为唯一权威来源，复用 Constitution 的外部引用模式

### Established Patterns
- 外部引用模式：GLOSSARY.md 引用路径 = `flow-kit/config/GLOSSARY.md`，与 TECH-01/02 外部引用模式一致
- 双条件退出标准：三阶段每阶段都有「用户确认+客观检查」双重标准，与 BP-04 Goal-Driven Execution 对齐

### Integration Points
- requirement-clarify.md 三阶段流程触发 ubiquitous-language.md 术语冲突检测（Alignment Check 退出标准）
- ubiquitous-language.md 维护流程更新 GLOSSARY.md（版本号+1）
- 清窗后自动重新触发术语冲突扫描（与 D-CD-04 联动）

</code_context>

<specifics>
## Specific Ideas

- 三阶段中的 Deep Dive 阶段使用「一次一问」模式，每个需求点单独深入问
- GLOSSARY.md 初始建立：半自动（自动提取 + 人工审核确认），避免完全手动或完全自动的歧义风险
- 清窗原因报告格式示例：`⚠️ 【流程预警：触发软清窗条件】原因：...请选择：① 执行软清窗；② 继续讨论；③ 执行硬清窗。`

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 09-Skills*
*Context gathered: 2026-05-07*