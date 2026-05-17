---
title: "superpowers-zh：17款AI工具通用的20个超能力"
source: "https://mp.weixin.qq.com/s/7qMitWwYLhjPrtWURePpyw"
author:
  - "[[风雨中同行]]"
published:
created: 2026-05-15
description: "159k star的英文原版我刚看到时挺兴奋。"
tags:
  - "clippings"
---
风雨中同行 *2026年5月9日 11:00*

159k star的英文原版我刚看到时挺兴奋。

以为又是一个"让AI会写代码"的工具。

结果发现，它根本不是教AI写代码。

它是教AI **怎么工作** 。

---

![[_resources/superpowers-zh：17款AI工具通用的20个超能力/bc2cf464de8074a10140bcf204749e27_MD5.webp]]

---

**这是个大反转。**

2026年了，Claude Code、Cursor、Codex这些AI编程工具，代码写得都不错。

但有个问题一直没解决：

**它们只会写，不会想。**

你让它"加个批量导出功能"，它直接开始写代码。

格式没问、分页没问、权限没问。

等你发现错了，它已经写了200行。

你还得花半小时告诉它"不是这样的，我要的是……"

这不是AI不够聪明。

是AI **没有工作方法论** 。

---

superpowers-zh 做的事，就是给AI装上这套方法论。

让AI从"你让它干啥它就干啥"的执行机器，变成会提问、会规划、会测试驱动开发的"靠谱工程师"。

我仔细拆解了这个项目（包括它的中文增强版），发现它提供的不是工具，是 **20个skill** （技能/方法论）。

每个skill教AI在特定场景下 **先做什么、再做什么、怎么验证** 。

这套方法论在17款AI工具上都能用。

Claude Code、Cursor、Gemini CLI、Codex、Hermes Agent、Kiro、Windsurf、Qwen Code……

一键安装，自动识别。

---

## 1\. 核心反转：AI缺的不是代码能力

我一开始也纳闷，AI代码生成能力都这么强了，为什么还需要这个？

直到我看到 superpowers 的一个对比示例。

**没有 superpowers 的对话：**

```
你：给用户模块加个批量导出功能
AI：好的，我来实现...
    export async function exportUsers() { ... }
你：等等，格式不对，没分页，大数据量会 OOM...
```

**装了 superpowers 后的对话：**

```
你：给用户模块加个批量导出功能
AI：在开始实现之前，我需要了解几个关键问题：
    1. 导出格式是 CSV 还是 Excel？
    2. 预计数据量多大？需要异步处理吗？
    3. 有权限要求吗？
    → 给出 2-3 个方案，确认后再动手
```

看到区别了吗？

AI不是直接写代码，而是 **先提问、再规划、最后才动手** 。

这背后就是 superpowers 的 **brainstorming skill** （头脑风暴技能）。

它会强制AI在写代码之前，先做需求分析、探索备选方案、给出设计文档给你确认。

这个skill在 superpowers-zh 里只是20个skill中的一个。

---

## 2\. 20个skill拆解：从头脑风暴到完成验证

superpowers-zh 提供的20个skill，分为三大类。

**第一类：开发流程控制（7个）**

这些skill把整个开发流程标准化了。

1. 1\. **brainstorming（头脑风暴）** — 需求来了不写代码，先问清楚、探索方案、给设计文档
2. 2\. **writing-plans（编写计划）** — 把设计拆成可执行的实施步骤，每步有文件路径、代码、验证方法
3. 3\. **executing-plans（执行计划）** — 按计划逐步实施，每步验证
4. 4\. **test-driven-development（测试驱动开发）** — 严格TDD：先写测试，再写代码，RED-GREEN-REFACTOR循环
5. 5\. **systematic-debugging（系统化调试）** — 四阶段调试法：定位→分析→假设→修复
6. 6\. **verification-before-completion（完成前验证）** — 声称完成前必须跑验证命令，证据先行
7. 7\. **subagent-driven-development（子agent驱动开发）** — 每个任务一个子agent，两轮审查

**第二类：协作与审查（5个）**

1. 8\. **requesting-code-review（请求代码审查）** — 派遣审查agent检查代码质量
2. 9\. **receiving-code-review（接收代码审查）** — 技术严谨地处理审查反馈，拒绝敷衍
3. 10\. **dispatching-parallel-agents（派遣并行agent）** — 多任务并发执行
4. 11\. **using-git-worktrees（使用git worktree）** — 隔离式特性开发
5. 12\. **finishing-a-development-branch（完成开发分支）** — 合并/PR/保留/丢弃四选一

**第三类：中国特色技能（6个）** — 这是 superpowers-zh 新增的

1. 13\. **chinese-code-review（中文代码审查）** — 符合国内团队文化的代码审查规范
2. 14\. **chinese-git-workflow（中文git工作流）** — 适配 Gitee/Coding/极狐 GitLab
3. 15\. **chinese-documentation（中文技术文档）** — 中文排版规范、中英混排、告别机翻味
4. 16\. **chinese-commit-conventions（中文提交规范）** — 适配国内团队的 commit message 规范
5. 17\. **mcp-builder（MCP服务器构建）** — 构建生产级MCP工具，扩展AI能力边界
6. 18\. **workflow-runner（工作流执行器）** — 在AI工具内运行多角色YAML工作流

还有两个元技能：

1. 19\. **writing-skills（编写skills）** — 创建新skill的方法论
2. 20\. **using-superpowers（使用superpowers）** — 如何调用和优先使用skills

---

## 3\. 工作流演示：AI现在怎么工作了

我拿一个具体场景演示一下。

假设我要"实现一个用户登录功能"。

**以前AI的做法：**

1. 2\. 写路由、写前端表单
2. 3\. 你发现没做密码加密，让它改
3. 4\. 它改了，又发现没做登录失败次数限制
4. 5\. 再改，又发现没做session过期处理……

这就是没有方法论的后果。

**装了 superpowers-zh 后，AI的工作流变成：**

**Step 1：brainstorming skill 自动激活**

AI先问你：

- • 登录方式：用户名+密码？手机号+验证码？第三方登录？
- • 密码加密方式：bcrypt？argon2？
- • 登录失败策略：几次锁定？锁定多久？

给3个方案让你选，你确认后生成设计文档。

**Step 2：writing-plans skill 激活**

把设计拆成实施计划：

- • 任务1：创建 User 模型，字段：username, password\_hash, login\_attempts, locked\_until
- • 任务2：实现密码加密（用 bcrypt），验证用 `test_password_hashing.py`
- • 任务3：实现登录逻辑，验证用 `test_login.py`
- • 任务4：实现失败次数限制，验证用 `test_login_rate_limit.py`

**Step 3：test-driven-development skill 激活**

每个任务都走 TDD：

```
先写测试：
def test_login_success():
    user = create_user("test", "password123")
    result = login("test", "password123")
    assert result.success == True

运行测试 → RED（失败）

再写代码：
def login(username, password):
    user = User.find_by_username(username)
    if verify_password(password, user.password_hash):
        return LoginResult(success=True)
    return LoginResult(success=False)

运行测试 → GREEN（通过）

重构代码（如果有需要）
```

**Step 4：verification-before-completion skill 激活**

AI声称"登录功能完成"前，必须运行：

- • 所有单元测试
- • 集成测试
- • 代码格式检查

看到"所有测试通过"的输出后，才能说完成了。

这就是有方法论的AI。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

---

## 4\. 与英文原版的区别：6个中国特色skill

superpowers 英文原版（obra/superpowers）有182k star，superpowers-zh 是它的中文增强版。

区别不只是翻译。

superpowers-zh 新增了6个面向中国开发者的skill：

**① chinese-git-workflow**

英文原版只适配 GitHub。

这个skill适配国内Git平台：

- • Gitee
- • Coding
- • 极狐 GitLab
- • CNB（腾讯云原生构建）

对应的CI/CD示例也有：

- • Gitee Go
- • Coding CI
- • 极狐 CI
- • `.cnb.yml`

**② chinese-code-review**

西方的代码审查风格偏直接："这个实现有问题，应该改成……"

国内团队文化偏委婉："这个想法挺好的，不过我在想如果这样的话会不会……"

这个skill让AI在审查代码时，用国内团队的沟通方式给反馈。

**③ chinese-documentation**

三个规范：

- • 中文排版规范（中英文之间加空格、标点使用）
- • 中英混排规则（技术术语保留英文）
- • 告别机翻味（不用"在当今……的时代""随着……的发展"）

**④ chinese-commit-conventions**

Conventional Commits 的中文适配：

- • feat: 新增用户登录功能
- • fix: 修复登录失败次数未重置的bug
- • docs: 更新API文档

自动生成 changelog。

**⑤ mcp-builder**

英文原版没有。

这个skill教你构建生产级MCP（Model Context Protocol）服务器，扩展AI能力边界。

比如你想让AI能读取公司内部文档、调用内部API，就需要MCP服务器。

**⑥ workflow-runner**

英文原版没有。

让你在AI工具内直接运行YAML工作流，实现多角色协作。

比如定义一个工作流：产品经理 → 架构师 → 开发 → 测试 → 交付。

丢一句需求进去，自动接力完成。

---

## 5\. 支持17款AI工具：一键安装

这是 superpowers-zh 另一个实用的地方。

**英文原版** ：每款工具分别装，每款一条不同的命令。

**superpowers-zh** ：一条命令自动识别。

```
cd /your/project
npx superpowers-zh
```

它会自动检测你项目里用的AI工具，把20个skill装到正确位置。

支持17款工具：

**CLI工具：**

- • Claude Code
- • Copilot CLI
- • Hermes Agent
- • Gemini CLI
- • Codex CLI
- • Aider
- • OpenCode
- • OpenClaw
- • Antigravity
- • Claw Code（Rust版）
- • Qwen Code（通义灵码）

**IDE工具：**

- • Cursor
- • Windsurf
- • Kiro
- • Trae
- • VS Code（Copilot插件）

**Agent框架：**

- • DeerFlow 2.0

识别不出来时，可以显式指定：

```
npx superpowers-zh --tool cursor
```

卸载也方便：

```
npx superpowers-zh --uninstall
```

会清理干净，不误删你自己写的内容。

---

## 6\. 实战建议：从哪个skill开始用

superpowers-zh 提供了20个skill，但不需要全用上。

我建议从这3个开始：

**① brainstorming**

这个skill最有价值。

让AI在写代码前先提问、先规划、先确认。

避免"写了一堆才发现方向错了"的浪费。

**② test-driven-development**

如果你团队有代码质量要求，这个skill能强制AI写测试。

不是"建议写测试"，是"不写测试代码不让运行"。

**③ verification-before-completion**

这个skill防止AI"嘴上说完成了，实际没验证"。

必须跑测试、跑lint，看到"全部通过"的输出才能声称完成。

---

## 7\. 一句话总结

superpowers-zh 做的事，是给AI编程工具装上 **工作方法论** 。

让AI从"你让它干啥它就干啥"的执行机器，变成会提问、会规划、会测试驱动开发的"靠谱工程师"。

这不是替代你的思考。

是让AI别再 **跳过思考直接动手** 。

---

## 🚀 加入我的AI学习圈子

💎 一顿饭钱，换一项终身技能

外面吃顿火锅要399，在这里——

你能获得改变未来的AI能力。

🔥 风行者AI全能班 | 第5期报名开启

历经4期打磨 · 300+视频 · 72+实战工具

课程内容大纲: https://fengxing.netlify.app/

📚 你将系统掌握：

🤖 WorkBuddy智能体开发

\- 从0搭建你的"贾维斯"AI助手

\- WorkBuddy小程序对接与自动化

\- 开发专属Skill，打造AI团队

💻 AI全栈编程实战

\- HTML落地页/Python脚本/Flutter App

\- 服务器部署+网络验证+支付对接

\- 20个变现应用源码全开源

✍️ 公众号自动运营系统

\- AI自动写文+生图+定时发布

\- 睡觉时也能持续产出内容

\- 代码+写作双杠杆变现

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

💰 投资自己，只需要一顿饭的代价

限时优惠：399元（原价899）

扫码加入，和300+学员一起

用AI构建你的被动收入管道👇

📱 扫码或打开链接报名，开启AI提效之旅

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

http://s.a0c.top/7CDXua9/GFQNM

━━━━━━━━━━━━━━

报名后联系方式：

微信：mkoijnn33

QQ：45561810

AI交流群：964202808（免费资料+工具）

精彩推荐

- [47K Star 的 Hermes Agent 爆火，但为什么我劝你用 WorkBuddy？](https://mp.weixin.qq.com/s?__biz=Mzk0ODMzNTk4OQ==&mid=2247487725&idx=1&sn=d06710a812bce3ff48e64c225274ddbb&scene=21#wechat_redirect)
- [我把AI住进了100个网页：PageAgent上手7天，效率提升5倍的秘密](https://mp.weixin.qq.com/s?__biz=Mzk0ODMzNTk4OQ==&mid=2247487613&idx=1&sn=6cca20c9683d53c77de5afb84e19d7d1&scene=21#wechat_redirect)
	[国内免费AI工具，让你的工作效率飞起来！](http://mp.weixin.qq.com/s?__biz=Mzk0ODMzNTk4OQ==&mid=2247484300&idx=1&sn=7a8331fb1b6383c7cd097a735ddd89ee&chksm=c3686796f41fee808e2ba436d9923d47b8c7583f0805ca9d8a3e5a384c23d2a1db81141152e7&scene=21#wechat_redirect)
	[我给5款AI编程工具配了同一个大脑，从此不用重复配置了](https://mp.weixin.qq.com/s?__biz=Mzk0ODMzNTk4OQ==&mid=2247487599&idx=1&sn=903229999af9b56d47539d81e8a2dd24&scene=21#wechat_redirect)
	[还在逐个平台刷选题？别人一条命令30秒扒完全网](https://mp.weixin.qq.com/s?__biz=Mzk0ODMzNTk4OQ==&mid=2247487553&idx=1&sn=f9433bf075d8f100056b44cbcdb6ae3c&scene=21#wechat_redirect)
- 你对今天分享的内容有什么想法？欢迎在留言区分享你的观点。
	原创不易，如果文章对你有帮助点赞 + 再看，谢谢。
	![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**微信扫一扫赞赏作者**

AI编程 · 目录

继续滑动看下一个

Auto编程

向上滑动看下一个