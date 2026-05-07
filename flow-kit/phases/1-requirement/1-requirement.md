--- BEGIN flow-kit/phases/1-requirement/1-requirement.md ---

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 flow-kit 工作流系统的核心骨架文件，定义需求澄清的标准流程。
> 所有 phase 文件必须遵循此模板结构，包含触发条件、核心行为、边界情况、输出物四个标准章节。

# Phase 1: Requirements - 需求澄清与确认

## 触发条件
{{TRIGGER}}

- Phase 0 完成了 Change ID 生成并确认需要进一步澄清
- 用户显式启动需求澄清流程
- 变更登记表中标记为"需要需求澄清"

## 核心行为
{{CORE_BEHAVIOR}}

1. **需求获取**：通过对话式交互收集详细需求
2. **功能分解**：将需求分解为独立的功能点
3. **验收标准定义**：为每个功能点定义可验证的验收标准
4. **非功能性需求识别**：识别性能、安全、兼容性等约束
5. **需求确认**：与用户确认需求理解无误
6. **优先级排序**：基于变更类型和业务价值排序功能点

## 边界情况
{{BOUNDARY_CASES}}

- **模糊需求**：用户描述不明确时，使用 5W1H 方法追问澄清
- **矛盾需求**：识别相互冲突的需求点并提请用户决策
- **遗漏需求**：识别明显但未提及的需求并补充
- **范围蔓延**：当需求超出原始 Change ID 范围时，提示创建新变更
- **外部依赖**：识别需要外部系统配合的需求点

## 输出物
{{OUTPUTS}}

- **需求文档**：结构化的功能需求列表
- **验收标准清单**：每个功能点对应的验收条件
- **需求追踪矩阵**：需求与 Change ID 的映射关系
- **后续 Phase 入口确认**：明确进入 2-design 的条件

## 项目类型检测（Phase 6 增强）

### 混合模式检测逻辑
1. 检查 `.flow-kit/project-type` 是否存在
2. 若存在：直接读取项目类型
3. 若不存在：使用以下检测信号判断

### 检测信号（D-07）
| 信号 | 棕地指标 | 绿地指标 |
|------|----------|----------|
| 文件指纹 | package.json + lock 文件存在 | 缺少锁文件 |
| Git Remote | 关联 GitHub/GitLab | 无 remote |
| 业务代码行数 | src/ 目录存在且 > 5000 LOC | LOC < 5000 |
| 历史 | 有 git history | 新项目 |

### 检测触发逻辑（当 .flow-kit/project-type 不存在时）
```bash
# 检测 1: package.json + lock 文件 → brownfield
if [ -f "package.json" ] && [ -f "package-lock.json" -o -f "yarn.lock" -o -f "pnpm-lock.yaml" ]; then
  echo "brownfield" > .flow-kit/project-type
  return
fi

# 检测 2: git remote → brownfield
if git remote get-url origin &>/dev/null; then
  echo "brownfield" > .flow-kit/project-type
  return
fi

# 检测 3: src/ LOC < 5000 + 无 git remote → greenfield
SRC_LOC=$(find src/ -name "*.ts" -o -name "*.js" -o -name "*.tsx" -o -name "*.jsx" 2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
if [ "$SRC_LOC" -lt 5000 ] && ! git remote get-url origin &>/dev/null; then
  echo "greenfield" > .flow-kit/project-type
  return
fi

# 默认: brownfield（保守策略）
echo "brownfield" > .flow-kit/project-type
```

### Guardrails 联动
- 棕地项目：提示 `建议使用 /flow-kit:guardrails 启用棕地护栏`
- 绿地项目：提示 `建议使用标准开发流程`

--- END flow-kit/phases/1-requirement/1-requirement.md ---
