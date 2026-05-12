--- BEGIN flow-kit/phases/2-design/2-design.md ---

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 flow-kit 工作流系统的核心骨架文件，定义架构设计的标准流程。
> 所有 phase 文件必须遵循此模板结构，包含触发条件、核心行为、边界情况、输出物四个标准章节。

# Phase 2: Design - 架构设计与技术方案

## 触发条件

- Phase 1 需求澄清完成并确认
- 用户显式启动设计流程
- 需求文档已通过确认

## 核心行为

1. **技术栈选择**：根据需求选择合适的技术栈和框架
2. **架构设计**：设计系统架构，使用 5 Stack Cards 方法：
   - **数据流图**：数据如何流动和转换
   - **组件图**：核心组件及其关系
   - **API 设计**：接口定义和协议
   - **存储设计**：持久化方案和数据模型
   - **部署图**：服务部署和扩展策略
3. **技术方案评审**：评估方案的可行性、风险和性能影响
4. **依赖分析**：识别内部和外部依赖
5. **设计决策记录**：记录关键技术决策及其理由

## 边界情况

- **技术选型冲突**：多个技术方案竞争时，基于项目约束选择
- **性能瓶颈**：识别设计中的性能风险点
- **安全性设计**：识别安全需求并纳入设计
- **兼容性考虑**：识别需要兼容的现有系统接口
- **可扩展性**：设计需考虑未来扩展需求

## 输出物

- **架构设计文档**：包含 5 Stack Cards
- **技术决策记录**：ADR 格式的决策文档
- **API 规格说明**：接口定义和协议文档
- **数据模型定义**：实体和关系说明
- **后续 Phase 入口确认**：明确进入 3-task 的条件

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

END flow-kit/phases/2-design/2-design.md ---
