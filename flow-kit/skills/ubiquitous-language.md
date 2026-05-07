---
skill: SKILL-37
name: Ubiquitous Language
when_to_use: 术语冲突检测和 GLOSSARY 维护
phases: 1-requirement, 2-design, 4-dev, 6-review
---

# Ubiquitous Language Skill

## WHEN_TO_USE
- **Phase**: 1-requirement、2-design、4-dev、6-review
- **Trigger**: 自动扫描节点 + 显式调用
- **自动触发时机**:
  - Alignment Check 结束前（requirement-clarify.md 调用）
  - 设计评审前（2-design 阶段）
  - 代码提交前（4-dev 阶段）
  - 文档评审前（6-review 阶段）

## HOW_TO_USE

### Conflict Detection（冲突检测）

**扫描流程**:
1. 提取当前文档中所有术语（名词、专业概念）
2. 对比 GLOSSARY.md 中的定义
3. 检测冲突类型：
   - **高优先级（阻断流程）**: 同名不同义 — 同一术语在不同文档中含义冲突
   - **中优先级（警告）**: 同义不同名 — 不同术语指代相同概念
4. 输出冲突报告

**冲突分级处理**:

| 优先级 | 类型 | 处理 |
|--------|------|------|
| 高 | 同名不同义 | **阻断流程**，必须解决后才能继续 |
| 中 | 同义不同名 | **警告**，建议统一但不强制 |

**冲突处理流程**:
```
检测到冲突 → 输出报告 → 按优先级处理
                              ↓
                    高优先级：暂停流程，产品负责人确认定义
                    中优先级：记录警告，建议标准术语
                              ↓
                    更新 GLOSSARY（版本号+1）
                              ↓
                    重新扫描 → 确认无冲突 → 流程继续
```

**输出格式**:
```markdown
## 术语冲突检测报告

**扫描时间：** [timestamp]
**扫描文件：** [文件列表]

### 高优先级冲突（阻断流程）

| 术语 | 冲突类型 | 定义 A | 定义 B | 涉及文档 |
|------|----------|--------|--------|----------|

**处理建议：** 请产品负责人确认唯一定义，更新 GLOSSARY 后继续。

### 中优先级警告

| 术语 | 冲突类型 | 别名 A | 别名 B | 推荐标准术语 |
|------|----------|--------|--------|--------------|
```

### GLOSSARY Maintenance（维护机制）

**半自动建立流程**:
1. 从需求文档自动提取候选术语（名词、专业概念）
2. 人工审核确认（产品负责人）
3. 添加到 GLOSSARY.md（版本号+1）

**变更触发条件**:
- 新术语发现且需要明确定义
- 现有术语定义需要修正
- 术语消歧完成

**审批机制**:
- 变更需产品负责人审批
- 审批后更新版本号
- 维护日志记录变更

### 触发节点映射

| 阶段 | 触发时机 | GLOSSARY 操作 |
|------|----------|---------------|
| 1-requirement | Alignment Check 结束前 | 扫描候选术语 |
| 2-design | 设计评审前 | 验证术语一致性 |
| 4-dev | 代码提交前 | 验证实现术语 |
| 6-review | 文档评审前 | 最终术语确认 |

## EXAMPLE

**场景**: requirement-clarify.md Alignment Check 触发 UL 扫描

```
[requirement-clarify 执行 Alignment Check]

[触发 ubiquitous-language 扫描]

## 术语冲突检测报告

**扫描时间：** 2026-05-07 14:30
**扫描文件：** prd.md, user-story-1.md

### 高优先级冲突（阻断流程）

| 术语 | 冲突类型 | 定义 A | 定义 B | 涉及文档 |
|------|----------|--------|--------|----------|
| 用户 | 同名不同义 | 注册账户的人 | 系统管理员 | prd.md L5, user-story-1.md L12 |

**处理：** 暂停流程，请产品负责人确认「用户」的定义。

[处理完成后]

[更新 GLOSSARY]
- Term: 用户
- Definition: 在本系统中注册并拥有唯一账户的个人
- Version: 1.0 → 1.1

[重新扫描]
术语冲突检测报告: 无冲突
→ Alignment Check 继续
```

## NOTES

### 与 GLOSSARY.md 的关系
- **GLOSSARY.md**: 静态权威文档，项目级唯一真相来源
- **ubiquitous-language.md**: 动态流程工具，触发扫描和维护操作
- 所有术语定义必须通过 UL 流程更新 GLOSSARY

### 与 Constitution 的关系
- BP-01~04 约束所有术语讨论行为
- 冲突解决必须符合「Simplicity First」原则

### 验证检查
- [ ] 高优先级冲突必须阻断流程直到解决
- [ ] 每次 GLOSSARY 变更版本号+1
- [ ] 所有冲突报告包含具体文档位置
- [ ] 触发时机符合四阶段映射

---
**关联技能**: requirement-clarify.md (SKILL-30) — 触发来源
**输出文件**: GLOSSARY.md（维护）
**权威来源**: flow-kit/config/GLOSSARY.md
