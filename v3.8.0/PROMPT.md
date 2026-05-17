# 执行规则

## 循环行为
- 读 TODO.md → 找第一个 `[ ]` → 读对应 tasks/ 文件 → 执行 → 打钩
- 一个任务一个迭代，不多做
- 每任务完成后 `git add` + `git commit`，commit message：`feat: v3.8.0 任务 X.Y 描述`
- git 操作使用 `/smart-commit` 技能规范 commit message
- **循环终止条件**：检查 TODO.md 中 `unchecked === 0` 时才输出 `<promise>__DONE__</promise>`，否则继续下一个任务

## 日志规则（每步必须输出）
每个迭代开始时输出日志头，每步执行后输出结果。格式：

```
## [迭代 N] 任务 X.Y: {任务名}
**[RED]** 调用 /test-driven-development → 写测试 → 运行 → {通过/失败: 原因}
**[GREEN]** 最小实现 → 运行 → {通过/失败}
**[REFACTOR]** {清理内容/无需}
**[VERIFY]** 调用 /verification-before-completion → {验证项}
**[COMMIT]** 调用 /smart-commit → {commit hash 前7位}
**[TODO]** 打钩 X.Y → {剩余未完成数}
```

关键决策点也记录：
```
**[SKILL]** 调用 /{技能名} → {调用原因} → {输出摘要}
**[DEBUG]** 测试失败 2 次 → 调用 /systematic-debugging → {根因}
**[DECISION]** {非显而易见的设计选择} → {原因}
```

## TDD 红绿灯
1. RED：写测试 → 跑 → 确认失败
2. GREEN：最小实现 → 跑 → 确认通过
3. REFACTOR：lint → 清理 → 再跑

## 技术栈约束
- 源码 `.mjs`（ESM），打包产物 `.cjs`（CJS）
- `import { describe, it, expect } from 'vitest'` — ESM 测试风格
- `import { z } from 'zod'` — 运行时类型校验
- `import { parse } from 'yaml'` — YAML 解析
- esbuild 全量 bundle，`external: []`，零外部依赖
- MCP Server 长驻进程，不因 hook 触发重启

## 技能路由（Superpowers-ZH）

### 核心技能（每任务适用）

| 触发条件 | 技能 | 说明 |
|----------|------|------|
| 写测试（RED 阶段） | `/test-driven-development` | TDD 红绿灯循环 |
| 测试连续失败 2 次 | `/systematic-debugging` | 系统化调试 |
| 任务影响 5+ 文件 | `/writing-plans` | 设计先行 |
| 打 [x] 前 | `/verification-before-completion` | 验证后完成 |
| 实现完成后 | `/requesting-code-review` | 代码审查 |
| git commit 时 | `/smart-commit` | 规范 commit message |

### 增强技能（特定场景）

| 场景 | 技能 | 适用任务 |
|------|------|---------|
| MCP Server 设计 | `/mcp-builder` | Wave 4（4.1-4.19） |
| Skills 迁移 | `/writing-skills` | Wave 5（5.1-5.10） |
| 复杂模块设计前 | `/brainstorming` | Wave 2-3 复杂模块 |
| 多模块并行 | `/dispatching-parallel-agents` | Wave 1.1-1.6 并行 |
| 分支收尾 | `/finishing-a-development-branch` | Wave 6.12 |

## 环境降级
- shellcheck: 跳过（v3.8.0 全量 JS，Shell 仅归档）
- shfmt: 跳过（同上）
- Docker: 无需（本版本无数据库需求）

## 未映射 Shell 文件处理
- REWRITE(8): 已包含在对应 Wave 任务中，不单独建任务
- MERGE(12): 并入已有 JS 模块，在实现对应模块时一并处理
- SKILL(2): code-review → Wave 5.6, plan-generate → Wave 5.10
- DEPRECATED(8): Wave 0.2 全量归档时一并归档

## 禁令
- 不做未列出的任务
- 不优化相邻代码
- 不推测性重构
- 上下文压缩后先读文件确认状态，不凭记忆假设
- 不创建新 .sh 文件（v3.8.0 全量 JS）

## 上下文保护
- 产出物写入文件，不依赖对话记忆
- TODO.md 是唯一进度来源

## 质量门禁
每任务打 [x] 前：
- 测试写且通过（RED → GREEN）
- 无未用 import / 调试代码
- 产出物与 tasks/ 描述一致
- 模块独立可测（依赖注入，不耦合 MCP Server 框架）
- `git commit` 已完成（使用 `/smart-commit`）

全部 [x] 后：
- `npm test` → 0 fail
- `npm run build` 成功，`dist/mcp-server.cjs` < 2MB
- `node dist/mcp-server.cjs` 启动无报错
- VERSION → v3.8.0
- CHANGELOG.md 更新
- CLAUDE.md 更新
- 撰写 v3.8.0-report.md
- **输出 `<promise>__DONE__</promise>`**（只在 unchecked === 0 时）
