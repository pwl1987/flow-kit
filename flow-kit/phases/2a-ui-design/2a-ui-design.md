> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本阶段在老项目前端变更时触发，确保视觉语汇一致，拦截 AI-slop 设计。

## 触发条件

- 老项目（brownfield）前端变更
- 涉及 UI 组件修改
- 用户显式调用 `/flow-kit:ui-design`

## 核心流程

### 1. 视觉语汇对齐（B6）
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

### 4. 3 维设计评审

**色彩系统**：检查配色是否与品牌一致，是否有 AI 生成的可疑渐变（紫粉/青绿等）
**留白节奏**：检查间距是否遵循 4px/8px 基准，是否一致
**排版层次**：检查字体层级是否清晰，是否使用垃圾字体（Inter 等 AI-slop 指纹）

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