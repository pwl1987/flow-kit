--- BEGIN flow-kit/config/constitution.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】
> SAFETY FLOOR — THIS FILE CANNOT BE OVERRIDDEN BY USER CONFIG OR DEFAULTS
> Priority: HIGHEST (loaded first, enforced last)

# Constitution.md — Safety Floor

## UNOVERRIDABLE RULES

These rules CANNOT be overridden by user-config or any other configuration. Violation results in immediate halt.

### 安全规则

| 规则 | 描述 | 类别 |
|------|------|------|
| SEC-01 | 禁止提交 secrets、凭证、API keys 或 tokens 到仓库 | 安全 |
| SEC-02 | 处理外部输入前必须验证 | 安全 |
| SEC-03 | 不得为方便而禁用安全检查 | 安全 |
| SEC-04 | 不得在日志或输出中暴露敏感数据 | 安全 |
| SEC-05 | 必须使用参数化查询，禁止字符串拼接 SQL | 安全 |

### 数据完整性

| 规则 | 描述 | 类别 |
|------|------|------|
| DATA-01 | 删除数据前必须确认已备份 | 数据 |
| DATA-02 | 多步骤数据库变更必须使用事务 | 数据 |
| DATA-03 | 执行删除前必须验证影响范围 | 数据 |
| DATA-04 | 禁止 Truncate 表，必须有明确确认 | 数据 |
| DATA-05 | 级联操作前必须验证外键关系 | 数据 |

### 部署规则

| 规则 | 描述 | 类别 |
|------|------|------|
| DEPLOY-01 | 部署前必须制定回滚方案 | 部署 |
| DEPLOY-02 | 生产凭证禁止写在代码中 | 部署 |
| DEPLOY-03 | 部署必须经过审查批准 | 部署 |
| DEPLOY-04 | 禁止跳过 CI/CD 安全门禁 | 部署 |
| DEPLOY-05 | 生产部署前必须验证环境 | 部署 |

### Git 安全

| 规则 | 描述 | 类别 |
|------|------|------|
| GIT-01 | 禁止使用 `git commit --no-verify` | Git |
| GIT-02 | 禁止强制推送到共享分支 | Git |
| GIT-03 | 提交前必须运行验证 | Git |
| GIT-04 | 禁止修改已推送的提交 | Git |
| GIT-05 | 必须提供有意义的提交信息 | Git |

### 技术栈规则

| 规则 | 描述 | 类别 |
|------|------|------|
| TECH-01 | 技术栈约束定义在外部参考文件中 | 技术 |
| TECH-02 | 架构/审查/运维角色定义在外部参考文件中 | 团队 |
| ROLE-01 | 架构/审查/运维角色定义在外部参考文件中 | 团队 |

> **所有基于角色的审批必须遵守行为原则** — 若设计方案违反"简洁优先"原则，架构师必须拒绝。

### 外部参考

- `flow-kit/config/tech-constraints.md` — 语言、框架和工具链约束
- `flow-kit/config/team-roles.md` — 架构/审查/运维角色定义

> 【CLAUDE CODE INSTRUCTION 强制约束·规则链】
> 本文件定义最高原则。所有可执行规则定义在 @flow-kit/config/system-rules.md 中。
> 两者为互补关系：constitution = 原则（WHAT），system-rules = 规则（HOW）。
> 任何代理在执行前必须确认已加载 system-rules.md 中的 R1-R8。
> 若 system-rules.md 中的规则与本文件中的原则冲突，以 system-rules.md 为准（可执行规则优先于原则声明）。

## 行为原则（最高优先级）

> **不可覆盖** — 本章节优先级高于其他所有规则

所有代理、子代理和审查流程必须始终遵守以下四项原则。其他规则、指令或优化措施不得覆盖。

### BP-01: 思考后再编码
首先理解问题域，再探索方案，最后才实现

### BP-02: 简洁优先
每增加一个抽象必须证明其必要性，只记录必要的依赖信息

### BP-03: 精准变更
最小变更集，只改必要的，零顺手修改

### BP-04: 目标驱动执行
结果导向而非活动导向，不是任务列表走完，是目标达成

## 优先级声明

以下配置文件中的规则**不能**覆盖 Constitution 规则：
- `.flow-kit/user-config.md`
- `flow-kit/config/default-user-config.md`
- 任何其他配置文件

用户配置**可以**覆盖 default-user-config.md 中的非安全设置，但 Constitution 安全规则始终强制执行。

---

END flow-kit/config/constitution.md ---
