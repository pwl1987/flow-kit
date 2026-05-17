# v3.8.0 任务索引（61 原子任务）

## Wave 0: 项目骨架

| # | 任务 | 详情文件 | 依赖 | 状态 |
|---|------|----------|------|------|
| 0.1 | 目录骨架 + package.json + 依赖安装 | tasks/0.1-skeleton.md | — | [ ] |
| 0.2 | 归档 v3.7.0 Shell | tasks/0.2-archive-shell.md | 0.1 | [x] |
| 0.3 | 创建 plugin.json | tasks/0.3-plugin-json.md | 0.1 | [x] |
| 0.4 | 创建 .mcp.json | tasks/0.4-mcp-json.md | 0.1 | [ ] |
| 0.5 | 创建 esbuild.config.mjs | tasks/0.5-esbuild.md | 0.1 | [ ] |
| 0.6 | 更新 vitest.config.ts | tasks/0.6-vitest.md | 0.1 | [ ] |

## Wave 1: 基础库层

| # | 任务 | 详情文件 | 源 Shell | 依赖 | 状态 |
|---|------|----------|---------|------|------|
| 1.1 | paths.mjs + 测试 | tasks/1.1-paths.md | lib/paths.sh(178行) | 0.6 | [ ] |
| 1.2 | error-handler.mjs + 测试 | tasks/1.2-error-handler.md | lib/error-handler.sh(244行) | 1.1 | [ ] |
| 1.3 | lock.mjs + 测试 | tasks/1.3-lock.md | scripts/dispatch-lock.sh(160行) | 1.1 | [ ] |
| 1.4 | cleanup.mjs + 测试 | tasks/1.4-cleanup.md | lib/cleanup.sh(47行) | 1.1 | [ ] |
| 1.5 | time-utils.mjs + 测试 | tasks/1.5-time-utils.md | lib/time-utils.sh(42行) | 1.1 | [ ] |
| 1.6 | preflight.mjs + 测试 | tasks/1.6-preflight.md | lib/preflight.sh(44行) | 1.1 | [ ] |

## Wave 2: 核心数据层

| # | 任务 | 详情文件 | 源 Shell | 依赖 | 状态 |
|---|------|----------|---------|------|------|
| 2.1 | session-state.mjs + 测试 | tasks/2.1-session-state.md | lib/session-state.sh(332行) | 1.2,1.5 | [ ] |
| 2.2 | metrics.mjs + 测试 | tasks/2.2-metrics.md | lib/metrics-logger.sh(73行) | 1.2,1.5 | [ ] |
| 2.3 | front-matter.mjs + 测试 | tasks/2.3-front-matter.md | lib/front-matter.sh(80行) | 1.2 | [ ] |
| 2.4 | security-scanner.mjs + 测试 | tasks/2.4-security-scanner.md | lib/security-scanner.sh(296行) | 1.2 | [ ] |
| 2.5 | conflict-detector.mjs + 测试 | tasks/2.5-conflict-detector.md | lib/conflict-detector.sh(221行) | 2.1 | [ ] |
| 2.6 | context-budget.mjs + 测试 | tasks/2.6-context-budget.md | lib/context-budget.sh(476行) | 1.2,1.5 | [ ] |
| 2.7 | project-info.mjs + 测试 | tasks/2.7-project-info.md | lib/project-info.sh(78行) | 1.1 | [ ] |

## Wave 3: 业务逻辑层

| # | 任务 | 详情文件 | 源 Shell | 依赖 | 状态 |
|---|------|----------|---------|------|------|
| 3.1 | phase-executor.mjs + 测试 | tasks/3.1-phase-executor.md | scripts/phase-executor.sh(113行) | 2.1,2.3 | [ ] |
| 3.2 | auto-pilot.mjs + 测试 | tasks/3.2-auto-pilot.md | scripts/auto-pilot.sh(264行) | 2.1,3.1 | [ ] |
| 3.3 | dispatch-core.mjs + 测试 | tasks/3.3-dispatch-core.md | scripts/dispatch.sh(890行) | 1.3,2.1 | [ ] |
| 3.4 | dispatch-parse.mjs + 测试 | tasks/3.4-dispatch-parse.md | scripts/dispatch-parse.sh(90行) | 1.2 | [ ] |
| 3.5 | command-gen.mjs + 测试 | tasks/3.5-command-gen.md | scripts/generate-commands.sh(293行) | 1.1,2.3 | [ ] |
| 3.6 | init-change.mjs + 测试 | tasks/3.6-init-change.md | scripts/init-change.sh(330行) | 1.3,2.1 | [ ] |
| 3.7 | validate-phase.mjs + 测试 | tasks/3.7-validate-phase.md | scripts/validate-phase.sh(650行) | 2.3,2.1 | [ ] |

## Wave 4: MCP Server + 工具注册

| # | 任务 | 详情文件 | 依赖 | 状态 |
|---|------|----------|------|------|
| 4.1 | server.mjs MCP Server 入口 | tasks/4.1-server.md | Wave 3 | [ ] |
| 4.2 | 工具：status + version + health | tasks/4.2-tools-status.md | 4.1 | [ ] |
| 4.3 | 工具：recall | tasks/4.3-tools-recall.md | 4.1 | [ ] |
| 4.4 | 工具：metrics | tasks/4.4-tools-metrics.md | 4.1 | [ ] |
| 4.5 | 工具：validate | tasks/4.5-tools-validate.md | 4.1 | [ ] |
| 4.6 | 工具：next_phase + run_phase | tasks/4.6-tools-phase.md | 4.1 | [ ] |
| 4.7 | 工具：init_change | tasks/4.7-tools-init.md | 4.1 | [ ] |
| 4.8 | 工具：dispatch | tasks/4.8-tools-dispatch.md | 4.1 | [ ] |
| 4.9 | 工具：shellcheck | tasks/4.9-tools-shellcheck.md | 4.1 | [ ] |
| 4.10 | 工具：register | tasks/4.10-tools-register.md | 4.1 | [ ] |
| 4.11 | hook：pre_tool_guard | tasks/4.11-hook-guard.md | 4.1 | [ ] |
| 4.12 | hook：post_edit_format | tasks/4.12-hook-format.md | 4.1 | [ ] |
| 4.13 | hook：quality_gate（async） | tasks/4.13-hook-quality.md | 4.1 | [ ] |
| 4.14 | hook：session_restore | tasks/4.14-hook-session.md | 4.1 | [ ] |
| 4.15 | hook：send_notification | tasks/4.15-hook-notify.md | 4.1 | [ ] |
| 4.16 | 工具：watch（monitor） | tasks/4.16-tools-watch.md | 4.1 | [ ] |
| 4.17 | hooks.json 配置 | tasks/4.17-hooks-json.md | 4.11-4.15 | [ ] |
| 4.18 | plugin.json 更新 | tasks/4.18-plugin-update.md | 4.17 | [ ] |
| 4.19 | esbuild 打包验证 | tasks/4.19-build-verify.md | 4.1-4.16 | [ ] |

## Wave 5: Skills 迁移

| # | 任务 | 详情文件 | 依赖 | 状态 |
|---|------|----------|------|------|
| 5.1 | 迁移 phase-0 skill | tasks/5.1-skill-phase-0.md | 4.19 | [ ] |
| 5.2 | 迁移 phase-1 skill | tasks/5.2-skill-phase-1.md | 4.19 | [ ] |
| 5.3 | 迁移 phase-2 skill | tasks/5.3-skill-phase-2.md | 4.19 | [ ] |
| 5.4 | 迁移 phase-3~8（批量 6 个） | tasks/5.4-skill-phase-3-8.md | 4.19 | [ ] |
| 5.5 | 迁移 health skill | tasks/5.5-skill-health.md | 4.19 | [ ] |
| 5.6 | 迁移 code-review skill | tasks/5.6-skill-review.md | 4.19 | [ ] |
| 5.7 | 迁移 recall skill | tasks/5.7-skill-recall.md | 4.19 | [ ] |
| 5.8 | 迁移 register-commands skill | tasks/5.8-skill-register.md | 4.19 | [ ] |
| 5.9 | 命令文件规范化 | tasks/5.9-commands-cleanup.md | 5.5-5.8 | [ ] |
| 5.10 | 迁移 plan-generate skill | tasks/5.10-skill-plan-generate.md | 4.19 | [ ] |

## Wave 6: 测试 + 文档 + 发布

| # | 任务 | 详情文件 | 依赖 | 状态 |
|---|------|----------|------|------|
| 6.1 | tests/helpers/test-utils.mjs | tasks/6.1-test-helpers.md | 0.6 | [ ] |
| 6.2 | Wave 1 模块单元测试 | tasks/6.2-test-wave1.md | 6.1 | [ ] |
| 6.3 | Wave 1.4-1.6 模块单元测试 | tasks/6.3-test-wave1b.md | 6.1 | [ ] |
| 6.4 | Wave 2 模块单元测试 | tasks/6.4-test-wave2.md | 6.1 | [ ] |
| 6.5 | Wave 2.4-2.6 模块单元测试 | tasks/6.5-test-wave2b.md | 6.1 | [ ] |
| 6.6 | Wave 3 模块单元测试 | tasks/6.6-test-wave3.md | 6.1 | [ ] |
| 6.7 | Wave 3.3-3.7 模块单元测试 | tasks/6.7-test-wave3b.md | 6.1 | [ ] |
| 6.8 | MCP 工具集成测试 | tasks/6.8-test-tools.md | 6.2-6.7 | [ ] |
| 6.9 | Hook 工具测试 | tasks/6.9-test-hooks.md | 6.2-6.7 | [ ] |
| 6.10 | E2E 测试 | tasks/6.10-test-e2e.md | 6.8,6.9 | [ ] |
| 6.11 | 文档迁移 | tasks/6.11-docs.md | 4.19 | [ ] |
| 6.12 | VERSION/CHANGELOG/发布 | tasks/6.12-release.md | 6.10 | [ ] |

---

完成标准：
- 全部 `[x]`
- `npm test` 通过
- `npm run build` 成功，`dist/mcp-server.cjs` < 2MB
- `node dist/mcp-server.cjs` 启动无报错
- 重新加载插件 → `flow_kit_status` 返回正确状态
- 编辑文件 → `post_edit_format` hook 触发
- Stop 事件 → `quality_gate` hook 触发
- 新会话 → `session_restore` hook 触发
- 根目录干净（< 10 文件）
- 所有原有 skills/commands 可正常加载

## 未映射 Shell 文件处理（34 个）

### REWRITE（8 个 → 独立 JS 文件）
以下 Shell 文件需要独立 JS 重写，功能已包含在对应 Wave 任务中：

| Shell 文件 | 行数 | 去向 | 包含在任务 |
|-----------|------|------|-----------|
| scripts/recall.sh | 113 | src/tools/recall.mjs | 4.3 |
| scripts/metrics.sh | 55 | src/tools/metrics.mjs | 4.4 |
| scripts/next-phase.sh | 91 | src/tools/phase.mjs | 4.6 |
| scripts/shellcheck-all.sh | 70 | src/tools/shellcheck.mjs | 4.9 |
| scripts/offline-mode.sh | 213 | src/tools/phase.mjs（内联） | 4.6 |
| scripts/performance-regression.sh | 61 | src/tools/metrics.mjs（内联） | 4.4 |
| scripts/pr-description.sh | 170 | src/tools/init.mjs（内联） | 4.7 |
| scripts/prd-parser.sh | 178 | src/lib/front-matter.mjs（内联） | 2.3 |

### MERGE（12 个 → 并入已有模块）
以下 Shell 文件功能已被 PRD 模块映射中的 JS 模块覆盖，不需独立任务：

| Shell 文件 | 并入目标 |
|-----------|---------|
| lib/cost-reporter.sh | src/lib/metrics.mjs |
| lib/context-updater.sh | src/lib/session-state.mjs |
| lib/expiry-checker.sh | src/lib/context-budget.mjs |
| lib/health-rotation.sh | src/lib/paths.mjs |
| lib/pr-generator.sh | src/lib/command-gen.mjs |
| lib/token-estimator.sh | src/lib/context-budget.mjs |
| scripts/dispatch-aggregate.sh | src/lib/dispatch-core.mjs |
| scripts/dispatch-status.sh | src/lib/dispatch-core.mjs |
| scripts/health-scheduler.sh | src/tools/status.mjs |
| scripts/log-aggregator.sh | src/lib/metrics.mjs |
| scripts/p0-check.sh | src/lib/security-scanner.mjs |
| scripts/caveman-compress.sh | src/lib/context-budget.mjs |

### SKILL（2 个 → skills/ 目录迁移）
| Shell 文件 | 去向 | 备注 |
|-----------|------|------|
| scripts/code-review.sh(435行) | skills/code-review/SKILL.md | Wave 5.6 |
| scripts/plan-generate.sh(442行) | skills/plan-generate/SKILL.md | **需新增任务** |

### DEPRECATED（8 个 → 归档）
| Shell 文件 | 废弃原因 |
|-----------|---------|
| scripts/doc-extractor.sh | MCP 工具清单自描述 |
| scripts/generate-api-docs.sh | MCP 工具签名自描述 |
| scripts/ide-adapter.sh | MCP 协议即适配层 |
| scripts/install.sh | npm install 替代 |
| scripts/tmux-aggregate.sh | agent dispatch 替代 |
| scripts/tmux-cleanup.sh | 同上 |
| scripts/tmux-init.sh | 同上 |
| scripts/tmux-run.sh | 同上 |

## 技术决策

| 决策 | 选择 | 原因 |
|------|------|------|
| 源码格式 | `.mjs`（ESM） | Node 原生支持，vitest 友好 |
| 打包产物 | `.cjs`（CJS） | MCP stdio 兼容性最好 |
| MCP Server 生命周期 | 长驻进程 | Claude Code 管理 stdio 连接，hook 不重启 |
| esbuild | 全量 bundle，external=[] | 零外部依赖，单文件分发 |
| commands/ 文件处理 | 37 个保留，M-/I- 前缀重命名 | 兼容现有用户习惯 |
| skills/ 辅助 skill | 16 个现有 skill 保留 | 非核心工作流但有用 |

## 新目录（Wave 0.1 创建）

```
src/lib/              # 15 个业务模块（.mjs）
src/tools/            # 12 核心 + 1 monitor MCP 工具
src/hooks/            # 5 hook MCP 工具
dist/                 # esbuild 产物
archive/v3.7.0-shell/ # Shell 归档
skills/phase-{0-8}/   # Phase skills
skills/{health,code-review,recall,register-commands}/
docs/                 # 迁移文档
tests/helpers/        # 共享测试工具
tests/tools/          # MCP 工具测试
tests/hooks/          # Hook 测试
```

## skills/ 现有文件说明

现有 skills/ 目录包含 16 个扁平 .md 文件（非目录结构）。v3.8.0 转为目录结构（`skills/<name>/SKILL.md`）时，这些文件保留并迁移到对应子目录。不属于核心工作流，但提供有用的辅助能力。

## Superpowers-ZH 技能依赖索引

每任务适用 `/test-driven-development`（RED）+ `/verification-before-completion`（打[x]前）+ `/requesting-code-review`（实现后）+ `/smart-commit`（git commit）。
以下仅列出**额外专用技能**：

| 任务 | 推荐技能 | 说明 |
|------|---------|------|
| Wave 1 全部（1.1-1.6） | `/dispatching-parallel-agents` | 6 个模块无依赖，可并行 |
| 2.4 security-scanner | `/brainstorming` | 18 种正则 + 多层检测，先设计 |
| 2.6 context-budget | `/brainstorming` | Token 估算算法复杂，先设计 |
| 3.3 dispatch-core | `/writing-plans` | 890 行 Shell → JS，影响 5+ 接口 |
| 3.7 validate-phase | `/writing-plans` | 650 行 Shell，9 个 schema 验证 |
| Wave 4 全部（4.1-4.19） | `/mcp-builder` | MCP Server 构建方法论 |
| 4.1 server.mjs | `/mcp-builder` + `/brainstorming` | 核心入口，需先设计架构 |
| 4.13 quality_gate | `/brainstorming` | async hook + asyncRewake 模式 |
| Wave 5 全部（5.1-5.10） | `/writing-skills` | Skills 目录结构迁移 |
| 5.6 code-review | `/writing-skills` | 435 行 Shell → SKILL.md |
| 5.10 plan-generate | `/writing-skills` | 442 行 Shell → SKILL.md |
| 6.12 发布 | `/finishing-a-development-branch` | 分支收尾 + 发布 |
