--- BEGIN flow-kit/commands/I-intel-scan.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】

## 优先级加载（任何逻辑不得违反）

1. **立即加载** `@flow-kit/config/constitution.md`（全局最高优先级）
2. **立即加载** `@flow-kit/config/default-user-config.md`，若存在 `.flow-kit/user-config.md` 则优先加载用户自定义配置
3. 后续所有逻辑必须遵守这两份配置

---

# 技术情报扫描

## 命令

`/flow-kit:scan`

## 目的

扫描代码库以获取技术栈清单、TODO/FIXME/HACK 注释、大文件和架构问题。生成分类的情报报告。

## 执行

### 1. 技术栈检测（与 M-health 相同）

检测并报告：

- 语言（按文件扩展名）
- 框架（package.json、go.mod 等）
- 构建系统
- 数据库/ORM 使用情况
- API 框架

### 2. 标记检测

**标记类型：**
| 标记 | 含义 | 严重阈值 |
|------|------|---------|
| TODO | 待处理任务 | 超 6 个月 |
| FIXME | 已知 bug | 任何 |
| HACK | 变通方案 | 超 3 个月 |
| XXX | 警告标记 | 任何 |
| NOTE | 重要备注 | 超 6 个月 |

**年龄分析：**

```markdown
| 年龄范围 | 数量 | 事项          |
| -------- | ---- | ------------- |
| >6 个月  | 15   | TODO 需要关注 |
| 3-6 个月 | 8    | 需要安排      |
| <1 个月  | 12   | 最近的，正常  |
```

**输出格式：**

```json
{
  "markers": {
    "TODO": {
      "count": 47,
      "oldest": "2024-01-15",
      "newest": "2026-03-20",
      "critical_age_count": 15
    },
    "FIXME": {
      "count": 12,
      "oldest": "2025-06-10",
      "newest": "2026-04-28",
      "critical_age_count": 5
    },
    "HACK": {
      "count": 3,
      "oldest": "2025-11-02",
      "newest": "2026-02-14",
      "critical_age_count": 1
    },
    "XXX": {
      "count": 8,
      "oldest": "2024-03-01",
      "newest": "2026-01-15",
      "critical_age_count": 2
    }
  },
  "total_critical": 23
}
```

### 3. 大文件检测

**阈值：**
| 类型 | 警告 | 严重 |
|------|------|------|
| 源码 | >500 行 | >1000 行 |
| 配置 | >300 行 | >500 行 |
| 测试 | >1000 行 | >2000 行 |
| 生成 | >2000 行 | >5000 行 |

**命令：**

- 查找大文件: `find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) -exec wc -l {} + | sort -rn | head -20`
- 按文件扩展名 + 行数过滤类型

**输出格式：**

```json
{
  "large_files": [
    {
      "file": "src/monolith.ts",
      "lines": 2847,
      "type": "source",
      "status": "CRITICAL"
    },
    {
      "file": "src/core/worker.ts",
      "lines": 1523,
      "type": "source",
      "status": "WARNING"
    }
  ],
  "total_critical": 1,
  "total_warning": 3
}
```

### 4. 循环依赖检测

**按技术栈的工具：**
| 技术栈 | 工具 | 命令 |
|--------|------|------|
| Node.js | madge | `npx madge --circular` |
| Python | pydeps | `pydeps --max-depth=3` |
| Go | go mod graph | `go mod graph \| grep -E '^(.*)->\1'` |
| Rust | cargo-udeps | `cargo udeps` |

**输出格式：**

```json
{
  "cycles": [
    { "path": "src/A.ts → src/B.ts → src/A.ts", "length": 3 },
    { "path": "src/C.ts → src/D.ts → src/E.ts → src/C.ts", "length": 4 }
  ],
  "total_cycles": 2,
  "status": "FAIL"
}
```

**严重度：** 1 个循环 = 高，2+ = 严重

### 5. 架构问题

**上帝对象（>2000 行）：**

```json
{
  "god_objects": [
    { "file": "src/monolith.ts", "lines": 2847 },
    { "file": "src/core/processor.ts", "lines": 1892 }
  ]
}
```

**深层嵌套（>5 层）：**

```json
{
  "deep_nesting": [
    { "file": "src/api/auth.ts", "line": 45, "depth": 6 },
    { "file": "src/utils/helpers.ts", "line": 128, "depth": 7 }
  ]
}
```

**大型模块（>30 个导出）：**

```json
{
  "large_modules": [
    { "file": "src/utils/index.ts", "exports": 47 },
    { "file": "src/constants/index.ts", "exports": 34 }
  ]
}
```

**缺少错误处理：**

```json
{
  "missing_error_handling": [
    { "file": "src/api/users.ts", "line": 67 },
    { "file": "src/core/worker.ts", "line": 112 }
  ]
}
```

### 6. 代码气味检测

**长参数列表（>5 个参数）：**

```json
{
  "long_parameters": [
    { "file": "src/api/handler.ts", "function": "processRequest", "params": 8 },
    { "file": "src/utils/validator.ts", "function": "validate", "params": 7 }
  ]
}
```

**特性依恋：**

- 方法使用其他类的数据多于自己的数据
- 通过 AST 分析检测：方法调用外部对象 > 方法调用 `this`

**不当亲密：**

- 两个类通过双向引用严重耦合
- 检测：类 A 导入 B 且 B 导入 A

**霰弹式修改：**

- 一个变更需要修改许多类
- 检测：单个函数被许多 PR 修改（需要历史分析）

**输出格式：**

```json
{
  "code_smells": {
    "long_parameters": 5,
    "feature_envy": 2,
    "inappropriate_intimacy": 3,
    "shotgun_surgery": 0
  },
  "architecture_issues": {
    "god_objects": 2,
    "deep_nesting": 12,
    "large_modules": 1,
    "missing_error_handling": 8
  },
  "total_issues": 33,
  "status": "WARN"
}
```

## 输出格式

```markdown
## 情报扫描报告

**扫描时间**: 2026-05-07 10:30:00
**范围**: src/, tests/, config/
**耗时**: 32s

### 技术栈

| 类别 | 检测到             |
| ---- | ------------------ |
| 语言 | TypeScript, Python |
| 框架 | React, FastAPI     |
| 构建 | Vite, Poetry       |
| API  | REST               |

### 标记摘要

| 标记  | 数量 | 超 6 个月 | 严重 |
| ----- | ---- | --------- | ---- |
| TODO  | 47   | 15        | 3    |
| FIXME | 12   | 4         | 5    |
| HACK  | 3    | 1         | 1    |

### 大文件

| 文件               | 行数 | 类型 | 警告 |
| ------------------ | ---- | ---- | ---- |
| src/monolith.ts    | 2847 | 源码 | 严重 |
| src/core/worker.ts | 1523 | 源码 | 警告 |

### 循环依赖
```

src/A.ts → src/B.ts → src/A.ts (循环)
src/C.ts → src/D.ts → src/C.ts (循环)

````

### 架构问题

1. **上帝对象**（检测到 3 个）：
   - src/monolith.ts: 2847 行
   - src/core/processor.ts: 1892 行

2. **深层嵌套**（12 处）：
   - src/api/auth.ts:45 (6 层)
   - src/utils/helpers.ts:128 (7 层)

3. **缺少错误处理**（8 处）：
   - src/api/users.ts:67 (无 try-catch)
   - src/core/worker.ts:112 (无错误处理)

### 建议

1. [严重] 处理 5 个标记为严重的 FIXME 注释
2. [高] 拆分 monolith.ts (2847 行 → 目标 <1000)
3. [高] 修复 2 个循环依赖
4. [中] 为 8 处添加错误处理

### JSON 输出（用于自动化）

```json
{
  "scan_time": "2026-05-07T10:30:00Z",
  "scope": ["src/", "tests/", "config/"],
  "duration_seconds": 32,
  "stack": {
    "languages": ["TypeScript", "Python"],
    "frameworks": ["React", "FastAPI"],
    "build": ["Vite", "Poetry"],
    "api": ["REST"]
  },
  "markers": {
    "TODO": { "count": 47, "age_6m_plus": 15, "critical": 3 },
    "FIXME": { "count": 12, "age_6m_plus": 4, "critical": 5 },
    "HACK": { "count": 3, "age_6m_plus": 1, "critical": 1 }
  },
  "large_files": [
    { "file": "src/monolith.ts", "lines": 2847, "type": "source", "status": "CRITICAL" },
    { "file": "src/core/worker.ts", "lines": 1523, "type": "source", "status": "WARNING" }
  ],
  "circular_dependencies": {
    "cycles": [
      { "path": "src/A.ts → src/B.ts → src/A.ts", "length": 3 },
      { "path": "src/C.ts → src/D.ts → src/C.ts", "length": 3 }
    ],
    "total": 2
  },
  "architecture_issues": {
    "god_objects": [
      { "file": "src/monolith.ts", "lines": 2847 },
      { "file": "src/core/processor.ts", "lines": 1892 }
    ],
    "deep_nesting": 12,
    "large_modules": 1,
    "missing_error_handling": 8
  },
  "code_smells": {
    "long_parameters": 5,
    "feature_envy": 2,
    "inappropriate_intimacy": 3,
    "shotgun_surgery": 0
  },
  "recommendations": [
    { "priority": "严重", "action": "处理 5 个标记为严重的 FIXME 注释" },
    { "priority": "高", "action": "拆分 monolith.ts (2847 行 → 目标 <1000)" },
    { "priority": "高", "action": "修复 2 个循环依赖" },
    { "priority": "中", "action": "为 8 处添加错误处理" }
  ],
  "status": "警告"
}
```

## 用法

```bash
@flow-kit/commands/I-intel-scan.md
```
````
