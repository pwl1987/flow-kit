# Shell 脚本编码规范

## 命名约定
- 函数名：`snake_case`，公共函数加 `_` 前缀（如 `_ss_now`）
- 全局常量：`UPPER_SNAKE_CASE`，加 `readonly`
- 局部变量：`lower_snake_case`
- 文件名：kebab-case（如 `session-state.sh`）
- 测试文件：`test-<module>.sh`（如 `test-session-state.sh`）

## 注释标准
- 文件头：功能描述 + 版本 + 依赖（3 行以内）
- 函数注释：仅当逻辑复杂时添加 WHY 注释（解释为什么，而非做了什么）
- 禁止 WHAT 注释（代码本身应自解释）
- 变更记录：使用 git log，不在文件头维护变更历史

## 架构模式
- 所有脚本必须 source error-handler.sh（通过 paths.sh 间接引用）
- 禁止覆盖 error-handler.sh 的日志函数
- 统一使用 `set -euo pipefail`（paths.sh 除外）
- 统一使用 paths.sh 的路径常量，禁止硬编码路径
- 所有临时文件必须使用 mktemp + trap 清理
- 所有外部命令调用必须有 fallback 或错误处理

## 编码最佳实践
- 优先使用内置 bash 功能，减少外部命令调用
- 使用 `[[ ]]` 而非 `[ ]` 进行条件测试
- 使用 `$( )` 而非反引号进行命令替换
- 变量引用始终使用双引号（`"$var"`）
- 使用 `local` 声明函数内变量
- 避免使用 eval