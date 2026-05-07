# Phase 7: P2 体验增强 - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-07
**Phase:** 7-P2-enhancement
**Areas discussed:** constitution TECH-01, P0-approval 审批流, 破坏性变更检测

---

## Area A: constitution TECH-01 技术栈约束

| Option | Description | Selected |
|--------|-------------|----------|
| 约束文件 TEAM-01.md | 统一技术栈约束文件，清晰但需要额外的模板 | |
| Constitution 新章节 | 直接写在 constitution.md 新章节，操作简单但可能稀释核心原则 | |
| Constitution + 外部引用 | 分层：Constitution 引用外部约束文件，灵活但多一跳 | ✓ |

**User's choice:** Constitution + 外部引用
**Notes:** 技术栈约束放在外部文件（tech-constraints.md），Constitution 引用

---

## Area A2: Architect/Reviewer/Ops 角色定义方式

| Option | Description | Selected |
|--------|-------------|----------|
| 各自语言规格内 | 每个语言规格文件独立增加角色定义小节 | |
| 统一角色配置 | 统一的 roles.md 配置，供所有语言规格引用 | |
| 显式标记 + 自动检测 | 角色定义放在外部引用文件，与 Constitution 配合 | ✓ |

**User's choice:** 显式标记 + 自动检测
**Notes:** 角色定义放在外部文件 team-roles.md，Constitution 引用

---

## Area A3: 技术栈约束维度

| Option | Description | Selected |
|--------|-------------|----------|
| TS + Node.js 约束 | TypeScript + Node.js（前后端统一技术栈） | |
| 仅语言/框架约束 | 约束主要语言/框架，工具链不限制 | |
| 语言 + 框架 + 工具链 | 语言 + 框架 + 构建工具链（npm/pnpm/yarn 等） | ✓ |

**User's choice:** 语言 + 框架 + 工具链
**Notes:** 技术栈约束包含语言、框架、构建工具链三个维度

---

## Area B: P0 变更审批流触发范围

| Option | Description | Selected |
|--------|-------------|----------|
| 所有代码变更 | 所有非配置代码变更都需要审批，覆盖全面但可能过度 | |
| 仅关键破坏性变更 | 仅破坏性变更 + 关键基础设施，覆盖精准但可能遗漏 | |
| 显式标记 + 自动检测 | 显式标记的文件（BREAKING-CHANGE.md）+ 自动检测的 P0 条件 | ✓ |

**User's choice:** 显式标记 + 自动检测
**Notes:** P0 变更触发条件：BREAKING-CHANGE.md 文件、*.sql 文件、migration/ 目录

---

## Area B2: APPROVAL.md.template 内容结构

| Option | Description | Selected |
|--------|-------------|----------|
| 必须审批人签字 | 需要审批人明确批准，操作严格但流程重 | |
| 仅记录无需批准 | 自动记录即可，流程轻但约束力弱 | |
| 批准/拒绝二选一 | 审批人可批准或拒绝，拒绝则阻止合并 | ✓ |

**User's choice:** 以选项 3（批准/拒绝二选一）为核心，扩展为「结构化审批记录 + 二元决策 + Constitution 强制校验」的完整模板
**Notes:** 二元决策（批准/拒绝）+ 结构化审批记录 + Constitution 强制校验，拒绝与 Phase5-6 联动

---

## Area B3: p0-approval 与 phase-executor 集成方式

| Option | Description | Selected |
|--------|-------------|----------|
| executor 自动调用 | p0-approval 命令在 executor 的 P0 检测触发后自动调用 | |
| 用户手动触发 | 用户手动触发 p0-approval，executor 检测到时提示用户执行 | |
| 独立命令 + executor 检测 | p0-approval 作为独立命令运行，executor 检测到 P0 时提示并阻止 | ✓ |

**User's choice:** 独立命令 + executor 检测
**Notes:** p0-approval 独立运行，executor 检测到 P0 时提示并阻止进入 Phase5-6

---

## Area C: 破坏性变更检测范围

| Option | Description | Selected |
|--------|-------------|----------|
| API+DB+Config 范围 | API 接口签名变更、数据库字段删除、配置文件结构变更 | |
| + 依赖兼容性 | API 接口签名变更、数据库字段删除、配置文件结构变更、依赖版本不兼容 | ✓ |
| 仅文件类型检测 | 仅文件类型自动检测（*.sql, BREAKING-CHANGE.md）+ 代码行数阈值 | |

**User's choice:** + 依赖兼容性
**Notes:** 破坏性变更检测扩展到依赖版本不兼容（package.json/yarn.lock 等锁文件变更）

---

## Area C2: 破坏性变更检测技术实现

| Option | Description | Selected |
|--------|-------------|----------|
| Pattern-based 模式 | pattern-based detection - 速度优先，简单实用 | |
| AST-based 模式 | AST-based detection - 精确但需要依赖解析器 | |
| 混用两者 | 文件指纹 + 正则模式组合 | ✓ |

**User's choice:** 混用两者
**Notes:** Pattern-based 用于快速文件指纹检测，AST-based 用于精确的 API 接口签名变更检测

---

## Area C3: 多语言规格中检测模式存放位置

| Option | Description | Selected |
|--------|-------------|----------|
| 各自语言规格内 | 每个语言规格文件独立增加 BREAKING-CHANGE.md 小节 | |
| 统一的检测配置 | 统一的 BREAKING-CHANGE-CHECKER.md 配置，供所有语言规格引用 | |
| 混用两者 | 多语言规格内 + 统一配置混用 | ✓ |

**User's choice:** 混用两者
**Notes:** 统一检测配置 + 各语言规格引用

---

## Claude's Discretion

- M-health / I-intel-scan 扫描规则充实的具体扫描规则（待 Phase 7 后续讨论）
- sync-team-config.md 的具体实现细节（待 Phase 7 后续讨论）

## Deferred Ideas

- M-health / I-intel-scan 扫描规则充实（Phase 7 后续讨论）
- sync-team-config.md 实现细节（Phase 7 后续讨论）