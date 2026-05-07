# CHANGE.md — v1.3 Enhancement

## Change ID
v1.3-enhancement

## 描述
对标 rihebty/flow-kit 的 R1-R8 系统级硬规则体系、caveman 的精确 Token 压缩、pua 的 AI 懈怠检测、gstack 的生产安全护栏、agency-orchestrator 的 DAG 任务编排、BMAD-METHOD 的规模自适应，补齐 v1.2 在「系统级硬规则、输出成本控制、AI 懈怠检测、任务并行编排、生产安全、规模自适应」上的 6 个关键缺口。

## 变更类型
Enhancement (minor version bump: v1.2 → v1.3)

## 目标版本
v1.3

## 范围清单

### 新增文件
| 文件 | 描述 | 来源 |
|------|------|------|
| `config/system-rules.md` | R1-R8 系统级硬规则 | rihebty/flow-kit |
| `skills/caveman-compress.md` | 三级输出压缩技能 | JuliusBrussee/caveman |
| `skills/failure-detector.md` | AI 懈怠模式自检 | tanweai/pua |
| `skills/dag-resolver.md` | 任务 DAG 依赖解析 | jnMetaCode/agency-orchestrator |
| `commands/careful.md` | 生产安全护栏命令 | garrytan/gstack |
| `commands/scale-level.md` | 规模自适应深度选择 | bmad-code-org/BMAD-METHOD |

### 修改文件
| 文件 | 变更 | 来源 |
|------|------|------|
| `config/constitution.md` | 增加 system-rules.md 强制引用 | 规则链 |
| `phases/3-task.md` | 集成 DAG 解析器 | agency-orchestrator |
| `phases/4-dev.md` | 集成 caveman + failure-detector | caveman + pua |
| `lib/phase-executor.md` | 增加 R1.8 跨任务失败检查 | rihebty/flow-kit |
| `GO.md` | 注册新命令 + 初始加载 system-rules.md | 全局路由扩展 |

## 验收标准

1. `config/system-rules.md` 存在且包含 R1-R8 完整规则
2. `skills/caveman-compress.md` 存在且包含 Lite/Full/Ultra 三级压缩
3. `skills/failure-detector.md` 存在且包含 5 大懈怠模式 + 7 点排查清单
4. `skills/dag-resolver.md` 存在且包含 DAG 拓扑排序逻辑
5. `commands/careful.md` 存在且包含 /careful /freeze /guard 三级护栏
6. `commands/scale-level.md` 存在且包含 L0-L3 规模评估
7. `config/constitution.md` 包含对 system-rules.md 的强制引用
8. `phases/3-task.md` 包含 DAG 解析器集成
9. `phases/4-dev.md` 包含 caveman + failure-detector 集成
10. `lib/phase-executor.md` 包含 R1.8 跨任务失败检查
11. `GO.md` 包含新命令注册和 system-rules.md 初始加载
12. 所有文件使用中文撰写，术语与 GLOSSARY.md 一致
13. 无语法错误，所有命令路由可解析

## 变更理由

v1.2 存在 6 个关键缺口：
- **系统级硬规则缺失**：AI 长对话中易"自我提示"、忘记失败尝试
- **输出成本控制不足**：65-87% Token 节省空间未被利用
- **AI 懈怠检测缺失**：蛮力重试、推卸责任等模式无强制排查
- **任务并行编排原始**：简单 [P] 标记无 DAG 依赖解析
- **生产安全护栏缺失**：破坏性命令无警告机制
- **规模自适应缺失**：所有任务同一深度，无复杂度适配

## 影响评估

- **向前兼容**：v1.3 完全兼容 v1.2，新增命令不影响现有路由
- **配置变更**：新增 `config/system-rules.md`，constitution.md 引用链更新
- **无破坏性变更**：所有修改为增量，无文件删除

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit/blob/main/RULES.md) — R1-R8 系统级硬规则
- [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) — 精确 Token 压缩
- [tanweai/pua](https://github.com/tanweai/pua) — AI 懈怠检测
- [jnMetaCode/agency-orchestrator](https://github.com/jnMetaCode/agency-orchestrator) — DAG 任务编排
- [garrytan/gstack](https://github.com/garrytan/gstack) — 生产安全护栏
- [bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) — 规模自适应
