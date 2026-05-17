---
title: "在微信里使用 Claude Code，刚刚在 GitHub 上开源了这个 Skill 。"
source: "https://mp.weixin.qq.com/s/97gEBa6m1-VIB25PFBELtw"
author:
  - "[[逛逛]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
逛逛 *2026年3月22日 23:39*

我让 Claude Code 去读了一下 ClawBot 包的源码。

里面有微信 Bot 的整套协议：HTTP 长轮询怎么收消息、AES 加密怎么处理、扫码认证怎么走、CDN 怎么上传下载媒体文件，全在里面。

不依赖 OpenClaw，照着这套协议自己写。

任何 Agent 都能接入微信。

![[_resources/在微信里使用 Claude Code，刚刚在 GitHub 上开源了这个 Skill 。/74934690ed192b445df4156db3cf2d2a_MD5.webp]]

我直接口喷 Claude Code，10 分钟开源了一个 SKill。

然后一在微信里面和电脑上的 Claude Code 聊天。

```bash
开源地址：https://github.com/Wechat-ggGitHub/wechat-claude-code
```

**01**

**

**微信里面用 Claude Code**

**

OpenClaw 能接入微信，靠的就是上面那套协议。

那如果我把 OpenClaw 的消息处理逻辑整个替换掉，换成 Claude Code 呢？

手机微信发一条消息过来，本地进程接收，直接丢给 Claude Code 处理，把结果发回微信。

不需要 OpenClaw Gateway，不需要公网 IP，不需要域名。

本地跑着一个 Node.js 进程就够了。

一个人从零写也不是不行，但效率不高。

这时候我想到一个工具：Superpowers。

**02**

**

**Superpowers 神器**

**

Superpowers 是 GitHub 上一个给 Claude Code 等用的 Skill 框架。

有 10 万的 Star，贼火。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

我之前都是用它来开发新项目。

你不用让 AI 随便写代码，而是按一套结构化的开发流程来：先头脑风暴想清楚，再写计划，最后并行开发。

我这次主要用了三个 Skill。

第一个是 Brainstorming 头脑风暴。

我先跟 Claude Code 说：

微信刚开放了 ClawBot 插件，你读一下 `@tencent-weixin/openclaw-weixin` 这个包的源码，看看能不能基于它的协议，把 Claude Code 直接接入微信。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

Claude Code 把这个包的代码全部过了一遍，然后我们开始讨论。

它分析了协议层的每个细节：认证流程是怎样的、消息格式长什么样、长轮询的超时机制、加解密的密钥怎么管理。

讨论下来，方案基本确定了：

从那个包里提取微信协议层，把 OpenClaw 的消息处理逻辑整个替换掉，改成调用 Claude Agent SDK。

用 query() 方法把消息发给 Claude Code，把流式返回的结果再发回微信。

有个细节我觉得挺关键的。

整个过程中 Claude Code 不只是个执行者，它会主动提出问题、挑战我的想法。

比如它问过：

① 技术上使用基于 OpenClaw 的方案还是不基于 Gateway，自己做？

② 要不要支持输入斜杠命令？

③ 如果涉及到授权，能不能你输入 yes/no 来控制？

这些问题帮我提前想清楚了很多边界情况。

第二个是 Writing Plans，写实施计划。

头脑风暴完了，方案基本清晰。

接着让 Claude Code 写了一份详细的实施计划，把整个项目拆成了十几个模块。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

Writing Plans 会自己落实一个 Markdown 文档到本地。

从微信协议层、加解密、媒体处理，到会话管理、命令路由、权限审批，每个模块都有具体的代码模板和接口定义。

哪些可以并行做，哪些必须串行，都标得清清楚楚。

看了一遍计划，我觉得没问题，直接进入下一步。

第三个是 Dispatching Parallel Agents，并行开发。

这一步是整个流程里最爽的。

Claude Code 同时派出多个 Agent，各自负责不同的模块。

微信协议层、Claude SDK 对接、会话管理、命令路由，这些没有依赖关系的模块全部同时开工。

Agent 之间通过共享的接口定义协作，不用等一个写完另一个才能开始。

最终 15 个模块全部编译通过。

**

03

看看效果

**

第一次使用，会弹出来一个二维码，让你用微信扫描。

然后就可以直接在微信和 Claude Code 对话了。

跑起来之后，效果是这样的：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

手机微信发条消息，HTTP 长轮询到本地 Node.js 进程，经 Claude Agent SDK 丢给 Claude Code，处理完直接发回微信。

不需要公网 IP，不需要域名，本地电脑跑着就行，macOS 用 launchd 管理守护进程，开机自动启动。

你在地铁上用手机给 Claude Code 派个活，等到了公司，活已经干完了。

另外开源整个流程也可以直接口喷 Claude Code。

让他帮你完成。

你只需要做的是审核、批准。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

微信开放 ClawBot 插件，官方的意思是让大家把 OpenClaw 接进来。

但底层协议是可以被读取的，这意味着微信 AI 的入口不只有 OpenClaw 一条路，任何 Agent 照着写对接层都能进。

04

**点击下方卡片，关注逛逛 GitHub**

这个公众号历史发布过很多有趣的开源项目，如果你懒得翻文章一个个找，你直接关注微信公众号：逛逛 GitHub ，后台对话聊天就行了：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

Agent · 目录

继续滑动看下一个

逛逛GitHub

向上滑动看下一个