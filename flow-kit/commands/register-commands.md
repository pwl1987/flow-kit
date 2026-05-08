# register-commands

> 【CLAUDE CODE INSTRUCTION 强制约束】

自动扫描 flow-kit 命令路由表，为每个逻辑命令在 `.claude/commands/` 下生成标准 Markdown 入口文件。

## 用法

```bash
/flow-kit:register-commands [flags]
```

## 参数

| 参数      | 说明                           |
| --------- | ------------------------------ |
| `--force` | 强制覆盖已存在的命令文件       |
| `--list`  | 列出当前注册状态（不生成文件） |

## 功能说明

### 1. 自动扫描

扫描以下来源构建命令路由表：

**来源A：GO.md 命令路由表**
解析 `flow-kit/GO.md` 中 `Available Commands` 表格，包含：

- `/flow-kit:careful` → `@flow-kit/commands/careful.md`
- `/flow-kit:freeze` → `@flow-kit/commands/careful.md --mode freeze`
- `/flow-kit:guard` → `@flow-kit/commands/careful.md --mode guard`
- `/flow-kit:unfreeze` → 解除 freeze 限制
- `/flow-kit:scale` → `@flow-kit/commands/scale-level.md`
- `/flow-kit:offline` → `@flow-kit/commands/offline-mode.md`
- `/flow-kit:minimal` → `@flow-kit/commands/minimal-mode.md`
- `/flow-kit:online` → `@flow-kit/commands/offline-mode.md`
- `/flow-kit:health` → `@flow-kit/commands/M-health.md`
- `/flow-kit:scan` → `@flow-kit/commands/I-intel-scan.md`
- `/flow-kit:update-context` → `@flow-kit/commands/update-context.md`
- `/flow-kit:sync-config` → `@flow-kit/commands/sync-team-config.md`
- `/flow-kit:check-expiry` → `@flow-kit/commands/check-expiry.md`
- `/flow-kit:estimate-tokens` → `@flow-kit/commands/estimate-tokens.md`
- `/flow-kit:project-type` → `@flow-kit/commands/project-type.md`
- `/flow-kit:recovery` → `@flow-kit/commands/check-expiry.md`
- `/flow-kit:pr-description` → `@flow-kit/commands/pr-description.md`
- `/flow-kit:cost-report` → `@flow-kit/commands/cost-report.md`
- `/flow-kit:p0` → `@flow-kit/commands/p0-approval.md`
- `/flow-kit:archive` → `@flow-kit/archive/archive-change.md`
- `/flow-kit:skill:[name]` → `@flow-kit/skills/[name].md`
- `/flow-kit:strategy` → `@flow-kit/commands/strategy-first.md`
- `/flow-kit:skill-audit` → `@flow-kit/commands/skill-audit.md`
- `/flow-kit:team` → `@flow-kit/commands/team-roles.md`
- `/flow-kit:dispatch` → `@flow-kit/skills/team-dispatch.md`

**来源B：flow-kit/commands/ 目录扫描**
扫描 `flow-kit/commands/` 目录下所有 `.md` 文件，发现未在 GO.md 中定义的命令。

### 2. 入口文件生成

为每个逻辑命令在 `.claude/commands/` 下生成标准入口文件：

```markdown
# [命令名称]

description: [命令描述]
reference: [原始文件路径]

---

[原始文件内容引用]
```

**入口文件命名规则**

- 命令：`/flow-kit:careful` → `.claude/commands/flow-kit-careful.md`
- 命令：`/flow-kit:freeze` → `.claude/commands/flow-kit-freeze.md`
- 技能路由：`/flow-kit:skill:xxx` → `.claude/commands/flow-kit-skill-xxx.md`

### 3. 参数处理

**`--list` 模式**
仅输出注册状态报告，不生成或修改任何文件：

```
=== flow-kit 命令注册状态 ===

已注册 (25):
  [+] /flow-kit:careful
  [+] /flow-kit:freeze
  ...

待注册 (0):
  ...

冲突 (0):
  ...

总计: 25 命令
```

**`--force` 模式**
覆盖已存在的入口文件，重新生成内容。

**无参数模式**

- 若入口文件已存在且未使用 `--force`，则跳过（不覆盖）
- 生成所有待注册命令的入口文件

### 4. 可视化注册报告

注册完成后输出：

```
╔══════════════════════════════════════════════════════════╗
║          flow-kit 命令注册报告                            ║
╠══════════════════════════════════════════════════════════╣
║ 扫描来源: GO.md 命令路由表 + commands/ 目录扫描          ║
╠══════════════════════════════════════════════════════════╣
║ 已注册: 25                                                ║
║ 待注册: 3                                                 ║
║ 冲突: 0                                                  ║
╠══════════════════════════════════════════════════════════╣
║ 新增文件:                                                 ║
║   + .claude/commands/flow-kit-scale.md                  ║
║   + .claude/commands/flow-kit-strategy.md               ║
║   + .claude/commands/flow-kit-team.md                   ║
╠══════════════════════════════════════════════════════════╣
║ 完成时间: 2026-05-08 00:14:32                            ║
╚══════════════════════════════════════════════════════════╝
```

## 命令路由表解析逻辑

```
1. 解析 GO.md 中 "Available Commands" 表格
2. 提取 "命令" 和 "目标文件" 列
3. 处理带参数命令（如 --mode freeze）
4. 处理动态路由（如 /flow-kit:skill:[name]）
5. 扫描 commands/ 目录补充遗漏的命令
6. 过滤纯内部命令（以 _ 开头的文件）
```

## 错误处理

| 错误类型             | 处理方式                  |
| -------------------- | ------------------------- |
| GO.md 不存在         | 输出错误并退出            |
| commands/ 目录不存在 | 仅使用 GO.md 路由表       |
| 目标文件不存在       | 在报告中标记为 "引用缺失" |
| 写入权限不足         | 输出错误并列出失败文件    |

## 示例

### /flow-kit:map-codebase 子命令

> v1.9 新增，v1.11 增强：返回重索引逻辑

扫描现有代码库，生成技术栈摘要和 CONTEXT.md 骨架：

```
/flow-kit:map-codebase [--output DIR] [--types ts,js,py] [--reindex]
```

功能：

1. 扫描项目源码，识别语言/框架/依赖
2. 生成技术栈摘要（语言分布、关键模块、架构约定）
3. 输出 `CONTEXT.md` 骨架，供 B1 入场扫描使用

**返回重索引逻辑（v1.11 新增）**：

> 借鉴 GSD /gsd-map-codebase：增量更新而不全量重扫

```
/flow-kit:map-codebase --reindex
```

- 检测已存在的索引文件（.planning/tech-stacks.json）
- 仅扫描变更的文件（git diff --name-only）
- 更新索引中的变更部分
- 保留未变更部分的索引数据
- 输出增量扫描报告

```bash
# 完整扫描
/flow-kit:map-codebase

# 增量重索引（仅扫描变更文件）
/flow-kit:map-codebase --reindex

# 指定输出目录
/flow-kit:map-codebase --output .planning

# 只扫描特定类型
/flow-kit:map-codebase --types ts,tsx
```

---

```bash
# 列出当前注册状态
/flow-kit:register-commands --list

# 注册所有命令
/flow-kit:register-commands

# 强制重新注册所有命令
/flow-kit:register-commands --force
```

---

**参考来源：**

- 命令路由定义：`flow-kit/GO.md` (Available Commands 表格)
- 命令实现文件：`flow-kit/commands/*.md`
- 技能路由：`flow-kit/skills/*.md`
- Claude Code 命令入口规范：`.claude/commands/` 目录
