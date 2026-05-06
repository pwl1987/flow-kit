> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件定义 Breaking Change 分类标准与审批流程。
> B1 Guardrail：Breaking Change Classification。

# B1: Breaking Change Classification

## 触发条件

- Brownfield 项目检测到
- `package.json` 依赖版本变更
- API 接口签名变更
- 数据库 Schema 变更
- 配置文件结构变更

## 核心行为

### P0: Emergency Bypass
| 属性 | 值 |
|------|-----|
| 风险等级 | 最高 |
| 审批要求 | 无（事后通知） |
| 适用场景 | 生产环境紧急修复、0-day 漏洞补丁 |
| 前置条件 | 用户明确标记 `P0` 或 `EMERGENCY` |

**流程**：
1. 立即执行变更
2. 执行后立即触发 B2-B4 审查
3. 24小时内补充变更记录

### P1: Breaking API/Contract
| 属性 | 值 |
|------|-----|
| 风险等级 | 高 |
| 审批要求 | 高级工程师或 Tech Lead 明确批准 |
| 适用场景 | 公开 API 变更、认证机制变更、核心数据模型变更 |
| 前置条件 | 完整影响分析报告 |

**流程**：
1. 提交变更影响分析
2. 获取审批人书面批准
3. 执行变更
4. 更新所有消费方文档

### P2: Non-breaking Enhancement
| 属性 | 值 |
|------|-----|
| 风险等级 | 中 |
| 审批要求 | Team Lead 口头或异步确认 |
| 适用场景 | 新功能添加、错误修复、文档更新 |
| 前置条件 | 变更范围清晰 |

**流程**：
1. 变更执行
2. 记录变更日志
3. 更新相关文档

## 边界情况

### 多级别变更共存
当单一变更同时包含多个级别时，按最高级别处理。

### 间接 Breaking Change
- 依赖的第三方库版本升级导致行为变化
- 识别为 P1，需要依赖影响分析

### 跨服务 Breaking Change
- 多服务共享 Schema 变更
- 自动识别为 P0 或 P1（取决于服务数量）

## 输出物

```
Breaking Change Classification Report
======================================
Change ID: [YYYY-MM-{SEQ}]
Classification: [P0 | P1 | P2]

Impact Analysis:
  - API Contracts: [Affected endpoints]
  - Data Models: [Affected schemas]
  - Dependencies: [Affected packages]

Approval:
  - Required: [Yes/No]
  - Approver: [Name/Role]
  - Timestamp: [DateTime]

Next Steps: [Based on classification]
```
