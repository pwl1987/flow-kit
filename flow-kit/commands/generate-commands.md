> 【CLAUDE CODE INSTRUCTION 强制约束】

实现 `/flow-kit:generate-commands` 命令，作为 `register-commands` 的底层生成器。

## 命令元数据

**命令路径**: `flow-kit:generate-commands`

**参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--dry-run` | flag | 否 | 只展示将要生成的内容，不写入文件 |
| `--project-only` | flag | 否 | 只生成项目级命令（跳过用户级） |
| `--user-only` | flag | 否 | 只生成用户级命令（跳过项目级） |
| `--output` | string | 否 | 指定输出目录（默认：项目级 `.claude/commands/`，用户级 `~/.claude/commands/`） |

## 解析命令元数据

### 解析流程

从 `flow-kit/commands/*.md` 文件中提取元数据：

1. **YAML 前言解析**（首选）
   ```yaml
   ---
   name: pr-description
   description: Generate PR description from git history
   parameters:
     - name: --format
       type: string
       default: markdown
       description: Output format
   allowed-tools:
     - bash
     - read
   ---
   ```

2. **首行描述解析**（回退方案）
   ```
   > 【CLAUDE CODE INSTRUCTION 强制约束】
   > 本命令提供 PR 描述生成功能。
   ```
   提取命令名称：从文件名 `pr-description.md` -> `pr-description`
   提取描述：从第二行或首段首句

3. **参数提取**
   - 从 YAML `parameters` 块
   - 或从描述中的 `/command:param` 模式

### 解析算法

```
for each file in flow-kit/commands/*.md:
    metadata = parse_yaml_frontmatter(file.content)
    if metadata.name:
        name = metadata.name
        description = metadata.description
        parameters = metadata.parameters
        allowed_tools = metadata.allowed-tools
    else:
        name = filename_without_extension
        description = extract_first_sentence(file.content)
        parameters = []
        allowed_tools = ["bash", "read", "edit"]
    emit CommandMetadata(name, description, parameters, allowed_tools, source_file)
```

## 生成斜杠命令模板

### Claude Code 斜杠命令文件格式

生成文件路径：`.claude/commands/{name}.md`

```markdown
# {name}

{description}

## 参数

{parameters_table}

## 工具限制

Allowed Tools: {allowed_tools.join(", ")}

## 原始文件

Source: `@flow-kit/commands/{source_filename}`

## 使用示例

```bash
/{name}
/{name} --param1 value1
```
```

### 模板变量

| 变量 | 来源 | 示例 |
|------|------|------|
| `{name}` | 文件名或 YAML | `pr-description` |
| `{description}` | YAML 或首行描述 | `Generate PR description from git history` |
| `{parameters_table}` | YAML parameters | `\| param \| type \| default \| description \|` |
| `{allowed_tools}` | YAML allowed-tools | `bash, read, edit` |
| `{source_filename}` | 源文件名 | `pr-description.md` |

## 输出模式

### 项目级输出

```
.claude/commands/
  careful.md
  check-expiry.md
  cost-report.md
  cross-session-search.md
  estimate-tokens.md
  pr-description.md
  project-type.md
  rollback.md
  ...
```

### 用户级输出

```
~/.claude/commands/
  careful.md
  check-expiry.md
  ...
```

### 输出判断逻辑

```javascript
if (args.user_only) {
    output_to_user_level()
} else if (args.project_only) {
    output_to_project_level()
} else {
    output_to_both_levels()
}
```

## Dry-run 模式

启用 `--dry-run` 时：

1. **不写入任何文件**
2. **输出将要生成的文件列表**

```
[DRY-RUN] Would generate the following command files:

Project-level (.claude/commands/):
  - careful.md (from careful.md)
  - estimate-tokens.md (from estimate-tokens.md)
  - pr-description.md (from pr-description.md)
  ... (N files total)

User-level (~/.claude/commands/):
  - careful.md
  - estimate-tokens.md
  ... (N files total)

Would write N files total (M project-level, K user-level)
```

3. **预览每个文件的内容**（前 20 行）

```
=== Project-level: .claude/commands/pr-description.md ===

# pr-description

Generate PR description from git history

## 参数

| param | type | default | description |
|-------|------|---------|-------------|
| --format | string | markdown | Output format |

## 工具限制

Allowed Tools: bash, read

## 原始文件

Source: @flow-kit/commands/pr-description.md

...
```

## 错误处理

| 场景 | 处理 |
|------|------|
| 文件解析失败 | 跳过该文件，输出警告 `[WARN] Failed to parse {filename}: {error}` |
| 无效 YAML | 回退到首行描述解析 |
| 输出目录不存在 | 自动创建目录 |
| 写入失败 | 输出错误 `[ERROR] Failed to write {path}: {error}` 并继续 |

## 实现示例

```javascript
// 核心生成逻辑
function generate_commands(args) {
    const commands_dir = 'flow-kit/commands'
    const files = glob(`${commands_dir}/*.md`)

    const metadata_list = files.map(file => {
        try {
            return parse_command_metadata(file)
        } catch (e) {
            console.warn(`[WARN] Failed to parse ${file}: ${e.message}`)
            return null
        }
    }).filter(Boolean)

    if (args.dry_run) {
        print_dry_run_preview(metadata_list)
        return
    }

    // 项目级输出
    if (!args.user_only) {
        const project_dir = '.claude/commands'
        ensure_dir(project_dir)
        metadata_list.forEach(meta => {
            const content = render_template(meta)
            write_file(`${project_dir}/${meta.name}.md`, content)
        })
    }

    // 用户级输出
    if (!args.project_only) {
        const user_dir = expand_path('~/.claude/commands')
        ensure_dir(user_dir)
        metadata_list.forEach(meta => {
            const content = render_template(meta)
            write_file(`${user_dir}/${meta.name}.md`, content)
        })
    }
}
```

## 依赖关系

- `register-commands.md` — 上层注册命令（调用本生成器）
- `flow-kit/commands/*.md` — 源命令文件（解析目标）

## 参考来源

- [Claude Code Slash Commands Documentation](https://docs.anthropic.com/en/docs/claude-code/slash-commands) — 斜杠命令格式规范
- [flow-kit/commands/](https://github.com/flow-kit/flow-kit/tree/main/flow-kit/commands) — 命令源文件目录