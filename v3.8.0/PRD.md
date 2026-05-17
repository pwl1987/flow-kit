# flow-kit v3.8.0 PRD：全量 JS 重写 + MCP Server 化

## 1. 背景与动机

### v3.7.0 回顾

v3.7.0 完成了 22 个任务，测试从 138 增长到 213（+54%），ShellCheck 零 error。但双验证矩阵暴露核心问题：

- **ralph-driven-dev 8/10**：任务拆分和循环执行有效
- **flow-kit 自验证 2/10**：纯 Shell 架构无法被 AI 直接调用

根因：flow-kit 是纯 Shell 脚本集合，没有 MCP Server 层。Ralph Loop 单线程独占会话，flow-kit 的交互式命令无法并行介入。Hooks 是被动触发的文本处理器，无法拦截质量问题。

### 技术决策

**全量 JS 重写**，统一为 JS + MD + JSON 技术栈：

1. **MCP Server 化**：18 个工具（12 核心 + 5 hook + 1 monitor），直接被 Claude Code 生态调用
2. **Hooks → mcp_tool 类型**：5 个 hook 全部通过 MCP 工具实现，支持 `input` 参数传递
3. **Skills 目录结构**：`skills/<name>/SKILL.md` 替代扁平 `commands/`
4. **esbuild 单文件打包**：零外部依赖，`dist/mcp-server.cjs`

### 官方规范依据

基于 2026-05-16 的 11 篇 Claude Code 官方文档分析：

- **Hooks 可直接调 MCP 工具**：`{ "type": "mcp_tool", "server": "flow-kit", "tool": "pre_tool_guard", "input": { "file_path": "..." } }`
- **Hooks 支持 `async + asyncRewake`**：质量门禁后台运行，失败时唤醒 Claude
- **Skills 合并 commands**：两种格式等价，推荐目录结构
- **MCP 工具延迟加载**：`alwaysLoad` 豁免核心工具
- **`CLAUDE_PROJECT_DIR` 环境变量**：MCP Server 进程自动注入

## 2. 目标

| # | 目标 | 验证标准 |
|---|------|---------|
| G1 | MCP Server 启动，18 工具可发现 | `node dist/mcp-server.cjs` 无报错 |
| G2 | Hooks 通过 mcp_tool 类型正确触发 | 编辑文件 → post_edit_format 被调用 |
| G3 | 所有 Shell 功能有 JS 等价实现 | 15 个 lib 模块 + 8 个 scripts 模块迁移完成 |
| G4 | 测试覆盖核心模块 | 单元测试 + 集成测试 + E2E 全通过 |
| G5 | 旧数据格式兼容 | session-state.json / metrics.jsonl 格式不变 |
| G6 | 插件可通过 Claude Code 安装 | `claude plugin validate` 通过 |

## 3. 架构

### 3.1 目录结构

```
flow-kit/
├── .claude-plugin/
│   └── plugin.json                 # 清单
├── .mcp.json                       # MCP Server 配置
├── hooks/
│   └── hooks.json                  # Hooks 配置（mcp_tool 类型）
├── skills/                         # Skills（SKILL.md 目录结构）
│   ├── health/SKILL.md
│   ├── code-review/SKILL.md
│   ├── phase-{0-8}/SKILL.md
│   ├── recall/SKILL.md
│   └── register-commands/SKILL.md
├── commands/                       # 斜杠命令（保留兼容）
├── src/                            # 全部 JS 源码
│   ├── server.mjs                  # MCP Server 入口
│   ├── tools/                      # 12 核心 + 1 monitor MCP 工具
│   ├── hooks/                      # 5 hook MCP 工具
│   └── lib/                        # 业务逻辑
├── dist/
│   └── mcp-server.cjs              # esbuild 打包产物
├── archive/                        # v3.7.0 Shell 归档
│   └── v3.7.0-shell/
├── config/ | guardrails/ | templates/ | reference/ | phases/  # 保留
├── tests/                          # 测试
├── docs/                           # 文档
├── VERSION | package.json | vitest.config.ts | esbuild.config.mjs
```

### 3.2 MCP Server 入口

```js
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new McpServer({ name: "flow-kit", version: "3.8.0" });
// 注册 18 个工具
const transport = new StdioServerTransport();
await server.connect(transport);
```

### 3.3 Hooks 配置

5 个 hook 全部用 `mcp_tool` 类型，支持 `input` 参数传递：

```json
{
  "PreToolUse": [{ "hooks": [{ "type": "mcp_tool", "tool": "pre_tool_guard",
    "input": { "tool_name": "${tool_name}", "file_path": "${tool_input.file_path}" } }] }],
  "PostToolUse": [{ "hooks": [{ "type": "mcp_tool", "tool": "post_edit_format",
    "input": { "file_path": "${tool_input.file_path}" } }] }],
  "Stop": [{ "hooks": [{ "type": "mcp_tool", "tool": "quality_gate",
    "async": true, "asyncRewake": true }] }],
  "SessionStart": [{ "hooks": [{ "type": "mcp_tool", "tool": "session_restore",
    "input": { "source": "${source}" } }] }],
  "Notification": [{ "hooks": [{ "type": "mcp_tool", "tool": "send_notification",
    "input": { "type": "${notification_type}" } }] }]
}
```

### 3.4 .mcp.json

```json
{
  "mcpServers": {
    "flow-kit": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/dist/mcp-server.cjs"],
      "alwaysLoad": true
    }
  }
}
```

## 4. MCP 工具清单（18 个）

### 核心 12 工具

| 工具 | 类型 | 功能 | maxResultSizeChars | alwaysLoad |
|------|------|------|-------------------|------------|
| `flow_kit_status` | 只读 | 会话状态 | — | true |
| `flow_kit_health` | 只读 | 项目健康 | — | true |
| `flow_kit_version` | 只读 | 版本信息 | — | true |
| `flow_kit_recall` | 只读 | 项目摘要 | 200000 | false |
| `flow_kit_metrics` | 只读 | 执行指标 | 200000 | false |
| `flow_kit_validate` | 只读 | Phase 验证 | — | false |
| `flow_kit_next_phase` | 写 | 推进 Phase | — | false |
| `flow_kit_run_phase` | 写 | 执行 Phase | — | false |
| `flow_kit_init_change` | 写 | 初始化变更 | — | false |
| `flow_kit_dispatch` | 写 | 多代理调度 | — | false |
| `flow_kit_shellcheck` | 写 | ShellCheck | — | false |
| `flow_kit_register` | 写 | 注册命令 | — | false |

### Hook 工具 5 个

| 工具 | Hook 事件 | 功能 |
|------|----------|------|
| `pre_tool_guard` | PreToolUse | 安全拦截（接收 tool_name/file_path/command） |
| `post_edit_format` | PostToolUse | 格式化（接收 file_path） |
| `quality_gate` | Stop | 质量门禁（async 后台运行） |
| `session_restore` | SessionStart | 会话恢复（接收 source） |
| `send_notification` | Notification | 通知（接收 type） |

### Monitor 工具 1 个

| 工具 | 类型 | 功能 |
|------|------|------|
| `flow_kit_watch` | Monitor | 实时指标流 |

## 5. 模块映射（Shell → JS）

| Shell 源 | JS 目标 | 行数 | 关键函数 |
|---------|--------|------|---------|
| `lib/paths.sh` | `src/lib/paths.mjs` | 178 | `getPaths()`, `initRuntimeDirs()`, `rotateLogs()` |
| `lib/error-handler.sh` | `src/lib/error-handler.mjs` | 244 | `logInfo/Warn/Error()`, `die()`, `safeExit()`, `setupTrap()` |
| `lib/cleanup.sh` | `src/lib/cleanup.mjs` | 47 | `registerCleanup()`, `withCleanup()` |
| `lib/time-utils.sh` | `src/lib/time-utils.mjs` | 42 | `getEpochMs()`, `dateToEpoch()` |
| `lib/preflight.sh` | `src/lib/preflight.mjs` | 44 | `requireTool()` |
| `lib/session-state.sh` | `src/lib/session-state.mjs` | 332 | `sessionInit/Set/Get()`, `sessionResumePrompt()` |
| `lib/metrics-logger.sh` | `src/lib/metrics.mjs` | 73 | `logEvent()`, `query()`, `summary()` |
| `lib/front-matter.sh` | `src/lib/front-matter.mjs` | 80 | `parseFrontMatter()`, `getField()` |
| `lib/security-scanner.sh` | `src/lib/security-scanner.mjs` | 296 | `scanSecrets()`, `scanSqlInjection()`, `scanXss()` |
| `lib/conflict-detector.sh` | `src/lib/conflict-detector.mjs` | 221 | `detectConflict()`, `handleConflictDecision()` |
| `lib/context-budget.sh` | `src/lib/context-budget.mjs` | 476 | `estimateTokens()`, `checkBudget()`, `getBudgetStatus()` |
| `lib/project-info.sh` | `src/lib/project-info.mjs` | 78 | `getGitInfo()`, `getVersion()` |
| `scripts/dispatch-lock.sh` | `src/lib/lock.mjs` | 160 | `acquireLock()`, `releaseLock()`, `isLockStale()` |
| `scripts/phase-executor.sh` | `src/lib/phase-executor.mjs` | 113 | `runPhase()`, `loadWorkflow()` |
| `scripts/auto-pilot.sh` | `src/lib/auto-pilot.mjs` | 264 | `doNext()`, `doStatus()`, `recommendNextStep()` |
| `scripts/dispatch.sh` | `src/lib/dispatch-core.mjs` | 890 | `splitTask()`, `executeSubagents()` |
| `scripts/dispatch-parse.sh` | `src/lib/dispatch-parse.mjs` | 90 | `parseManifest()`, `parseSubtask()` |
| `scripts/generate-commands.sh` | `src/lib/command-gen.mjs` | 293 | `generateEntry()`, `registerAllCommands()` |
| `scripts/init-change.sh` | `src/lib/init-change.mjs` | 330 | `initChange()`, `checkCollision()` |
| `scripts/validate-phase.sh` | `src/lib/validate-phase.mjs` | 650 | `validateArtifacts()`, `validateSchema()` |
| `hooks/*.sh` ×5 | `src/hooks/*.mjs` ×5 | 523 | 作为 MCP hook 工具暴露 |

### 5.1 未映射 Shell 文件分类（34 个）

| 分类 | 数量 | 代表文件 | 去向 |
|------|------|---------|------|
| REWRITE | 8 | `recall.sh`, `metrics.sh`, `next-phase.sh`, `offline-mode.sh`(213行), `performance-regression.sh`(61行), `pr-description.sh`(170行), `prd-parser.sh`(178行), `shellcheck-all.sh` | 独立 JS 文件（功能已包含在对应 Wave 任务中） |
| MERGE | 12 | `cost-reporter.sh`, `context-updater.sh`, `expiry-checker.sh`, `health-rotation.sh`, `pr-generator.sh`, `token-estimator.sh`, `dispatch-aggregate.sh`, `dispatch-status.sh`, `health-scheduler.sh`, `log-aggregator.sh`, `p0-check.sh`, `caveman-compress.sh` | 并入已有 JS 模块（metrics/context-budget/session-state/dispatch-core/security-scanner） |
| SKILL | 2 | `code-review.sh`(435行), `plan-generate.sh`(442行) | `skills/<name>/SKILL.md` 目录迁移 |
| DEPRECATED | 8 | `doc-extractor.sh`, `generate-api-docs.sh`, `ide-adapter.sh`, `install.sh`, `tmux-aggregate.sh`, `tmux-cleanup.sh`, `tmux-init.sh`, `tmux-run.sh` | 归档到 `archive/v3.7.0-shell/` |

### 5.2 工具文件命名约定

`src/tools/` 下一个工具一个文件，不合并：

| 文件 | 包含工具 |
|------|---------|
| `status.mjs` | `flow_kit_status` + `flow_kit_version` + `flow_kit_health` |
| `recall.mjs` | `flow_kit_recall` |
| `metrics.mjs` | `flow_kit_metrics` |
| `validate.mjs` | `flow_kit_validate` |
| `shellcheck.mjs` | `flow_kit_shellcheck` |
| `phase.mjs` | `flow_kit_next_phase` + `flow_kit_run_phase` |
| `init.mjs` | `flow_kit_init_change` |
| `dispatch.mjs` | `flow_kit_dispatch` |
| `register.mjs` | `flow_kit_register` |
| `watch.mjs` | `flow_kit_watch` |

## 6. 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 运行时 | Node.js | >=18 |
| MCP SDK | @modelcontextprotocol/sdk | ^1.29.0 |
| Schema | zod | ^3.23.0 |
| YAML 解析 | yaml | ^2.4.0 |
| 测试 | vitest | ^2.0.0 |
| 打包 | esbuild | ^0.21.0 |

## 7. 数据格式兼容

以下文件格式在 v3.8.0 中**不变**：

- `.flow-kit/session-state.json` — v2 schema，JS 直接读写
- `.flow-kit/logs/metrics.jsonl` — JSONL 格式，JS 追加写入
- `lib/validation/schemas/phase-*.schema.json` — 9 个 JSON Schema 保留
- `phases/*.md` YAML front matter — 格式不变

## 8. 技术决策

### 8.1 JS 模块系统：源码 .mjs → 打包 .cjs

| 层级 | 格式 | 原因 |
|------|------|------|
| 源码 `src/**/*.mjs` | ESM（import/export） | Node.js 原生支持，vitest 原生支持，tree-shaking 友好 |
| 测试 `tests/**/*.test.mjs` | ESM | vitest 已配置 ESM |
| 打包产物 `dist/mcp-server.cjs` | CJS | Claude Code MCP 协议通过 stdio 启动，CJS 兼容性最好（无需 --experimental-modules） |
| esbuild 配置 `esbuild.config.mjs` | ESM | esbuild 原生支持 |

**关键**：esbuild `format=cjs` 将所有 ESM import 打包为 CJS require。`node_modules/` 中 `@modelcontextprotocol/sdk`、`zod`、`yaml` 全部 bundle 进去（`external: []`）。**产物零外部依赖**。

### 8.2 MCP Server 生命周期

Claude Code 管理 MCP Server 进程：

1. **插件加载时**：`claude` 进程根据 `.mcp.json` 启动 `node dist/mcp-server.cjs`，保持 stdio 长连接
2. **工具调用时**：通过 JSON-RPC over stdio 发送请求，**不重新启动进程**
3. **Hooks `mcp_tool` 类型**：Claude Code 内部路由到已运行的 MCP Server，**不启动新进程**
4. **插件卸载时**：claude 进程发送 SIGTERM，MCP Server 优雅退出

**结论**：MCP Server 是长驻进程，不会因为 hook 触发而频繁启动。一次启动，全程复用。

### 8.3 目录创建完整性

所有新目录在 Wave 0.1 一次性创建：

```
src/lib/          # 业务逻辑（15 个模块）
src/tools/        # MCP 核心工具（12 个）
src/hooks/        # MCP hook 工具（5 个）
dist/             # esbuild 打包产物
archive/v3.7.0-shell/  # Shell 归档
  ├── lib/
  ├── scripts/
  └── hooks/
skills/            # 新格式 Skills 目录
  ├── phase-0/
  ├── phase-1/
  ├── ...
  ├── phase-8/
  ├── health/
  ├── code-review/
  ├── recall/
  └── register-commands/
docs/              # 文档迁移目标
tests/helpers/     # 共享测试工具
tests/tools/       # MCP 工具测试
tests/hooks/       # Hook 工具测试
```

## 9. 约束

1. **esbuild 单文件打包**：`dist/mcp-server.cjs` 为唯一分发产物，零外部依赖
2. **源码 ESM、产物 CJS**：开发用 .mjs，打包输出 .cjs
3. **Shell 归档不删除**：`archive/v3.7.0-shell/` 保留所有 Shell 脚本
4. **commands/ 保留兼容**：新 skills/ 和旧 commands/ 共存
5. **所有测试 ESM 风格**：`import { describe, it, expect } from 'vitest'`
6. **每个模块独立可测**：依赖注入，不耦合 MCP Server 框架
7. **根目录干净**：<10 个文件，Shell 全归档
8. **MCP Server 长驻进程**：不因 hook 触发重启
9. **现有 skills/ 保留**：16 个辅助 skill（agent-orchestrator, debugging, verification 等）保留在 skills/ 目录，不删除
10. **commands/ 仅重命名**：37 个命令文件保留，`M-health.md` → `health.md`、`I-intel-scan.md` → `intel-scan.md`

## 10. 风险

| 风险 | 概率 | 缓解 |
|------|------|------|
| `@modelcontextprotocol/sdk` API 变更 | 低 | 锁定 `^1.29.0` |
| esbuild CJS 打包兼容 | 中 | Wave 4 优先验证 bundle 运行 |
| Hooks mcp_tool 类型不稳定 | 中 | 保留 command 类型 fallback |
| vitest ESM 适配 | 中 | vitest.config.ts 已支持 |
| MCP Server 内存泄漏（长驻进程） | 中 | 每次请求后清理临时对象，Node.js --max-old-space-size=256 |
| 34 个 Shell 文件无独立映射 | 中 | 分类处理：REWRITE(8) / MERGE(12) / SKILL(2) / DEPRECATED(8) |

## 11. 验收标准

1. `npm run build` 成功，`dist/mcp-server.cjs` 存在且 <2MB
2. `npm test` 全部通过
3. `node dist/mcp-server.cjs` 启动无报错
4. 重新加载插件 → `flow_kit_status` 返回正确状态
5. 编辑文件 → `post_edit_format` hook 触发
6. Stop 事件 → `quality_gate` hook 触发
7. 新会话 → `session_restore` hook 触发
8. 目录结构干净（根目录 <10 文件）
9. 所有原有 skills/commands 可正常加载
