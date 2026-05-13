# /flow-kit:install

flow-kit 自动化安装部署命令。

## 功能

1. **OS 检测** — 自动识别 Linux/macOS/WSL
2. **依赖检查** — 验证 bash/jq/git/python3
3. **自动安装** — 提供缺失依赖的安装命令
4. **命令注册** — 自动注册所有斜杠命令
5. **Hooks 验证** — 检查 `.claude/settings.json` 配置
6. **功能测试** — 运行完整测试套件验证安装

## 使用场景

- 首次安装 flow-kit
- 更新到新版本后重新配置
- 验证环境依赖完整性
- 自动化 CI/CD 部署

## 执行模式

### 交互式（默认）

```bash
/flow-kit:install
```

- 缺失依赖时提示安装命令
- 询问是否执行安装
- 询问是否运行测试

### 静默模式

```bash
/flow-kit:install --silent
```

- 自动安装所有缺失依赖
- 自动执行所有步骤
- 适用于 CI/CD 环境

## 依赖要求

| 依赖    | 必需 | 说明               |
| ------- | ---- | ------------------ |
| bash    | ✅   | >= 4.0             |
| jq      | ✅   | JSON 处理          |
| git     | ✅   | 版本控制           |
| python3 | ⚪   | 可选，部分功能需要 |

## 安装步骤

1. **OS 检测** — 识别操作系统和包管理器
2. **依赖检查** — 逐个验证依赖可用性
3. **自动安装** — 提示或自动安装缺失依赖
4. **命令注册** — 调用 `generate-commands.sh --force`
5. **Hooks 验证** — 检查 settings.json 配置
6. **功能测试** — 运行 `tests/run-tests.sh`

## 输出示例

```
==========================================
  flow-kit 自动化安装
==========================================

[install] 检测操作系统...
[install] OS: Linux
[install] 包管理器: apt-get

[install] 检查依赖...

[install] ✅ bash 5.1.16 (>= 4.0)
[install] ✅ jq 已安装
[install] ✅ git 已安装
[install] ✅ python3 已安装（可选）

[install] ✅ 所有依赖检查通过
[install] 注册斜杠命令...
[install] ✅ 斜杠命令注册成功

[install] 验证 Hooks 配置...
[install] ✅ Hooks 配置已存在

[install] 运行功能测试...
### shell syntax
### test-session-state.sh
...
[install] ✅ 功能测试通过

==========================================
[install] ✅ flow-kit 安装完成
==========================================

[install] 下一步:
  1. 运行 /flow-kit:init "变更描述" 开始第一个变更
  2. 运行 /flow-kit:hooks 查看 Hooks 配置指南
  3. 运行 /flow-kit:status 查看当前状态
```

## 故障排除

### macOS bash 版本过低

```bash
brew install bash
# 脚本自动使用 #!/usr/bin/env bash
```

### Homebrew 未安装

访问 https://brew.sh 安装 Homebrew

### 依赖安装失败

手动安装：

```bash
# macOS
brew install jq git

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y jq git

# CentOS/RHEL
sudo yum install -y jq git
```

## 相关命令

- `/flow-kit:register-commands` — 仅注册斜杠命令
- `/flow-kit:generate-commands` — 重新生成命令
- `/flow-kit:hooks` — Hooks 配置指南

---

**版本**: v3.3.0  
**脚本**: `flow-kit/scripts/install.sh`
