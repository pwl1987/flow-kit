---
title: "如何用CLAUDE.md把Claude Code调教成靠谱队友"
source: "https://mp.weixin.qq.com/s/gdPOEbomKRwWgdNYEFar0w"
author:
  - "[[印亚荣]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
印亚荣 *2026年3月18日 21:20*

回复“claude”或者“CLAUDE”就可以获得我整理的最终CLAUDE.md文件

> “
> 
> 让AI编程助手从"临时工"变成"老员工"，关键不在于它有多聪明，而在于你如何配置它。
> 
> ”

今天和大家分享一个使用Claude Code的人都无法避免的文件—— `CLAUDE.md` ，它是一个纯文本的Markdown文件，你可以在里面写下任何你希望Claude记住的规则、偏好和约定。每次Claude启动时都会自动读取这个文件，就像给它灌输了一套"工作守则"。不用学任何新语法，会写字就能配置。

![[_resources/如何用CLAUDE.md把Claude Code调教成靠谱队友/b3d4a8aa1384c53de63f844f3e4a4df6_MD5.webp]]

### 先搞懂：CLAUDE.md是什么？

简单说， `CLAUDE.md` 就是你写给AI的"员工手册"。Claude Code 支持 **三级配置** ，按优先级从低到高：

| 级别 | 存放位置 | 适用范围 | 典型用途 |
| --- | --- | --- | --- |
| **User（用户）** | `~/.claude/CLAUDE.md` | 你的所有项目 | 个人偏好、通用工作流 |
| **Project（项目）** | `./CLAUDE.md`  或 `./.claude/CLAUDE.md` | 团队共享（提交到 Git） | 技术栈、目录结构、团队规范 |
| **Local（本地）** | `./.claude/settings.local.json` | 仅你在此项目 | 个人覆盖、实验性配置（自动 gitignore） |

**三级配置如何协作？**

优先级： **Local > Project > User** （更具体的配置优先）

关键规则：

- 规则自动叠加，冲突时更具体的配置覆盖更通用的
- 数组类配置（如权限列表）会合并，而非替换

举个例子：

- User 规定"代码风格用4空格缩进"
- Project 规定"这个项目用2空格缩进"→ 覆盖 User

最终效果：当前项目用2空格缩进。

**设置方法** ：

User 级（全局配置）：

- Mac/Linux： `mkdir -p ~/.claude && nano ~/.claude/CLAUDE.md`
- Windows：在 `%USERPROFILE%\.claude\` 目录下创建

Project 级：

- 直接在项目根目录创建 `CLAUDE.md` 或 `.claude/CLAUDE.md` 文件即可
- 会随代码提交到 Git，团队成员共享
![Image](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### 一、上下文控制：防止AI"注意力涣散"

**技巧1：用@显式引用文件** 每次提需求时，用 `@filename.py` 或 `@src/classes/` 直接指定文件范围。注意： **@符号必须在输入指令之前** ，否则不生效。

**技巧3：超过3个文件就拆分** 如果一个任务需要改动超过3个文件，先停下来，把它拆成更小的子任务。大任务容易让AI"上下文爆炸"，产生幻觉。

针对这个让AI总结了关于这部分，如何编写CLAUDE.md文件：

> “
> 
> **Task Execution Protocol:**
> 
> - **Threshold:** Before modifying more than 3 files or implementing a complex feature, **MUST** run `/decompose` first.
> - **Workflow:** List the plan -> Wait for user `y` to confirm -> Execute sub-tasks one by one.
> - **Strict Rule:** No coding until the plan is approved.
> 
> ”

**技巧4：创建/decompose命令** 在CLAUDE.md里定义一个 `/decompose` 命令，让AI自动把大计划拆成可逐一执行的任务清单。

> “
> 
> `/decompose`: Before executing any complex task, analyze the requirements and break them down into a **Markdown checklist**. Each task must:
> 
> - Be atomic (affecting < 3 files).
> - Include a brief description of the implementation logic.
> - Be ordered by dependency.
> - **Wait for my approval** before starting the first item.
> 
> ”

**技巧7：用.claudeignore做硬隔离**

类似`.gitignore` ，把敏感文件、无关文件排除在AI的视野之外：

- 保护API密钥、密码等敏感数据
- 屏蔽 `node_modules` 、编译产物等大型目录
- 限制核心配置文件的修改权限

**软隔离vs硬隔离** 硬隔离（`.claudeignore` ）的问题是：屏蔽了图片，哪天你想让它批量转格式，它会报错找不到文件。软隔离（在CLAUDE.md里声明"除非@引用，否则不主动访问"）更灵活：平时不碰，需要时用@显式引用即可。

### 二、持久记忆：让AI"像老员工一样工作"

**技巧2：先方案后动手** 在CLAUDE.md里写明：写任何代码前，必须先描述完整方案并等待人工批准。需求模糊时，主动提问而不是瞎猜。

> “
> 
> - **The Approval Rule:** Before writing, modifying, or deleting any code, you **MUST** present a detailed implementation plan.
> - **Content of the Plan:** 1. **Objective:** What problem are we solving? 2. **Proposed Changes:** List specific files and the logic to be updated. 3. **Potential Risks:** Mention any breaking changes or edge cases.
> - **The Wait Command:** After presenting the plan, stop and wait for my explicit confirmation (e.g., "y", "go", or "proceed"). **Strictly no coding until approved.**
> 
> ”

**技巧5：写清楚项目规范** 把技术栈、文件夹结构、编码规范、要避免的反模式全部写进CLAUDE.md。AI每次启动都会读取，相当于给它做了"入职培训"。

**技巧12：错了先问，别急着改** 配置一条规则：当我说"错了"时，先提问澄清问题所在，而不是直接重写。这能避免AI在错误方向上越走越远。

**技巧16：每次纠错都更新规则** 每次你纠正AI的错误，就让它在CLAUDE.md里新增一条规则。这样同样的错误永远不会犯第二次——AI真的能"长记性"。

### 三、测试驱动：把TDD思维植入AI

**技巧8：先写测试再修Bug** 遇到Bug时，要求AI先写一个能复现问题的测试用例，再修复代码直到测试通过。这能确保修复是真正有效的。

**技巧9：主动预判问题** 让AI写完代码后，主动列出可能出问题的场景，并建议相应的测试用例。把质量意识内化到AI的工作流程里。

### 四、工作流自动化：把AI变成"团队"

**技巧6：用/memory保存个人偏好** 跨项目持久的偏好（比如你喜欢的代码风格、常用的工具链）用 `/memory` 命令保存，避免每次都重复说明。

**技巧10、11：创建专用命令**

- `/review-xyz` ：专门检查代码正确性、边界情况、与现有代码的一致性
- `/test` ：调用Sub-Agent自动运行测试套件

**技巧17：把成功的Prompt转为命令** 任何用得顺手的Prompt，都值得转成slash命令或Skill。复用才是效率的来源。

**技巧18：用Sub-Agent隔离大任务** 重复性高、上下文占用大的任务，创建专用Sub-Agent来处理。这样不会污染主上下文，AI能保持"头脑清醒"。

### 五、安全迭代：平衡速度与风险

**技巧13：/rewind回滚变更** 改错了？用 `/rewind` 命令回滚，然后给出更精准的反馈重试。

**技巧14：Git worktrees并行开发** 利用Git worktrees，可以在不同目录并行运行多个Agent会话，任务之间互不干扰。

**技巧15：一次性环境快速迭代** 在可恢复的一次性环境里，用 `claude --dangerously-skip-permissions` 跳过权限确认，快速迭代原型。

---

**写在最后**

这18条技巧的核心思想其实就一句话： **把AI当成新员工来管理** 。

你不会指望一个新人第一天就知道所有规矩，但你会给他一份员工手册，告诉他什么能做、什么不能做、遇到问题先问谁。

CLAUDE.md就是这份手册。写得越清楚，AI就越像个"靠谱队友"。

回复“claude”或者“CLAUDE”就可以获得我整理的最终CLAUDE.md文件，将其放在自己对应的文件夹下面就可以了。

~ End ~

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**微信扫一扫赞赏作者**

AI · 目录

继续滑动看下一个

印亚荣

向上滑动看下一个