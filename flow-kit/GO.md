--- BEGIN flow-kit/GO.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】

## 优先级加载（任何逻辑不得违反）

1. **立即加载** `@flow-kit/config/constitution.md`（全局最高优先级）
2. **立即加载** `@flow-kit/config/default-user-config.md`，若存在 `.flow-kit/user-config.md` 则优先加载用户自定义配置
3. 后续所有逻辑必须遵守这两份配置

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
| `/flow-kit:health` | `@flow-kit/commands/M-health.md` |
| `/flow-kit:scan` | `@flow-kit/commands/I-intel-scan.md` |
| `/flow-kit:update-context` | `@flow-kit/commands/update-context.md` |
| `/flow-kit:sync-config` | `@flow-kit/commands/sync-team-config.md` |
| `/flow-kit:archive` | `@flow-kit/archive/archive-change.md` |

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
   - show "Available commands: /flow-kit:health, /flow-kit:scan, /flow-kit:update-context, /flow-kit:sync-config, /flow-kit:archive"
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