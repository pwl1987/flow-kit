---
phase: 1
name: "需求澄清（绿地）"
stage: thinking
allowed_operations:
  - 需求提问
  - 验收标准定义
  - 用户故事编写
forbidden_operations:
  - 代码修改
  - 测试编写
expected_artifacts:
  - .flow-kit/requirements.md
next_phase: 2
---
# Phase 1: 需求澄清 — 绿地项目

> 适用：从零开始的新项目开发

## 绿地项目重点

- 定义 MVP 核心功能
- 识别非功能需求
- 制定发布计划

## 执行步骤

### Step 1: MVP 定义

1. **核心功能优先级**

   ```markdown
   ## MVP 功能定义

   ### P0 必须有（发布前）

   - [ ] 核心功能 1
   - [ ] 核心功能 2

   ### P1 第一版扩展（发布后 1 周）

   - [ ] 扩展功能 1
   - [ ] 扩展功能 2

   ### P2 后续迭代

   - [ ] 高级功能
   ```

### Step 2: 用户故事

使用 5W1H 方法：

- Who（谁使用）
- What（做什么）
- Why（为什么）
- When（何时用）
- Where（哪里用）
- How（怎么用）

```markdown
## 用户故事

### 用户故事 #1

**角色**：作为 [用户类型]
**我想要**： [功能]
**以便**： [价值]

**验收标准**：

- Given [条件]
- When [操作]
- Then [结果]
```

### Step 3: 非功能需求

| 类型   | 要求             |
| ------ | ---------------- |
| 性能   | 响应时间 < 200ms |
| 安全   | HTTPS、参数校验  |
| 兼容性 | 主流浏览器       |
| 可用性 | 99.9% uptime     |

### Step 4: 边界条件

识别极端情况和异常处理：

- 空输入
- 超大输入
- 并发请求
- 网络异常

## 输出物

- `.specs/{change-id}/REQUIREMENT.md` — 需求文档
- MVP 定义
- 用户故事
- 非功能需求

## 下一步

- `/flow-kit:phase-2` — 架构设计
- `/flow-kit:next` — 自动推进
