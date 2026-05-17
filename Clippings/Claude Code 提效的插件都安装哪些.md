---
title: "Claude Code 提效的插件都安装哪些"
source: "https://mp.weixin.qq.com/s/fLqvTB80MIgVGuWTcPKxgg"
author:
  - "[[付辉]]"
published:
created: 2026-05-15
description: "claude code 有哪些提效的工具？插件市场提供了很多工具，我也想安装一些有用的或者好玩的。"
tags:
  - "clippings"
---
付辉 *2026年5月5日 23:15*

claude code 有哪些提效的工具？插件市场提供了很多工具，我也想安装一些有用的或者好玩的。

第一个插件 superpowers，还是官方库里的插件。这个插件被用来明确你的真实需求，在真正开始之前会反复和你确认一些具体的问题。我们和大模型的交互往往是反复修正确认的，要真正解决一个开放性的问题，经常会涉及到多次沟通。

> As soon as it sees that you're building something, it doesn't just jump into trying to write code. Instead, it steps back and asks you what you're really trying to do.

这其中少数沟通其实是不必要的，往往是因为我们没有和大模型明确清楚，或者我们自己没有想清楚，这个插件就是用来强迫我们明确的，会给我们一些开放性的问题供我们提前确认。

![[_resources/Claude Code 提效的插件都安装哪些/6fc131e9439ae3c7755b324bf4ea9b92_MD5.webp]]

我在 OpenClaw 上也装了这个插件，比较明显的体感就是大模型在实际执行前多了几步反复确认的动作，比如，下面的截图所示。不过，你可能会担心，这玩意会额外增加了token的消耗。对于简单的任务确实如此，但据说对于复杂的任务会明显降低token的消耗。

总结一下这个工具，强迫你想清楚问题之后再动手做事。之前你可以直接写代码，现在你需要出一个设计文档才能写代码。

---

第二个插件 claude-hud，实时显示正在发生的事情——上下文使用率、活跃工具、运行中的 Agent 和待办进度。始终在你的输入下方可见，插件显示的效果如下图

这个能力其实挺常见的，但它其实也不是特别有用，只是显示到终端里就觉得特别酷炫，有些东西就是这样，啥用没有，但挡不住大家喜欢。值的强调的是，需要你通过命令 /claude-hud:configure 去配置一下。

这里显示的是 Sonnet 4.6 但其实我本地安装的并不是，前面的文章中我有提到我使用的模型，大家通过我分享的连接购买人数超过3个人，我就能获得佣金，但很遗憾，至今没有获得。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

---

第三个插件 feature-dev，它也可以作为程序开发的小帮手，当你想扩展一个新的特性，或者，你就想梳理现有代码汇总结论，都可以让大模型使用这个skill 来实现

它有点类似 superpowers，都是提供了问题处理的一种范式，它的核心理念是不急于写代码，而是通过系统化的流程确保：

1. 理解现有代码库
2. 明确所有模糊需求
3. 设计优雅的架构
4. 保证代码质量
![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

---

上面提到了三个插件，其实还有很多，下面我们说几个可以和 claude code 搭配使用的工命令行具，关键点是提到命令行的操作效率，界面可视化效果要酷炫。

第一个命令行工具 glow，有了这个工具，就可以在控制台查看 markdown文件，没有安装它之前，你看的是黑白电视，安装了它之后，你看的是彩色电视。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

这个名字和grow很像的，你可别差错了，下面是使用 glow 查看 markdown 文件的效果。正常来说，很多编译器都集成了这个能力，但总是需要切换到编译器才行，现在可以直接在 terminal 中完成查看了。

第二个命令行工具 zoxide，快速cd到目标目录，还有一个类似的命令 jump，干的事一样。

比如我想跳转到项目 list\_view 下，只要我之前输入过这个路径，我通过下面的命令就可以立即调整到这里。它最大的作用其实是省去了记忆的心智负担，但长时间不记忆也容易出问题。

```nginx
z list_view
```

第三个命令行工具 lazygit，命令行下的可视化git工具，看到这个工具的视觉效果，总感觉我的开发能力也成倍地提高了。它可以配合 claude code 来使用，左边是 claude 写代码，右边是可视化的修改视图。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**微信扫一扫赞赏作者**

继续滑动看下一个

乌海线平刚

向上滑动看下一个