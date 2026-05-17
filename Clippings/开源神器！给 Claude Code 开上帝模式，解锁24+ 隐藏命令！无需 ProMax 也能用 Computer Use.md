---
title: "开源神器！给 Claude Code 开上帝模式，解锁24+ 隐藏命令！无需 Pro/Max 也能用 Computer Use"
source: "https://mp.weixin.qq.com/s/tfR6Ri12BDPaLKyLaC9jCg"
author:
  - "[[码上源泉]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
码上源泉 *2026年4月10日 19:40*

Claude Code 里有一批功能：

`Computer Use` 、 `Ultraplan` 、 `Ultrareview` 需要你订阅 Pro/Max

24+ 隐藏命令：

- • `/share`
- • `/teleport`
- • `/bughunter`
- •...

只对 Anthropic 内部员工开放。

安全层会拒绝渗透测试、C2 框架、漏洞利用相关的请求。

连生成 URL 都被禁止。

今天看一个项目，一行命令把这些全解锁了：

跑完安装命令，再敲 `claude` ，Logo 从橙色变绿色。

上帝模式就开了。

## 是什么

`ClawGod` 不是第三方客户端，它是 **作用在官方 Claude Code 之上的运行时补丁** 。

不替换原程序，不 fork 代码。

Claude Code 官方更新以后，重新跑一遍安装命令，补丁自动重新应用。

项目： `https://github.com/0Chencc/clawgod`  
![[_resources/开源神器！给 Claude Code 开上帝模式，解锁24+ 隐藏命令！无需 ProMax 也能用 Computer Use/75640b4cf176e3103f9f509d78faa085_MD5.webp]]

## 做了什么

### 功能解锁

| 功能 | 效果 |
| --- | --- |
| **内部用户模式** | 解锁 24+ 隐藏命令、调试日志、API 请求记录 |
| **Agent Teams** | 多智能体 Swarm 协作，不需要额外参数 |
| **Computer Use** | 屏幕控制功能，无需 Max/Pro 订阅（仅 macOS） |
| **Ultraplan** | 通过 Claude Code Remote 做多智能体规划 |
| **Ultrareview** | 通过 Claude Code Remote 自动化 Bug 查找 |
| **GrowthBook 覆盖** | 通过配置文件覆盖任意 Feature Flag |

### 限制移除

| 移除的限制 | 说明 |
| --- | --- |
| **CYBER\_RISK\_INSTRUCTION** | 安全测试拒绝提示不再出现 |
| **URL 限制** | "禁止生成或猜测 URL" 指令被删除 |
| **操作强制确认** | 破坏性操作前不再弹窗确认 |
| **登录提醒** | 启动时的 "未登录" 提醒被移除 |

### 额外能力

- • **第三方 API 支持** — 可以配置任意 OpenAI 兼容端点，不局限 Anthropic
- • **Auto-mode 解锁** — 第三方 API 用户也能用 auto-mode
- • **消息过滤器绕过** — 显示原本对非 Anthropic 用户隐藏的内容

## 原理

Claude Code 的本质是一个 npm 包 `@anthropic-ai/claude-code` 。

核心代码打包在一个巨大的 `cli.js` 文件里，混淆压缩后的 JavaScript，通常好几 MB。

ClawGod 做的事情可以拆成 5 步：

**1\. 下载原版**

把 Claude Code 的 npm 包下载到 `~/.clawgod` 目录，不影响你全局安装的那个。

**2\. 提取原生模块**

如果你装的是 Claude Code 的原生二进制版本（Bun 打包的单文件）

ClawGod 会解析其二进制格式 `Mach-O` 、 `ELF` 、 `PE` 三种都支持——从中提取 `.node` 原生模块：

- • `image-processor` （图像处理）
- • `audio-capture` （Voice Mode 需要）
- • `computer-use-input` / `computer-use-swift` （Computer Use 需要）

**3\. 正则补丁**

核心在 `patch.js` 。它对混淆后的 `cli.original.js` 做正则匹配和替换：

| 补丁目标 | 匹配什么 | 替换成什么 |
| --- | --- | --- |
| 用户类型伪装 | `return"external"` | `return"ant"`  （伪装内部用户） |
| 订阅检查绕过 | `return X==="max"\|\|X==="pro"` | `return!0`  （永远放行） |
| 功能开关 | `isEnabled:()=>!1` | `isEnabled:()=>!0` |
| 安全指令 | 包含安全拒绝提示的字符串 | 删掉 |
| 品牌色 | `rgb(215,119,87)`  （橙色） | `rgb(34,197,94)`  （绿色） |

因为用正则而不是硬编码偏移量，所以 Claude Code 更新后补丁还能继续用。

**4\. 包装器替换**

生成一个新的 `cli.js` 作为入口，负责：

- • 从 `~/.clawgod/provider.json` 读取自定义 API 配置
- • 从 `~/.clawgod/features.json` 读取 Feature Flag 覆盖
- • 设置 `ANTHROPIC_API_KEY` 、 `ANTHROPIC_BASE_URL` 等环境变量
- • 最后加载被补丁过的 `cli.original.js`

**5\. 命令替换**

把你 PATH 里的 `claude` 命令替换为指向 `~/.clawgod/cli.js` 的启动脚本。

原版备份为 `claude.orig` ，随时可以切回去。

装完以后 `~/.clawgod` 目录长这样：

```
~/.clawgod/
├── cli.original.js        # 原始 bundle（未补丁）
├── cli.original.js.bak    # 补丁前备份
├── cli.js                 # 包装器入口
├── patch.js               # 补丁引擎
├── vendor/                # 原生模块
├── provider.json          # API 配置
└── features.json          # 功能开关
```

## 安装

```
# macOS / Linux
curl -fsSL https://github.com/0Chencc/clawgod/releases/latest/download/install.sh | bash

# Windows PowerShell
irm https://github.com/0Chencc/clawgod/releases/latest/download/install.ps1 | iex
```

也可以指定版本安装：

```
# 通过环境变量指定版本
CLAWGOD_VERSION=2.1.89 curl -fsSL https://github.com/0Chencc/clawgod/releases/latest/download/install.sh | bash
```

装完以后：

```
claude              # 运行补丁版（绿色 Logo）
claude.orig         # 运行原版（橙色 Logo）
```

如果命令没立即生效：

```
hash -r   # 刷新 shell 缓存
```

**前提条件** ：

- • Node.js >= 18 + npm

## 配置第三方 API

`~/.clawgod/provider.json` 可以配置任意 API 端点：

```
{
  "apiKey": "your-api-key",
  "baseURL": "https://your-api-endpoint.com",
  "model": "your-model-name",
  "timeout": 60000
}
```

`~/.clawgod/features.json` 控制功能开关：

```
{
  "ultraplan": true,
  "ultrareview": true,
  "agentTeams": true
}
```

## 更新

重新跑安装命令就行，补丁会自动重新应用：

```
curl -fsSL https://github.com/0Chencc/clawgod/releases/latest/download/install.sh | bash
```

## 卸载

```
# macOS / Linux
curl -fsSL https://github.com/0Chencc/clawgod/releases/latest/download/install.sh | bash -s -- --uninstall
hash -r

# Windows
irm https://github.com/0Chencc/clawgod/releases/latest/download/install.ps1 -OutFile install.ps1
.\install.ps1 -Uninstall
```

卸载会把 `claude.orig` 恢复成 `claude` ，清理 `~/.clawgod` 下的补丁文件。

## 风险和注意

**1\. 账号风险**

绕过订阅墙和安全限制可能违反 Anthropic 的服务条款，存在账号被封的可能。

**2\. 安全伦理**

移除了 CYBER\_RISK\_INSTRUCTION 后，Claude Code 不再拒绝渗透测试、C2 框架等请求。请在合法授权范围内使用。

**3\. 补丁稳定性**

补丁基于正则表达式匹配混淆代码。如果 Claude Code 未来版本大幅改变混淆方式，补丁可能失效。不过项目作者更新挺快，10 天内已经 15 个 commit。

**4\. Computer Use 仅限 macOS**

Computer Use 依赖 macOS 特定的 Swift 原生模块，Windows 和 Linux 上暂不可用。

**5\. 仍需 Claude Code 账号**

这不是一个独立的客户端，你需要先通过 `claude auth login` 认证。

---

如果你觉得这篇文章对你有帮助，记得点赞、分享，关注，万分感谢！

**微信扫一扫赞赏作者**

Claude Code · 目录

作者提示: 个人观点，仅供参考

继续滑动看下一个

码上源泉

向上滑动看下一个