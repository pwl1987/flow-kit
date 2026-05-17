# /ralph — 启动 Ralph 驱动开发

使用 ralph-driven-dev 技能将 PRD 拆分为原子任务并启动 Ralph Loop 自动执行。

## 用法

```
/ralph <PRD文件路径>
```

## 示例

```
/ralph 3.7.0.md
```

## 流程

1. 解析 PRD → 拆分原子任务
2. 生成 TODO.md + PROMPT.md + tasks/*.md
3. 启动 Ralph Loop 自动循环执行

## 前置条件

- 已安装 ralph-driven-dev 技能（~/.claude/skills/ralph-driven-dev/）
- 已安装 ralph-loop 插件（可选，用于自动循环）

## 如果未安装

提示用户：
```
ralph-driven-dev 技能未检测到。
安装方式：将技能目录复制到 ~/.claude/skills/ralph-driven-dev/
```
