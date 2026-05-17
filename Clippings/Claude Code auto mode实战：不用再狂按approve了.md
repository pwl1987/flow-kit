---
title: "Claude Code auto mode实战：不用再狂按approve了"
source: "https://mp.weixin.qq.com/s/Es1J6JzGnR7hVuf3EqtbRw"
author:
  - "[[92year]]"
published:
created: 2026-05-15
description: "93%的审批用户直接点同意，auto mode让Claude自己判断安全不安全，不用再一直盯屏幕了"
tags:
  - "clippings"
---
92year *2026年3月31日 23:22*

## Claude Code auto mode实战：不用再狂按approve了

你用Claude Code跑一个稍微复杂点的任务，屏幕上弹多少次approve？读文件要approve，跑命令要approve，改配置还是approve。Anthropic自己统计过，93%的审批用户直接点了同意，根本没看内容。

3月底Anthropic上线了auto mode。让Claude自己判断哪些操作安全、哪些需要拦截。不用 `--dangerously-skip-permissions` 那么激进，也不用一直盯着屏幕。

## 怎么开

打开Claude Code，输入 `/permissions` 选auto mode。或者启动时加参数：

> `claude --permission-mode auto`

第一次用会提示确认，之后不用管。Max套餐直接能用，不额外收费。

## 两层过滤器

**输入层** ：Claude读文件、抓网页拿到的结果，先过一遍注入检测。如果内容看起来像劫持指令的（文件里藏"忽略前面所有指令"），系统会加警告提醒Claude不可信。

**输出层** ：每次执行操作前，一个Sonnet 4.6分类器检查操作是否合理。先做单token快判，大部分操作直接放行；被标记才启动完整推理。分类器只看用户消息和工具调用，不看Claude的思考过程——防止Claude"自我说服"绕过检查。

## 拦什么、放什么

读文件、搜索代码、查看目录这些只读操作直接放行。你配了always-allow的工具也直接过。

以下这些会被拦（都是Anthropic内部真实事故案例）：

**范围扩大** ——你说"清理旧分支"，Claude去删远程分支。拦住，因为"旧分支"太模糊，删远程不可逆。

**翻找凭证** ——任务碰到认证错误，Claude开始翻环境变量找别的API key。拦住，这些凭证可能给别的服务用的。

**猜参数** ——你说"取消我的任务"，Claude查了集群挑名字最像的去删。拦住，可能猜错目标。

**往外发数据** ——Claude想分享调试脚本，构造了Gist上传命令。拦住，内容可能保密。

**跳安全检查** ——部署过不了预检，Claude加了 `--skip-verification` 重试。拦住。

## 用了一周的感受

日常写代码、改配置、跑测试全自动了，不弹approve。跑那种改十几个文件的重构任务体验提升明显。

偶尔误拦。让它curl测本地API，被当成"往外发数据"。这时候它不会直接失败，换方式重试。

有一次让它"重置测试数据库"，准备跑drop database的时候被拦住了，要我确认。这个拦得好。

## 注意事项

**权限规则会被覆盖** 。进auto mode后，之前配的一些shell命令always-allow规则会被收回。python/node解释器的通配规则、包管理器run命令都会收回。

**额外token消耗** 。分类器跑在Sonnet 4.6上，每次操作都过一遍。日常感觉不明显，但几百次工具调用的大任务，token消耗会高一截。

配合 `/schedule` 定时任务效果好——定时任务本来没人盯，但又不想完全开放权限，auto mode正好卡在这个位置。

每天一篇AI工具实战，关注「AI实战派」，明天见。

继续滑动看下一个

92year

向上滑动看下一个