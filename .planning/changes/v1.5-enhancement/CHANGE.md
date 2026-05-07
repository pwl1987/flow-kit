# CHANGE.md — v1.5 Enhancement

## Change ID
v1.5-enhancement

## 描述
吸收外部方案的四个核心升级：
- **渐进披露 token 预算规则**（rihebty/flow-kit）：三类文件加载策略 + 首轮 REFERENCE ≤150 行
- **5 维设计评审**（huashu-design）：3 维升级至 5 维（+信息层级 +动效语义）+ 品牌资产协议
- **评分驱动自动迭代循环**（autoresearch）：PASSING_SCORE 升级，80+/60-79/40-59/<40 四档自动处理
- **结构化经验沉淀**（deer-flow）：LESSONS.md.template 升级为 YAML TIL 格式
- **并行执行协调协议**（gstack）：team-dispatch.md 增加聚合和冲突检测

## 目标版本
v1.5

## 范围清单

### 修改文件（8个）

| 文件 | 变更 |
|------|------|
| `GO.md` | +渐进披露规则表（SPEC/REFERENCE/PROMPT 三类加载策略） |
| `lib/phase-executor.md` | +文件加载策略检查，禁止全量读大型 REFERENCE |
| `phases/2a-ui-design/2a-ui-design.md` | 3 维→5 维 + 品牌资产协议 |
| `reference/frontend-engineer-rules.md` | +AI-slop 指纹库 v2（OKLCH + 禁止渐变正则） |
| `skills/failure-detector.md` | PASSING_SCORE → 自动迭代循环（最大 3 轮） |
| `templates/LESSONS.md.template` | 纯文本 → YAML TIL 结构化格式 |
| `skills/team-dispatch.md` | +并行执行协调协议（聚合 + 冲突检测） |
| `config/system-rules.md` | +R1.9 渐进披露规则 + R1.10 文件加载策略表 |

## 验收标准

1. GO.md 包含三类文件加载策略表（整读OK/grep/read offset）+ 首轮 REFERENCE ≤150 行
2. 2a-ui-design.md 包含 5 维设计评审（色彩/留白/排版/信息层级/动效）+ 品牌资产协议
3. failure-detector.md 包含自动迭代循环规则（四档 + 3 轮上限）
4. LESSONS.md.template 使用 YAML TIL 格式（id/type/severity/context/problem/root_cause/solution/prevention/tags/timestamp）
5. team-dispatch.md 包含并行聚合和冲突检测协议
6. system-rules.md 包含 R1.9 + R1.10
7. frontend-engineer-rules.md 包含 AI-slop 指纹库 v2（OKLCH + 禁止渐变正则）
8. 所有修改文件含参考来源段落

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit) — 渐进披露 token 预算规则
- [alchaincyf/huashu-design](https://github.com/alchaincyf/huashu-design) — 5 维设计哲学 + OKLCH 色彩空间
- [smallnest/autoresearch](https://github.com/smallnest/autoresearch) — PASSING_SCORE 自动迭代
- [bytedance/deer-flow](https://github.com/bytedance/deer-flow) — 结构化记忆 TIL 格式
- [garrytan/gstack](https://github.com/garrytan/gstack) — 并行 session 聚合