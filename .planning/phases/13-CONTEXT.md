# 13-CONTEXT.md — v1.3 Enhancement

## 变更 ID
v1.3-enhancement

## 阶段类型
Enhancement (非标准 Phase 13，用于 flow-kit 自我升级)

## 核心决策

### D1: system-rules.md 定位
- **决策**：`config/system-rules.md` 为独立文件，R1-R8 直接生效，不通过 constitution.md 嵌套
- **理由**：R1-R8 是可执行规则（HOW），constitution 是原则（WHAT），分离更清晰
- **来源**：PRD v1.3 Section 1

### D2: constitution.md 修改策略
- **决策**：在 BEHAVIORAL PRINCIPLES 前插入规则链引用段
- **理由**：保持 constitution 最高原则地位，同时明确 system-rules 是实际执行层
- **来源**：PRD v1.3 Section 2

### D3: caveman-compress 激活时机
- **决策**：4-dev SUMMARY.md 用 Full，5-test 用 Lite，6-review 用 Lite（严重问题保留完整）
- **理由**：不同阶段需要不同压缩力度，测试报告需要高可读性
- **来源**：PRD v1.3 Section 3

### D4: failure-detector 触发阈值
- **决策**：同一命令/方法连续失败 ≥ 2 次触发蛮力重试检测
- **理由**：1 次失败可能是偶然，≥2 次才是模式
- **来源**：PRD v1.3 Section 4

### D5: DAG 解析与 [P] 标记冲突
- **决策**：用户手动标记 [P] 与 DAG 检测冲突时，以 DAG 检测为准并警告用户
- **理由**：DAG 基于文件依赖分析，比主观标记更可靠
- **来源**：PRD v1.3 Section 5

### D6: careful 命令模式
- **决策**：`/careful` 警告模式，`/freeze` 限制编辑范围，`/guard` 两者合一
- **理由**：渐进式安全护栏，用户可选择介入深度
- **来源**：PRD v1.3 Section 6

### D7: scale-level 评估维度
- **决策**：L0 Quick Fix / L1 Feature / L2 Epic / L3 Architecture 四级
- **理由**：基于改动文件数量 + 是否涉及公共接口/数据库/核心框架
- **来源**：PRD v1.3 Section 7

### D8: R1.8 跨任务失败检查位置
- **决策**：在 lib/phase-executor.md 的 Pre-Requisite Gate 步骤中集成
- **理由**：所有 DEV 任务实现前必经此 Gate
- **来源**：PRD v1.3 Section 10

### D9: GO.md 命令扩展
- **决策**：新增 5 个命令路由：`/careful` `/freeze` `/guard` `/unfreeze` `/scale`
- **理由**：用户需要显式激活安全护栏，规模评估也需显式触发
- **来源**：PRD v1.3 Section 11

## 新增文件清单（6个）

| 文件 | R1-R8 规则数 | caveman 级别 | 懈怠模式 | 规模级 |
|------|-------------|-------------|---------|-------|
| `config/system-rules.md` | R1-R8 | - | - | - |
| `skills/caveman-compress.md` | - | Lite/Full/Ultra | - | - |
| `skills/failure-detector.md` | - | - | 5 大 + 7 点 | L0-L4 |
| `skills/dag-resolver.md` | - | - | - | - |
| `commands/careful.md` | - | - | - | - |
| `commands/scale-level.md` | - | - | - | L0-L3 |

## 修改文件清单（5个）

| 文件 | 变更点 |
|------|-------|
| `config/constitution.md` | +规则链引用段 |
| `phases/3-task.md` | +DAG 解析器集成 |
| `phases/4-dev.md` | +caveman + failure-detector |
| `lib/phase-executor.md` | +R1.8 跨任务失败检查 |
| `GO.md` | +5 命令路由 + system-rules 初始加载 |

## 术语一致性
- 全部使用中文撰写
- 术语与 `templates/GLOSSARY.md.template` 对齐
- 发现冲突使用 `skills/ubiquitous-language.md` 处理

## 参考来源
- rihebty/flow-kit RULES.md (R1-R8)
- JuliusBrussee/caveman (Token 压缩)
- tanweai/pua (懈怠检测)
- jnMetaCode/agency-orchestrator (DAG)
- garrytan/gstack (安全护栏)
- bmad-code-org/BMAD-METHOD (规模自适应)
