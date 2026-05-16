---
phase: 6
name: "代码审查（绿地）"
stage: thinking
allowed_operations:
  - Review反馈
  - 问题标记
  - 功能完整性审查
forbidden_operations:
  - 直接修改代码
expected_artifacts:
  - REVIEW.md
next_phase: 7
---
# Phase 6: 代码审查 — 绿地项目

> 适用：从零开始的新项目开发

## 绿地项目重点

- 三轮审查
- 架构合理性
- 开发规范

## 执行步骤

### Step 1: 第一轮 - 架构审查

1. **审查内容**
   - 架构设计合理
   - 模块划分清晰
   - 数据模型正确

2. **检查清单**
   - [ ] 架构符合项目规模
   - [ ] 模块边界清晰
   - [ ] 扩展性良好

### Step 2: 第二轮 - 设计审查

1. **审查内容**
   - API 设计
   - 错误处理
   - 日志规范

2. **检查清单**
   - [ ] RESTful 规范
   - [ ] 错误码统一
   - [ ] 日志级别正确

### Step 3: 第三轮 - 工程审查

1. **审查内容**
   - 代码规范
   - 测试覆盖
   - 文档完整

2. **检查清单**
   - [ ] ESLint 通过
   - [ ] 覆盖率达标
   - [ ] README 完整

## 输出物

- REVIEW.md — 审查报告
- 问题修复记录

## 下一步

- `/flow-kit:phase-7` — 集成归档
- `/flow-kit:next` — 自动推进
