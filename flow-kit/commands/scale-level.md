# 【CLAUDE CODE INSTRUCTION 强制约束】

> 本命令根据项目复杂度自动调整规划深度，支持四级规模评估。

## 规模等级定义

### L0: Quick Fix

- **改动文件**: 1-2 个文件
- **无公共接口变更**
- **无数据库/框架核心变更**
- **执行策略**: 极简模式，跳过 Phase 2-3，直接 Phase 4 实现
- **示例**: 修复拼写错误、调整样式、添加日志

### L1: Feature

- **改动文件**: 3-10 个文件
- **涉及公共接口（API/组件接口）**
- **轻度涉及数据模型**
- **执行策略**: 标准流程，完整 Phase 1-8
- **示例**: 新增功能模块、API 扩展

### L2: Epic

- **改动文件**: 10+ 个文件
- **涉及数据库 schema 变更**
- **涉及核心框架修改**
- **执行策略**: 标准流程 + 额外架构评审门
- **示例**: 支付流程重构、用户系统重设计

### L3: Architecture

- **改动文件**: 跨系统变更
- **涉及多服务协调**
- **需要架构评审委员会**
- **执行策略**: 完整流程 + 强制 Phase 0 架构设计 + 分阶段 rollout
- **示例**: 微服务拆分、新增多租户

---

## 自动评估维度

| 维度 | 评估方法 |
|------|----------|
| 改动文件数量 | `cloc` 或简单计数 |
| 公共接口变更 | `grep` 接口定义文件 |
| 数据库变更 | 检查 migration 文件 |
| 核心框架变更 | 检查框架核心文件 |
| 跨系统变更 | 检查服务边界 |

---

## 使用方式

### 手动指定

```
/flow-kit:scale L0  # 强制指定为 Quick Fix
/flow-kit:scale L1  # 强制指定为 Feature
```

### 自动评估

执行自动评估后输出：

```
[Scale Assessment]
  Level: L{level}
  Confidence: {high|medium|low}
  File count: {n}
  Public API: {yes|no}
  Database: {yes|no}
  Core Framework: {yes|no}

  Recommended flow: {flow description}
  Phase skip suggestion: {phases to skip if any}
```

---

## 流程映射表

| 规模等级 | 推荐流程 | 可跳过的 Phase |
|----------|----------|----------------|
| L0 | 极简模式 | Phase 2, Phase 3 |
| L1 | 标准流程 | 无 |
| L2 | 标准流程 + 架构评审 | 无 |
| L3 | 完整流程 + Phase 0 | 无 |
