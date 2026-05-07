# Frontend Engineer Rules

11 delivery checks for frontend quality gates. Framework-agnostic.

## Delivery Checks

1. **Lint clean** — eslint/tslint/pylint pass
2. **Type check** — TypeScript passes / Python type hints check
3. **Unit tests** — All unit tests green
4. **Integration tests** — Critical paths covered
5. **Build** — Production build succeeds
6. **Bundle size** — Within defined budget
7. **Accessibility** — axe-core/lighthouse a11y score >= 90
8. **Performance** — LCP < 2.5s, FID < 100ms
9. **Security headers** — CSP, HSTS, X-Frame-Options configured
10. **Cross-browser** — Chrome/Firefox/Safari baseline works
11. **Mobile responsive** — Layout adapts to viewport

---

## AI-slop 指纹库 v2

### 禁止的渐变模式（正则）

```
#| 紫色渐变（AI生成特征）
gradient.*#9333ea.*#ec4899
gradient.*#a855f7.*#ec4899

#| 青色渐变
gradient.*#06b6d4.*#10b981
gradient.*#22d3ee.*#34d399

#| 其他AI可疑渐变
gradient.*#f472b6.*#c084fc  #粉紫
gradient.*#60a5fa.*#a78bfa  #蓝紫
```

### OKLCH 色彩空间优先声明

> AI 生成设计倾向于使用 sRGB 饱和色。flow-kit 优先 OKLCH 色彩空间，
> 因为它更符合人类视觉感知，提供更自然的色彩过渡。
>
> 推荐工具：oklch.com 或 Tailwind CSS oklch()

### 字体黑名单

| 字体 | 原因 |
|------|------|
| Inter | AI 生成特征，过于中性 |
| Roboto | AI 生成特征，Google 默认 |
| Arial | 无个性，Windows 默认 |
| system-ui | 无品牌区分度 |

### 禁止的模式

- 无内容的占位图（纯色块 + 模糊）
- "Lorem ipsum" 真实内容占位
- 虚假数据（"张 三" / "示例公司"）
- 过度使用 emoji 代替专业图标

## 品牌资产协议

若项目有品牌资产（logo/色板/UI 截图），设计决策优先级：
1. 品牌资产（最高优先级）
2. flow-kit 内置语汇
3. 通用设计系统

使用品牌色时，标注：`[品牌色: {hex}]`
