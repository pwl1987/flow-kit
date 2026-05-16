---
phase: 5
name: "测试验证（绿地）"
stage: execution
allowed_operations:
  - 测试编写
  - 覆盖率检查
  - 端到端测试
forbidden_operations:
  - 需求修改
  - 架构变更
expected_artifacts:
  - 测试文件
next_phase: 6
---
# Phase 5: 测试验证 — 绿地项目

> 适用：从零开始的新项目开发

## 绿地项目重点

- 建立测试体系
- 新增覆盖率 ≥ 60%
- 配置 CI/CD

## 执行步骤

### Step 1: 测试金字塔

1. **测试层次**

   ```
        /\
       /E2E\
      /------\
     /Integr \
    /  Unit   \
   ```

2. **覆盖率要求**
   | 类型 | 要求 |
   |------|------|
   | 新增代码 | ≥ 60% |
   | 核心逻辑 | 100% |

### Step 2: 运行测试

```bash
npm test -- --coverage
```

### Step 3: CI/CD 配置

1. **GitHub Actions**
   ```yaml
   name: Test
   on: [push, pull_request]
   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - run: npm install
         - run: npm test
   ```

## 输出物

- 测试报告
- CI/CD 配置
- 覆盖率报告

## 下一步

- `/flow-kit:phase-6` — 代码审查
- `/flow-kit:next` — 自动推进
