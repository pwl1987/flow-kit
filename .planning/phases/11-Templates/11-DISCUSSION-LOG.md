# Phase 11 Discussion Log

**Date:** 2026-05-07
**Phase:** 11 — Templates + Commands

---

## Gray Area A：GLOSSARY.md.template 模板结构

**Q1:** 模板包含哪些 section？
**Options:** 6-field 强制 + 2-field 可选 / 4-field 精简版 / 自定义组合
**Selection:** 6-field 强制 + 2-field 可选（推荐方案）
**Notes:**
- 用户提供了完整结构设计：Term / Definition / Usage Rules / Category / Example / See Also
- Version & History / Owner 为可选字段
- Usage Rules 是约束性字段，含适用/禁用/边界区分
- Category 支持多级分类，与 LESSONS.md.template 标签体系对齐

---

## Gray Area B：search-lessons 命令设计

**Q1:** 搜索方式
**Options:** 关键词匹配 / 语义搜索 / 混合模式
**Selection:** 混合模式（关键词优先 + 语义兜底）

**Q2:** 输出格式
**Options:** 列表模式 / 摘要模式 / 可切换
**Selection:** 可切换（默认列表 + --verbose 摘要模式）

**Q3:** LESSONS.md 读写权限
**Options:** 仅追加 / 可编辑 / 结构化追加
**Selection:** 结构化追加（### Entries 用户写，### Extracted 系统只读）

---

## Gray Area C：模板路径定位

**Q1:** 模板放在哪里？
**Options:** templates/ 根目录 / flow-kit/templates/ / 双路径
**Selection:** flow-kit/templates/

**Notes:** templates/ 根目录不存在，flow-kit/templates/ 是唯一正确路径

---

## Deferred

- 是否将 search-lessons 命令打包为独立 Skill（供其他 phase 复用）

