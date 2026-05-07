# CHANGE.md — v1.4 Enhancement

## Change ID
v1.4-enhancement

## 描述
补齐 v1.3 PRD 遗留的 3 个跨版本缺口（multi-ide-guide、skill-audit、2a-ui-design），并引入：
- CEP/gstack 策略先行理念（STRATEGY.md 锚点）
- gstack 6 角色虚拟工程团队（CEO/Designer/Eng-Manager/Reviewer/QA/Security）
- huashu-design 3 维设计评审（色彩系统/留白节奏/排版层次）
- autoresearch 质量评分机制（PASSING_SCORE 80 分默认）

## 目标版本
v1.4

## 范围清单

### 新增文件（6个）

| 文件 | 描述 | 来源 |
|------|------|------|
| `reference/multi-ide-guide.md` | 多 IDE 适配（Claude Code/Windsurf/Cursor/Copilot）| rihebty/flow-kit |
| `commands/skill-audit.md` | 5 点技能质量审计 | alirezarezvani/claude-skills + yknothing/skills-refiner |
| `phases/2a-ui-design/2a-ui-design.md` | UI 设计阶段（含 3 维评审） | huashu-design + garden-skills |
| `commands/strategy-first.md` | 策略先行锚点 | EveryInc/cep + gstack |
| `commands/team-roles.md` | 6 角色虚拟工程团队 | gstack + BMAD |
| `skills/team-dispatch.md` | DAG 角色任务分发 | Yeachan-Heo/oh-my-claudecode + agency-orchestrator |

### 修改文件（4个）

| 文件 | 变更 |
|------|------|
| `phases/1-requirement.md` | +strategy-first 可选步骤 |
| `phases/6-review.md` | +多角色审查集成 |
| `skills/failure-detector.md` | +PASSING_SCORE 质量评分 |
| `GO.md` | +4 命令路由 + 多 IDE 检测 |

## 验收标准

1. `reference/multi-ide-guide.md` 存在且包含 Claude/Windsurf/Cursor/Copilot 适配方案
2. `commands/skill-audit.md` 存在且包含 5 点审计（完整性/引用有效/版本标注/过期检测/拓扑报告）
3. `phases/2a-ui-design/2a-ui-design.md` 存在且包含 v0 草稿→UI-DESIGN.md→3维评审流程
4. `commands/strategy-first.md` 存在且输出 STRATEGY.md
5. `commands/team-roles.md` 存在且包含 6 角色（CEO/Designer/Eng-Manager/Reviewer/QA/Security）
6. `skills/team-dispatch.md` 存在且基于 DAG 路由
7. `phases/1-requirement.md` 包含 strategy-first 集成
8. `phases/6-review.md` 包含多角色审查集成
9. `skills/failure-detector.md` 包含 PASSING_SCORE（默认 80 分）
10. `GO.md` 包含 4 个新命令路由
11. 所有新文件含「参考来源」段落
12. VERSION 更新为 v1.4

## 变更理由

v1.3 遗留 3 个跨版本缺口 + 4 个新功能来源：
- multi-ide-guide: 多 IDE 用户需要适配指南
- skill-audit: 技能包质量需要自动审计
- 2a-ui-design: UI 设计阶段长期缺失
- strategy-first: 80% 时间应花在规划审查
- 6-role team: 单人 AI 缺乏多视角审查
- 3-dim review: 视觉一致性需要专门评审
- PASSING_SCORE: 质量驱动自动迭代

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit) — 多 IDE 适配方案
- [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) — 235 技能模块化组织
- [yknothing/skills-refiner](https://github.com/yknothing/skills-refiner) — skill-hygiene 拓扑扫描
- [alchaincyf/huashu-design](https://github.com/alchaincyf/huashu-design) — 20 设计哲学 + 5 维评审
- [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) — /ce-strategy 策略锚定
- [garrytan/gstack](https://github.com/garrytan/gstack) — 23 角色虚拟工程团队
- [bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) — Party Mode 单会话多角色
- [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — Team 模式任务分发
- [jnMetaCode/agency-orchestrator](https://github.com/jnMetaCode/agency-orchestrator) — DAG 并行检测
- [smallnest/autoresearch](https://github.com/smallnest/autoresearch) — PASSING_SCORE 评分驱动迭代