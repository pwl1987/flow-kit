--- BEGIN flow-kit/phases/5-test/5-test.md ---

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 flow-kit 工作流系统的核心骨架文件，定义测试验证的标准流程。
> 所有 phase 文件必须遵循此模板结构，包含触发条件、核心行为、边界情况、输出物四个标准章节。

# Phase 5: Test - 测试验证与质量确认

## 触发条件

- Phase 4 开发完成并提交
- 用户显式启动测试验证流程
- 代码库处于可测试状态

## 核心行为

### 测试金字塔裁剪路由

> v1.7 新增：按项目类型自动选择测试层级组合

根据项目类型自动选择测试组合：

| 项目类型 | 测试层级组合 | 跳过 |
|---------|------------|------|
| **前端项目** | 单元测试 → 组件测试 → E2E | 性能压力测试、兼容性测试 |
| **后端/API 项目** | 单元测试 → 集成测试 → 性能压力测试 | E2E |
| **全栈项目** | 单元测试 → 集成测试 → E2E | 性能压力测试（除非明确要求） |
| **CLI/库项目** | 单元测试 → 兼容性测试 | E2E、性能压力测试 |

1. **测试执行**：运行完整测试套件
2. **覆盖率分析**：检查代码覆盖率是否达到阈值
3. **缺陷修复**：对发现的缺陷进行定位和修复
4. **回归测试**：确保修复未引入新问题
5. **验收测试**：基于需求文档执行验收测试
6. **质量门检查**：验证所有质量指标达标

## 边界情况

- **测试超时**：长时间运行的测试识别并优化
- ** flaky 测试**：识别不稳定测试并隔离处理
- **覆盖率不足**：未达标时补充测试用例
- **环境差异**：测试环境与生产环境差异导致的失败
- **已知缺陷**：已记录的缺陷与新发现缺陷的区分

## 输出物

- **测试报告**：执行结果和覆盖率报告
- **缺陷清单**：发现的缺陷及修复状态
- **验收测试结果**：是否满足验收标准
- **质量门确认**：各指标达标状态
- **后续 Phase 入口确认**：明确进入 6-review 的条件

## 【强制】阶段切换交接验证门

> v1.11 新增：5-test → 6-review 切换时触发 Agent 交接验证门

**切换前检查**：
1. 触发 `@flow-kit/skills/agent-pipeline.md` 的 Agent 交接验证门
2. 输出 Handler 覆盖矩阵（验证测试用例 → API handler 映射）
3. 执行 Task-PRD 对齐检查（验证测试覆盖功能点）
4. 更新追责链（记录测试负责人和完成状态）

**通过条件**：6 项自检全部通过 + 交接验证门通过
**失败处理**：暂停并等待修复，不进入 6-review

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

END flow-kit/phases/5-test/5-test.md ---

<!-- v3.1.0 session-state: 测试通过时 session_set status done，失败时 session_set status blocked -->
