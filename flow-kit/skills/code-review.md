--- BEGIN flow-kit/skills/code-review.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为代码审查技能包 (SKILL-33)，用于 Phase 6 代码审查阶段。
> 遵循 WHEN_TO_USE / HOW_TO_USE / EXAMPLE / NOTES 四段式结构。

# Skill: Code Review (SKILL-33)

## WHEN_TO_USE

- **Phase**: Phase 6 — Code Review
- **Trigger**: 开发任务完成，需要进行质量审查时
- **场景**:
  - PR/MR 创建后需要多维度审查
  - 变更涉及业务逻辑、UX、技术实现
  - 需要确保安全性、性能、可维护性
  - 多层审查需要系统化执行

## HOW_TO_USE

### 标准化执行流程（D-14）

```
前置自动化检查 → 人工三层审查 → 补充自动化检查 → 输出分级报告
```

### 三种 Review 深度模板（D-15）

| 模板 | 适用场景 | 审查深度 | Token 消耗 |
|------|----------|----------|------------|
| **简化模板** | P2/单文件修改 | CEO 层快速检查 | 低 |
| **标准模板** | P1/模块级变更 | CEO + Engineering | 中 |
| **深度模板** | P0/微服务级变更 | CEO + Design + Engineering + 额外检查 | 高 |

**P0 强制使用深度模板**。

### 棕地专用模板（D-16）
- 额外检查项：历史逻辑兼容性、依赖风险分析
- 激活条件：`.flow-kit/project-type` 为 `brownfield`
- 输出：在标准报告末尾附加 "Brownfield Risk Assessment" 小节

### 自动化检查命令（D-13）

| 检查项 | 命令 | 类型 | 适用模板 |
|--------|------|------|----------|
| Lint | `npm run lint` | 阻断 | 全部 |
| Typecheck | `npm run typecheck` | 阻断 | 全部 |
| Build | `npm run build` | 阻断 | 标准+深度 |
| Unit Tests | `npm run test` | 阻断 | 标准+深度 |
| Security Scan | `/flow-kit:health` | 阻断 | 深度 |
| 依赖检查 | `npm audit` | 警告 | 深度 |

**阻断项**：必须通过，否则拒绝合并
**警告项**：仅提示，不阻止合并

### 三层审查模型

按顺序执行，从业务层到工程层。上一层失败则停止。

#### 第一层：架构师审查（业务层）

**审查者视角**：Product Owner / Business Owner

| 检查项 | 问题 | 通过标准 |
|--------|------|----------|
| **需求覆盖** | 是否解决了原始需求？ | 所有 acceptance criteria 满足 |
| **验收标准** | 是否满足定义的成功条件？ | 度量指标全部达成 |
| **业务逻辑** | 业务规则是否正确实现？ | 边界条件覆盖 |
| **用户体验** | 操作流程是否符合用户预期？ | 核心路径无阻碍 |

#### 第二层：设计审查（设计层）

**审查者视角**：UX Designer / Visual Designer

| 检查项 | 问题 | 通过标准 |
|--------|------|----------|
| **视觉一致性** | 与现有设计语言一致？ | 符合 design system |
| **交互逻辑** | 操作反馈是否符合直觉？ | 无歧义的交互 |
| **可访问性** | 是否满足 WCAG 标准？ | AA 级别合规 |
| **响应式** | 不同设备上表现正确？ | Mobile/Tablet/Desktop |

#### 第三层：工程审查（工程层）

**审查者视角**：Senior Engineer / Tech Lead

| 检查项 | 问题 | 通过标准 |
|--------|------|----------|
| **安全性** | 是否有 SQL injection / XSS 等漏洞？ | 安全 checklist 通过 |
| **性能** | 是否有 N+1 / 大文件处理等问题？ | 性能基准达标 |
| **可维护性** | 代码是否清晰、可测试？ | 测试覆盖率 >= 80% |
| **最佳实践** | 是否遵循语言/框架规范？ | Linter 无警告 |

## 示例

### 审查 Checklist（每层）

```markdown
## 架构师审查 Checklist
- [ ] 原始需求中的每个用例都有对应实现
- [ ] 验收标准中的每个度量指标可验证
- [ ] 边界条件（如空输入、最大值）有处理
- [ ] 错误场景有合适的用户提示

## 设计审查 Checklist
- [ ] 颜色、字体、间距符合 design system
- [ ] 按钮状态（hover/active/disabled）正确
- [ ] 表单验证反馈及时且清晰
- [ ] 移动端布局正常

## 工程审查 Checklist
- [ ] 无硬编码凭证或 secrets
- [ ] 参数化查询防止 injection
- [ ] 索引正确，查询性能 < 100ms
- [ ] 单元测试覆盖核心逻辑
- [ ] 依赖无已知 CVE
```

### 审查执行示例

**PR 场景**：用户订单创建功能

```
架构师审查:
  ✓ 创建订单流程完整
  ✓ 折扣码验证逻辑正确
  ✓ 超时情况有处理（30s timeout）
  → 通过

设计审查:
  ✓ 表单布局符合现有模式
  ✗ 错误提示使用系统默认样式（应使用 design system）
  → 失败 → 返回修改

[修改后]
设计审查:
  ✓ 错误提示使用 design system 组件
  ✓ 移动端布局正常
  → 通过

工程审查:
  ✓ 无 SQL injection 风险
  ✓ 事务正确处理
  ✓ 测试覆盖率 85%
  → 通过

Overall: 有条件通过
```

### 棕地项目审查示例

**场景**：棕地项目修改订单模块

```
[棕地风险评估]
  历史逻辑兼容性：✓ 通过（保留原有折扣计算逻辑）
  依赖风险分析：
    - OrderService → PaymentService（高风险，新接口）
    - OrderService → UserService（低风险，接口未变）
  建议：单独测试 Order → Payment 集成

Overall: 有条件通过
```

## NOTES

### 审查顺序重要性

```
CEO → Design → Engineering
```

- **前置层失败**，后续层无需审查（节省时间）
- **Design 失败**，Engineering 审查无意义（可能大改）

### 常见 Findings

| 类别 | 发现 | 严重度 |
|------|------|--------|
| **业务** | 折扣计算未考虑叠加场景 | High |
| **UX** | 移动端表单提交按钮被键盘遮挡 | Medium |
| **安全** | API 缺少 rate limiting | High |
| **性能** | N+1 查询问题 | Medium |
| **可维护** | 缺少错误边界 | Low |

### Token 预算预警（D-17）
深度模板消耗更多 token。使用前自动检测：
- 若 >= 80% 预算：提示用户归档旧 phase 文件
- 若 >= 90% 预算：建议降级到标准模板
- 命令：`bash flow-kit/lib/token-estimator.sh`` 查看详情

### PR 描述自动填充（D-18）
审查完成后，结果自动填充到 PR 描述的审查结果部分。
格式：
```markdown
## 审查结果
- 架构师审查: ✓ 通过
- 设计审查: ✓ 通过
- 工程审查: ✓ 通过（3 个问题，均已解决）
- 棕地风险: 低
```

### 审查输出

```markdown
## 代码审查报告

**PR**: #123 - Order creation with discount
**审查者**: [架构师, 设计, 工程]

### 结果

| 层级 | 状态 | 发现问题 |
|------|------|---------|
| 架构师 | ✓ 通过 | 0 |
| 设计 | ✓ 通过 | 0 |
| 工程 | ✓ 通过 | 0 |

### 摘要
所有层级通过。可以合并。

### 意见
- 下一次迭代考虑添加加载状态以改善 UX
```

### 验证检查

- [ ] 三层审查按顺序执行
- [ ] 每层至少有一个检查项
- [ ] 发现问题记录在 review report
- [ ] 上层失败则停止后续审查

---

**关联技能**: verification.md (SKILL-36) — 审查后验证
**前置技能**: subagent-execution.md (SKILL-32) — 开发完成后
--- END flow-kit/skills/code-review.md ---
