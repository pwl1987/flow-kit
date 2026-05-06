# 棕地项目示例

本示例展示如何为已有项目引入 flow-kit，并使用棕地护栏。

## 场景

**项目：** 已有 3 年历史的 Node.js + Express 项目
**需求：** 添加缓存层优化性能
**特点：** 无 AI 辅助开发规范，技术债务较多

## 引入 flow-kit

### 1. 健康扫描

```bash
/flow-kit:health
```

输出示例：
```
代码健康度：C+
- 重复代码：12 处
- 缺失测试覆盖率：67%
- 建议：启用极简模式
```

### 2. Intel 扫描

```bash
/flow-kit:scan
```

输出示例：
```
技术债务：
- TODO: 23 个
- FIXME: 8 个
- 技术栈版本：Express 4.x（建议升级）
- 安全问题：3 个（见 security-checklist）
```

### 3. 生成 CONTEXT.md

```bash
/flow-kit:update-context
```

输出 `CONTEXT.md`，包含：
- 项目结构
- 技术栈清单
- 代码分布
- 已知问题

## 棕地护栏

### B1 入场扫描

自动检测：
- 代码库结构
- 现有测试框架
- CI/CD 配置
- 依赖版本

### B3 边界约束

每个任务需声明：
```yaml
read_files:
  - src/services/UserService.ts
write_files:
  - src/services/CacheService.ts
```

### B4 破坏性变更分级

缓存层变更属于 **P1 中风险**：
- 需全库引用扫描
- 需回滚方案
- 需人工确认

### B5 沿用抽象

实现新缓存服务前：
```bash
grep -r "cache" src/
```
结果：发现 `src/utils/Cache.js` 已存在但未启用

## 完整流程

### Phase 0-1: 立项与需求

```bash
@flow-kit/phases/0-change/0-change.md
# 输出：change-id = cache-layer-20260507

@flow-kit/phases/1-requirement/1-requirement.md
# 输出：REQUIREMENT.md（包含缓存策略选择）
```

### Phase 2: 设计（含护栏）

```bash
@flow-kit/phases/2-design/2-design.md
```

设计阶段强制执行：
- B2 架构对齐：复用现有 `Cache.js` 还是新建？
- B6 视觉语汇对齐：（本项目无 UI 变更，跳过）

### Phase 3: 任务拆解

```bash
@flow-kit/phases/3-task/3-task.md
```

输出 `TASK.md`：
```xml
<tasks>
  <task id="001">
    <desc>评估并修复现有 Cache.js</desc>
    <files read="src/utils/Cache.js" write="src/utils/Cache.js"/>
    <verify>npm test -- --grep "Cache"</verify>
    <guardrails>B5</guardrails>
  </task>
  <task id="002" parallel="true">
    <desc>实现 Redis 缓存适配器</desc>
    <files read="src/utils/Cache.js,package.json" write="src/cache/RedisAdapter.ts"/>
    <verify>npm test -- --grep "RedisAdapter"</verify>
    <breaking-change level="P1"/>
  </task>
</tasks>
```

### Phase 4-6: 开发、测试、审查

每个任务执行时：
1. 读取边界声明的 read_files
2. 仅写入 write_files 声明的文件
3. 执行 verify 命令

### Phase 7: 集成归档

```bash
@flow-kit/phases/7-integration/7-integration.md
```

输出：
- git commit with change-id
- 归档到 `.specs/archive/`
- 更新 `CONTEXT.md`
- 提取教训到 `LESSONS.md`

## 教训沉淀

`LESSONS.md` 新增：
```markdown
## cache-layer-20260507

### 发现
- 现有 Cache.js 被遗忘但可用
- 首次复用抽象节省 2 小时

### 预防措施
- 后续变更前强制 grep 复用检查
```

---

## 生成文件

```
.specs/cache-layer-20260507/
├── CHANGE.md
├── .STATE
├── CONTEXT.md          # 新增：入场扫描结果
├── REQUIREMENT.md
├── DESIGN.md
├── TASK.md
├── SUMMARY.md
├── REVIEW.md
└── LESSONS.md          # 新增：经验教训
```
