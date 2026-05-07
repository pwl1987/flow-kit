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

--- END flow-kit/phases/6-review/6-review.md ---
