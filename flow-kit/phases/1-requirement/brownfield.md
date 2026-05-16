---
phase: 1
name: "需求澄清（棕地）"
stage: thinking
allowed_operations:
  - 需求提问
  - 验收标准定义
  - 影响分析
forbidden_operations:
  - 代码修改
  - 测试编写
expected_artifacts:
  - .flow-kit/requirements.md
next_phase: 2
---
# Phase 1: 需求澄清 — 棕地项目

> 适用：已有代码库的业务迭代开发

## 棕地项目重点

- 理解现有代码结构
- 明确修改边界（不破坏现有功能）
- 制定回归测试计划

## 执行步骤

### Step 1: 理解现有代码

1. **阅读现有实现**

   ```bash
   # 查看相关模块的代码
   cat src/auth/login.ts

   # 查看现有测试
   cat tests/auth/*.test.ts
   ```

2. **识别修改边界**
   - ✅ 新增文件（安全）
   - ✅ 修改已有文件的新增部分
   - ❌ 不修改核心接口签名
   - ❌ 不删除已有功能

### Step 2: 边界条件定义

1. **现有功能兼容性**
   - 现有 API 必须继续工作
   - 数据库向后兼容
   - 配置格式兼容

2. **回归测试计划**

   ```markdown
   ## 回归测试清单

   - [ ] 现有登录流程正常
   - [ ] 密码登录测试通过
   - [ ] 现有数据不受影响
   ```

### Step 3: 术语对齐

使用 `skills/ubiquitous-language.md` 检测术语冲突：

1. 识别需求文档中的关键术语
2. 与现有代码中的命名对比
3. 冲突未解决则阻断流程

### Step 4: 历史教训匹配

读取 `.specs/LESSONS.md`（若存在），匹配相似需求的教训。

## 输出物

- `.specs/{change-id}/REQUIREMENT.md` — 需求文档
- 回归测试清单
- 修改边界定义

## 下一步

- `/flow-kit:phase-2` — 架构设计
- `/flow-kit:next` — 自动推进
