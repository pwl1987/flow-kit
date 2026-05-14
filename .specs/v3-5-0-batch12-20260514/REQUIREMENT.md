# 需求文档

## 变更 ID

v3-5-0-batch12-20260514

## 需求背景

基于 DEVELOPMENT-IMPROVEMENT-PLAN.md v2.0 差距分析，完成 P1+P2 遗漏项。v3.4.0 已完成 Section 1 Phase 1-2（代码质量基础），本次覆盖剩余质量优化、功能增强、测试和文档。

## 功能需求

### R1: tmux 脚本 error-handler 集成 [P1]

**描述**: tmux-{init,run,aggregate,cleanup}.sh 仅 source paths.sh，未 source error-handler.sh，错误处理不一致
**文件**: scripts/tmux-\*.sh (4 个)
**验收标准**:

- Given source 任一 tmux 脚本
- When 调用 log_info
- Then 函数存在且可用

### R2: conflict-detector 文件+依赖冲突检测 [P1]

**描述**: 当前 conflict-detector.sh 仅检测状态冲突（session-state status），缺少文件级冲突和依赖冲突检测
**文件**: lib/conflict-detector.sh
**验收标准**:

- Given 两个变更修改同一文件
- When 调用 detect_conflict
- Then 检测到文件冲突
- Given 变更 A 依赖变更 B 修改的模块
- When 调用 detect_conflict
- Then 检测到依赖冲突

### R3: conflict-detector 测试覆盖 [P1]

**描述**: conflict-detector.sh 无单元测试
**文件**: tests/test-conflict-detector.sh (新建)
**验收标准**:

- Given bash tests/test-conflict-detector.sh
- When 检查结果
- Then 覆盖 detect_conflict / handle_conflict_decision / interactive_conflict_resolution

### R4: code-review 测试覆盖 [P1]

**描述**: code-review.sh 无单元测试
**文件**: tests/test-code-review.sh (新建)
**验收标准**:

- Given bash tests/test-code-review.sh
- Then 覆盖文件扫描 / 语法检查 / 安全扫描 / 报告生成

### R5: plan-generate 测试覆盖 [P1]

**描述**: plan-generate.sh 无单元测试
**文件**: tests/test-plan-generate.sh (新建)
**验收标准**:

- Given bash tests/test-plan-generate.sh
- Then 覆盖 REVIEW 解析 / 方案生成 / 里程碑分组

### R6: 护栏自动激活 [P2]

**描述**: phase-executor.sh 不根据项目类型自动推荐护栏
**文件**: scripts/phase-executor.sh
**验收标准**:

- Given project_type=brownfield
- When 执行 phase-executor
- Then 输出包含 "guard full" 建议
- Given project_type=greenfield
- When 执行 phase-executor
- Then 输出包含 "guard minimal" 建议

### R7: 模板变量校验 [P2]

**描述**: init-change.sh 不校验模板变量是否完整
**文件**: scripts/init-change.sh
**验收标准**:

- Given 模板包含 {{VAR}} 但 VAR 未定义
- When 调用模板渲染
- Then 输出错误提示，列出所有未定义变量

### R8: phase-executor find 调用优化 [P2]

**描述**: phase-executor.sh 使用 `ls -d` + glob 模式查找 phase 目录
**文件**: scripts/phase-executor.sh
**验收标准**:

- Given phase 目录存在
- When load_workflow 被调用
- Then 无 `find` 外部命令调用

### R9: 临时文件统一管理 [P2]

**描述**: 缺少统一的临时文件清理机制，各脚本分散处理
**文件**: lib/cleanup.sh (新建)
**验收标准**:

- Given 注册临时文件
- When trap EXIT 触发
- Then 所有注册文件被清理

### R10: 并行测试执行 [P2]

**描述**: run-tests.sh 串行执行所有测试，速度慢
**文件**: tests/run-tests.sh
**验收标准**:

- Given 运行 run-tests.sh
- When 测试数量 > 5
- Then 使用 xargs -P 并行执行，总时间减少 40%+

### R11: Makefile [P2]

**描述**: 无统一构建入口，lint/test/benchmark 命令分散
**文件**: Makefile (新建)
**验收标准**:

- Given Makefile 存在
- When make lint / make test / make format
- Then 对应命令正确执行

### R12: shfmt 集成 [P2]

**描述**: 无 Shell 脚本格式化工具
**文件**: .shfmtrc (新建), Makefile
**验收标准**:

- Given shfmt 已安装
- When make format
- Then 所有 .sh 文件格式化一致

### R13: markdownlint 集成 [P2]

**描述**: 无 Markdown 文档质量检查
**文件**: .markdownlint.json (新建), Makefile
**验收标准**:

- Given markdownlint 已安装
- When make lint-md
- Then 所有 .md 文件通过检查

### R14: 测试覆盖率提升 [P2]

**描述**: session-state 覆盖率 70%、dispatch 覆盖率 30%、缺少 tmux/caveman 测试
**文件**: tests/test-\*.sh
**验收标准**:

- Given 运行全量测试
- Then session-state 覆盖 ≥90%, dispatch 覆盖 ≥60%
- tmux 测试存在, caveman-compress 测试存在

### R15: API-REFERENCE.md [P2]

**描述**: 无 API 参考文档
**文件**: API-REFERENCE.md (新建), scripts/doc-extractor.sh (新建)
**验收标准**:

- Given doc-extractor.sh 存在
- When bash scripts/doc-extractor.sh
- Then 生成 API-REFERENCE.md 包含所有公共函数签名

### R16: DEVELOPMENT-GUIDE.md [P2]

**描述**: 无开发指南
**文件**: DEVELOPMENT-GUIDE.md (新建)
**验收标准**:

- Given DEVELOPMENT-GUIDE.md 存在
- Then 包含环境配置 / 开发规范 / 调试技巧

### R17: TROUBLESHOOTING.md [P2]

**描述**: 无常见问题文档
**文件**: TROUBLESHOOTING.md (新建)
**验收标准**:

- Given TROUBLESHOOTING.md 存在
- Then 覆盖安装问题 / 运行时问题 / 测试问题

## 非功能需求

- 向后兼容: 29+ 命令行为不变
- 测试门禁: 每次提交 run-tests.sh 通过
- ShellCheck: 0 error

## 边界条件

- 棕地项目: 不破坏已有功能
- 跨平台: macOS + Linux 兼容
- 增量交付: 每个需求独立可测试
