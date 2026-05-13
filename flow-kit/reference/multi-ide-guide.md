> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件提供多 IDE 适配方案，确保 flow-kit 在 Claude Code、Windsurf、Cursor、Copilot 等主流 AI IDE 中一致工作。

## 1. 通用方式（任何 AI IDE 都适用）

flow-kit 的 3 文件基线在任何 AI IDE 中均可工作：

| 文件 | 用途 | 引用方式 |
|------|------|----------|
| `GO.md` | 入口点 | `@flow-kit/GO.md` |
| `config/constitution.md` | 安全地板 | `@flow-kit/config/constitution.md` |
| `config/system-rules.md` | R1-R8 规则 | `@flow-kit/config/system-rules.md` |

**通用适配原则：**
- 入口文件始终为 `GO.md`，各 IDE 均支持 `@` 引用语法
- 安全规则（constitution.md）和系统规则（system-rules.md）提供一致性保障
- 不依赖任何 IDE 特定功能

---

## 2. Claude Code 适配

Claude Code 是 flow-kit 的原生目标 IDE，提供最完整支持。

**Skill 安装：**
```
flow-kit/skills/（对应 skill 文件）
```
例如：`flow-kit/skills/agent-pipeline.md` 启动研究→计划→实现阶段流程。

**SYSTEM.md 全局注入：**
- 路径：`~/.claude/projects/{project}/SYSTEM.md`
- 内容：引用 flow-kit 核心文件路径
- 效果：每次会话自动加载 flow-kit 上下文

**@引用：**
```
@flow-kit/GO.md
```
Claude Code 原生支持 `@` 文件引用，自动解析相对路径。

---

## 3. Windsurf 适配

**Workflow 复制：**
1. 将 `flow-kit/` 目录复制到项目根目录
2. 在 Windsurf 工作流中引用 `flow-kit/GO.md`
3. 使用 Windsurf 的 `.windsurfrules` 配置自定义规则

**.windsurfrules 配置示例：**
```
# Windsurf Rules
[workflow]
include = "flow-kit/GO.md"

[rules]
safety_threshold = "flow-kit/config/constitution.md"
system_rules = "flow-kit/config/system-rules.md"
```

**关键路径映射：**
| flow-kit 路径 | Windsurf 映射 |
|---------------|---------------|
| `GO.md` | `./flow-kit/GO.md` |
| `config/` | `./flow-kit/config/` |

---

## 4. Cursor 适配

**.cursorrules 配置：**
在项目根目录创建 `.cursorrules` 文件：

```
# Cursor Rules
[reference]
entry = "flow-kit/GO.md"
safety = "flow-kit/config/constitution.md"
rules = "flow-kit/config/system-rules.md"
```

**@引用方式：**
Cursor 支持 `@` 引用，与 Claude Code 相同：
```
@flow-kit/GO.md
```

**快捷命令映射：**
| 功能 | Cursor 快捷键 |
|------|---------------|
| 引用文件 | `@` |
| 触发建议 | `Cmd+K` / `Ctrl+K` |

---

## 5. Copilot/Codex/Gemini 适配

**@引用通用方式：**
主流 AI IDE 均支持 `@` 文件引用语法：
```
@flow-kit/GO.md
```

**API 差异说明：**

| IDE | @引用支持 | 文件解析方式 |
|-----|-----------|-------------|
| Copilot | 部分支持 | 需显式提及文件路径 |
| Codex | 支持 | 通过 prompt 中引用 |
| Gemini | 有限支持 | 推荐在 prompt 开头引用 |

**兼容性提示：**
- 在 Copilot/Codex 中使用 flow-kit 时，建议在 prompt 开头明确引用：
  ```
  参考 flow-kit/GO.md 的工作流程。当前任务：[描述]
  ```
- Gemini 用户建议在每次对话开始时粘贴 GO.md 的关键段落

---

## 6. SYSTEM.md 全局注入

全局注入 SYSTEM.md 可降低 60% 摩擦，让 flow-kit 在每次会话中自动激活。

**降低摩擦的核心机制：**
- 无需每次手动引用 flow-kit 文件
- 会话启动时自动加载安全规则和系统规则
- 保持跨会话一致性

**各 IDE 的注入路径：**

| IDE | 注入路径 | 配置位置 |
|-----|----------|----------|
| Claude Code | `~/.claude/projects/{project}/SYSTEM.md` | 项目级配置 |
| Windsurf | `~/.windsurf/config.json` | 全局配置 |
| Cursor | `{project}/.cursorrules` | 项目根目录 |
| Copilot | `~/.copilot/systeminstructions.md` | 全局配置 |

**通用注入内容模板：**
```markdown
# SYSTEM.md 全局注入

## flow-kit 引用
- 入口：`flow-kit/GO.md`
- 安全地板：`flow-kit/config/constitution.md`
- 系统规则：`flow-kit/config/system-rules.md`

## 工作流偏好
- Mode: YOLO（自动批准）
- Granularity: Coarse（3-5 phases）
- Parallelization: 并行执行
- Git Tracking: 启用
```

**验证方法：**
1. 在新会话中输入 `@flow-kit/GO.md`
2. 确认 IDE 能正确解析并显示文件内容
3. 检查安全规则是否在对话中生效

---

## 7. 故障排查

**常见问题与解决方案：**

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| `@` 引用无法解析 | 文件路径错误 | 检查 flow-kit 目录是否在项目根目录 |
| 安全规则未生效 | 未正确注入 | 确认 SYSTEM.md 注入路径正确 |
| IDE 不支持 `@` 语法 | 旧版本 IDE | 在 prompt 开头手动引用文件内容 |
| 多 IDE 规则冲突 | 配置重复 | 使用 IDE 特定配置文件覆盖通用规则 |
| 会话间状态丢失 | 未持久化 | 确保在 SYSTEM.md 中声明规则 |

**调试步骤：**
1. 确认 `flow-kit/` 目录存在于项目根目录
2. 验证 `GO.md`、`config/constitution.md`、`config/system-rules.md` 三文件完整
3. 测试 `@flow-kit/GO.md` 引用是否生效
4. 检查 IDE 的配置路径是否正确指向 flow-kit

---

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit) — 多 IDE 兼容方案 + SYSTEM.md 全局注入策略