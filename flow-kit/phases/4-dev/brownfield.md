---
phase: 4
name: "开发执行（棕地）"
stage: execution
allowed_operations:
  - 编码
  - 单元测试
  - 兼容性检查
forbidden_operations:
  - 架构变更
  - 需求修改
expected_artifacts:
  - 源码文件
next_phase: 5
---
# Phase 4: 开发执行 — 棕地项目

> 适用：已有代码库的业务迭代开发

## 棕地项目重点

- 增量开发
- 每次提交前运行护栏检查
- 保持现有功能正常

## 执行步骤

### Step 1: TDD 开发

1. **先写测试**

   ```bash
   # 编写新增功能的测试
   cat > tests/auth/third-party.test.ts
   ```

2. **运行现有测试**
   ```bash
   npm test -- --grep "现有功能"
   ```

### Step 2: 增量实现

1. **小步提交**
   - 每完成一个任务提交一次
   - 提交信息描述清晰

2. **护栏检查**
   ```bash
   /flow-kit:guard
   ```

### Step 3: 进度记录

更新 `PROGRESS.md`：

```markdown
## 完成情况

- [x] 任务 #1: Google 登录插件
- [ ] 任务 #2: GitHub 登录插件
```

## 输出物

- 代码实现
- 单元测试
- PROGRESS.md 更新

## 下一步

- `/flow-kit:phase-5` — 测试验证
- `/flow-kit:next` — 自动推进
