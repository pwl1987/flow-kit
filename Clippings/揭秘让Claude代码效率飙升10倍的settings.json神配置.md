---
title: "揭秘让Claude代码效率飙升10倍的settings.json神配置"
source: "https://mp.weixin.qq.com/s/livSW0BDmPbvQUq1psxIyQ"
author:
  - "[[尼克]]"
published:
created: 2026-05-15
description: "使用 Claude Code 的人，几乎都在吐槽同一个问题：每次想让它编辑个文件，或者跑个测试，都要点一下\x26quot;允"
tags:
  - "clippings"
---
尼克 *2026年4月30日 12:13*

![[_resources/揭秘让Claude代码效率飙升10倍的settings.json神配置/23ff3b16bc7f8cc1b1c4ebab25b6f69c_MD5.webp]]

使用 Claude Code 的人，几乎都在吐槽同一个问题：每次想让它编辑个文件，或者跑个测试，都要点一下"允许"。一个小功能搞下来，鼠标要连点几十次，刚进入工作状态就被打断，整个思路都断了。

解决办法是一个叫 **settings.json** 的文件。

一个文件，几条规则，就能让 Claude 不再为日常操作反复请求许可，同时又牢牢锁住那些真正可能搞出大问题的命令。

很多人压根不知道这个文件的存在。即便知道的，大多也只是写了三行配置，基本没发挥作用。下面就是正确配置它的方法。

![[_resources/揭秘让Claude代码效率飙升10倍的settings.json神配置/125ec2a85130336adb6b9972a1df1e2f_MD5.webp]]

## 文件存放位置

和 CLAUDE.md 一样，分三个层级：

```
~/.claude/settings.json           → 全局（对所有项目生效）
.claude/settings.json             → 项目级（团队共享，提交到 git）
.claude/settings.local.json       → 本地（个人独有，应加入 gitignore）
```

全局配置放那些你希望到处通用的权限。项目配置放团队共享的规则。本地配置则用于不适合提交到 git 的个人偏好。

各层级的规则会自动合并。比如全局设置允许 **Bash(npm \*)** ，而项目设置里禁止了 **Bash(npm publish)** ，两条规则会同时生效。

禁止规则的优先级永远高于允许规则。

## 权限系统速览

三个数组控制一切：

```
{
  "permissions": {
    "allow": [],
    "deny": [],
    "ask": []
  }
}
```

**allow** ：Claude 直接使用这些工具，不弹出确认框。

**deny** ：Claude 完全不能碰这些操作，彻底封死。

**ask** ：每次都用确认框来征询许可。

判断顺序是先查 deny，再查 ask，最后才是 allow，首次命中的规则生效。对于同一个工具，deny 规则始终会覆盖 allow 规则。

规则的写法是： **工具名称** 或者 **工具名称(模式)** 。

```
"Bash"              → 所有 bash 命令（风险极高）
"Bash(npm install)"  → 只匹配 npm install
"Bash(npm run *)"    → 匹配任何 npm run 脚本
"Bash(git *)"        → 匹配任何 git 命令
"Write(src/**)"      → 只允许在 src/ 目录下写文件
"Read(.env*)"        → 读取所有 .env 文件
```

注意， `*` 前面的空格是有意义的。 `Bash(ls *)` 能匹配 `ls -la` ，但匹配不到 `lsof` 。这里用的是 glob 模式，不是正则。

📸 ФОТО 1:

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

## 五种权限模式

除了逐条写规则，也可以直接设定一个默认模式：

```
{
  "permissions": {
    "defaultMode": "default"
  }
}
```
```
default          → 危险操作一律询问
acceptEdits      → 自动批准文件编辑，bash 命令仍需询问
plan             → 只读模式，不允许任何修改
dontAsk          → 所有未显式允许的操作全部拒绝
bypassPermissions → 批准一切（仅限在容器或 CI 环境里用）
```

会话过程中可以随时切换：按 **Shift+Tab** 就能在 default、acceptEdits 和 plan 三种模式之间循环切换，不需要去改配置文件。

## 哪些该放行（安全清单）

以下命令每天要反复执行几十次。让 Claude 直接运行能省下大量时间：

```
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "LS",
      "Bash(npm run *)",
      "Bash(npm install *)",
      "Bash(npm test *)",
      "Bash(npx tsc *)",
      "Bash(npx vitest *)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git checkout *)",
      "Bash(git branch *)",
      "Write(src/**)",
      "Edit",
      "MultiEdit"
    ]
  }
}
```

规律很明显：读操作（Read、Glob、Grep、LS）全放开。Bash 命令只针对特定工具（npm、git、测试工具等）放行。写文件则只限定在 src/ 目录内。

## 哪些该禁止（安全防线）

以下命令可能造成严重损失，要一视同仁地封堵：

```
{
  "permissions": {
    "deny": [
      "Read(.env*)",
      "Read(**/secrets/**)",
      "Write(.env*)",
      "Write(production.*)",
      "Write(.github/workflows/*)",
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(git push *)",
      "Bash(git merge *)",
      "Bash(npm publish *)",
      "Bash(docker *)",
      "Bash(curl * | sh)",
      "Bash(wget *)"
    ]
  }
}
```

核心原则是，Claude 可以读你的代码、写你的代码、跑测试、提交变更。但它永远不能读取密钥，不能 push 到远端仓库，不能递归删除文件，也不能运行任何带 sudo 的命令。

危险的活儿一律拦在 deny 这道墙后面。

## 给 settings.json 加上钩子

设置和钩子可以放在同一个文件里。比如每次编辑完自动格式化代码，提交前自动检查代码规范：

```
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.py)",
        "hooks": [
          {
            "type": "command",
            "command": "python -m black $file"
          }
        ]
      },
      {
        "matcher": "Write(*.ts)",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $file"
          }
        ]
      }
    ]
  }
}
```

每个.py 文件保存后自动用 Black 格式化。

每个.ts 文件保存后自动用 Prettier 格式化。

不弹窗，不用手动操作。

## 团队共享配置

把项目级配置放在 **.claude/settings.json** 里提交到 git，整个团队就能共用同一套权限：

```
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(npm run *)",
      "Bash(npm test *)"
    ],
    "deny": [
      "Read(.env*)",
      "Bash(npm publish *)",
      "Bash(rm -rf *)",
      "Write(production.*)"
    ],
    "defaultMode": "acceptEdits"
  }
}
```

新同事拉下仓库，打开 Claude Code，一切都已配置妥当。不用折腾初始设置，不用纠结"哪些命令该放行"，也不用担心有人不小心放行了 **Bash(rm -rf \*)** 。Anthropic 的 Boris Cherny 就是这么干的：团队共用一个 settings.json，例行命令预先放行，危险操作提前封死。

## 开箱即用的完整配置

这是一套针对 Node.js/TypeScript 项目可以直接使用的完整 settings.json。

复制到 **~/.claude/settings.json** 即为全局配置，放到 **.claude/settings.json** 则只对当前项目生效：

```
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "LS",
      "Edit",
      "MultiEdit",
      "Write(src/**)",
      "Write(tests/**)",
      "Write(docs/**)",
      "Bash(npm run *)",
      "Bash(npm install *)",
      "Bash(npm test *)",
      "Bash(npx tsc *)",
      "Bash(npx vitest *)",
      "Bash(npx prettier *)",
      "Bash(npx eslint *)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git checkout *)",
      "Bash(git branch *)",
      "Bash(cat *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(wc *)",
      "Bash(find *)",
      "Bash(echo *)"
    ],
    "deny": [
      "Read(.env*)",
      "Read(**/secrets/**)",
      "Write(.env*)",
      "Write(production.*)",
      "Write(.github/workflows/*)",
      "Write(package-lock.json)",
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(git push *)",
      "Bash(git merge *)",
      "Bash(git rebase *)",
      "Bash(npm publish *)",
      "Bash(docker *)",
      "Bash(curl * | sh)",
      "Bash(wget *)",
      "Bash(chmod *)",
      "Bash(chown *)"
    ],
    "defaultMode": "acceptEdits"
  },
"hooks": {
    "PostToolUse": [
      {
        "matcher": "Write(*.ts)",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $file"
          }
        ]
      },
      {
        "matcher": "Write(*.tsx)",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $file"
          }
        ]
      }
    ]
  }
}
```

直接复制这份配置，根据你的目录结构调整 Write 的白名单。

根据你的技术栈增减 Bash 规则（把 npm 换成 pnpm，加上 python 命令，诸如此类）。

deny 列表在不同项目之间基本无需大动。

## 配置前后对比

配置 settings.json 之前：

- 每次会话弹出 30 到 40 个权限确认框
- 每次都要点"允许"来放行 npm install
- 不小心放行过一个 rm -rf 吓得一身冷汗
- 新同事加入后得手动把所有配置都过一遍
- 每两分钟就被打断一次，工作流支离破碎

配置 settings.json 之后：

- 每次会话最多弹出 0 到 3 次确认框
- 日常操作瞬间完成
- 危险命令被挡在配置层，碰都碰不到
- 团队共用一个配置文件，所有人开箱即用
- 工作流不再被打断

花两分钟配置一次，之后每次写代码都快人一步。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

继续滑动看下一个

尼克的AI笔记

向上滑动看下一个