--- BEGIN flow-kit/skills/verification.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为交付验证技能包 (SKILL-36)，用于 Phase 4-5 完成前的质量门控。
> 遵循 WHEN_TO_USE / HOW_TO_USE / EXAMPLE / NOTES 四段式结构。

# Skill: Verification (SKILL-36)

## WHEN_TO_USE

- **Phase**: Phase 4 (Dev Complete) 或 Phase 5 (Testing Complete)
- **Trigger**: 标记 feature 完成前必须通过验证
- **场景**:
  - 任务开发完成，准备提交 review
  - 测试全部通过，准备集成
  - Release 前最终检查
  - 用户演示前质量确认

## HOW_TO_USE

### 分阶段验证门控（D-21）

| Phase | 验证级别 | 检查项 |
|-------|----------|--------|
| Phase 1-2 | 轻量 | lint, typecheck, build |
| Phase 3-4 | 基础 | + unit tests, coverage >= 70% |
| Phase 5-6 | 全量 | + integration tests, security scan, E2E |

### 棕地/绿地差异
| 项目类型 | 额外检查 |
|----------|----------|
| 棕地 | 历史兼容性检查、依赖风险分析 |
| 绿地 | 标准检查（无历史包袱） |

### Token 预算联动
- Phase 5-6 全量检查前自动检测 token 预算
- 若 >= 80%，提示用户：`[HINT] Token budget at {pct}%, consider running /flow-kit:cleanup first`
- 用户确认后继续或降级到基础检查

### Self-Check Delivery Checklist

**原则**: Verification is YOUR job, not the user's.

#### Pre-Review Checklist（Phase 4 → Phase 5）

```markdown
## Delivery Checklist

### Code Quality
- [ ] Lint passes: `npm run lint` or `pnpm lint`
- [ ] Typecheck passes: `npm run typecheck` or `tsc --noEmit`
- [ ] Build succeeds: `npm run build`
- [ ] No console.log/debugger statements
- [ ] No TODO/FIXME comments (documented in ticket)

### Testing
- [ ] Unit tests: `npm run test` (all green)
- [ ] Integration tests: `npm run test:integration` (if applicable)
- [ ] Test coverage: >= 80% (or per project standard)
- [ ] New tests for new logic
- [ ] No test commented out

### Documentation
- [ ] Code comments for complex logic
- [ ] API docs updated (if public API changed)
- [ ] README updated (if needed)
- [ ] CHANGELOG entry added

### Security
- [ ] No secrets/credentials in code
- [ ] Environment variables used for config
- [ ] Input validation present
- [ ] SQL injection prevention
- [ ] XSS prevention (if frontend)

### Review Readiness
- [ ] Self-reviewed own PR
- [ ] Review checklist completed (see code-review.md)
- [ ] Labels/milestone set
- [ ] Description explains WHY, not just WHAT
```

#### Pre-Integration Checklist（Phase 5 → Phase 6）

```markdown
## Integration Checklist

### Functional
- [ ] All acceptance criteria met
- [ ] E2E tests pass (if applicable)
- [ ] Manual test cases executed
- [ ] Edge cases covered

### Performance
- [ ] Load test passed (if applicable)
- [ ] No memory leaks
- [ ] Response time within SLA

### Deployment
- [ ] Config reviewed (no dev secrets)
- [ ] Migration scripts tested
- [ ] Rollback plan documented
- [ ] Monitoring/alerting configured
```

## EXAMPLE

### 场景：完成订单功能开发

**Task**: 实现订单创建功能

**执行 Verification**:
```bash
# 1. Code Quality
$ npm run lint
✓ No ESLint errors

$ npm run typecheck
✓ TypeScript: 0 errors

$ npm run build
✓ Build successful

# 2. Testing
$ npm run test
✓ 12 tests passed
✓ Coverage: 85%

# 3. Review preparation
$ cat prd-checklist.md
✓ Order created with correct total
✓ Discount applied correctly
✓ Invalid discount code rejected
✓ Edge case: empty cart handled

# 4. Security check
$ grep -r "password\|secret\|apiKey" src/
✓ No hardcoded secrets found

# 5. Review
$ gh pr create --title "feat: order creation" --body "..."
✓ PR created
✓ Linked to issue #123
```

**Verification Report**:
```markdown
## Delivery Verification Report

**Feature**: Order Creation
**PR**: #456
**Date**: 2026-05-06

### Results

| Category | Status | Notes |
|----------|--------|-------|
| Lint | ✓ PASS | No errors |
| Typecheck | ✓ PASS | 0 errors |
| Build | ✓ PASS | Success |
| Unit Tests | ✓ PASS | 12/12 |
| Coverage | ✓ PASS | 85% |
| Security | ✓ PASS | No secrets |
| Review | ✓ READY | PR created |

### Sign-off

**Developer**: Claude Code
**Date**: 2026-05-06

Ready for code review.
```

### 验证失败恢复指南

| 失败类型 | 原因 | 修复命令 |
|----------|------|----------|
| Lint 失败 | 代码风格问题 | `npm run lint:fix` |
| Typecheck 失败 | 类型不匹配 | `npm run typecheck:fix` |
| 测试失败 | 逻辑错误 | `npm run test:debug` |
| 构建失败 | 编译错误 | `npm run build:debug` |
| 安全扫描失败 | 漏洞检测 | `/flow-kit:security-fix` |

**一键修复流程**：
1. 识别失败类型
2. 执行对应修复命令
3. 重新运行验证
4. 若仍失败，调用 `/flow-kit:debug-snapshot` 保存现场

## NOTES

### 跳过 Verification 的风险

| Skip | Risk |
|------|------|
| Skip lint | Code style issues in PR |
| Skip typecheck | Runtime errors in production |
| Skip tests | Regressions undetected |
| Skip security | Vulnerabilities exposed |
| Skip review | Bugs reach production |

### 质量门标准

| 项目 | 最低标准 | 目标标准 |
|------|----------|----------|
| **Lint** | 0 errors | 0 warnings |
| **Typecheck** | 0 errors | 0 errors |
| **Test Coverage** | 70% | 85% |
| **Build** | Success | Fast (< 5min) |

### 常见失败模式

| 问题 | 原因 | 修复 |
|------|------|------|
| Lint 失败 | 代码风格不规范 | 运行 `npm run lint:fix` |
| Typecheck 失败 | 类型不匹配 | 修复类型定义 |
| 测试失败 | 逻辑错误或依赖问题 | 调试并修复 |
| 构建失败 | 编译错误或资源缺失 | 检查依赖 |

### 验证检查

- [ ] Lint passes
- [ ] Typecheck passes
- [ ] Tests pass (>= 80% coverage)
- [ ] Build succeeds
- [ ] No secrets in code
- [ ] Review prepared

---
**关联技能**: code-review.md (SKILL-33) — 验证后提交审查
**前置条件**: 任务开发完成
**重要性**: HIGH — 不验证直接提交 = 低质量交付
--- END flow-kit/skills/verification.md ---