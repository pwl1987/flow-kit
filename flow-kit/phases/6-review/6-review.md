--- BEGIN flow-kit/phases/6-review/6-review.md ---

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 flow-kit 工作流系统的核心骨架文件，定义代码评审的标准流程。
> 所有 phase 文件必须遵循此模板结构，包含触发条件、核心行为、边界情况、输出物四个标准章节。

# Phase 6: Review - 三层代码评审

## 触发条件
{{TRIGGER}}

- Phase 5 测试验证通过
- 用户显式启动评审流程
- 代码处于可评审状态

## 核心行为
{{CORE_BEHAVIOR}}

1. **第一层 - 正确性评审**：验证代码逻辑正确性
   - 功能是否符合需求
   - 边界条件处理
   - 错误处理完整性
2. **第二层 - 质量评审**：验证代码质量
   - 代码风格和可读性
   - 架构一致性
   - 测试覆盖充分性
3. **第三层 - 安全评审**：验证安全性
   - 输入验证
   - 权限检查
   - 敏感数据处理
4. **评审意见处理**：对评审意见进行分类和优先级排序
5. **复审确认**：确认评审意见已处理

## 边界情况
{{BOUNDARY_CASES}}

- **评审意见冲突**：评审意见相互冲突时提请裁决
- **架构偏差**：代码与设计架构不一致时要求整改
- **安全漏洞**：发现安全漏洞时立即标记并修复
- **性能问题**：性能不达标时要求优化
- **评审超时**：评审时间过长时进入快速评审模式

## 输出物
{{OUTPUTS}}

- **评审报告**：三层评审结果汇总
- **修复清单**：需要修复的问题列表
- **评审结论**：通过/有条件通过/拒绝
- **后续 Phase 入口确认**：明确进入 7-integration 的条件

## 【强制】阶段切换交接验证门

> v1.11 新增：6-review → 7-integration 切换时触发 Agent 交接验证门

**切换前检查**：
1. 触发 `@flow-kit/skills/agent-pipeline.md` 的 Agent 交接验证门
2. 输出 Handler 覆盖矩阵（验证审查意见 → 代码改动映射）
3. 执行 Task-PRD 对齐检查（验证审查意见覆盖完整）
4. 更新追责链（记录审查负责人和完成状态）

**通过条件**：6 项自检全部通过 + 交接验证门通过
**失败处理**：暂停并等待修复，不进入 7-integration

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

## 【强制】两阶段独立审查（防信息污染）

> v1.7 新增：避免一次调用中的自我肯定偏差

### 阶段 A·审查计划

先输出审查计划，包含：
- 审查范围（哪些文件/模块）
- 重点关注维度（正确性/安全性/性能/可读性）
- 预期审查深度（P0 致命 / P1 严重 / P2 一般 / P3 建议）

等待用户确认后进入阶段 B。

### 阶段 B·审查执行

用户确认计划后，在新子代理中执行审查：
- 仅携带审查计划和原始代码
- **不携带**阶段 A 的中间讨论
- 独立输出评审意见

### 目的

避免 AI 在起草计划时进入审查模式，产生自我肯定偏差。

---

## 【强制】多角色审查（Multi-Role Review）

> 【CLAUDE CODE INSTRUCTION 强制约束·多角色审查】
>
> 1. 对高风险变更（涉及安全/数据库/公共API），自动激活 @flow-kit/commands/team-roles.md。
> 2. 按角色顺序执行审查：Reviewer → Security（若涉及安全）→ Designer（若涉及UI）。
> 3. 每个角色输出独立审查段，问题汇总到 REVIEW.md 按 P0-P3 分级。
> 4. 角色切换遵守 R3.4（清窗后切换）。

### 高风险变更判定

满足任一条件即触发多角色审查：

- 涉及数据库 schema 变更
- 涉及公共 API 接口
- 涉及安全敏感操作（认证/授权/支付）
- 涉及 3 个以上文件变更

### 审查角色顺序

1. **Reviewer**：代码审查 + 生产 bug 发现
2. **Security**：OWASP + STRIDE 审计（高风险变更时）
3. **Designer**：UI 变更时激活（色彩/排版/布局）

### 输出格式

每个角色输出独立段：

```markdown
## Reviewer 审查

[检查结果]

## Security 审查

[检查结果]

## Designer 审查

[检查结果]
```

问题汇总到 REVIEW.md 按 P0-P3 分级。

--- END flow-kit/phases/6-review/6-review.md ---
