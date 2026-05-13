> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件实现最小模式白名单和阶段跳过逻辑。
> D4-4: Minimal Mode Implementation

# Minimal Mode

## 状态跟踪

| 状态字段 | 类型 | 默认值 | 说明 |
|---------|------|---------|------|
| `isMinimal` | boolean | false | 是否处于最小模式 |
| `minimalReason` | string | null | whitelist / manual |

## 触发方式

### 手动触发

```
/flow-kit:minimal
```

效果：
- `isMinimal = true`
- `minimalReason = "manual"`
- 输出：`[INFO] Minimal mode forced. Skipping Phase 5 (Test) and Phase 6 (Review).`

### 自动检测白名单

当变更涉及的文件全部匹配以下条件时自动触发：

**文件白名单**：
- `README.md`
- `CHANGELOG.md`
- `LICENSE`
- `*.config.js`
- `*.config.ts`
- `*.config.json`
- `*.yaml`
- `*.yml`

**目录白名单**：
- `flow-kit/` 下所有文件

**大小条件**：
- 单文件变更 < 50行diff
- 总变更文件数 < 3个

效果：
- `isMinimal = true`
- `minimalReason = "whitelist"`
- 输出：`[INFO] Minimal mode auto-activated (whitelist match). Skipping Phase 5/6.`

## 阶段跳过行为

当 `isMinimal = true` 时的执行路径：

```
Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 (Dev) -> [SKIP Phase 5] -> [SKIP Phase 6] -> Phase 7 (Integration)
```

### 跳过的阶段

| 阶段 | 原功能 | 跳过效果 |
|------|--------|----------|
| Phase 5: Test | 运行测试套件 | 无测试验证 |
| Phase 6: Review | 代码审查 | 无人工审查 |

### 保留的阶段

- Phase 1-4: 正常执行
- Phase 7: Integration（始终执行）
- Constitution安全检查：始终强制执行

## 与phase-executor集成

在 `flow-kit/lib/phase-executor.sh` 中的集成点：

```
1. Before Phase 5 execution:
   - Check isMinimal flag
   - If isMinimal == true:
     - Log: "Skipping Phase 5 (Test) - minimal mode"
     - Skip to Phase 6 check
   - Else:
     - Execute Phase 5 normally

2. Before Phase 6 execution:
   - Check isMinimal flag
   - If isMinimal == true:
     - Log: "Skipping Phase 6 (Review) - minimal mode"
     - Skip to Phase 7
   - Else:
     - Execute Phase 6 normally
```

## 安全保证

**Constitution规则始终强制执行**：

| 规则 | 说明 | 最小模式下 |
|------|------|-----------|
| SEC | 安全检查 | 始终运行 |
| DATA | 数据保护 | 始终运行 |
| DEPLOY | 部署安全 | 始终运行 |
| GIT | git操作安全 | 始终运行 |

最小模式影响范围：
- Phase 5 (Test) - 跳过
- Phase 6 (Review) - 跳过

不影响：
- Constitution安全检查
- Phase 1-4 开发活动
- Phase 7 集成验证

## 使用场景

| 场景 | 触发方式 | 说明 |
|------|----------|------|
| 快速修复文档 | 自动白名单 | 无需测试/审查 |
| 配置文件更新 | 自动白名单 | 低风险变更 |
| CI/CD快速部署 | 手动强制 | 跳过验证加速 |
| flow-kit内部更新 | 自动白名单 | flow-kit/目录下 |

---

**关联文件**：
- `@flow-kit/GO.md` (命令路由)
- `@flow-kit/lib/phase-executor.sh` (执行器集成)
- `@flow-kit/config/constitution.md` (安全规则)