---
phase: 4
name: "开发执行"
stage: execution
allowed_operations:
  - 编码
  - 单元测试
forbidden_operations:
  - 架构变更
  - 需求修改
expected_artifacts:
  - 源码文件
next_phase: 5
---
--- BEGIN flow-kit/phases/4-dev/4-dev.md ---

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 flow-kit 工作流系统的核心骨架文件，定义开发执行的标准流程。
> 所有 phase 文件必须遵循此模板结构，包含触发条件、核心行为、边界情况、输出物四个标准章节。

# Phase 4: Development - 开发执行与 TDD

## v1.3 升级指令

### caveman 压缩集成
子代理启动时自动加载 @flow-kit/skills/caveman-compress.md（Full 级别），SUMMARY.md 使用 Full 压缩。

### failure-detector 集成
启用 @flow-kit/skills/failure-detector.md 的自动触发条件监控：
- 同一命令/方法连续失败 ≥ 2 次 → 触发蛮力重试检测
- 输出包含推卸责任话术 → 触发推卸责任检测
- 有搜索能力但不搜索 → 触发工具闲置检测

若出现触发条件立即暂停并执行 7 点排查清单。

### R1.6 反重复检查联动
每次恢复工作前：
1. 读 PROGRESS.md 的「已排除方案」段
2. 确认接下来要尝试的方案不在该清单里
3. 若新方案与已排除方案相同或近似，必须显式回答差异

## 触发条件

- Phase 3 任务拆分完成
- 用户显式启动开发流程
- 任务列表已通过确认

## 核心行为

### TDD 硬阻断（强制执行）

**触发时机：** 进入 TDD 循环前（Red 阶段前）

**阻断规则：**
1. **验证必须可执行**：测试代码必须是可运行的测试（禁止伪代码、占位符、注释掉的代码）
2. **Red 未完成 → Green 禁止**：未编写失败的测试用例不允许进入实现阶段
3. **框架中立**：不强制特定测试框架，但验证必须可实际运行（能执行、能失败、能通过）
4. **阻断检查点**：
   - 检查测试文件是否创建
   - 检查测试是否为有效代码（非空、非占位符）
   - 检查测试可执行（能运行并产生结果）

**违反处理：** 若跳过测试直接写实现，executor 需在提交前补充测试，否则拒绝提交。

---

**Goal-Driven Execution（目标驱动执行）**

_核心理念：任务完成 = 完成标志达成，不是任务列表走完。_

**规则：**

1. **完成标志要求**：每个 TASK.md 任务必须包含 `完成标志: [验收标准]` 字段
2. **客观验证**：完成标志必须是可客观衡量的（test passes / 验收标准 / 里程碑）
   - 禁止：主观描述（"完成"、"处理好"、"差不多了"）
   - 允许：具体指标（"单元测试全部通过"、"API 返回 200"、"文件已创建"）
3. **任务完成判断**：executor 验证完成标志达成后方可标记任务完成
4. **模板更新**：新任务模板由 executor 创建时更新，不追溯修改现有 TASK.md

**完成标志格式：**

```
完成标志: [test passes | 验收标准描述 | 里程碑描述]
```

**示例：**

- `完成标志: 所有新增单元测试通过（jest --passing）`
- `完成标志: API 端点 /users 返回 200 且响应结构符合 schema`
- `完成标志: src/auth.ts 文件已创建并导出 AuthService 类`

---

### TDD 循环执行

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

- **测试失败**：测试不通过时，优先修复测试或代码
- **任务阻塞**：遇到阻塞时，标记并跳过，继续执行其他任务
- **范围偏差**：开发中发现设计问题时，回溯到设计阶段
- **技术债务**：识别并记录而非立即处理
- **合并冲突**：多人协作时处理合并冲突

## 输出物

- **可运行代码**：通过基本测试的功能代码
- **测试套件**：覆盖核心功能的测试用例
- **提交历史**：清晰的增量提交记录
- **技术债务清单**：识别的待处理债务
- **后续 Phase 入口确认**：明确进入 5-test 的条件

## 【强制】阶段切换交接验证门

> v1.11 新增：4-dev → 5-test 切换时触发 Agent 交接验证门

**切换前检查**：

1. 触发 `@flow-kit/skills/agent-pipeline.md` 的 Agent 交接验证门
2. 输出 Handler 覆盖矩阵（验证 API endpoint → handler 函数映射）
3. 执行 Task-PRD 对齐检查（验证功能点覆盖）
4. 更新追责链（记录任务负责人和完成状态）

**通过条件**：6 项自检全部通过 + 交接验证门通过
**失败处理**：暂停并等待修复，不进入 5-test

## 项目类型检测（Phase 6 增强）

### 混合模式检测逻辑

1. 检查 `.flow-kit/project-type` 是否存在
2. 若存在：直接读取项目类型
3. 若不存在：使用以下检测信号判断

### 检测信号（D-07）

| 信号         | 棕地指标                     | 绿地指标   |
| ------------ | ---------------------------- | ---------- |
| 文件指纹     | package.json + lock 文件存在 | 缺少锁文件 |
| Git Remote   | 关联 GitHub/GitLab           | 无 remote  |
| 业务代码行数 | src/ 目录存在且 > 5000 LOC   | LOC < 5000 |
| 历史         | 有 git history               | 新项目     |

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

--- END flow-kit/phases/4-dev/4-dev.md ---

<!-- v3.1.0 session-state: 每完成一个任务时调用 session_task_set T{N} done 更新记忆 -->
