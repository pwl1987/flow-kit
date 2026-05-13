# flow-kit 编码规范

## 命名约定

- 函数: `snake_case` — `session_get`, `check_lock_conflicts`
- 常量: `UPPER_SNAKE_CASE` + `readonly` — `readonly FLOW_KIT_DIR="$PATHS_FLOW_KIT_DIR"`
- 文件: `kebab-case` — `dispatch-lock.sh`, `session-state.sh`
- 变量: `snake_case` — `task_desc`, `result_file`

## 注释标准

- 仅写 **WHY** 注释（解释非显而易见的设计决策）
- 不写 **WHAT** 注释（代码本身应自解释）
- 函数头部保留一行描述注释

```bash
# 好：解释 WHY
# v2.7.0 修复：僵尸进程 kill -0 仍返回 true，需双重检测
if [ "$alive" = false ] || [ -f "$result_file" ]; then

# 坏：解释 WHAT
# 检查进程是否存活
kill -0 "$pid"
```

## 架构模式

### 必须遵守

- 所有脚本 `set -euo pipefail`（paths.sh 除外，因被 source）
- 必须 `source error-handler.sh` 或 `source paths.sh` 获取基础工具
- **禁止覆盖** `log_info/log_warn/log_error/log_debug`，使用命名空间前缀（如 `scan_info`）
- 临时文件在 `trap EXIT` 中清理
- 路径常量统一在 `paths.sh` 定义，禁止脚本内硬编码

### 文件结构

```bash
#!/bin/bash
# filename.sh — 一行描述
# v3.4.0 变更说明（可选）

set -euo pipefail

# source 依赖
source "$SCRIPT_DIR/../lib/paths.sh"
source "$SCRIPT_DIR/../lib/error-handler.sh"

# 函数定义（先内部后公开）

# main 入口
main() { ... }

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## 编码实践

### 条件测试

```bash
# 用 [[ ]] 代替 [ ]
if [[ -f "$file" ]]; then    # 好
if [ -f "$file" ]; then      # 避免
```

### 命令替换

```bash
# 用 $( ) 代替反引号
local dir=$(dirname "$0")    # 好
local dir=`dirname "$0"`     # 避免
```

### 变量引用

```bash
# 总是双引号变量
echo "$result"               # 好
echo $result                 # 避免（word splitting 风险）
```

### local 赋值

```bash
# 分开声明和赋值（SC2155）
local var                    # 声明
var=$(some_command)          # 赋值

# 避免：local var=$(some_command)  # 掩盖退出码
```

### 错误处理

```bash
# 用 || true 处理预期失败
rm -f "$tmpfile" 2>/dev/null || true

# 用 || 提供默认值
local val=$(cat "$file" 2>/dev/null || echo "")
```

## 测试规范

- 测试文件: `tests/test-{module}.sh`
- 每个测试函数以 `test_` 前缀
- 断言函数: `assert_equals`, `assert_contains`, `assert_file_exists`
- 测试入口: `bash tests/run-tests.sh`

## 版本规范

- 版本号格式: `vMAJOR.MINOR.PATCH`
- 版本文件: `flow-kit/VERSION`
- 每次变更更新 VERSION + CLAUDE.md 版本行
