# ralph-driven-dev 参考指南

## 快速开始

### 1. 创建 Ralph Loop 目录

在项目中创建 `ralph/` 目录：

```bash
mkdir -p ralph/tasks
```

### 2. 初始化文件

从模板复制：

```bash
# 复制模板到 ralph/ 目录
cp .claude/skills/ralph-driven-dev/template/ralph/TODO.md ralph/
cp .claude/skills/ralph-driven-dev/template/ralph/PROMPT.md ralph/
cp .claude/skills/ralph-driven-dev/template/ralph/PRD.md ralph/
```

### 3. 自定义 PRD

编辑 `ralph/PRD.md`：
- 替换 `{project}` 为项目名
- 替换 `{project_description}` 为项目描述
- 添加具体目标和模块

### 4. 拆分任务

在 `ralph/TODO.md` 中添加任务：

```markdown
| 0.1 | 目录骨架 | tasks/0.1-skeleton.md | — | [ ] |
| 1.1 | 核心模块 | tasks/1.1-core.md | 0.1 | [ ] |
```

为每个任务创建 `ralph/tasks/X.Y-name.md` 文件。

### 5. 激活 Ralph Loop

```bash
/skill ralph-driven-dev
```

或手动执行：

```
读取 ralph/TODO.md 获取任务索引。读取 ralph/PROMPT.md 获取执行规则...
```

## 目录结构

```
{project}/
├── ralph/                    # Ralph Loop 根目录
│   ├── PRD.md               # 项目需求文档
│   ├── PROMPT.md            # 执行规则
│   ├── TODO.md              # 任务索引
│   └── tasks/               # 任务详情
│       ├── 0.1-name.md
│       ├── 1.1-name.md
│       └── ...
├── src/                      # 源码
├── tests/                    # 测试
└── dist/                     # 产物
```

## 任务命名约定

| 前缀 | 含义 | 示例 |
|------|------|------|
| 0.x | 项目骨架 | 0.1-skeleton, 0.2-config |
| 1.x | 基础模块 | 1.1-paths, 1.2-error-handler |
| 2.x | 核心数据层 | 2.1-session-state, 2.2-metrics |
| 3.x | 业务逻辑层 | 3.1-phase-executor, 3.2-auto-pilot |
| 4.x | 基础设施 | 4.1-server, 4.2-tools |
| 5.x | 测试/文档 | 5.1-test-utils, 5.2-docs |

## 日志格式示例

```
## [迭代 1] 任务 0.1: 项目骨架
**[RED]** 调用 /test-driven-development → 编写测试验证目录存在 → 运行 → FAIL: 功能未实现
**[GREEN]** 实现目录创建逻辑 → 运行 → PASS
**[REFACTOR]** 无需
**[REVIEW]** 自查正确性 → 无问题
**[FIX]** 无需
**[VERIFY]** 调用 /verification-before-completion → 项目测试命令 → PASS
**[COMMIT]** 调用 /smart-commit → a1b2c3d
**[TODO]** 打钩 0.1 → 剩余 N 个任务
```

## 质量门禁配置

### 外部工具集成（可选）

若项目使用 flow-kit，可在 `ralph/PROMPT.md` 中配置迁移模式：

```markdown
## 质量门禁降级（迁移场景）

当 .flow-kit/session-state.json 中 phase=0 且 status=init 时，跳过 artifact 检查。
若不使用 flow-kit，忽略此配置。
```

自定义 quality gate 脚本需先检查文件是否存在：

```bash
# 安全检查：文件不存在时跳过
if [[ -f ".flow-kit/session-state.json" ]]; then
    phase=$(jq -r '.phase // -1' .flow-kit/session-state.json 2>/dev/null)
    status=$(jq -r '.status // ""' .flow-kit/session-state.json 2>/dev/null)
    if [[ "$phase" == "0" && "$status" == "init" ]]; then
        echo "[ralph] 迁移模式，跳过 artifact 检查"
        exit 0
    fi
fi
```

**注意**：若项目不使用 flow-kit，此段代码不会执行（文件不存在时跳过）。

## 故障排除

| 问题 | 解决 |
|------|------|
| 日志格式不对 | 检查 PROMPT.md 日志规则是否正确 |
| 任务漏做 | 重新读 TODO.md，确认全部 [x] |
| 测试一直失败 | 调用 /systematic-debugging |
| 循环不终止 | 检查是否有 [ ] 未打钩 |
| context 满 | 先 commit，再继续循环 |

## 自动项目延续

Ralph Loop 在项目完成后（unchecked=0）向用户展示延续选项。

### 具体步骤

```
步骤 1: 检测完成
  → grep -c '\[ \]' ralph/TODO.md 返回 0
  → 输出"项目完成"摘要

步骤 2: 向用户询问（AskUserQuestion）
  选项 A: 创建新版本（基于当前 TODO 结构生成新 TODO）
  选项 B: 结束发布（项目构建命令 + VERSION + CHANGELOG）
  选项 C: 结束，不创建新项目

步骤 3a: 若选择 A（创建新版本）
  1. 统计当前项目 Wave 数和任务数
  2. 将 ralph/ 复制为 ralph-{version}-archive/（保留完整历史）
  3. 基于归档版本的 Wave 结构，生成新 TODO.md（任务内容更新，状态重置）
  4. 用户编辑新 PRD.md 和 tasks/ 文件
  5. 提示用户确认新项目范围

步骤 3b: 若选择 B（结束发布）
  1. 项目构建命令（见 PROMPT.md 技术栈约束）
  2. 更新 VERSION
  3. 更新 CHANGELOG.md
  4. 输出 <promise>__DONE__</promise>

步骤 3c: 若选择 C
  输出 <promise>__DONE__</promise>
```

### 版本号自动递增

```bash
# 从 VERSION 文件提取当前版本
current=$(cat VERSION | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
major=$(echo $current | cut -d. -f1 | tr -d 'v')
minor=$(echo $current | cut -d. -f2)
patch=$(echo $current | cut -d. -f3)

# 提议新版本
echo "当前版本：$current"
echo "建议升级："
echo "  v${major}.$((minor+1)).0 - 次版本功能扩展"
echo "  v$((major+1)).0.0 - 主版本架构重构"
echo "  v${major}.${minor}.$((patch+1)) - 补丁修复"
```

## 反模式（Anti-Patterns）

| 反模式 | 症状 | 正确做法 |
|--------|------|---------|
| 跳过 RED | 测试直接通过 | 必须先看到测试失败 |
| 批量实现 | 一次做 3 个任务 | 每次只做一个 |
| 猜测进度 | "我记得任务 3 完成了" | 看 TODO.md |
| 推测性重构 | "这段以后可能有用" | YAGNI，不做 |
| 忽略失败测试 | 测试失败但继续 | 先修复测试，再 GREEN |
| 上下文记忆 | "我刚才说要做 X" | 产出物写文件 |
| 范围蔓延 | "顺便把 Y 也做了" | 只做 tasks/ 中的任务 |

## 与其他循环系统对比

| 特性 | Ralph Loop | PDCA | OODA |
|------|------------|------|------|
| 适用场景 | 复杂任务拆分 | 流程优化 | 快速响应 |
| 循环粒度 | 单任务（分钟级）| 整个流程 | 单决策 |
| 进度追踪 | 显式 TODO.md | 隐式经验 | 隐式直觉 |
| AI 友好度 | ★★★★★ | ★★ | ★★★ |
| TDD 集成 | 原生 | 无 | 无 |
| 自动推进 | 是 | 否 | 否 |

## 命令速查

```bash
# 激活 Ralph Loop
/skill ralph-driven-dev

# 查看进度
grep -c '\[ \]' ralph/TODO.md  # 剩余任务数

# 快速验证（根据项目替换测试命令）
# 示例：npm test && echo "全部通过"
# 示例：pytest && echo "全部通过"
{项目测试命令} && echo "全部通过"

# 查看当前任务
grep -m1 '\[ \]' ralph/TODO.md

# 终止循环
# 在对话中输入 "停止 ralph"
```

## 术语表

| 术语 | 英文 | 定义 |
|------|------|------|
| Ralph | Ralph | 循环引擎的名字 |
| 迭代 | iteration | 一次完整的任务循环 |
| 波浪 | Wave | 一组可并行的任务 |
| 检查点 | checkpoint | git tag 标记的稳定状态 |
| 红绿灯 | RED/GREEN/REFACTOR | TDD 三阶段 |
| artifact | artifact | 任务产出物 |
| 迁移模式 | migration mode | phase=0,status=init |

## 参见

- [SKILL.md](SKILL.md) — 技能定义（方法论）
- [template/ralph/PROMPT.md](template/ralph/PROMPT.md) — 执行规则模板
- `/smart-commit` — 规范 commit
- `/test-driven-development` — TDD 循环
- `/verification-before-completion` — 完成前验证
- `/systematic-debugging` — 系统化调试
- `/writing-plans` — 复杂任务设计
- `/brainstorming` — 需求分析