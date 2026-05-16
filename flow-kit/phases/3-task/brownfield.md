---
phase: 3
name: "执行计划（棕地）"
stage: thinking
allowed_operations:
  - 任务拆分
  - 优先级排序
  - 回归评估
forbidden_operations:
  - 代码修改
  - 测试执行
expected_artifacts:
  - .flow-kit/DEV-PLAN.md
next_phase: 4
---
# Phase 3: 任务拆解 — 棕地项目

> 适用：已有代码库的业务迭代开发

## 棕地项目重点

- 保持现有 API 契约
- 任务粒度 < 2 小时
- 识别可并行任务

## 执行步骤

### Step 1: 任务拆分

1. **按现有模块拆分**

   ```markdown
   ## 任务列表

   ### 任务 #1

   **模块**：src/auth/providers/
   **描述**：新增 Google 登录插件
   **估计**：2 小时
   **依赖**：无
   ```

2. **遵守现有接口**
   - 不改变已有接口签名
   - 新增接口独立实现

### Step 2: 依赖分析

1. **任务依赖图**

   ```
   [数据库模型] → [业务逻辑] → [API 接口]
         ↓
   [数据迁移]
   ```

2. **可并行检测**
   - 无依赖的任务可并行
   - 不同模块的任务可并行

### Step 3: 风险标记

高风险任务标记：

- 涉及核心接口修改
- 数据库结构变更
- 涉及认证/授权

## 输出物

- `.specs/{change-id}/TASK.md` — 任务列表
- 依赖关系图
- 风险标记

## 下一步

- `/flow-kit:phase-4` — 开发执行
- `/flow-kit:next` — 自动推进
