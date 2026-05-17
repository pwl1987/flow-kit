---
# 此文件为 Ralph Loop 执行器示例。
# 实际运行时由 Claude 在会话中动态维护状态。
# 不需要复制到项目模板中。
active: false
iteration: 0
max_iterations: 200
completion_promise: "__DONE__"
---

# Ralph Loop 执行器

## 主循环

1. 读取 ralph/TODO.md → 找第一个 [ ]
2. **检查依赖**：若依赖非 "—"，检查依赖任务是否已 [x]
   → 未完成：跳到依赖任务先执行
   → 循环依赖：拆分任务打破循环
3. 读取 ralph/tasks/X.Y-name.md → 获取详情
4. RED → GREEN → REFACTOR → 质量内循环(REVIEW→FIX→TEST) → VERIFY → COMMIT → 打钩
5. 熔断：连续失败 ≥ 5 次 → 自动诊断→修复→重设计→拆分→标记[B]继续
6. 继续下一个任务

## 项目延续（unchecked=0 时）

1. 统计已完成任务数和 Wave 数
2. 向用户询问：创建新版本 / 结束发布 / 结束不创建
3. 按用户选择执行

## 检查点

- 每完成一个 Wave（该 Wave 下所有任务均 [x]）：
  - `git add .`
  - `git commit -m "feat: wave {N} 完成"`
  - `git tag ralph-wave{N}-$(date +%Y%m%d)`
- Wave 序号从当前完成任务的编号中提取（如 2.3 → 2）
- Context 满时：git commit 保存进度

## 循环终止

unchecked=0 时，按用户选择输出 `<promise>__DONE__</promise>`
