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

## 上下文归档模式 (Context Archival)

当 check-expiry.md 触发（30+ 天）时使用此模式。

### 触发条件

- 上下文过期（30 天无活动）
- 用户执行 `/flow-kit:archive --context`
- check-expiry.md 调用

### 归档目标结构

```
archive/{YYYY-MM}/context-{YYYY-MM-DD}/
  ├── README.md          # 上下文摘要（包含哪些 phase，最后活动）
  ├── .planning/        # 完整 .planning 目录快照
  └── metadata.yaml      # archived_at, original_path, reason: context-expiry
```

### 上下文归档步骤

1. 创建时间戳目录
2. 复制 .planning/ 目录
3. 创建 README.md（包含 phase 摘要和恢复命令）
4. 创建 metadata.yaml（reason: context-expiry）

### 验证检查

| 检查项 | 要求 |
|--------|------|
| .planning/ 完整性 | 所有 phase 子目录已复制 |
| README.md | 包含 phase 摘要和恢复命令 |
| metadata.yaml | reason: context-expiry |

## 恢复上下文 (Recovery)

从上下文归档恢复：`/flow-kit:archive archive/{YYYY-MM}/context-{YYYY-MM-DD}`

### 恢复步骤

1. 验证归档路径存在且包含 .planning/ 目录
2. 备份当前 .planning/（若存在）
3. 复制归档内容回 .planning/
4. 更新文件时间戳为恢复时刻
5. 输出恢复报告

---

**关联文件**：
- `@flow-kit/commands/check-expiry.md` (上下文过期检测)
