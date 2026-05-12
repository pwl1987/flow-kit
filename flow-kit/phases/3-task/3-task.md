--- BEGIN flow-kit/phases/3-task/3-task.md ---

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 flow-kit 工作流系统的核心骨架文件，定义任务拆分的标准流程。
> 所有 phase 文件必须遵循此模板结构，包含触发条件、核心行为、边界情况、输出物四个标准章节。

# Phase 3: Task - 任务拆分与细化

## 触发条件

- Phase 2 架构设计完成并确认
- 用户显式启动任务拆分流程
- 设计文档已通过评审

## 核心行为

1. **功能点拆解**：将设计文档中的功能点拆解为可执行任务
2. **任务细化**：将每个任务进一步细化为 5-15 分钟的原子任务
3. **任务依赖分析**：识别任务间的依赖关系和执行顺序
4. **[P] 可并行任务标记**：在任务列表中用 `[P]` 标记无依赖、可并行的任务
5. **自动 DAG 解析**：在 [P] 标记后自动调用 @flow-kit/skills/dag-resolver.md，用生成的执行顺序替换简单 [P] 标记
6. **任务估算**：评估每个任务的复杂度和工作量
7. **任务分配规划**：规划任务的分配策略（人/角色）
8. **验收条件映射**：将验收标准映射到具体任务

## 边界情况

- **任务过大**：单个任务超过 15 分钟时，继续拆分为子任务
- **任务过小**：多个小于 2 分钟的任务合并为组合任务
- **循环依赖**：识别任务间的循环依赖并重新设计
- **阻塞任务**：识别外部依赖导致的阻塞任务
- **优先级冲突**：同优先级任务竞争资源时，基于 Deadline 排序

## 输出物

- **任务列表**：原子化任务清单，每个任务 5-15 分钟
- **任务依赖图**：展示任务间依赖关系
- **任务估算报告**：工作量评估汇总
- **执行计划**：基于依赖和优先级的执行顺序
- **后续 Phase 入口确认**：明确进入 4-dev 的条件

## 依赖图

### 执行序列
（由 dag-resolver.md 自动生成）

### 并行组
（由 dag-resolver.md 自动生成）

### 关键路径
@critical: （由 dag-resolver.md 自动生成）

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
  echo "project_type: brownfield" > .flow-kit/project-type
  return
fi

# 检测 2: git remote → brownfield
if git remote get-url origin &>/dev/null; then
  echo "project_type: brownfield" > .flow-kit/project-type
  return
fi

# 检测 3: src/ LOC < 5000 + 无 git remote → greenfield
SRC_LOC=$(find src/ -name "*.ts" -o -name "*.js" -o -name "*.tsx" -o -name "*.jsx" 2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
if [ "$SRC_LOC" -lt 5000 ] && ! git remote get-url origin &>/dev/null; then
  echo "project_type: greenfield" > .flow-kit/project-type
  return
fi

# 默认: brownfield（保守策略）
echo "project_type: brownfield" > .flow-kit/project-type
```

### Guardrails 联动
- 棕地项目：提示 `建议使用 /flow-kit:guard full 启用棕地护栏`
- 绿地项目：提示 `建议使用标准开发流程`

---

END flow-kit/phases/3-task/3-task.md ---
