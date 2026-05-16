---
phase: 2
name: "方案设计（棕地）"
stage: thinking
allowed_operations:
  - 架构设计
  - ADR记录
  - 兼容性分析
forbidden_operations:
  - 代码修改
  - 测试执行
expected_artifacts:
  - .flow-kit/design.md
next_phase: 3
---
# Phase 2: 架构设计 — 棕地项目

> 适用：已有代码库的业务迭代开发

## 棕地项目重点

- 分析现有架构，找扩展点
- 保持向后兼容
- 设计增量扩展而非修改核心

## 执行步骤

### Step 1: 分析现有架构

1. **读取架构文档**

   ```bash
   cat docs/architecture.md
   cat docs/api-design.md
   ```

2. **理解核心组件**
   - 数据流：输入→处理→输出
   - 组件关系：依赖、调用
   - API 契约：接口签名

### Step 2: 找到扩展点

1. **扩展模式选择**
   | 模式 | 适用场景 | 示例 |
   |------|----------|------|
   | 策略模式 | 算法变化 | 支付方式 |
   | 插件模式 | 功能扩展 | 第三方集成 |
   | 装饰器模式 | 功能增强 | 日志、缓存 |
   | 适配器模式 | 接口统一 | 旧接口兼容 |

2. **扩展点设计**

   ```markdown
   ## 扩展点设计

   ### 扩展点 #1

   **位置**：src/plugins/
   **接口**：IPlugin
   **实现**：ThirdPartyAuthPlugin
   ```

### Step 3: 向后兼容

1. **API 兼容策略**
   - 不修改现有接口签名
   - 新增可选参数（带默认值）
   - 使用 versioned API

2. **数据兼容策略**
   - 新增字段（ nullable）
   - 不删除已有字段
   - 迁移脚本支持回滚

### Step 4: 回滚方案

必须制定回滚方案！

````markdown
## 回滚方案

### 最坏情况回滚

```bash
git checkout HEAD~1
npm install
```
````

### 渐进回滚

设置功能开关 `FEATURE_X_ENABLED=false`

## 输出物

- `.specs/{change-id}/DESIGN.md` — 设计文档
- 扩展点设计方案
- 回滚方案

## 下一步

- `/flow-kit:phase-3` — 任务拆解
- `/flow-kit:next` — 自动推进
