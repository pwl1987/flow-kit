# 架构设计

## 变更 ID

v3-5-0-batch12-20260514

## 技术方案

### R1: tmux error-handler 集成

**文件**: scripts/tmux-{init,run,aggregate,cleanup}.sh
**方案**: 在每个 tmux 脚本 source paths.sh 后添加 `source "$SCRIPT_DIR/../lib/error-handler.sh"`

### R2: conflict-detector 增强

**文件**: lib/conflict-detector.sh
**方案**: 新增 3 个函数：

- `detect_file_conflicts <change_id>` — 扫描 .specs/<change_id>/ 识别涉及的文件，对比当前变更文件列表
- `detect_dependency_conflicts <module>` — 检查目标模块是否被当前变更修改
- 扩展 `detect_conflict()` 调用链：状态冲突 → 文件冲突 → 依赖冲突

### R3-R5: 新模块测试

**方案**: 新建 3 个测试文件，每个覆盖核心函数

- test-conflict-detector.sh: classify_requirement / detect_conflict / detect_file_conflicts / handle_conflict_decision
- test-code-review.sh: 文件扫描 / bash -n 检查 / shellcheck 集成 / 报告生成
- test-plan-generate.sh: parse_review / generate_plan / milestone 分组

### R6: 护栏自动激活

**文件**: scripts/phase-executor.sh main()
**方案**: 在 L108 guard 输出前，检查 `.flow-kit/guardrails-active` 文件。若不存在，输出激活提示并自动写入

### R7: 模板变量校验

**文件**: scripts/init-change.sh
**方案**: sed 替换前，先 `grep -o '{{[A-Z_]*}}'` 提取所有变量，检查是否有未定义变量，列出缺失项

### R9: 临时文件统一管理

**文件**: lib/cleanup.sh (新建)
**方案**: 注册式临时文件管理

```bash
_CLEANUP_FILES=()
register_cleanup() { _CLEANUP_FILES+=("$1"); }
do_cleanup() { rm -f "${_CLEANUP_FILES[@]}" 2>/dev/null || true; }
```

各脚本 source 后用 `register_cleanup` 注册文件，trap EXIT 调用 `do_cleanup`

### R10: 并行测试

**文件**: tests/run-tests.sh
**方案**: 用 `xargs -P$(nproc)` 并行运行 test-\*.sh，保留串行 e2e

### R11: Makefile

**文件**: Makefile (新建)
**目标**: lint / test / format / format-check / lint-md / benchmark

### R12: shfmt 集成

**文件**: .shfmtrc (新建)
**配置**: -i 4 -ci -sr (4空格缩进, switch case缩进, 重定向运算符空格)

### R13: markdownlint 集成

**文件**: .markdownlint.json (新建)
**配置**: MD013: false (行长度), MD033: false (内联HTML)

### R14: 测试覆盖率提升

**文件**: tests/test-session-state.sh (扩展), tests/test-dispatch.sh (扩展), tests/test-tmux.sh (新建), tests/test-caveman-compress.sh (新建)
**方案**: 补充边界条件和错误路径测试

### R15-R17: 文档建设

- doc-extractor.sh: 遍历 lib/_.sh + scripts/_.sh，提取函数签名和注释
- API-REFERENCE.md: doc-extractor 输出
- DEVELOPMENT-GUIDE.md: 环境配置 + 开发规范 + 调试技巧
- TROUBLESHOOTING.md: 安装/运行/测试常见问题

## 实施顺序

1. R1 tmux error-handler (最独立)
2. R9 cleanup.sh (基础设施)
3. R2 conflict-detector 增强
4. R7 模板变量校验
5. R6 护栏自动激活
6. R11 Makefile + R12 shfmt + R13 markdownlint
7. R10 并行测试
8. R3-R5 + R14 测试覆盖
9. R15-R17 文档

## 回滚方案

全部改动可通过 git revert 单文件回滚。新建文件直接删除。
