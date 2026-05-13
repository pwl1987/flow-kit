# 【CLAUDE CODE INSTRUCTION 强制约束】
> 本命令执行 8 点技能质量审计，输出技能依赖关系图和健康报告。

## 执行 /flow-kit:scan

执行八项检查：

### 1. 完整性检查
检查所有 .md 文件是否包含必需字段：
- 触发条件（activation conditions）
- 核心行为（core behavior）
- 输出物（outputs）

### 2. 引用有效性
检查所有 `@flow-kit/xxx.md` 引用是否存在对应文件。
输出格式：
```
⚠️ 悬空引用: @flow-kit/xxx.md (文件不存在)
✅ 有效引用: @flow-kit/skills/yyy.md
```

### 3. 版本标注
检查每个技能文件是否有「参考来源」段落。
无参考来源的文件标记为"待补充"。

### 4. 过期检测
若参考来源库有重大更新（检查 GitHub release/API breaking changes），标记为"待review"。

### 5. 斜杠命令注册状态审计

检查 `.claude/commands/` 下的斜杠命令注册状态：
- 命令文件是否存在且最新
- 交叉引用完整性（命令 → 源文件）
- 过期检测（源文件比命令文件新）

### 6. Benchmark 评分

| 维度 | 评分标准 | 权重 |
|------|---------|------|
| 完整性 | 包含触发条件+核心行为+输出物 | 0.3 |
| 引用有效性 | 所有 @flow-kit 引用存在 | 0.2 |
| 版本标注 | 有参考来源段落 | 0.15 |
| 斜杠命令 | 在 .claude/commands/ 已注册 | 0.15 |
| 可维护性 | 单一职责、结构清晰 | 0.2 |

### 7. GO.md 三要素合规检查

> v1.7 新增：检查执行计划三要素声明规范

检查 phases/ 下各阶段的执行逻辑是否包含"已加载/未加载/第一动作"三要素声明。

输出格式：
```
✅ 合规: phase-2-design.md
❌ 缺失"未加载": phase-3-task.md
❌ 缺失"第一动作": phase-5-test.md
```

### 8. 拓扑报告
输出技能依赖关系图到 `.specs/skill-audit-report.md`：
```yaml
## 技能拓扑图

### 依赖关系
- requirement-clarify.md → constitution.md, system-rules.md
- task-master.md → constitution.md, system-rules.md

### 审计结果
| 文件 | 完整性 | 引用 | 版本标注 | 过期 |
|------|--------|------|----------|------|
| requirement-clarify.md | ✅ | ✅ | ✅ | - |
```

输出文件：`.specs/skill-audit-report.md`

---

## 参考来源

- [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) — 235 技能模块化组织方式
- [yknothing/skills-refiner](https://github.com/yknothing/skills-refiner) — skill-hygiene 拓扑扫描
