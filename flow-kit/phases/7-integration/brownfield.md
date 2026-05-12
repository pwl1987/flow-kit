# Phase 7: 集成归档 — 棕地项目

> 适用：已有代码库的业务迭代开发

## 棕地项目重点

- 增量归档
- 经验教训沉淀
- 知识传承

## 执行步骤

### Step 1: 合并代码

1. **PR 审查**
   - 代码审查通过
   - 测试覆盖达标
   - 文档已更新

2. **合并**
   ```bash
   git checkout main
   git merge feature/xxx
   ```

### Step 2: 更新文档

1. **更新架构文档**
   - 新增扩展点说明
   - API 变更记录

2. **更新部署文档**
   - 配置变更
   - 环境变量

### Step 3: 归档变更

1. **归档内容**

   ```
   .flow-kit/archive/
   └── {change-id}/
       ├── CHANGE.md
       ├── REQUIREMENT.md
       ├── DESIGN.md
       ├── TASK.md
       ├── REVIEW.md
       └── SUMMARY.md
   ```

2. **经验教训**
   记录到 `.specs/LESSONS.md`：
   - 成功经验
   - 教训（避免重复踩坑）

## 输出物

- 归档记录
- LESSONS.md 更新
- 项目文档更新

## 下一步

- `/flow-kit:archive` — 完成归档
