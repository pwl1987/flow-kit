# CHANGE.md — v1.7 Enhancement

## Change ID
v1.7-enhancement

## 描述
对标 rihebty/flow-kit，引入 5 项精度更高的机制：
- **进度恢复四段模板**：子代理完成时强制输出"已完成→当前在做→下一步→已排除方案"
- **执行计划三要素声明**：进入阶段前显式声明"已加载/未加载/第一动作"
- **三路线成本对比**：strategy-first 增加完整/极简/单点三挡位 token 预算对比
- **独立审查两阶段**：先输出审查计划，用户确认后再执行审查（防信息污染）
- **测试金字塔裁剪路由**：按项目类型自动选择测试层级组合

## 目标版本
v1.7

## 范围清单

### 新增文件（1个）

| 文件 | 描述 | 来源 |
|------|------|------|
| `templates/PROGRESS.md.template` | 子代理进度文件模板（含四段格式） | rihebty/flow-kit |

### 修改文件（7个）

| 文件 | 变更 |
|------|------|
| `skills/subagent-execution.md` | +进度恢复四段模板 |
| `GO.md` | +执行计划三要素声明规则 |
| `commands/strategy-first.md` | +三路线成本对比（完整/极简/单点） |
| `phases/6-review.md` | +两阶段独立审查机制（防信息污染） |
| `phases/5-test.md` | +测试金字塔裁剪路由 |
| `CLAUDE.md` | 版本号更新到 v1.7 |
| `commands/skill-audit.md` | +三要素合规检查 |

## 验收标准

1. `subagent-execution.md` 包含四段进度模板
2. `GO.md` 包含执行计划三要素声明规则
3. `strategy-first.md` 包含三路线成本对比
4. `phases/6-review.md` 包含两阶段独立审查机制
5. `phases/5-test.md` 包含测试金字塔裁剪路由
6. `templates/PROGRESS.md.template` 存在且含四段格式
7. `CLAUDE.md` 版本号更新到 v1.7
8. `skill-audit.md` 包含三要素合规检查

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit) — 进度恢复四段模板、执行计划三要素声明、三路线成本对比、独立审查两阶段、测试金字塔裁剪路由、PROGRESS.md 模板