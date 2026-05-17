---
title: "让 Claude Code 成本爆降 80%，这个开源工具有点猛..."
source: "https://mp.weixin.qq.com/s/L11cw9ecXrmwbX4CV5P9yA"
author:
  - "[[小 G]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
小 G *2026年5月5日 17:06*

如今 Claude Code、Codex 这些 AI 工具已成为我们日常工作里离不开的编程伙伴。

但雇这位伙伴干活并不便宜，有时候只写两个简单功能，Token 消耗就动辄几百万。

打开账单页面一看，头瞬间就大。而且这位伙伴经常在同一个会话里反复读同一个文件，跟得了短期失忆症似的。

整个项目结构在它眼里就是一片黑雾，每次干活都得从零摸索一遍。

直到前几天，偶然在 GitHub 上发现了 **OpenWolf** 这款开源工具，号称「Claude Code 的第二大脑」。

![[_resources/让 Claude Code 成本爆降 80%，这个开源工具有点猛/25a75374af13af7374e96afc6ab914df_MD5.webp]]

不替开发者跑 AI，也不改原有工作流，只是在背后悄悄给 Claude 装上一套外挂记忆系统，让它干活的时候不再瞎摸。

同一个项目、同样的 Prompt，裸 Claude CLI 烧掉 250 万 Token，而 OpenWolf 加 Claude CLI 只用了 42.5 万，相比节省约 80%。

作者在 20 个项目、132 多次会话的统计数据中，实测平均节省 65.8%，重复文件读取拦截率 71%。

![[_resources/让 Claude Code 成本爆降 80%，这个开源工具有点猛/7f5fa0a40d313dac4d0bb95688911d54_MD5.webp]]

那它是怎么做到的？原理其实不复杂。

Claude Code 提供了一套生命周期 Hook，简单理解在 Claude 干活前后插一脚的机制。

OpenWolf 就是用 6 个 Hook 脚本，在 Claude 读文件、写代码的关键节点上做手脚，把信息提前塞给它。

具体落到工程上，是

```
.wolf/
```
目录里的三个核心文件。

```
anatomy.md
```
**，相当于项目地图。**

里面给每个文件附上一行描述和 Token 估算，比如 “这个文件是 CLI 入口，大约 180 Token”。

Claude 想读文件之前，OpenWolf 会先把这条信息塞过去。

看完描述发现不需要细读，这次文件打开就直接省掉了。

```
cerebrum.md
```
**，是一份学习记忆。**

每次我们纠正 Claude，或者表达某个偏好，都会被记下来。

最有意思的是里面那个 Do-Not-Repeat 列表，字面意思就是「不许再犯」。

下次新会话开始时，Claude 会先翻一遍，避免在同一个地方第二次摔跤。

```
buglog.json
```
**，是一本 Bug 账本。**

改完一个 Bug，错误信息、根因和修复方案会自动归档。

下次再遇到类似报错，Claude 先去搜一下，发现已经修过就直接套用方案，不用从头排查。

![image-20260504195233200](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

除了这三个主要文件之外，OpenWolf 还给我们内置了一些实用的小工具。

```
token-ledger.json
```
，记录每个会话花了多少 Token、命中地图多少次、拦截了多少次重复读取。

还有 Design QC 命令，能自动给运行中的应用每个页面截一组全屏图，扔给 Claude 评价设计，对前端开发者相当友好。

配套的 Reframe 功能也很实用，内置了 12 套主流 UI 框架，包含 shadcn/ui、Magic UI、DaisyUI 等等，提供迁移指引，换框架这种重活，一句话丢给 Claude 跑。

![image-20260504195401255](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

聊完功能，再来看下安装使用教程。

OpenWolf 的上手还是比较简单，只需要三行命令即可搞定：

```bash
npm install -g openwolfcd your-projectopenwolf init
```

```
claude
```
就行，OpenWolf 会在后台默默接管。

```
openwolf status
```
就能看到健康检查输出，确认 Hook 生效了。

![demo8-ezgif.com-video-to-gif-converter](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

需要注意几个点。

Claude Code 的 Hook 机制偶尔会出现没触发的情况，这时候 OpenWolf 会自动降级到

```
CLAUDE.md
```

Token 估算用的是字符长度换算，不是 API 精确计数，误差大概 15%。

目前工具正在初期开发阶段，作者也直说「工具不完善」，如遇到问题可以给作者提 Issue。

### 写在最后

今天分享的 OpenWolf，做的事情其实就一件：让 Claude Code 用得起。

这件事在 2026 年只会愈发重要。模型的编程能力一路上探，开发者交给它的活越来越多，月底账单跟着水涨船高。

OpenWolf 没把自己包装成 Agent 框架，只用 6 个 Hook 脚本，让 Claude 少读点没用的、记住点学过的、避开点踩过的坑。

虽然工具目前还在开发初期，难免有粗糙的地方，但这个思路是对的。

如果大家也在为 Claude Code 的账单发愁，不妨花几分钟装来试试，应该会有不错的惊喜。

GitHub 项目地址：https://github.com/cytostack/openwolf

今天的分享到此结束，感谢大家抽空阅读，我们下期再见，Respect！

AI · 目录

继续滑动看下一个

GitHubDaily

向上滑动看下一个