> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本命令输出团队共享安装指令，供新成员一键配置 flow-kit。

## 执行 /flow-kit:share-install

### 功能

检测项目配置，输出供新成员执行的命令：

1. 检测 `.claude/settings.json` 是否存在
2. 检测 `flow-kit/hooks/` 目录是否存在
3. 输出完整的安装指令

### 输出格式

```bash
# 团队共享安装指令

## 前置要求
- Claude Code 已安装
- Git 已安装

## 执行步骤

### 1. 克隆项目（若尚未克隆）
git clone <repo-url> <project-name>
cd <project-name>

### 2. 安装 hooks（推荐）
./flow-kit/flow-kit.sh hooks install

### 3. 或手动安装
# 复制 hooks 脚本
cp -r flow-kit/hooks/ .claude/hooks/

# 复制 settings
cp flow-kit/.claude/settings.json .claude/settings.json

# 重启 Claude Code

### 4. 注册斜杠命令
/flow-kit:register-commands
```

### 团队共享文件

| 文件                    | 说明           |
| ----------------------- | -------------- |
| `flow-kit/hooks/*.sh`   | 5 个保护 hooks |
| `.claude/settings.json` | hooks 配置     |
| `flow-kit/`             | 完整工具包     |

### 使用场景

- 新成员加入时
- 团队标准化配置
- CI/CD 环境初始化
