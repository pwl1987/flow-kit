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

### 三层审查模型

按顺序执行，从业务层到工程层。上一层失败则停止。

#### Layer 1: CEO Review（业务层）

**审查者视角**：Product Owner / Business Owner

| 检查项 | 问题 | 通过标准 |
|--------|------|----------|
| **需求覆盖** | 是否解决了原始需求？ | 所有 acceptance criteria 满足 |
| **验收标准** | 是否满足定义的成功条件？ | 度量指标全部达成 |
| **业务逻辑** | 业务规则是否正确实现？ | 边界条件覆盖 |
| **用户体验** | 操作流程是否符合用户预期？ | 核心路径无阻碍 |

#### Layer 2: Design Review（设计层）

**审查者视角**：UX Designer / Visual Designer

| 检查项 | 问题 | 通过标准 |
|--------|------|----------|
| **视觉一致性** | 与现有设计语言一致？ | 符合 design system |
| **交互逻辑** | 操作反馈是否符合直觉？ | 无歧义的交互 |
| **可访问性** | 是否满足 WCAG 标准？ | AA 级别合规 |
| **响应式** | 不同设备上表现正确？ | Mobile/Tablet/Desktop |

#### Layer 3: Engineering Review（工程层）

**审查者视角**：Senior Engineer / Tech Lead

| 检查项 | 问题 | 通过标准 |
|--------|------|----------|
| **安全性** | 是否有 SQL injection / XSS 等漏洞？ | 安全 checklist 通过 |
| **性能** | 是否有 N+1 / 大文件处理等问题？ | 性能基准达标 |
| **可维护性** | 代码是否清晰、可测试？ | 测试覆盖率 >= 80% |
| **最佳实践** | 是否遵循语言/框架规范？ | Linter 无警告 |

## EXAMPLE

### 审查 Checklist（每层）

```markdown
## CEO Review Checklist
- [ ] 原始需求中的每个用例都有对应实现
- [ ] 验收标准中的每个度量指标可验证
- [ ] 边界条件（如空输入、最大值）有处理
- [ ] 错误场景有合适的用户提示

## Design Review Checklist
- [ ] 颜色、字体、间距符合 design system
- [ ] 按钮状态（hover/active/disabled）正确
- [ ] 表单验证反馈及时且清晰
- [ ] 移动端布局正常

## Engineering Review Checklist
- [ ] 无硬编码凭证或 secrets
- [ ] 参数化查询防止 injection
- [ ] 索引正确，查询性能 < 100ms
- [ ] 单元测试覆盖核心逻辑
- [ ] 依赖无已知 CVE
```

### 审查执行示例

**PR 场景**：用户订单创建功能

```
CEO Review:
  ✓ 创建订单流程完整
  ✓ 折扣码验证逻辑正确
  ✓ 超时情况有处理（30s timeout）
  → PASS

Design Review:
  ✓ 表单布局符合现有模式
  ✗ 错误提示使用系统默认样式（应使用 design system）
  → FAIL → 返回修改

[修改后]
Design Review:
  ✓ 错误提示使用 design system 组件
  ✓ 移动端布局正常
  → PASS

Engineering Review:
  ✓ 无 SQL injection 风险
  ✓ 事务正确处理
  ✓ 测试覆盖率 85%
  → PASS

Overall: APPROVED
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

### 审查输出

```markdown
## Code Review Report

**PR**: #123 - Order creation with discount
**Reviewers**: [CEO, Design, Engineering]

### Results

| Layer | Status | Findings |
|-------|--------|----------|
| CEO | ✓ PASS | 0 |
| Design | ✓ PASS | 0 |
| Engineering | ✓ PASS | 0 |

### Summary
All layers passed. Ready to merge.

### Comments
- Consider adding loading state for better UX next iteration
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