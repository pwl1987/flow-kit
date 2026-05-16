---
phase: 7
name: "集成部署（绿地）"
stage: execution
allowed_operations:
  - 部署脚本
  - 版本标记
  - 首次部署
forbidden_operations:
  - 需求修改
  - 架构变更
expected_artifacts:
  - 部署记录
next_phase: 8
---
# Phase 7: 集成归档 — 绿地项目

> 适用：从零开始的新项目开发

## 绿地项目重点

- 完整归档
- MVP 发布
- 项目复盘

## 执行步骤

### Step 1: 最终检查

1. **功能完整性**
   - [ ] MVP 功能全部完成
   - [ ] 文档齐全
   - [ ] 部署就绪

2. **质量检查**
   - [ ] 测试通过
   - [ ] 代码规范
   - [ ] 安全检查

### Step 2: 发布准备

1. **版本号**

   ```bash
   git tag v1.0.0
   ```

2. **发布检查清单**
   - [ ] CHANGELOG 更新
   - [ ] 版本号打标签
   - [ ] 部署脚本验证

### Step 3: 归档

1. **完整归档**

   ```
   .flow-kit/archive/
   └── {project-name}/
       ├── DESIGN.md
       ├── ARCHITECTURE.md
       ├── API.md
       ├── TEST-PLAN.md
       └── DEPLOYMENT.md
   ```

2. **项目复盘**
   - 做得好的
   - 需要改进的
   - 下次迭代注意

## 输出物

- 归档记录
- 项目文档
- 复盘报告

## 下一步

- `/flow-kit:archive` — 完成归档
