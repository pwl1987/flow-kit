# 测试 PRD：最小加法模块

## 背景
验证 Ralph + Superpowers-ZH 技能调用链路。

## 功能
创建一个 `add.mjs` 模块，导出 `add(a, b)` 函数。

## 约束
- 源码 `.mjs`（ESM）
- vitest 测试
- TDD 红绿灯

## 验收标准
- `add(1, 2)` 返回 3
- `add(-1, 1)` 返回 0
- 测试全部通过
