--- BEGIN flow-kit/GO.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】

## 优先级加载（任何逻辑不得违反）

1. **立即加载** `@flow-kit/config/constitution.md`（全局最高优先级）
2. **立即加载** `@flow-kit/config/default-user-config.md`，若存在 `.flow-kit/user-config.md` 则优先加载用户自定义配置
3. **立即加载** `@flow-kit/config/system-rules.md`（R1-R8 系统级硬规则）
4. 后续所有逻辑必须遵守这三份配置

## 启动检查（自动执行，非阻塞）

在命令路由之前执行以下检查：

1. **上下文过期检测** (`@flow-kit/commands/check-expiry.md`)
   - 扫描 `.planning/phases/` 下 .md 文件的最后修改时间
   - 15 天警告：输出 `[WARNING] Context will expire in {N} days`
   - 30 天阻止：输出 `[BLOCK] Context expired, run recovery or archive`

2. **Token 估算** (`@flow-kit/commands/estimate-tokens.md`)
   - 静默统计 .planning/phases/ 下 LOC（排除 template）
   - 80% budget：输出警告
   - 100% budget：阻止继续

## 项目类型检测（启动时自动执行）

读取 `.flow-kit/project-type` 文件，若不存在则提示：
  [INFO] 项目类型未检测，运行 `/flow-kit:project-type detect` 进行检测

### 规模自动评估
加载 @flow-kit/commands/scale-level.md，根据改动范围自动评估 L0-L3 级别。
L0 直接进入极简模式，跳过 Phase 2-3。

### 检测结果输出格式
当检测到项目类型后，显示：

```
[Project Type Detection]
  Type: {brownfield|greenfield|light-brownfield}
  Confidence: {high|medium|low}
  
  Recommended Actions:
    - /flow-kit:guardrails  (棕地项目启用护栏)
    - /flow-kit:skill:code-review  (P0 变更使用深度模板)
    - /flow-kit:skill:verification  (Phase 4-5 使用全量验证)
  
  Quick Commands:
    - /flow-kit:project-type detect  (重新检测)
    - /flow-kit:project-type brownfield  (手动设为棕地)
    - /flow-kit:project-type greenfield  (手动设为绿地)
```

---

## 命令路由规则

当用户输入 `/flow-kit:xxx` 格式命令时，按以下顺序匹配：

1. **精确匹配**：若命令完全等于已知命令，直接路由
2. **模糊匹配**：计算 Levenshtein 距离，若最小距离 <= 2，提示 "Did you mean `{closest}`? [y/n]"
3. **子串匹配**：若命令是某已知命令的子串，建议该命令
4. **无匹配**：显示所有可用命令及用法提示

---

# flow-kit Entry Point

## Available Commands

| 命令 | 目标文件 |
|------|----------|
| `/flow-kit:careful` | `@flow-kit/commands/careful.md` |
| `/flow-kit:freeze` | `@flow-kit/commands/careful.md --mode freeze` |
| `/flow-kit:guard` | `@flow-kit/commands/careful.md --mode guard` |
| `/flow-kit:unfreeze` | 解除 freeze 限制 |
| `/flow-kit:scale` | `@flow-kit/commands/scale-level.md` |
| `/flow-kit:offline` | `@flow-kit/commands/offline-mode.md` |
| `/flow-kit:minimal` | `@flow-kit/commands/minimal-mode.md` |
| `/flow-kit:online` | `@flow-kit/commands/offline-mode.md` |
| `/flow-kit:health` | `@flow-kit/commands/M-health.md` |
| `/flow-kit:scan` | `@flow-kit/commands/I-intel-scan.md` |
| `/flow-kit:update-context` | `@flow-kit/commands/update-context.md` |
| `/flow-kit:sync-config` | `@flow-kit/commands/sync-team-config.md` |
| `/flow-kit:check-expiry` | `@flow-kit/commands/check-expiry.md` |
| `/flow-kit:estimate-tokens` | `@flow-kit/commands/estimate-tokens.md` |
| `/flow-kit:project-type` | `@flow-kit/commands/project-type.md` |
| `/flow-kit:recovery` | `@flow-kit/commands/check-expiry.md` |
| `/flow-kit:pr-description` | `@flow-kit/commands/pr-description.md` |
| `/flow-kit:cost-report` | `@flow-kit/commands/cost-report.md` |
| `/flow-kit:p0` | `@flow-kit/commands/p0-approval.md` |
| `/flow-kit:archive` | `@flow-kit/archive/archive-change.md` |
| `/flow-kit:skill:[name]` | `@flow-kit/skills/[name].md` |

## Skill Routing（按 Phase 上下文）

| Phase | 触发场景 | 推荐技能 |
|-------|----------|----------|
| Phase 1 | 需求模糊/不完整 | `@flow-kit/skills/requirement-clarify.md` |
| Phase 2 | 任务拆解 | `@flow-kit/skills/task-master.md` |
| Phase 3+ | 并行任务分发 | `@flow-kit/skills/subagent-execution.md` + `@flow-kit/skills/parallel-dispatch.md` |
| Phase 4-5 | 交付前验证 | `@flow-kit/skills/verification.md` |
| Phase 6 | 代码审查 | `@flow-kit/skills/code-review.md` |
| Any | Bug 诊断 | `@flow-kit/skills/debugging.md` |

**直接调用**：`@flow-kit/skills/[skill-name].md`
**模糊路由**：`/flow-kit:skill:requirement-clarify` → 匹配 `@flow-kit/skills/requirement-clarify.md`

## Routing Logic

```
1. Parse user input for /flow-kit:xxx command pattern
2. EXACT MATCH:
   - if command == known_command -> route directly
3. FUZZY SEARCH (Levenshtein):
   - calculate distance to all known commands
   - if min_distance <= 2 -> prompt "Did you mean {closest}? [y/n]"
   - if y -> route to closest
4. SUBSTRING MATCH:
   - if command is substring of any known -> suggest matched command
5. NO MATCH:
   - show "Available commands: /flow-kit:health, /flow-kit:scan, /flow-kit:update-context, /flow-kit:sync-config, /flow-kit:check-expiry, /flow-kit:estimate-tokens, /flow-kit:offline, /flow-kit:minimal, /flow-kit:pr-description, /flow-kit:cost-report, /flow-kit:p0, /flow-kit:archive"
```

## Levenshtein Implementation

```javascript
function levenshtein(a, b) {
  const matrix = Array(b.length + 1).fill(null)
    .map(() => Array(a.length + 1).fill(null));
  for (let i = 0; i <= a.length; i++) matrix[0][i] = i;
  for (let j = 0; j <= b.length; j++) matrix[j][0] = j;
  for (let j = 1; j <= b.length; j++) {
    for (let i = 1; i <= a.length; i++) {
      const cost = a[i - 1] === b[j - 1] ? 0 : 1;
      matrix[j][i] = Math.min(
        matrix[j][i - 1] + 1,
        matrix[j - 1][i] + 1,
        matrix[j - 1][i - 1] + cost
      );
    }
  }
  return matrix[b.length][a.length];
}

function findClosestCommand(input, commands) {
  let minDist = Infinity;
  let closest = null;
  for (const cmd of commands) {
    const dist = levenshtein(input, cmd);
    if (dist < minDist) {
      minDist = dist;
      closest = cmd;
    }
  }
  return { closest, distance: minDist };
}
```

**Fuzzy match threshold**: distance <= 2 triggers "Did you mean?" prompt

## Confirmation Prompt

When Levenshtein distance <= 2:
```
Did you mean `/flow-kit:health`? [y/n]
```
- `y` or `yes`: route to suggested command
- `n` or `no`: show available commands

--- END flow-kit/GO.md ---