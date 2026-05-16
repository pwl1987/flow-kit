---
phase: 3
name: "执行计划（绿地）"
stage: thinking
allowed_operations:
  - 任务拆分
  - 优先级排序
  - 依赖规划
forbidden_operations:
  - 代码修改
  - 测试执行
expected_artifacts:
  - .flow-kit/DEV-PLAN.md
next_phase: 4
---
# Phase 3: 任务拆解 — 绿地项目

> 适用：从零开始的新项目开发

## 绿地项目重点

- 全新模块设计
- 每个任务 < 2 小时
- 建立任务跟踪

## 执行步骤

### Step 1: 按功能拆分

1. **核心模块划分**

   ```markdown
   ## 任务列表

   ### 任务 #1

   **模块**：src/user/
   **描述**：用户注册功能
   **估计**：3 小时
   ```

2. **前后端分离**
   - 前端任务
   - 后端任务
   - 联调任务

### Step 2: 任务排序

1. **优先级排序**
   - P0：核心功能
   - P1：重要功能
   - P2：辅助功能

2. **开发顺序**
   - 先核心后周边
   - 先数据后业务
   - 先接口后实现

### Step 3: 估算工时

| 任务类型   | 估计 |
| ---------- | ---- |
| 新增 API   | 1-2h |
| 新增页面   | 2-3h |
| 数据库设计 | 1-2h |
| 单元测试   | 1h   |

## 输出物

- `.specs/{change-id}/TASK.md` — 任务列表
- 优先级排序
- 工时估算

## 下一步

- `/flow-kit:phase-4` — 开发执行
- `/flow-kit:next` — 自动推进
