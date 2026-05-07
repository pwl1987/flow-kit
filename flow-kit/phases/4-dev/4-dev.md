--- BEGIN flow-kit/phases/4-dev/4-dev.md ---

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 flow-kit 工作流系统的核心骨架文件，定义开发执行的标准流程。
> 所有 phase 文件必须遵循此模板结构，包含触发条件、核心行为、边界情况、输出物四个标准章节。

# Phase 4: Development - 开发执行与 TDD

## 触发条件
{{TRIGGER}}

- Phase 3 任务拆分完成
- 用户显式启动开发流程
- 任务列表已通过确认

## 核心行为
{{CORE_BEHAVIOR}}

1. **TDD 循环执行**：遵循 Red-Green-Refactor 循环
   - Red：编写失败的测试
   - Green：编写通过的最简代码
   - Refactor：重构优化代码
2. **原子任务执行**：按任务列表顺序执行每个 5-15 分钟任务
3. **增量式代码生成**：每次任务完成时保持功能可用
4. **实时 lint/typecheck**：确保代码符合质量标准
5. **提交管理**：每个任务完成为一个逻辑提交点
6. **进度追踪**：监控任务完成率和阻塞点

## 边界情况
{{BOUNDARY_CASES}}

- **测试失败**：测试不通过时，优先修复测试或代码
- **任务阻塞**：遇到阻塞时，标记并跳过，继续执行其他任务
- **范围偏差**：开发中发现设计问题时，回溯到设计阶段
- **技术债务**：识别并记录而非立即处理
- **合并冲突**：多人协作时处理合并冲突

## 输出物
{{OUTPUTS}}

- **可运行代码**：通过基本测试的功能代码
- **测试套件**：覆盖核心功能的测试用例
- **提交历史**：清晰的增量提交记录
- **技术债务清单**：识别的待处理债务
- **后续 Phase 入口确认**：明确进入 5-test 的条件

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

--- END flow-kit/phases/4-dev/4-dev.md ---
