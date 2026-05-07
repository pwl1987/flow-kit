# Phase 9: Skills 质量升级 - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-07
**Phase:** 09-Skills
**Areas discussed:** Phase Structure, UL/GLOSSARY Relationship, Conflict Detection, Clear Window

---

## Phase Structure（三阶段结构设计）

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | 严格顺序：Alignment Check → Deep Dive → Verification & Documentation，不循环 | |
| Option B | 有条件循环：Deep Dive 发现歧义可退回 Alignment Check；Verification 失败退回 Deep Dive | ✓ |
| Option C | 迭代深化：三阶段构成循环单元，每个需求经历多次"对齐→深入→验证" | |

**User's choice:** B — 有条件循环
- Alignment Check → Deep Dive：严格顺序，不可跳过
- Deep Dive 发现歧义影响整体目标 → 退回 Alignment Check
- Deep Dive 发现歧义仅影响局部细节 → 本阶段补充澄清，不回溯
- Deep Dive → Verification & Documentation：顺序执行
- Verification 失败 → 退回 Deep Dive，不回 Alignment Check

**Notes:** 用户提供了完整的退出标准方案：「用户确认+客观检查」双条件模式，与 Constitution 四原则对齐。

---

## UL/GLOSSARY Relationship（ubiquitous-language.md 与 GLOSSARY.md 的关系）

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | `skills/GLOSSARY.md` — 技能附属文件 | |
| Option B | `flow-kit/config/GLOSSARY.md` — 项目级全局权威，与 Constitution 并列 | ✓ |
| Option C | `.planning/GLOSSARY.md` — 项目规划文档的一部分 | |

**User's choice:** B — `flow-kit/config/GLOSSARY.md`
**理由:** 全局共享配置，与 Constitution 并列，体现项目级术语标准地位；适配跨阶段共享需求；职责完全分离（GLOSSARY=静态权威，ubiquitous=动态流程工具）。

**补充决策:**
- ubiquitous-language.md 路径: `skills/ubiquitous-language.md`
- 初始建立: 半自动（自动提取候选术语 + 人工审核确认）
- 维护机制: 触发变更 → 产品负责人审批 → 更新 GLOSSARY（版本号+1）
- Constitution 引用 GLOSSARY.md 作为唯一权威来源

---

## Conflict Detection（术语冲突检测机制）

| Option | Description | Selected |
|--------|-------------|----------|
| 自动扫描为主 | 关键节点强制触发，辅以显式调用 | ✓ |
| 显式调用为主 | 用户按需触发，辅以自动扫描 | |

**User's choice:** 自动扫描为主，显式调用为辅

**冲突分级:**
- 高优先级（阻断流程）: 同名不同义 → 暂停，走变更流程
- 中优先级（警告提示）: 同义不同名 → 输出警告+推荐，不强制阻断

**触发时机:** Alignment Check 结束前 / 设计初稿评审前 / 代码提交前（CI/CD）/ 评审文档提交前

---

## Clear Window（强制清窗规则）

| 清窗级别 | 触发场景 | 后续步骤 | Selected |
|---------|----------|----------|----------|
| 软清窗（默认） | 歧义积累超过阈值、用户主动触发 | 退回 Alignment Check 重新对齐，保留已澄清内容 | ✓ |
| 硬清窗（极端） | 连续2次软清窗仍无法对齐 | 终止当前流程，标记「无法达成共识」，需重新发起 | ✓ |

**用户选择:** 双模式结合 — 软清窗为主，硬清窗为极端场景备选

**决策机制:** 自动预警 + 用户确认（skill 输出原因报告，用户选择执行哪种）

---

## Deferred Ideas

None — discussion stayed within phase scope.

---

*Phase: 09-Skills*
*Discussion completed: 2026-05-07*