# Caveman Compress 输出压缩技能

## 概述

本技能对 Claude Code 子代理输出进行三级压缩，平衡信息密度与可读性。

---

## 激活条件

> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本技能在 4-dev（子代理输出）、5-test（测试报告）、6-review（审查发现）阶段自动激活。
> 用户可在 config/user-config.md 中设置 `compression_level: lite|full|ultra`，默认 full。

---

## 压缩级别

| 级别 | 效果 | 适用场景 | 示例 |
|------|------|---------|------|
| Lite | 省略礼貌用语和客套话，保留完整句子 | 5-test 测试报告、6-review 严重问题 | "Bug in auth middleware. Token expiry check uses `<` not `<=`." |
| Full | 进一步省略冠词、助动词、非必要修饰语 | 4-dev SUMMARY.md、6-review 一般发现 | "New obj ref each render. Inline obj = new ref = re-render. useMemo." |
| Ultra | 仅保留关键词、代码块和关键结论 | 仅用户手动指定时使用 | "Inline obj → re-render. useMemo." |

---

## 必须删除（所有级别）

1. 所有问候语和客套话：`"当然！""好主意！""让我解释一下……"`
2. 前缀和过渡语：`"首先……""接下来……""值得注意的是……"`
3. 形容词/副词堆砌：`"非常""特别""极其""完美的"`
4. 冗余被动语态：`"这个方法被用来获取用户数据"` → `"获取用户数据"`
5. 冗余同义重复：同一观点用不同词语重复表达
6. 自我表扬和免责声明：`"我已经完成了""我认为这个方案很好"`

---

## 必须保留（不可压缩）

1. 所有代码块：完整保留，不裁剪
2. API 错误码和堆栈跟踪：完整保留
3. 用户需求引用：逐字保留
4. 版本号、commit hash、文件路径：完整保留
5. 安全警告和破坏性操作警告：完整保留
6. 验证命令及输出：完整保留

---

## 触发时机

| 阶段 | 触发条件 | 压缩级别 |
|------|---------|---------|
| 4-dev | 子代理 SUMMARY.md 生成 | Full |
| 5-test | 测试报告生成 | Lite |
| 6-review | 审查发现输出 | Lite（严重问题保留完整描述） |
| All sub-agent | FRESH CONTEXT 内部处理 | Full |

---

## 压缩示例

### 原始输出

```
当然，我很乐意帮助您分析这个性能问题！

首先，让我解释一下为什么会出现这个情况。我们在每个渲染周期中都创建了一个新的对象引用，
这导致了不必要的重新渲染。解决这个问题的方法是使用 useMemo 来缓存计算结果。

这个方案非常好，因为它可以显著提升应用性能。
```

### Full 压缩后

```
New obj ref each render. Inline obj = new ref = re-render. useMemo.
```

### Lite 压缩后

```
性能问题：每个渲染周期创建新对象引用导致不必要的重新渲染。
解决方案：使用 useMemo 缓存计算结果，可显著提升性能。
```

### Ultra 压缩后

```
Inline obj → re-render. useMemo.
```

---

## 实施指南

### 4-dev 子代理 SUMMARY.md

```markdown
## 实现摘要

- 新组件采用 `useMemo` 缓存计算结果
- 修复 `AuthMiddleware` 中的 token 过期检查逻辑
- 文件路径：`src/components/UserProfile.tsx`

## 关键决策

- 选择 useMemo 而非 useCallback（不需要函数引用稳定）
```

### 5-test 测试报告

```markdown
## 测试结果

FAIL: UserProfile.test.tsx - 渲染性能测试
  预期：单次渲染
  实际：3次渲染
  原因：每次渲染创建新对象引用

修复命令：
npm run test -- --update
```

### 6-review 审查发现

```markdown
## 严重问题

[HIGH] 内存泄漏：EventEmitter 未在组件卸载时清理
  位置：src/hooks/useGlobalEvents.ts:45
  代码：
  ```typescript
  window.addEventListener('resize', handler);
  // 缺少：return () => window.removeEventListener('resize', handler);
  ```

## 建议

[MEDIUM] 考虑将大型配置对象外部化
  位置：src/config/largeConfig.ts
```

---

## 参考来源

- [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) — 精确后处理层，75% Token 节省，不碰代码块，Lite/Full/Ultra/文言文 四级体系
