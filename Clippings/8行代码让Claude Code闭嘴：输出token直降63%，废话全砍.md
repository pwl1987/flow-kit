---
title: "8行代码让Claude Code闭嘴：输出token直降63%，废话全砍"
source: "https://mp.weixin.qq.com/s/DrPUykwCwIEryUDwYBxucQ"
author:
  - "[[winkrun]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
winkrun *2026年4月2日 20:53*

Claude Code每次回复你，先要说一句「Sure!」「Great question!」，结尾再来句「I hope this helps!」，中间还要复述一遍你的问题，顺手给你一些没要求的建议。

这些「礼貌」全在消耗token，但信息量为零。

有人忍不了了。开发者Drona Gangarapu往项目根目录扔了个8行的CLAUDE.md，效果惊人：

- 代码review：120词 → 30词（-75%）
- 概念解释：180词 → 65词（-64%）
- 纠正错误事实：55词 → 20词（-64%）

总输出token减少63%，信息零损失。

这8行规则具体内容如下：

```
1. Think before acting. Read existing files before writing code.（行动前先思考。写代码前先阅读现有文件。）
2. Be concise in output but thorough in reasoning.（输出要简洁，但推理要彻底。）
3. Prefer editing over rewriting whole files.（优先编辑而不是重写整个文件。）
4. Do not re-read files you have already read.（不要重复阅读已经读过的文件。）
5. Test your code before declaring done.（在宣布完成前测试你的代码。）
6. No sycophantic openers or closing fluff.（不要有奉承的开场白或结束语。）
7. Keep solutions simple and direct.（保持解决方案简单直接。）
8. User instructions always override this file.（用户指令始终覆盖此文件。）
```

核心就一条： **别废话** 。别开场的客套话，别结尾的礼貌性祝福，别复述问题，直接给答案。

第三方独立测试验证了效果：在CSV Reporter、SQLite窗口函数、WebSocket计数器三个编码挑战中，v8配置（7行规则 + 20次工具调用预算）比之前最优方案C-structured成本低17.4%。

但项目主页写得非常诚实：CLAUDE.md本身每轮对话都要作为输入token加载。只有高频场景——Agent循环、自动化流水线、日均100+ prompt——才有净收益。偶尔聊两句反而更贵。

本质就是一个取舍：用input token换output token。配额紧张的2026，这个账值得算一算。

有多个profile可选：通用版、编码benchmark版、开发项目版、Agent流水线版、数据分析版。最激进的v8配置只有20次工具调用预算，逼Claude提前规划而不是边试边改——适合简单任务的成本敏感场景。

项目地址：https://github.com/drona23/claude-token-efficient

关注公众号回复“进群”入群讨论。

**微信扫一扫赞赏作者**

精品项目 · 目录

继续滑动看下一个

AI工程化

向上滑动看下一个