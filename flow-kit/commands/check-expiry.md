> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件实现上下文过期检测逻辑。
> D4-1: Context Expiry Detection

# Context Expiry Detection

## 触发条件

- **15 天警告**：上下文最后活动后 15 天，输出警告通知
- **30 天归档**：上下文最后活动后 30 天，自动触发归档操作

## 核心行为

### 活动检测逻辑

1. 扫描 `.planning/phases/` 下所有 `.md` 文件（排除 TEMPLATE 文件）
2. 获取所有文件的最后修改时间，取最新值作为"最后活动时间"
3. 计算距离今天的天数

### 警告通知格式

当 15 ≤ 天数 < 30 时：
```
[WARNING] Context will expire in {days_remaining} days (30-day auto-archive)
Run `/flow-kit:archive` manually to archive early, or `flow-kit:recovery` to restore.
```

### 归档触发行为

当天数 >= 30 时：
1. 输出阻止性警告
2. 自动调用 archive-change.md 的上下文归档模式
3. 归档目标：`.planning/` 目录压缩到 `archive/{YYYY-MM}/context-{date}/`

## 命令

| 命令 | 行为 |
|------|------|
| `/flow-kit:check-expiry` | 立即检查并输出当前上下文状态 |
| `/flow-kit:recovery {archive-path}` | 从归档恢复上下文 |

### check-expiry 执行流程

```
1. Scan .planning/phases/*/*.md files (exclude *template*)
2. Find most recent modification date (max mtime)
3. Calculate days_since = (today - max_mtime) in days
4. If days_since >= 15 AND days_since < 30:
   - Output WARNING notification
5. If days_since >= 30:
   - Output BLOCK notification
   - Trigger context archive operation
6. If days_since < 15:
   - Output status: "Context age: {days_since} days (healthy)"
```

### recovery 命令格式

```
/flow-kit:recovery archive/{YYYY-MM}/context-{YYYY-MM-DD}
```

恢复步骤：
1. 验证归档路径存在且包含完整结构
2. 将归档内容解压回 `.planning/` 目录
3. 更新文件时间戳为恢复时刻
4. 输出恢复报告

## 实现细节

### 文件扫描逻辑

```javascript
// 伪代码
files = glob('.planning/phases/**/*.md')
        .filter(f => !f.includes('template') && !f.includes('TEMPLATE'))
mostRecent = max(files.map(f => getMtime(f)))
daysSince = (now - mostRecent) / (1000 * 60 * 60 * 24)
```

### 归档目标结构

```
archive/{YYYY-MM}/context-{YYYY-MM-DD}/
  ├── README.md          # 上下文摘要（包含哪些 phase，最后活动）
  ├── .planning/        # 完整 .planning 目录快照
  └── metadata.yaml      # archived_at, original_path, reason: context-expiry
```

## 恢复流程

1. 用户执行 `/flow-kit:recovery {archive-path}`
2. 验证目标路径存在
3. 解压 `.planning/` 目录内容
4. 恢复所有 phase 文件到原始位置
5. 输出恢复报告

## 边界情况

### 归档失败
- 权限不足：输出错误，不修改任何文件
- 目标已存在：追加时间戳到目录名

### 恢复失败
- 归档结构不完整：拒绝恢复，输出缺失文件列表
- 冲突文件存在：提示用户确认覆盖

---

**关联文件**：
- `@flow-kit/archive/archive-change.md` (归档核心逻辑)
- `@flow-kit/GO.md` (启动时检查)