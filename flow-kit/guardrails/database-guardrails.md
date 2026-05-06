> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件定义数据库操作安全规范。
> B2 Guardrail：Database Safety。

# B2: Database Guardrails

## 触发条件

- DDL 操作检测：`ALTER TABLE`, `DROP TABLE`, `CREATE TABLE`, `CREATE INDEX`
- DML 批量操作检测：`UPDATE` / `DELETE` 无 `WHERE` 或 `WHERE` 使用 `id IN (...)`
- 迁移文件检测：`migrations/`, `schema.rb`, `alembic/`
- ORM 检测：`sequelize`, `prisma`, `typeorm`, `sqlalchemy`

## 核心行为

### DDL Safety Section

#### 禁止操作（除非 P0）
| 操作 | 风险 |
|------|------|
| `DROP TABLE` | 数据永久丢失 |
| `DROP COLUMN` | 数据永久丢失 |
| `ALTER COLUMN TYPE` | 潜在数据转换丢失 |
| `DROP INDEX` | 查询性能下降 |

#### 需要 Review 的操作
| 操作 | Review 要求 |
|------|-------------|
| `CREATE TABLE` | Schema 设计评审 |
| `ALTER TABLE ADD COLUMN` | 默认值与约束检查 |
| `CREATE INDEX` | 性能影响分析 |
| `ALTER TABLE MODIFY` | 兼容性检查 |

### DML Safety Section

#### 高风险操作（需要额外确认）
```sql
-- 危险：批量更新无 WHERE
UPDATE users SET status = 'inactive';

-- 安全：单条更新
UPDATE users SET status = 'inactive' WHERE id = 123;

-- 危险：DELETE 无 WHERE
DELETE FROM audit_log;

-- 安全：带条件的 DELETE
DELETE FROM audit_log WHERE created_at < '2025-01-01';
```

#### 批量操作规范
1. **备份要求**：任何影响 100+ 行数据的操作前需有备份
2. **分批执行**：超过 1000 行建议分批执行
3. **时间窗口**：选择低峰期执行

## 边界情况

### 紧急修复（P0）
- 允许跳过 DDL Review
- 要求：立即记录变更，24小时内补充 Review
- 触发事后完整性检查

### 外键与约束
- 添加外键前检查引用完整性
- 删除有外键引用的列需先移除约束

### 事务规范
- DDL 操作建议在事务中执行（支持的情况下）
- 明确指定 `BEGIN` / `COMMIT` / `ROLLBACK`

## 输出物

```
Database Safety Review Report
=============================
Change ID: [YYYY-MM-{SEQ}]

DDL Operations:
  - Type: [CREATE/ALTER/DROP]
  - Object: [table/column/index]
  - Risk Level: [HIGH/MEDIUM/LOW]

DML Operations:
  - Affected Rows: [count]
  - WHERE Clause: [present/missing]
  - Batch Size: [count]

Safety Checks:
  - Backup Required: [Yes/No]
  - Review Required: [Yes/No]
  - Transaction: [Yes/No]

Status: [APPROVED/REJECTED/PENDING]
```

### Rollback Requirements
- 所有 DDL 变更必须保留 rollback 脚本
- DML 变更前必须备份受影响数据
