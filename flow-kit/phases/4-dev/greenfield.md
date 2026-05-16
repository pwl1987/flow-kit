---
phase: 4
name: "开发执行（绿地）"
stage: execution
allowed_operations:
  - 编码
  - 单元测试
  - 功能实现
forbidden_operations:
  - 架构变更
  - 需求修改
expected_artifacts:
  - 源码文件
next_phase: 5
---
# Phase 4: 开发执行 — 绿地项目

> 适用：从零开始的新项目开发

## 绿地项目重点

- TDD 开发
- 建立代码规范
- 自动化格式化

## 执行步骤

### Step 1: 初始化项目

1. **创建项目结构**

   ```bash
   mkdir -p src/{user,auth,api}
   mkdir -p tests/{unit,integration}
   ```

2. **配置工具链**
   - ESLint + Prettier
   - TypeScript
   - Jest/Vitest

### Step 2: TDD 开发

1. **先写测试**

   ```bash
   # 用户注册功能
   cat > tests/user/register.test.ts
   ```

2. **实现功能**
   ```bash
   # 运行测试直到通过
   npm test
   ```

### Step 3: 代码规范

1. **提交前检查**

   ```bash
   npm run lint
   npm run format
   ```

2. **Git hook**
   - pre-commit 自动格式化
   - pre-push 运行测试

## 输出物

- 代码实现
- 单元测试
- CI/CD 配置

## 下一步

- `/flow-kit:phase-5` — 测试验证
- `/flow-kit:next` — 自动推进
