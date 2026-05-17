---
title: "Claude的/rewind功能，你真的用对了吗"
source: "https://mp.weixin.qq.com/s/QuxXy81N5hp_zFzYg3nngw"
author:
  - "[[抛个砖头]]"
published:
created: 2026-05-15
description: "它是一个非常实用的context管理工具"
tags:
  - "clippings"
---
抛个砖头 *2026年4月20日 17:21*

经常用AI的小伙伴应该都有一个痛点，那就是在AI犯错需要撤销操作的时候会比较麻烦。尤其是写代码的时候还可以通过git来做版本控制，但是修改ppt或者文档的时候就需要找着AI给出的修改历史逐行撤销了。

好在前一段时间Claude推出了内置的\`/rewind\`命令，可以帮助你一次性撤销在某段对话中做的所有操作，重置回之前的状态。

在使用\`/rewind\`命令的很长一段时间里，我都以为这个命令的主要功能是撤销操作。但这几天我才发现这个命令比我想象的还要强大。

它不仅仅会把操作回滚，还会把模型的context window一起回滚。

例如，在我rewind之前，我的Messages已经用掉了35.6k的context。

![[_resources/Claude的rewind功能，你真的用对了吗 1/353812f25a9daf8baf792e7c35910d9d_MD5.webp]]

但当我rewind之后，context window回到了对话发生前的用量，只有8.1k了。

这里再解释一下：为什么回滚context window那么重要呢？

首先，模型的context window是有上限的，以Claude举例，sonnet的context总量在200k，Opus的context总量是1M。这个窗口大小决定了模型在一次对话当中能够参考多少信息。

一旦你提供给大模型的信息超过了这个总量，之前的信息就会被大模型忘记。

而且，大模型可以高质量处理信息的区间一般在模型的总context window的40%左右。这样换算下来，sonnect真正能够处理的信息上限大概相当于一本《了不起的盖茨比》，而Opus能够处理的信息量上限大概相当于哈利波特系列的前三部之和。

所以妥善的控制context的使用量，是确保模型性能的关键之一。在编程领域，甚至有一个专门的概念叫做Context Engineering，目的就是最高效的来利用大模型的context。

![dumbzone-curve](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

dumbzone-curve

第二点，你放在context window里的每一段信息，都会影响模型后续的判断。因为在同一个session里，大模型的每一次回复都会回过头去参考这个session里的所有历史对话，指令，和中间结论。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

所以当大模型在其中一段对话的回答和执行中出现了偏差以后，最好的方式是把这段信息从context里完全的抹除掉，避免它产生噪音，影响模型后面的判断。

这就是\`/rewind\`这个命令最有价值的地方。

它是我们的对话栏中非常实用的Context Engineering工具，确保我们只把真正有价值，准确的信息放进了context里，提高AI的工作质量。

打工人的AI课 · 目录

继续滑动看下一个

抛个砖头

向上滑动看下一个