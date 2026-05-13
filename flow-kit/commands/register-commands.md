# register-commands

> flow-kit v2.6.1 命令

生成 flow-kit 精简斜杠命令入口到 `flow-kit/.claude/commands/`。

## 用法

```bash
/flow-kit:register-commands
```

等价 CLI：

```bash
bash flow-kit/scripts/generate-commands.sh --force
```

## 当前生成命令

### 核心命令

| 命令                          | 来源                                     |
| ----------------------------- | ---------------------------------------- |
| `/flow-kit:init`              | `flow-kit/commands/init-change.md`       |
| `/flow-kit:health`            | `flow-kit/commands/M-health.md`          |
| `/flow-kit:scan`              | `flow-kit/commands/I-intel-scan.md`      |
| `/flow-kit:scale`             | `flow-kit/commands/scale-level.md`       |
| `/flow-kit:mode`              | `flow-kit/GO.md`                         |
| `/flow-kit:guard`             | `flow-kit/commands/careful.md`           |
| `/flow-kit:hooks`             | `flow-kit/commands/hooks-guide.md`       |
| `/flow-kit:register-commands` | `flow-kit/commands/register-commands.md` |
| `/flow-kit:generate-commands` | `flow-kit/commands/generate-commands.md` |
| `/flow-kit:archive`           | `flow-kit/commands/archive.md`           |
| `/flow-kit:next`              | `flow-kit/GO.md`                         |
| `/flow-kit:status`            | `flow-kit/GO.md`                         |

### Phase 命令

| 命令                | Phase 目录                       |
| ------------------- | -------------------------------- |
| `/flow-kit:phase-0` | `flow-kit/phases/0-change/`      |
| `/flow-kit:phase-1` | `flow-kit/phases/1-requirement/` |
| `/flow-kit:phase-2` | `flow-kit/phases/2-design/`      |
| `/flow-kit:phase-3` | `flow-kit/phases/3-task/`        |
| `/flow-kit:phase-4` | `flow-kit/phases/4-dev/`         |
| `/flow-kit:phase-5` | `flow-kit/phases/5-test/`        |
| `/flow-kit:phase-6` | `flow-kit/phases/6-review/`      |
| `/flow-kit:phase-7` | `flow-kit/phases/7-integration/` |
| `/flow-kit:phase-8` | `flow-kit/phases/8-rollback/`    |

总计：21 个核心命令。

## 生成规则

- 已存在文件：默认跳过。
- `--force`：覆盖重生成。
- Phase 命令传递数字参数给 `phase-executor.sh`，避免 `phase-0` 与 `0-change` 目录名不匹配。

## 安装方式

### 方式一：子模块安装（推荐）

```bash
# 添加 flow-kit 作为 Git 子模块
git submodule add https://github.com/pwl1987/flow-kit.git .flow-kit

# 注册斜杠命令（输出到项目根目录 .claude/commands/）
bash .flow-kit/scripts/generate-commands.sh --force
```

### 方式二：插件安装（Phase 3）

```bash
# 安装为 Claude Code 插件
claude plugin install --dir .flow-kit
```

插件安装后，hooks 和命令自动注册，无需手动执行 `generate-commands.sh`。

## 验证

```bash
# 检查命令数量
ls .claude/commands/flow-kit:*.md | wc -l   # 应为 21

# 测试斜杠命令
/flow-kit:health
/flow-kit:phase-0
```
