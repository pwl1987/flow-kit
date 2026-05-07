# 【CLAUDE CODE INSTRUCTION 强制约束】
> 本命令执行 5 点技能质量审计，输出技能依赖关系图和健康报告。

## 执行 /flow-kit:skill-audit

执行五项检查：

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

### 5. 拓扑报告
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
