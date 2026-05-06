> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件定义 Archive 逻辑与流程。
> ARCH-90: Archive Logic Implementation。

# Archive Change Logic

## 触发条件

- 用户执行 `/flow-kit:archive` 命令
- 变更被标记为 `deprecated`
- 变更已过期（超过 90 天无活动）
- 项目归档请求

## 核心行为

### Archive 路径结构

```
archive/
  └── {YYYY-MM}/
      └── {change-id}/
          ├── README.md          # 变更摘要
          ├── {original-files}   # 原始文件
          └── metadata.yaml      # 归档元数据
```

### Archive 步骤

1. **创建时间戳目录**
   ```bash
   mkdir -p archive/$(date +%Y-%m)/{change-id}
   ```

2. **移动变更文件**
   ```bash
   mv .specs/{change-id}/* archive/{YYYY-MM}/{change-id}/
   ```

3. **创建 README.md**
   ```markdown
   # {change-id}

   ## Original Location
   `.specs/{change-id}`

   ## Archived Date
   {YYYY-MM-DD}

   ## Reason
   [deprecated/expired/manual]

   ## Related Links
   - PR: [link if merged]
   - Issues: [link if any]
   ```

4. **创建 metadata.yaml**
   ```yaml
   archived_at: {YYYY-MM-DD}
   original_path: .specs/{change-id}
   archive_path: archive/{YYYY-MM}/{change-id}
   reason: deprecated | expired | manual
   archived_by: {agent-id}
   ```

5. **更新 .specs/INDEX.md**
   - 在对应条目添加 `Archived: {YYYY-MM-DD}`
   - 添加指向 archive 路径的链接

### 验证检查

| 检查项 | 要求 |
|--------|------|
| 文件完整性 | 所有原始文件已迁移 |
| README.md | 在 archive 目录创建 |
| metadata.yaml | 包含所有必填字段 |
| INDEX.md | 已更新归档引用 |

## 边界情况

### 归档失败
- 文件被锁或不可访问
- 目标目录已存在
- 权限不足

**处理**：中止操作，返回错误，不修改任何文件

### 部分归档
- 只归档部分文件
- 保留剩余文件在原位置
- 记录为 Partial Archive

### 恢复归档
- 从 archive 移回 .specs/
- 需要明确恢复原因
- 记录恢复操作

## 输出物

```
Archive Operation Report
========================
Change ID: {change-id}
Archive Path: archive/{YYYY-MM}/{change-id}

Files Archived:
  - [file1]
  - [file2]

Validation:
  - README.md: [Created/Missing]
  - metadata.yaml: [Created/Missing]
  - INDEX.md: [Updated/Not Updated]

Status: [SUCCESS/FAILED/PARTIAL]
```

---

**关联文件**：
- `@flow-kit/commands/M-health.md` (健康检查)
- `.specs/INDEX.md` (变更索引)
