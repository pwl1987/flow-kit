---
phase: 2a
name: "界面设计（棕地）"
stage: thinking
allowed_operations:
  - UI设计
  - 组件规划
  - 样式兼容
forbidden_operations:
  - 代码修改
  - 架构变更
expected_artifacts:
  - .flow-kit/ui-design.md
next_phase: 3
---
> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本阶段在老项目前端变更时触发，确保视觉语汇一致，拦截 AI-slop 设计。

## 触发条件

- 老项目（brownfield）前端变更
- 涉及 UI 组件修改
- 用户显式调用 `/flow-kit:phase-2（UI 条件路由）`

## 核心流程

### 1. 视觉语汇对齐（B4）
检测并对齐项目的视觉语言：
- 调性（tonal）— 产品给人什么感觉
- 主色（primary color）— 品牌色系
- 字体（typography）— 字体族和层级
- 布局（layout）— 栅格系统和间距

### 2. v0 草稿确认
输出 v0 草稿（30 秒可扫完）：
```
## v0 草稿

### 调性
[产品感觉描述]

### 主色
[hex color codes]

### 字体
[font-family]

### 布局假设
[栅格/间距描述]
```

用户确认后进入下一步。

### 3. 写 UI-DESIGN.md
完整 UI 设计文档，包含：
- 设计规范
- 组件清单
- 交互状态

### 4. 5 维设计评审

#### 维度1·色彩系统
- 主色一致性：确认与项目现有 --color-accent 一致
- 对比度合规：WCAG AA 标准（正文 4.5:1，大文本 3:1）
- AI-slop 指纹色检测：禁止紫色渐变(#9333ea→#ec4899)、青色渐变(#06b6d4→#10b981)
- OKLCH 色彩空间优先（来源 huashu-design 标准）

#### 维度2·留白节奏
- padding/margin 遵循 4px 递增节奏（4/8/12/16/24/32/48）
- 卡片间距统一
- 内容密度适中（老项目对齐既有密度）

#### 维度3·排版层次
- heading/body/caption 三层渐深
- 字体黑名单：Inter、Roboto、Arial、system-ui
- 禁止无理由的衬线展示字体

#### 维度4·信息层级（新增）
- 主操作/次操作/辅助信息视觉权重分明
- 主操作按钮：最高对比度+最大尺寸
- 次操作：边框样式或文字链接
- 辅助信息：降低透明度或使用 caption 字号

#### 维度5·动效语义（新增）
- 过渡 duration 与距离匹配（150-300ms）
- 缓动曲线一致性：入场 ease-out、离场 ease-in、持续 ease-in-out
- 禁止无目的的动画（仅装饰性旋转/弹跳）

### 品牌资产协议（可选）

若用户提供了品牌资产（logo/色板/UI截图），则：
1. 所有设计决策以品牌资产为最高优先级
2. 内置 20 种设计语汇兜底（来源 huashu-design）
3. 输出时标明哪些决策来自品牌资产、哪些来自内置语汇

### 5. AI-slop 指纹扫描

检测以下 AI 生成指纹：
- Inter 字体使用
- 紫粉渐变（purple-pink gradient）
- emoji 代替图标（😀 而不是 SVG）
- 虚构数据占位（"Lorem ipsum"、假姓名）

### 6. 占位符策略表

强制包含：
```yaml
## 占位符策略

| 类型 | 策略 | 示例 |
|------|------|------|
| 图片 | 使用真实图片或清晰占位符 | placeholder.com |
| 文字 | 使用真实内容或 {{variable}} | {{user_name}} |
| 数据 | 使用结构化假数据 | {name: "张 三", role: "工程师"} |
```

## 输出物

- `v0 草稿.md` — 视觉语汇快照
- `UI-DESIGN.md` — 完整设计文档
- `设计评审报告.md` — 3 维评审 + AI-slop 扫描结果

## 绑定

绑定 `reference/frontend-engineer-rules.md`

---

## 参考来源

- [alchaincyf/huashu-design](https://github.com/alchaincyf/huashu-design) — 20 设计哲学 + 5 维评审（精简为 3 维）
- [garden-skills](https://github.com/garden-skills) — v0 草稿确认 + 视觉语汇对齐 + 占位符策略