# Phase 2a: UI 设计 — 绿地项目

> 适用：全新项目，无既有视觉语言约束

## 绿地项目特点

- 无既有设计包袱，可自由选择设计体系
- 可直接采用现代设计趋势
- 重点在于快速建立设计系统基础

## 执行步骤

### Step 1: 选择设计体系

1. **推荐方案**
   | 方案 | 适用场景 | 特点 |
   |------|----------|------|
   | Tailwind + 组件库 | 快速启动 | shadcn/ui, Radix UI |
   | CSS-in-JS | 定制化需求 | Styled Components, Panda CSS |
   | 设计系统 | 中长期项目 | 建立 Design Token |

2. **选择主字体**
   - 推荐：Geist, Satoshi, Cabinet Grotesk
   - 避免：Inter, Roboto, Arial

### Step 2: 建立色彩系统

```css
:root {
  --color-primary: #xxx;
  --color-secondary: #xxx;
  --color-muted: #xxx;
  --color-accent: #xxx;
}
```

### Step 3: 布局节奏

- 使用 4px 基础网格
- 间距递增：4, 8, 12, 16, 24, 32, 48, 64
- 容器最大宽度：1280px

### Step 4: 输出设计文档

创建 `UI-DESIGN.md`：

- 色彩定义
- 字体规范
- 间距系统
- 组件清单

## 输出物

- `UI-DESIGN.md` — 设计规范文档
- Design Token 文件（如使用）

## 下一步

- `/flow-kit:phase-3` — 任务拆解
