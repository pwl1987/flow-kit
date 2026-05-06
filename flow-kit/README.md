> 【CLAUDE CODE INSTRUCTION 强制约束】
>
> 本文件为 flow-kit 的入口文档。所有 flow-kit 操作从本文档开始。
> 禁止修改本文档结构。如需变更，参考 .planning/ROADMAP.md 的变更流程。

--- BEGIN flow-kit/README.md ---

# flow-kit 快速入口

## Quick Start

### 如何调用 flow-kit

1. **首次扫描**：执行 `/flow-kit:health` 进行代码健康检查
2. **创建规格目录**：创建 `.specs/{change-id}/` 目录结构
3. **开始变更**：使用 8 阶段开发工作流

### 首次使用步骤

```
1. /flow-kit:health        # 运行健康扫描，识别代码质量基线
2. mkdir .specs/$(date +%Y%m%d-%H%M%S)  # 创建变更规格目录
3. /flow-kit:scan          # 运行 Intel 扫描，检测 TODO/FIXME
4. /flow-kit:update-context  # 更新项目上下文
```

### 基本工作流

```
规划(0) → 上下文(1) → 规格(2) → 研究(3) → 计划(4) → 执行(5) → 审查(6) → 交付(7) → 回滚(8)
```

详细命令参考见 [GO.md](./GO.md)

---

## Cost Table

| Context Usage | Quality | Claude's State |
|---------------|---------|----------------|
| 0-30% | PEAK | Thorough, comprehensive |
| 30-50% | GOOD | Confident, solid work |
| 50-70% | DEGRADING | Efficiency mode begins |
| 70%+ | POOR | Rushed, minimal |

---

## Scenario Decision Tree

**What type of change?**

- **Simple** (1-3 files, known stack)
  - Minimal mode / skip phases
  - Example: Fix typo, update config, add simple feature

- **Medium** (new feature, existing stack)
  - Standard 8-phase flow
  - Example: Add API endpoint, implement feature module

- **Complex** (architecture, new stack)
  - Full 8-phase with design review
  - Example: New service, database migration, complex integration

- **Brownfield** (existing project)
  - Apply B1-B6 guardrails first
  - Then proceed with appropriate flow

---

## Command Reference

| Command | Description |
|---------|-------------|
| `/flow-kit:health` | Code health scan - analyzes code quality baseline |
| `/flow-kit:scan` | Intel scan - detects TODO/FIXME and technical debt |
| `/flow-kit:update-context` | Update project context with latest information |
| `/flow-kit:sync-config` | Sync team configuration across members |
| `/flow-kit:archive` | Archive completed change to history |

---

*See [GO.md](./GO.md) for detailed command documentation*

--- END flow-kit/README.md ---
