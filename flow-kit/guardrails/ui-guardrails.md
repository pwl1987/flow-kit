> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件定义 UI 视觉词汇一致性检查。
> B4 Guardrail：UI Vocabulary Alignment。

# B4: UI Guardrails

## 触发条件

- UI 组件变更涉及共享组件
- 新增颜色、字体、间距
- 设计系统相关文件变更
- 用户可见界面修改

## 核心行为

### Visual Vocabulary Alignment

#### Design Token Consistency

| Token 类型 | 验证项 |
|------------|--------|
| Color | 所有颜色使用 Design Token，非硬编码值 |
| Typography | 字体族、字号、行高来自定义系统 |
| Spacing | 间距使用 4px/8px 网格系统 |
| Border Radius | 统一使用定义好的圆角变量 |
| Shadow | 阴影级别统一管理 |

#### Typography Scale

```
Font Stack:
  - Primary: [System Font Stack]
  - Monospace: [Code Font Stack]

Type Scale (默认):
  - xs: 12px / 1.4
  - sm: 14px / 1.4
  - base: 16px / 1.5
  - lg: 18px / 1.5
  - xl: 20px / 1.4
  - 2xl: 24px / 1.3
  - 3xl: 30px / 1.2
  - 4xl: 36px / 1.1
```

#### Color System Alignment

| 用途 | 变量命名规范 |
|------|-------------|
| Primary | `--color-primary-*` |
| Secondary | `--color-secondary-*` |
| Semantic | `--color-success`, `--color-error`, `--color-warning` |
| Neutral | `--color-gray-*` |

### Component Review Checklist

- [ ] 新组件有对应的 Storybook 文档
- [ ] 组件状态（default/hover/active/disabled）完整
- [ ] 响应式断点一致
- [ ] 无重复实现（SearchInput vs FindBox）
- [ ] Accessibility 属性完整（aria-*）

## 边界情况

### 第三方 UI 库
- 引入新的 UI 库需 Tech Lead 批准
- 确保与现有 Design Token 兼容
- 记录为 B5: Third-party Component

### 快速原型
- P0 场景允许跳过部分 UI 检查
- 必须在 48 小时内补充 Review
- 使用 `UI-WIP` 标记

### 设计系统升级
- 涉及 Design Token 变更需要设计评审
- 提前通知所有消费方
- 准备回滚方案

## 输出物

```
UI Visual Consistency Report
=============================
Change ID: [YYYY-MM-{SEQ}]

Design Tokens:
  - Colors: [Added/Modified/Removed count]
  - Typography: [Added/Modified/Removed count]
  - Spacing: [Added/Modified/Removed count]

Components:
  - New: [list]
  - Modified: [list]
  - Removed: [list]

Consistency Check:
  - Token Usage: [Pass/Fail]
  - Typography Scale: [Pass/Fail]
  - Color System: [Pass/Fail]

Review Required: [Yes/No]
Reviewer: [Name]
```

### Visual Review Requirements
- 新增共享组件需要截图对比
- 修改现有组件需要 Before/After
- 移动端适配截图
