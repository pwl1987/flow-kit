> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件实现回滚工作流命令规格。
> D-RB-01: 回滚粒度 = commit + 生成文件
> D-RB-02: 触发方式 = 手动/自动/监控三种
> D-RB-03: 回滚深度 = 仅已标记的稳定点
> D-RB-04: 用户调整标记 = --adjust=promote|demote|remove
> D-RB-05: 安全护栏 = 确认提示 + 备份创建 + 影响范围预览
> D-RB-06: 回滚后处理 = 自动写入 LESSONS.md

# Rollback

## 命令格式

```
/flow-kit:phase-8 --phase=<phase-id> [--trigger=<manual|auto|monitor>] [--force] [--adjust=<promote|demote|remove>]
```

## 参数说明

| 参数        | 必需 | 默认值 | 说明                                      |
| ----------- | ---- | ------ | ----------------------------------------- |
| `--phase`   | 是   | -      | 指定要回滚的阶段ID                        |
| `--trigger` | 否   | manual | 触发方式：manual / auto / monitor         |
| `--force`   | 否   | false  | 跳过所有安全护栏（危险）                  |
| `--adjust`  | 否   | -      | 调整稳定点标记：promote / demote / remove |

## 状态跟踪

| 状态字段         | 类型    | 默认值 | 说明                 |
| ---------------- | ------- | ------ | -------------------- |
| `canRollback`    | boolean | false  | 是否有可回滚的稳定点 |
| `lastRollbackAt` | string  | null   | 上次回滚时间         |

## 触发方式

### 手动触发

```
/flow-kit:phase-8 --phase=<phase-id> --trigger=manual
```

效果：

- 加载 `.planning/checkpoints/{phase}-stable.json`
- 验证存在可回滚的稳定点
- 执行安全护栏检查

### 自动触发

当以下条件满足时自动触发：

- 监控检测到阶段状态异常
- 连续3次验证失败
- 标记为 `auto-trigger-enabled` 的阶段

效果：

- 设置 `lastRollbackAt = now()`
- 记录 `rollbackReason = "auto-trigger"`
- 写入 LESSONS.md

### 监控触发

```
/flow-kit:phase-8 --phase=<phase-id> --trigger=monitor
```

用于持续监控场景：

- 定期检查阶段健康状态
- 异常时发送告警并等待确认
- 确认后执行回滚

## 安全护栏

### 1. 确认提示

回滚前必须确认：

```
[WARNING] Rollback Phase {phase-id}
Impact Preview:
  - Files to revert: {n}
  - Changes since stable: {description}
  - This action cannot be undone.

Type 'yes' to confirm:
```

### 2. 备份创建

执行回滚前自动创建备份：

```
backup/{phase}-{YYYY-MM-DD-HHMMSS}/
├── commits/
├── files/
└── metadata.json
```

备份内容：

- 从稳定点以来的所有 commit
- 受影响文件的完整副本
- 回滚操作的元数据

### 3. 影响范围预览

列出将回滚的文件和变更：

```
Impact Analysis:
  Files: [file1, file2, ...]
  Commits: [hash1 -> hash2]
  Lines added: {n}
  Lines removed: {n}
```

## 调整稳定点标记

### promote

将当前状态标记为新的稳定点：

```
/flow-kit:phase-8 --phase=<phase-id> --adjust=promote
```

### demote

移除现有稳定点标记（不回滚文件）：

```
/flow-kit:phase-8 --phase=<phase-id> --adjust=demote
```

### remove

删除指定稳定点文件：

```
/flow-kit:phase-8 --phase=<phase-id> --adjust=remove
```

## 与phase-executor集成

在 `flow-kit/lib/phase-executor.sh` 中的集成点：

```
集成点 9: Rollback Trigger

1. On markStablePoint() call:
   - Create .planning/checkpoints/{phase}-stable.json
   - Store: commit hash, timestamp, files list, phase state

2. On rollback trigger:
   - Check canRollback flag
   - Load stable checkpoint data
   - Execute rollback with safety guards
   - Update lastRollbackAt
   - Auto-write to LESSONS.md
```

## 稳定点文件格式

`.planning/checkpoints/{phase}-stable.json`:

```json
{
  "phase": "12",
  "commitHash": "abc1234",
  "timestamp": "2026-05-07T12:00:00Z",
  "files": ["file1.md", "file2.md"],
  "state": "stable",
  "markup": "Rollback point created at phase completion"
}
```

## 回滚后处理

### 自动写入 LESSONS.md

回滚完成后自动追加到 `.planning/phases/{phase}/LESSONS.md`:

```markdown
## Rollback Log - {timestamp}

- Trigger: {manual|auto|monitor}
- Reason: {rollback reason}
- Files reverted: {list}
- Backup: {backup path}
```

## 使用场景

| 场景             | 触发方式       | 行为             |
| ---------------- | -------------- | ---------------- |
| 手动回退到稳定点 | manual         | 全安全护栏       |
| 监控自动恢复     | auto           | 静默执行 + 日志  |
| 批量回滚多个阶段 | manual --force | 跳过确认（危险） |
| 调整标记优先级   | adjust         | 仅修改标记       |

---

**关联文件**：

- `@flow-kit/GO.md` (命令路由)
- `@flow-kit/lib/phase-executor.sh` (执行器集成)
- `.planning/checkpoints/` (稳定点存储)
- `.planning/phases/{phase}/LESSONS.md` (回滚日志)
