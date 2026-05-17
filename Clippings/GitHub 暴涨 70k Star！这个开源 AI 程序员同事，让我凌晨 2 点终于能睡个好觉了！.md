---
title: "GitHub 暴涨 70k Star！这个开源 AI 程序员同事，让我凌晨 2 点终于能睡个好觉了！"
source: "https://mp.weixin.qq.com/s/v1EoGevObG2pSHkh1SWgVg"
author:
  - "[[小果]]"
published:
created: 2026-05-15
description: "前阵子又一个凌晨两点，我对着屏幕上那个怎么都调不通的 API 接口抓狂。"
tags:
  - "clippings"
---
小果 *2026年4月6日 18:24*

点一下关注，AI不迷路

---

前阵子又一个凌晨两点，我对着屏幕上那个怎么都调不通的 API 接口抓狂。console.log 打了一屏幕，咖啡喝了两杯，眼睛酸得跟进了沙子似的。那感觉你懂吧？就是那种明明觉得自己离成功只差一步，但偏偏这步怎么也跨不过去的绝望。

正当我想着要不干脆躺平明天再说的时候，突然想起了之前在技术群里看到有人提过的 **OpenHands** 。当时只是随手收藏了 GitHub 链接，想着有空试试。死马当活马医呗，反正都这样了。

![[_resources/GitHub 暴涨 70k Star！这个开源 AI 程序员同事，让我凌晨 2 点终于能睡个好觉了！/b4cb2944ec5c2d286b7381129713d0bd_MD5.webp]]

OpenHands GitHub主页

没想到啊，这一试真让我惊到了。它不仅帮我定位到了那个隐藏得极深的异步调用问题，还顺手把代码重构得更优雅了一些。那一刻，我感觉自己像是突然多了个经验丰富的程序员搭档，还是那种随叫随到、从不抱怨、甚至不需要喝咖啡的那种。

![[_resources/GitHub 暴涨 70k Star！这个开源 AI 程序员同事，让我凌晨 2 点终于能睡个好觉了！/69806da682cfa2b41617b1aef4cb74c6_MD5.webp]]

OpenHands界面截图

### 这玩意儿到底是个啥？

可能有些朋友还没听说过， **OpenHands** （以前叫 OpenDevin）是现在 GitHub 上特别火的一个开源项目，已经拿了超过七万个 Star。简单来说，它就是一个能 **像人类开发者一样独立工作** 的 AI 助手。

不过别误会，它可不是那种只会给你代码建议的"聪明一点的自动补全"。这家伙是真能动手干活—— **修改代码、运行命令、浏览网页查资料、调用 API** ，甚至还能去 StackOverflow 上扒代码片段。在 SWE-bench 那个很有名的软件工程基准测试里，它成功解决了超过一半的真实 GitHub 问题，这个成绩在开源项目里确实是相当能打了。

最让我心动的还是它的 **多智能体协作** 能力。复杂任务来了，它会自动拆解成几个子任务，然后不同的 Agent 分工协作完成。这就好比你一个人要搬一箱书，它不会傻傻地让你一次搬完，而是会分成几摞，分批搬运，效率自然高了不少。

![OpenHands CLI](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

OpenHands CLI

### 手把手教你装起来，真的超简单

我知道很多人看到这种工具就怕配置麻烦，但 OpenHands 的安装其实特别友好，官方提供了好几种方式，咱们挑两种最实用的来说。

#### 方法一：Docker 一键启动（强烈推荐小白）

如果你电脑上已经装了 Docker，那基本上就是复制粘贴几行命令的事儿。

先拉取最新的运行镜像：

```
docker pull docker.all-hands.dev/all-hands-ai/runtime:0.50-nikolaik
```

然后直接运行这个长长的命令（别被长度吓到，直接复制就行）：

```
docker run -it --rm --pull=always \
    -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.50-nikolaik \
    -e LOG_ALL_EVENTS=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/.openhands:/.openhands \
    -p 3000:3000 \
    --add-host host.docker.internal:host-gateway \
    --name openhands-app \
    docker.all-hands.dev/all-hands-ai/openhands:0.50
```

等看到终端里提示服务启动成功了，打开浏览器访问 `http://localhost:3000` ，你就能看到 OpenHands 的界面了。整个过程大概也就两三分钟，比你泡碗面还快。

![OpenHands界面](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

OpenHands界面

#### 方法二：pip 安装（适合喜欢轻量级的）

如果你是个 Python 开发者，不想用 Docker，也可以用 pip 直接装：

```
pip install openhands
```

装完之后输入：

```
openhands start
```

同样能在浏览器里打开 `localhost:3000` 使用。不过要注意，这种方式需要你的 Python 版本在 3.11 以上。

要是你是那种喜欢折腾源码的极客，也可以直接从 GitHub clone 下来本地运行：

```
git clone https://github.com/All-Hands-AI/OpenHands.git
cd OpenHands
pip install -e ".[dev]"
python -m openhands.core.main
```

### 配置模型，给它装上"大脑"

装好了软件，下一步就是配置 AI 模型了。OpenHands 支持市面上主流的 LLM， **Anthropic 的 Claude 3.5 Sonnet** 是目前社区公认效果最好的，Claude 3.7 也支持的。当然，如果你更习惯用 OpenAI 的 GPT-4o，或者想用本地的 Ollama 跑开源模型，也都是可以的。

第一次打开界面的时候，系统会提示你输入 API Key。拿到 Anthropic 或者 OpenAI 的 API Key 填进去就行了。建议大家在本地建个 `.env` 文件把密钥存里面，安全一些，也免得每次重启都要重新输入。

配置好模型之后，你就可以开始跟你的 AI 同事对话了。界面上有个聊天框，你可以直接用自然语言描述需求，比如："帮我给这个项目加个深色模式功能"，或者"这个报错的根源在哪里，帮我修一下"。

### 实际用起来是什么感觉？

用了这段时间，我发现 OpenHands 最爽的地方在于它的 **自主性** 。以前用其他 AI 编程工具，基本上是我写一段，它提示一段，节奏很碎。但 OpenHands 更像是："行，这个需求我明白了，我去搞定，搞定叫你。"

它会自己分析项目结构，找到需要修改的文件，甚至中间遇到不确定的地方还会主动去网上搜索最佳实践。最贴心的是，它运行在 **隔离的 Docker 沙箱环境** 里，就算执行命令也不会搞乱你的本地系统，安全感满满。

而且啊，它的界面设计得挺人性化的，左边是对话区，右边可以同时看到文件管理器、终端输出、甚至还有一个内置的浏览器窗口。你能实时看到它正在浏览什么网页、执行什么命令，有种"看着它干活"的掌控感。

有个小插曲，有一次我让它帮忙优化一个数据处理脚本，它居然自己发现了逻辑漏洞，还跑去查了 Pandas 的官方文档确认函数用法。这种细节真的挺让人惊喜的，感觉不只是在执行命令，而是真的有在"思考"。

![OpenHands与GPT-OSS合作](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

OpenHands与GPT-OSS合作

### 写在最后

当然啦，OpenHands 也不是万能的。特别复杂的架构设计，或者需要深度业务理解的需求，它还是需要你的指导。但日常的代码重构、Bug 修复、写个简单的功能模块，它确实能帮你省下大量时间。

最重要的是， **它是完全开源免费的** 。比起那些动辄每月几百块的闭源工具，OpenHands 让我们普通人也能体验到顶级 AI 编程助手的能力。社区也很活跃，GitHub 上 issues 回复很快，遇到什么问题基本都能找到解决方案。

如果你也经常被那些重复性的编码工作折磨，或者只是单纯想试试 AI 到底能帮到什么程度，真心建议花十分钟把它装起来试试。说不定，你也能找回凌晨两点前睡觉的自由。

**GitHub 开源地址：https://github.com/All-Hands-AI/OpenHands**

专注分享 GitHub知识，分享AI 资讯和AI搞米经验。

点关注，后台回复"OpenClaw"，可领取OpenClaw全栈部署与效能实战指南。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

想围观朋友圈，一起交流AI的，可加我VX，备注“ **AI** "。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

github开源项目分享 · 目录

继续滑动看下一个

GHub开源精选库

向上滑动看下一个