# 简单功能变更示例

本示例展示使用 flow-kit 处理简单的功能变更。

## 场景

**需求：** 为现有 Node.js 项目添加用户登录功能

**特点：**
- 变更范围：3-5 个文件
- 技术栈：已确定（Express + JWT）
- 复杂度：中等

## 完整流程

### 1. 变更立项（Phase 0）

```
执行：@flow-kit/phases/0-change/0-change.md
输入："添加用户登录功能"
输出：change-id = user-auth-20260507
```

### 2. 需求澄清（Phase 1）

```
执行：@flow-kit/phases/1-requirement/1-requirement.md
输出：REQUIREMENT.md
  - POST /api/auth/login 端点
  - JWT token 生成与验证
  - 密码加密存储（bcrypt）
  - 登录失败次数限制
```

### 3. 架构设计（Phase 2）

```
执行：@flow-kit/phases/2-design/2-design.md
输出：DESIGN.md
  - 技术选型：Express + jsonwebtoken + bcrypt
  - 目录结构：src/auth/
  - API 设计文档
```

### 4. 任务拆解（Phase 3）

```
执行：@flow-kit/phases/3-task/3-task.md
输出：TASK.md（XML 格式）

<tasks>
  <task id="001">
    <desc>创建 User 模型</desc>
    <files read="src/models/" write="src/models/User.ts"/>
    <verify>npm test -- --grep "User model"</verify>
  </task>
  <task id="002" parallel="true">
    <desc>实现 JWT 认证中间件</desc>
    <files read="src/middleware/" write="src/middleware/auth.ts"/>
    <verify>npm test -- --grep "auth middleware"</verify>
  </task>
  <task id="003">
    <desc>实现登录 API</desc>
    <files read="src/routes/auth.ts" write="src/routes/auth.ts"/>
    <verify>npm test -- --grep "login"</verify>
  </task>
</tasks>
```

### 5-7. 开发、测试、审查（Phase 4-6）

按任务顺序执行，每个任务完成后执行 verify。

### 8. 集成归档（Phase 7）

```
执行：@flow-kit/phases/7-integration/7-integration.md
输出：
  - git commit
  - 更新 CONTEXT.md
  - 归档到 .specs/archive/user-auth-20260507/
```

---

## 极简模式

对于简单变更，可启用极简模式：

```bash
/flow-kit:minimal
```

极简模式会跳过 Phase 5（测试）和 Phase 6（审查），直接进入集成。

---

## 生成文件

本示例生成了以下文件：

```
.specs/user-auth-20260507/
├── CHANGE.md           # 变更描述
├── .STATE             # 状态记录
├── REQUIREMENT.md      # 需求文档
├── DESIGN.md          # 设计文档
├── TASK.md            # 任务列表
├── SUMMARY.md         # 执行总结
└── REVIEW.md          # 审查报告
```
