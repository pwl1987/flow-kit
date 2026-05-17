# 执行规则

## 循环行为
- 读 TODO.md → 找第一个 `[ ]` → 读对应 tasks/ 文件 → 执行 → 打钩
- 一个任务一个迭代，不多做

## TDD 红绿灯
1. RED：写测试 → 跑 → 确认失败
2. GREEN：最小实现 → 跑 → 确认通过
3. REFACTOR：ShellCheck → 清理 → 再跑

## 技能路由（flow-kit 自身能力）
- 写测试 → flow-kit phase-5-test 工作流（TDD 红绿灯）
- 调试失败 → flow-kit phase-8-rollback（回滚+RCA 5 Whys）
- 任务影响 5+ 文件 → flow-kit phase-2-design（设计先行）
- 2+ 无依赖任务 → flow-kit dispatch 多代理调度
- 打 [x] 前 → flow-kit stop-quality-gate hook + validate-phase.sh 产出物校验
- 实现完成后 → flow-kit phase-6-review（代码审查）
- 格式化 → flow-kit post-edit-format hook（自动格式化）
- 安全扫描 → flow-kit security-scanner.sh（密钥检测）
- 进度追踪 → flow-kit auto-pilot.sh --status

## 环境降级
- shfmt: 跳过（未安装，shellcheck 覆盖）
- Docker: 无需（本版本无数据库需求）

## 双重验证
- Ralph Loop 执行任务 + flow-kit 自身功能验证
- Phase 工作流指导实现、hooks 自动格式化、auto-pilot 追踪进度
- 验证用 /verification-before-completion、评审用 /requesting-code-review

## 禁令
- 不做未列出的任务
- 不优化相邻代码
- 不推测性重构
- 上下文压缩后先读文件确认状态，不凭记忆假设

## 上下文保护
- 产出物写入文件，不依赖对话记忆
- TODO.md 是唯一进度来源

## 质量门禁
每任务打 [x] 前：
- 测试写且通过（RED → GREEN）
- ShellCheck 零 error
- 无未用 import / 调试代码
- 产出物与 tasks/ 描述一致

全部 [x] 后：
- 全量测试 → 0 fail
- ShellCheck 全量 → 0 error
- VERSION 更新 → v3.7.0
- CHANGELOG.md 更新
- 撰写 v3.7.0-report.md（执行摘要、ralph 评估、flow-kit 自验证、踩坑、升级建议）
- 输出 __DONE__
