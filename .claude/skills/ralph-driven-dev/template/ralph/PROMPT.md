# 执行规则

## 循环行为
- 读 TODO.md → 找第一个 `[ ]`
- **检查依赖**：若该任务的依赖列不是 `—`，检查依赖任务是否已 `[x]`
  - 若未完成：跳到那个未完成的依赖任务，优先执行（递归）
  - 若检测到循环依赖（A→B→A）：拆分其中一个任务打破循环
- 读 tasks/ 文件 → 执行以下流程 → 打钩：
  1. RED（测试先行）
  2. GREEN（最小实现）
  3. REFACTOR（清理）
  4. 质量内循环：REVIEW → FIX → TEST → REVIEW（最多 3 轮，直到无问题）
  5. VERIFY（全量测试 + 构建）
  6. COMMIT
  7. 追加日志到 tasks/ 文件底部
  8. 打钩 [x]
- **熔断与自动恢复**：
  - 同一任务连续失败 ≥ 5 次 → 触发熔断
  - 自动诊断并尝试修复（环境/配置/依赖）
  - 若修复不成 → 自动重新分析任务，更新 GREEN 步骤，重置计数重试
  - 若仍熔断 → 自动拆分为子任务，更新 TODO.md 和 tasks/
  - 若拆分后仍失败 → 检查下游任务依赖：
    * 下游不依赖当前任务 → 标记为 [B]，继续下一个 [ ] 任务
    * 下游依赖当前任务 → 标记为 [B]，**暂停循环并说明阻塞原因**（无法自动解除阻塞）
  - 所有非阻塞任务完成后，回头再次尝试修复 [B] 任务
  - 全程动作记录在 ralph/EXPERIENCE.md 中
- 一个任务一个迭代，不多做
- 每任务完成后 `git add` + `git commit`，commit message：`{type}: {project} 任务 {X.Y} 描述`
- git 操作使用 `/smart-commit` 技能规范 commit message
- **循环终止条件**：当且仅当 TODO.md 中**所有**任务状态均为 `[x]`，且最后一次 VERIFY 全部通过，才输出 `<promise>__DONE__</promise>`。不管有多少个 Wave，严格顺序执行。若任一任务失败，循环会重试或自动恢复，绝不提前终止。

## 日志规则（每步必须输出）
```
## [迭代 N] 任务 X.Y: {任务名}
**[RED]** 调用 /test-driven-development → 写测试 → 运行 → {通过/失败: 原因}
**[GREEN]** 最小实现 → 运行 → {通过/失败}
**[REFACTOR]** {清理内容/无需}
**[REVIEW#1]** {自查结果}
  **[FIX]** {修正内容/无需}
  **[TEST]** {重新运行测试结果}
**[REVIEW#2]** {二次评审，如无需则省略}
**[VERIFY]** 全量测试 + 构建 → {结果}
**[COMMIT]** 调用 /smart-commit → {commit hash 前7位}
**[TODO]** 打钩 X.Y → {剩余未完成数}
```

关键决策点也记录：
```
**[SKILL]** 调用 /{技能名} → {调用原因} → {输出摘要}
**[DEBUG]** 测试失败 2 次 → 调用 /systematic-debugging → {根因}
**[DECISION]** {非显而易见的设计选择} → {原因}
**[BLOCKED]** 任务 X.Y 标记为 [B] → {原因} → 继续下一个任务
```

## TDD 红绿灯 + 质量内循环
1. RED：写测试 → 跑 → 确认失败
2. GREEN：最小实现 → 跑 → 确认通过
3. REFACTOR：lint → 清理 → 再跑（保持绿色）
4. 质量内循环：
   a. REVIEW：调用 /requesting-code-review 或自查
   b. 若发现问题 → FIX（修改代码）→ TEST（重新运行测试，必须绿色）
   c. 回到步骤 a，直到 REVIEW 无新问题（最多 3 轮）

## 技术栈约束（根据项目替换）
<!-- 示例（Node.js 项目）：
- 源码 .mjs，产物 .cjs
- 测试框架 vitest
- 类型校验 zod
- 构建工具 esbuild
-->
- 测试命令：{填写，如 `npm test`、`pytest`、`mvn test`}
- 构建命令：{填写，如 `npm run build`、`pip install .`，若无则留空}
- 源码语言/格式约束：{如 Python 3.10+、Java 17、ESM .mjs}

## 自动修复命令（可选，用于熔断恢复）
- 安装依赖：{如 `npm install`、`pip install -r requirements.txt`}
- 环境检查：{如 `node -v`、`python --version`}
- 代码自动修复：{如 `eslint --fix`、`black .`、无则留空}

## 技能路由（Superpowers-ZH）

### 核心技能（每任务适用）

| 触发条件 | 技能 | 缺失时替代 |
|----------|------|-----------|
| 写测试（RED 阶段） | `/test-driven-development` | 先写测试再写实现 |
| 测试连续失败 2 次 | `/systematic-debugging` | 手动分析错误日志，定位根因 |
| 任务影响 5+ 文件 | `/writing-plans` | 在 task 文件中详细列出步骤 |
| 打 [x] 前 | `/verification-before-completion` | 运行项目测试命令确认通过 |
| 代码评审（REVIEW 阶段） | `/requesting-code-review` | 自查代码正确性 |
| git commit 时 | `/smart-commit` | `git commit -m "feat: ..."` |

### 增强技能（特定场景）

| 场景 | 技能 | 缺失时替代 | 适用任务 |
|------|------|-----------|---------|
| 复杂模块设计前 | `/brainstorming` | 列出 3 个方案比较 | 复杂重构/新功能 |
| 多模块并行 | `/dispatching-parallel-agents` | 按顺序逐个执行 | 独立任务并行 |
| 分支收尾 | `/finishing-a-development-branch` | 手动发布流程 | 完成发布 |

## 质量门禁
每任务打 [x] 前：
- 测试写且通过（RED → GREEN）
- 无未用 import / 调试代码
- 产出物与 tasks/ 描述一致
- 质量内循环已通过（至少一次 REVIEW 通过，修复后 TEST 绿色）
- 全量测试 + 构建通过（VERIFY）
- 若 TODO.md 包含"技术决策"表，必须遵守
- git commit 已完成

全部 [x] 后：
- 项目测试命令通过
- 项目构建命令成功（若有）
- **输出 `<promise>__DONE__</promise>`**（只在 unchecked === 0 时）

## 检查点
- 每完成一个 Wave（该 Wave 下所有任务均 `[x]`），立即执行：
  1. `git add .`
  2. `git commit -m "feat: wave {N} 完成"`
  3. `git tag ralph-wave{N}-$(date +%Y%m%d)`
  4. 更新 ralph/EXPERIENCE.md 追加本 Wave 经验总结
- Wave 序号从当前完成任务的编号中提取（如 2.3 → 2）

## 禁令
- 不做未列出的任务
- 不优化相邻代码
- 不推测性重构
- 上下文压缩后先读文件确认状态，不凭记忆假设

## 上下文保护
- 产出物写入文件，不依赖对话记忆
- TODO.md 是唯一进度来源
