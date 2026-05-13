# performance-guardrails.md — B5 性能护栏

> v2.7.0 P2 新增：检测常见性能问题

## 性能护栏规则

### P1: O(n²) 嵌套循环检测

**规则**：禁止在热点路径上使用 O(n²) 或更差的嵌套循环

**检测方法**（静态代码扫描）：

```bash
# 检测嵌套 for 循环（JavaScript/TypeScript）
grep -rn "for.*for" --include="*.ts" --include="*.js" src/

# 检测 Python 嵌套循环
grep -rn "for.*for" --include="*.py" .
```

**违规示例**：

```javascript
// ❌ 违规：嵌套循环处理用户列表
for (let i = 0; i < users.length; i++) {
  for (let j = 0; j < users.length; j++) {
    if (users[i].id === users[j].friendId) { ... }
  }
}

// ✅ 合规：使用 Map 哈希查找 O(n)
const userMap = new Map(users.map(u => [u.id, u]));
```

**通过标准**：热点文件（被频繁调用）中不得存在未优化的嵌套循环

---

### P2: N+1 查询检测

**规则**：禁止在循环中执行数据库查询

**检测方法**：

```bash
# JavaScript/TypeScript：检测循环内的 await 或 .then
grep -rn "for.*await\|for.*\.then" --include="*.ts" --include="*.js" src/

# Python：检测循环内的 SQL 执行
grep -rn "for.*cursor.execute\|for.*session.query" --include="*.py" .
```

**违规示例**：

```python
# ❌ 违规：N+1 查询
for user_id in user_ids:
    user = session.query(User).filter_by(id=user_id).first()

# ✅ 合规：批量查询
users = session.query(User).filter(User.id.in_(user_ids)).all()
user_map = {u.id: u for u in users}
```

---

### P3: 未使用索引的 SQL 检测

**规则**：大数据表的 WHERE/ORDER BY 字段必须有索引

**检测方法**：

```bash
# 检测慢查询模式（需要结合具体 DB schema）
grep -rn "WHERE\|ORDER BY" --include="*.sql" migrations/
```

**违规示例**：

```sql
-- ❌ 违规：orders 表的 user_id 无索引，百万级数据查询慢
SELECT * FROM orders WHERE user_id = 123 ORDER BY created_at DESC;

-- ✅ 合规：先确认索引存在
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

---

### P4: 阻塞主线程的同步大文件读取

**规则**：禁止在主线程同步读取 >10MB 的文件

**检测方法**：

```bash
# 检测同步文件读取（Node.js）
grep -rn "fs\.readFileSync\|fs\.readSync" --include="*.ts" --include="*.js" src/

# 检测 Python 大文件同步读取
grep -rn "open.*'r'\|with open" --include="*.py" . | grep -v "encoding"
```

**违规示例**：

```javascript
// ❌ 违规：同步读取大文件，阻塞事件循环
const data = fs.readFileSync("/path/to/large-file.bin");

// ✅ 合规：使用流式异步读取
const stream = fs.createReadStream("/path/to/large-file.bin");
```

---

## 与 M-health.md 健康扫描联动

性能护栏检查结果自动集成到健康报告中：

```json
{
  "performance_guardrails": {
    "P1_nested_loops": { "found": 2, "status": "WARN" },
    "P2_n1_queries": { "found": 0, "status": "PASS" },
    "P3_missing_indexes": { "found": 1, "status": "FAIL" },
    "P4_sync_io": { "found": 0, "status": "PASS" }
  },
  "overall": "WARN"
}
```

---

## 通过标准

| 严重度       | 发现数 | 状态 |
| ------------ | ------ | ---- |
| P1 嵌套循环  | 0      | PASS |
| P2 N+1 查询  | 0      | PASS |
| P3 缺失索引  | 0      | PASS |
| P4 同步大 IO | 0      | PASS |

**任意一项 FAIL = 整体 FAIL**

---

## 参考来源

- [eslint-plugin-react-hooks](https://github.com/facebook/react) — React Hooks 性能规则
- [sqLEL](https://github.com/salsita/sq Lel) — SQL 性能分析
- [Node.js Performance Best Practices](https://nodejs.org/en/guides) — Node.js 性能最佳实践
