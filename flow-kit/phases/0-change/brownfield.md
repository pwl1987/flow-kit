# Phase 0: 变更立项 — 棕地项目

> 适用：已有代码库的业务迭代开发

## 棕地项目特点

- 已有稳定功能模块和历史代码
- 需要保护现有功能不破坏
- 重点：影响范围评估、破坏性变更识别

## 执行步骤

### Step 1: 影响范围评估

1. **统计修改范围**

   ```bash
   # 查找本次变更涉及的文件
   git diff --name-only HEAD~10

   # 统计文件数和代码行数
   git diff --stat HEAD~10
   ```

2. **识别高风险文件**
   - 核心业务逻辑（domain/、core/）
   - 公共 API 接口（api/、routes/）
   - 数据库模型（models/、schema/）
   - 认证授权（auth/、permission/）

### Step 2: 破坏性变更识别

使用 B1 护栏检测：

1. **API 签名变更**
   - 函数名/参数变更
   - 返回值结构变化
   - 新增 required 参数

2. **数据库变更**
   - ALTER TABLE 修改列
   - DROP COLUMN/TABLE
   - 索引删除

3. **配置文件变更**
   - 环境变量删除
   - 配置文件结构变化

### Step 3: 风险评级

| 风险等级 | 标准                 | 处理方式                   |
| -------- | -------------------- | -------------------------- |
| P0       | 紧急变更，可绕过护栏 | 先执行后记录，24h 内补评审 |
| P1       | 破坏性 API/契约变更  | 必须经过评审               |
| P2       | 非破坏性增强         | 标准流程                   |

### Step 4: 护栏配置

**棕地项目必须启用全部护栏 B1-B6**

```bash
/flow-kit:guard full
```

### Step 5: 生成 Change ID

```bash
./flow-kit.sh change init "变更描述"
```

## 输出物

- `.specs/{change-id}/CHANGE.md` — 变更摘要
- 影响范围评估文档
- 破坏性变更列表
- 风险评级

## 下一步

- `/flow-kit:phase-1` — 需求澄清
- `/flow-kit:next` — 自动推进
