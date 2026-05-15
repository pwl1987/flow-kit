# flow-kit 开发指南

## 环境配置

### 系统要求
- macOS >= 12 / Ubuntu >= 22.04 / WSL2
- bash >= 4.0
- Node.js >= 18（用于 JS 检测脚本）
- jq >= 1.6
- git >= 2.30

### 安装步骤
1. 克隆仓库
2. 注册命令：`bash flow-kit/scripts/generate-commands.sh --force`
3. 验证安装：`bash flow-kit/scripts/validate-phase.sh --help`

### 开发工具推荐
- ShellCheck（Shell 静态分析）
- shfmt（Shell 格式化）
- markdownlint（Markdown 检查）
- hyperfine（性能测试）

## 开发规范
- 遵循本目录的 CODING-STANDARDS.md
- 所有脚本必须通过 ShellCheck
- 所有新功能必须有单元测试
- 所有 CLI 脚本必须有 -h/--help

## 调试技巧
- `bash -x script.sh` — 追踪执行
- `set -x` — 脚本内启用调试
- 查看 `.flow-kit/logs/` 中的日志文件
- `hyperfine 'bash script.sh'` — 性能分析