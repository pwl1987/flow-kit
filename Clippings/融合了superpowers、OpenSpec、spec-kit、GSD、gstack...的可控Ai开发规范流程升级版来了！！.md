---
title: "融合了superpowers、OpenSpec、spec-kit、GSD、gstack...的可控Ai开发规范流程升级版来了！！"
source: "https://mp.weixin.qq.com/s/gvRWbnB1heYGhUtNGYetWQ"
author:
  - "[[rihebty]]"
published:
created: 2026-05-15
description: "先说丑话：这玩意儿很费 token用 flow-kit 跑项目，token 消耗会比你直接让 AI 撸代码高出"
tags:
  - "clippings"
---
rihebty *2026年5月11日 11:43*

## 先说丑话：这玩意儿很费 token

用 flow-kit 跑项目， **token 消耗会比你直接让 AI 撸代码高出一截** ——保守估计 **至少 2~3 倍** ，复杂模块更多。

原因不复杂：每个阶段都要产出 `.md` 工件、读 LESSONS、读 CONTEXT、跑自检、做反问、写 SUMMARY。这些都是真金白银的 token。

我用它跑了一个 **智能慢病管理系统** ——医生工作台、患者入组、随访方案、患者端这几大块就烧了蛮多tokens，具体的没统计，都是网友给的api😄。

所以 **不是每个项目都值得用** ：

- 写一次性脚本 / 学习项目 / 玩具 demo → 别用，纯浪费
- 真要长期维护、要给别人看、要上生产 → 这 2~3 倍 token 换的是少返工 / 不踩重复坑 / 能交接 / 半年后还能接得回去

我自己的判断：写得越久 / 维护期越长，越划算。

项目地址：github.com/rihebty/flow-kit

> **图：贴几张我项目的实战代码和网页截图，不然有人又说没实战过，AI生成文章啥的，Ui我是发了几版给医院主任，他建议用这版，说符合医疗设计，不是很懂哈哈哈**

![[_resources/融合了superpowers、OpenSpec、spec-kit、GSD、gstack...的可控Ai开发规范流程升级版来了！！/3f6ca3526cb6e8f370d8ef6f01d0d692_MD5.webp]]![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E) ![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

---

## 上一篇之后陆续融的几块（先过一遍）

上一篇（\[flow-kit 续：几个用下来觉得值的设计\]）之后我没停手，陆续往里塞了一些东西。这一节先快速过一遍，下一节讲跑慢病系统时新补的。

**andrej-karpathy-skills 四守则进 RULES** ——动手前先想清楚 / 怎么简单怎么来 / 改动外科手术化 / 目标可验证。说白了就是治 AI"想多了 / 改多了 / 顺手重构 / 跑偏"这四个常见病。落到规则上就是：禁止过度抽象、禁止投机加功能、禁止顺手 drive-by 重构、必须匹配现有风格。

**四闸门 + 第五闸门** ——之前 AI 经常预算估完就当流程过了直接动手。现在硬规定：路由声明 → 用户回复 → 加载 prompt 并确认 → prompt 第一步反问并等回复，四步一步都不能跳。阶段切换时再加一道闸门：必须产出工件 + 输出过渡声明 + 用户确认才能进下一阶段。

**@GO.md 零例外路由** ——只要消息里出现 `@GO.md` ，不管后面跟什么内容，AI 都必须先给路由声明或选项菜单，禁止直接动手、禁止沉默。这条是治"我发了路由文件 AI 还是当成普通需求处理，还一直给我跳过，气人啊"。

**验收准则用 Given / When / Then** ——之前 AC 写得太自由，AI 写测试时对不上。现在 REQUIREMENT.md 模板要求 AC 用 BDD 三段式，这样 5-test 阶段能直接派生测试矩阵，不用再翻译一遍。

## 这几块是"内功"层面的，单看每条都不起眼，合在一起体感是 AI 守规矩多了。

## 部署到底该不该走，先问 4 个问题

跑慢病系统时，某天我对着一个本地工具脚本随口说了句"@GO.md 部署一下"，AI 真的开始问我要 Vercel token——这玩意儿压根没要发布的必要。

新加了 `8-release.md` ，并在它最前面放了一个"前置 4 问"：

1. 这次的 change 都 merge 到主干了吗？
2. 主干跟生产环境真的有 diff 吗？
3. 必须立刻让用户看到，还是能攒一批再发？
4. 这项目有外部用户 / 真实生产环境吗？

四个全 ✅ 才进发布流程。任一 ❌ 都给替代路径，不让步。第 4 个最常救场——很多个人项目根本不需要"发布"，本地跑起来就完了，AI 不该被一句"上线"带跑偏。

> **图：又是耗token的一步啊**

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

---

## 线上炸了，走完整流程来不及

慢病系统给用户演示前一晚，登录接口 502。如果按主流程走 0-change → 1-requirement →... 这条线，演示估计也别看了。

新加了 `H-hotfix.md` ，分三档：

- **P0**
	（用户完全不可用）：先回滚再诊断，AI 不许在没回滚前查代码
- **P1**
	（部分功能炸）：3 问澄清后直接进修复，跳过完整需求 / 设计阶段
- **P2**
	（边缘问题）：建议走正常 0-change，别滥用 hotfix

但 hotfix 有个尾巴——事故解决后 24 小时内必须补齐 INCIDENT.md / CHANGE.md / SUMMARY.md / 测试 / LESSONS 提名 5 件事，相当于"先救火再补流程"。这条是为了防止 hotfix 被当成"绕过流程的捷径"长期滥用。

---

## Deepseek key 我真的不小心 commit 过

写患者随访 AI 助手那块要调 Deepseek。我让 AI 帮我接，它顺手把 key 写进了 `config.ts` ，我还顺手 commit 了。等到第二天才反应过来——已经在 git 历史里了，还好是没开源的哈哈哈哈。

新加了 `4-dev.md § 1.5.7` ：只要任务里出现 `api_key / token / secret / password` 这类词，或者要新增对外部服务的调用，AI 必须：

- 强制走 `.env.example` + `.gitignore` 这套
- 提交前自己跑三条命令扫敏感信息（ `git diff --staged | grep` / `git grep` / 文件名扫）
- 如果检测到我已经把真实 key commit 了，立刻给"撤销 + revoke + rotate"的应急步骤

补完之后又翻了两个老项目，扫出 2 处小问题。这条早加早安心。

---

## 隔了一段时间再回项目，AI 比我还懵

有个项目中间被打断过——出差回来，前面做到哪、还有什么坑都忘了。我打开 IDE 看着一堆 `.specs/` 目录发呆。

新加了 `R-recall.md` ：触发后 AI 会把 `STATE.md` + 最近 3 个 SUMMARY.md + LESSONS.md + 待办 grep 出来，给我一份"5 分钟项目摘要 + 推荐下一步"。如果搁置超过 30 天还会做 bit rot 检查（依赖是不是有破坏性更新、CI 还能不能跑、test 还过不过）。

跟 4-dev 的"入场恢复"是两件事——后者只管单个 task 中断，前者是整个项目层面的捡起来。

---

## 还有几个小的

**反问别死循环** ——之前 1-requirement 阶段 AI 能问我十几轮，每轮还差不多。现在硬限制 2 轮，第 3 轮必须用默认值往下走，写进"假设与默认值"段落让我事后 review。同时给了几个 escape 词（"够了"/"按你想的来"），我说了就立刻收尾。

**前端必须用中文** ——AI 写出来的表格表头、分页组件、日期选择器一打开全是 "Previous" / "Next" / "OK"，慢病系统给医生用这哪能行。R8.3 现在管三类：自己写的字符串、第三方组件 locale 配置、配置驱动的字面量（columns 定义里的 title 那种）。4-dev 自检会扫一遍。

**纠偏要识别** ——我经常发"@GO.md 那里改一下不对，应该是..."，之前 AI 当成新需求又跑一遍 0-change。现在 GO.md 和 0-change 都加了"中途变更 / 纠偏 rewind"识别——检测到纠偏措辞 + 当前有进行中的 change，就回到对应阶段改文件，而不是新开。

---

## 一个体感

跑这个慢病系统让我体会到 flow-kit 真正的价值不在"流程多严"，而在 **它会替我记住那些我自己懒得记的事** ——secrets 别 commit、schema 改了带 migration、删代码先 grep、清窗前写 PROGRESS、纠偏不要被当成新需求、本地工具不需要 release。

我自己人肉做也能做到这些，但人会忘、会偷懒，AI 不会。

代价就是 token 烧得是真多啊，在这里诚挚感谢赞助deepseek和glm的网友😄。如果项目不带来效益，真不建议使用！赚点钱不容易！！！

> 项目地址（最新的还没发布哈哈哈哈）：github.com/rihebty/flow-kit

## 欢迎大家法克下来自己改，毕竟这都是我自己开发流程，适合自己的才是最好的，别人的参考一下就好。有问题随时来。

[开源，开源，融合多个AI工具的AI规范化编程项目发布了！！](https://mp.weixin.qq.com/s?__biz=MzkyMDU4ODYyNg==&mid=2247483822&idx=1&sn=3c51546293b853c78ea6490f3a9e9c81&scene=21#wechat_redirect)

[每个ide都可以使用！！我融合了superpowers、OpenSpec、spec-kit、GSD、gstack、claude-task-master写一套可控Ai开发规范流程](https://mp.weixin.qq.com/s?__biz=MzkyMDU4ODYyNg==&mid=2247483817&idx=1&sn=cfda61a2e03655be25c8bc5bc5c3e2d2&scene=21#wechat_redirect)

继续滑动看下一个

自我学习笔记记录

向上滑动看下一个