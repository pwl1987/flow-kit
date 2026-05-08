--- BEGIN flow-kit/phases/0-change/0-change.md ---

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 flow-kit 工作流系统的核心骨架文件，定义变更识别的标准流程。
> 所有 phase 文件必须遵循此模板结构，包含触发条件、核心行为、边界情况、输出物四个标准章节。
>
> 占位符说明：本文档中的 {{TRIGGER}}、{{CORE_BEHAVIOR}}、{{BOUNDARY_CASES}}、{{OUTPUTS}} 等占位符由 AI 在阶段启动时根据实际变更上下文自动填充，用户无需手动替换。

# Phase 0: Change ID - 变更识别与立项

## 触发条件
{{TRIGGER}}

- 用户通过自然语言、Issue 或 Ticket 描述变更需求
- 系统识别到需要创建新的 Change ID 的场景
- 外部系统（如 GitHub Issue、Jira Ticket）触发变更请求

## 核心行为
{{CORE_BEHAVIOR}}

1. **变更需求解析**：解析用户输入，提取核心变更意图
2. **Change ID 生成**：为每个变更分配唯一标识符，格式：`{slugified-function}-{YYYYMMDD}`
   - 从用户需求提取核心功能关键词，转小写字母、数字、短横线组合（slugify）
   - 中文关键词转拼音首字母缩写或直译英文
   - 示例："添加通知中心" → `notification-center-20260508`
3. **变更分类**：将变更归类为 Feature/Bugfix/Refactor/Docs/Config
4. **关联分析**：识别变更涉及的范围、依赖和影响域
5. **立项登记**：在变更登记表中创建条目，记录变更元数据

## 边界情况
{{BOUNDARY_CASES}}

- **空输入**：用户未提供有效变更描述时，提示补充说明
- **重复变更**：检测是否与现有 Change ID 重复或重叠
- **超大变更**：单一变更涉及超过 5 个模块时，提示拆分为多个变更
- **跨团队变更**：涉及多团队时，识别主要负责团队
- **紧急变更**：标记为 P0 的变更直接进入快速通道

## 输出物
{{OUTPUTS}}

- **Change ID**：唯一标识符，如 `2026-05-001`
- **变更登记表条目**：包含变更类型、优先级、涉及模块
- **变更影响范围分析**：初步识别的受影响区域
- **后续 Phase 入口确认**：明确是否进入 1-requirement

---

END flow-kit/phases/0-change/0-change.md ---
