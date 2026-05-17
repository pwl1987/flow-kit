---
title: "一人一城：gstack+Superpowers"
source: "https://mp.weixin.qq.com/s/-nTmRGikXBhC6pHGHB2Z_Q"
author:
  - "[[被测试耽误的大厨]]"
published:
created: 2026-05-15
description: "“我在过去60天里，写了60万+行生产代码（35%为测试用例），日均1-2万行，而且是在全职管理Y Comb"
tags:
  - "clippings"
---
被测试耽误的大厨 *2026年3月30日 09:30*

“我在过去60天里，写了60万+行生产代码（35%为测试用例），日均1-2万行，而且是在全职管理Y Combinator的兼职状态下完成的。”  
——YC总裁&CEO Garry Tan，2026年开源gstack时的自述

很多用过Claude Code的开发者，都踩过同一个天坑：写个单文件脚本、改几行代码它神乎其神，但一旦做前后端完整项目、带数据库的生产级应用，它写着写着就“飞了”——上下文全丢、忽略已有代码、凭空捏造不存在的API、改了A模块崩了B功能，上线就出生产事故。

本质问题根本不是AI不够聪明，而是你只给了它一个空白聊天框，却没给它一套工程团队的纪律、角色分工和标准化流程。AI不是只会打字的码农，它能当你的CEO、架构师、设计师、QA、安全专家、运维，甚至是一整个完整的研发团队。

今天这篇纯实战指南，不讲废话，全是可复制的操作步骤，手把手教你用2026年开发者圈爆火的两套Claude Code工作流神器：

- • **gstack** ：YC总裁Garry Tan开源的「虚拟工程团队」，把完整敏捷研发流程拆成了一行行斜杠命令，单人就能跑出20人团队的产能
- • **Superpowers** ：专治AI写代码“瞎发散”的「TDD执行包工头」，用强制测试驱动开发锁死代码质量，杜绝AI乱写

我会修正全网流传的错误安装步骤、可直接复制的联合使用SOP、国内用户专属的网络&成本避坑方案，看完就能照着操作，把Claude Code从“代码聊天机器人”变成你的专属研发团队。

## gstack：把Claude Code变成完整工程团队，先纠正90%人都踩的安装错误

gstack不是零散的提示词合集，而是一套完整的软件工程工厂。它把20个专业研发角色+8个效率工具，封装成了28个开箱即用的斜杠命令，完整覆盖敏捷开发的全流程： **Think→Plan→Build→Review→Test→Ship→Reflect** ，每个环节的输出自动流入下一个环节，从根源上杜绝AI“写飞了”的问题。

### 【官方标准安装步骤】解决装完用不了的核心问题

全网流传的安装教程90%都缺了最关键的CLAUDE.md配置，这也是你装完后Claude识别不到命令、技能不生效的核心原因。以下步骤完全对齐官方开源文档，可直接复制执行。

#### 前置依赖

- • 必装：Claude Code、Git、Bun v1.0+
- • Windows用户额外需安装Node.js（Bun在Windows上存在Playwright管道传输已知bug，需Node.js做兜底兼容）

#### 全局安装（所有项目通用，推荐新手首选）

打开Claude Code终端，直接粘贴以下命令，Claude会自动完成安装：

```
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack && cd ~/.claude/skills/gstack && ./setup
```

#### 核心必做——配置CLAUDE.md（不做=装了白装）

在你的项目根目录新建/编辑 `CLAUDE.md` 文件，添加以下gstack专属配置，Claude才能正确识别并调用所有技能：

```
## gstack
Use /browse from gstack for all web browsing. Never use mcp__claude-in-chrome__* tools.
Available skills: /office-hours, /plan-ceo-review, /plan-eng-review, /plan-design-review,
/design-consultation, /review, /ship, /land-and-deploy, /canary, /benchmark, /browse,
/qa, /qa-only, /design-review, /setup-browser-cookies, /setup-deploy, /retro,
/investigate, /document-release, /codex, /cso, /autoplan, /careful, /freeze, /guard,
/unfreeze, /gstack-upgrade.
If gstack skills aren't working, run \`cd .claude/skills/gstack && ./setup\` to build the binary and register skills.
```

#### 项目内安装（团队协作专用，可选）

如果需要团队成员克隆仓库后直接使用gstack，无需每个人单独安装，执行以下命令即可把gstack打入项目仓库：

```
cp -Rf ~/.claude/skills/gstack .claude/skills/gstack && rm -rf .claude/skills/gstack/.git && cd .claude/skills/gstack && ./setup
```

> 补充：gstack完全免费，采用MIT开源协议，无付费版、无waitlist，同时兼容Codex、Gemini CLI、Cursor等支持SKILL.md标准的AI代理工具。

### 【新手必学5个核心实战命令】看完就能用，直接落地

gstack有28个技能，新手不用全学，先掌握这5个核心命令，就能覆盖80%的开发场景，立刻感受到产能提升。

| 命令 | 对应角色 | 实战使用场景 | 核心效果 | 新手避坑 |
| --- | --- | --- | --- | --- |
| `/office-hours` | YC创业导师 | 所有项目的第一步，需求脑暴阶段 | 不顺着你的功能需求走，而是通过6个强制问题戳中真实痛点，推翻伪需求，自动生成可落地的设计文档，直接流入后续所有环节 | 不要上来就让AI写代码，先跑这个命令，从根源上避免做无用功 |
| `/plan-ceo-review` | 公司CEO/创始人 | 需求确认阶段，写代码前必跑 | 从商业价值、用户留存、开发成本等10个维度做完整评审，直接砍掉无意义的炫技功能、无效需求，从源头节省API成本和开发时间 | 不要怕AI怼你的需求，它帮你避开90%的无效开发 |
| `/plan-eng-review` | 研发经理/架构师 | 技术方案设计阶段 | 用ASCII图画出完整数据流、状态机、异常处理路径，明确测试矩阵、安全风险，把所有隐藏的技术坑提前挖出来，锁死接口契约和数据结构 | 必须等这个命令跑完、方案确认后再写代码，否则AI一定会写飞 |
| `/qa` | QA测试负责人 | 代码开发完成后，上线前验收 | 这是gstack的杀手锏。它会启动真实Chromium浏览器，自动点击页面、走通完整业务流程、填表单、复现bug，甚至自动修复问题并生成回归测试用例 |  |
| `/ship` | 发布工程师 | 最终上线阶段 | 自动同步主干代码、跑全量测试、审计测试覆盖率、推送代码、创建PR，甚至会自动给没有测试框架的项目初始化测试框架 | 它会自动调用 `/document-release` 更新所有项目文档，再也不会出现README和代码不同步的问题 |

### 【新手保命必备】2个安全命令，杜绝AI搞崩项目

- • `/careful` ：开启安全护栏，AI执行 `rm -rf` 、 `DROP TABLE` 、 `git force-push` 等危险命令前，会强制弹出警告，新手一定要默认开启
- • `/freeze [目录]` ：锁定编辑范围，AI只能修改指定目录的文件，避免调试时AI乱改其他模块的代码，导致项目直接崩掉

## Superpowers：专治AI瞎发散的TDD执行包工头

如果说gstack是管方向、管流程的研发总监，那Superpowers就是抓执行、抓代码质量的一线包工头。它的核心逻辑是 **强制TDD测试驱动开发** ：不写测试不准写代码，测试不通过不准进入下一步，从根源上杜绝AI写代码“发散跑偏”。

### 标准安装方式

在Claude Code终端中，通过官方插件市场直接安装：

```
/plugin install superpowers@claude-plugins-official
```

安装完成后重启Claude Code，即可自动激活。

### 核心实战3步工作流，完美衔接gstack的设计方案

日常开发中，不要再对AI说“帮我写个登录页面”，按照以下步骤执行，AI写的代码再也不会跑偏：

#### 第一步：基于gstack的设计文档，生成微任务清单

```
/superpowers:write-plan
```

> 核心效果：AI会直接读取gstack生成的设计文档、架构方案，把完整需求拆解成几十个 **2-5分钟就能完成的微小任务** ，每个任务都严格遵循TDD规范，先写测试，再写代码。  
> 示例任务清单：
> 
> - •步骤1：在 tests/auth.test.ts 编写空邮箱格式报错的测试用例
> - •步骤2：运行测试，确认测试预期失败
> - •步骤3：在 src/auth.ts 编写最少代码让测试通过
> - •步骤4：代码规范检查，Commit提交

#### 第二步：多线程并发执行，双Review锁死质量

```
/superpowers:execute-plan
```

> 核心效果：主进程不会亲自写代码，而是给每个微任务派发一个\*\*独立的子代理（Subagent）\*\*并发执行。每个子代理写完代码后，会强制触发「代码规范审查+代码质量审查」双评审，全绿灯才会进入下一步，你只需要等着看结果就行。

#### 第三步：需求脑暴与边界场景梳理（可选）

```
/superpowers:brainstorm
```

> 核心效果：AI会以高级工程师的视角，反问你需求的边缘场景，比如做文件上传功能，它会问你大文件断点续传方案、文件格式限制、并发上传控制等问题，补全需求的所有细节。

## 终极联合打法：两大神器组合SOP，从需求到上线全流程保姆级教程

在真实的高强度开发中，最有效的方式是把gstack和Superpowers串联起来，形成「定方向→锁方案→写代码→做验收→上生产」的完整闭环。以下是可直接复制的标准操作流程，哪怕是单人开发，也能跑出专业团队的规范和效率。

### 需求对齐与方案锁死（gstack全程把控，杜绝伪需求）

新需求进来，绝对不要先写代码，先跑gstack的完整方案评审：

- • 执行 `/office-hours` ，让AI帮你拆解真实痛点，生成完整设计文档
- • 执行 `/plan-ceo-review` ，从商业和产品视角砍掉无效需求，锁定最小可行版本
- • 执行 `/plan-eng-review` ，锁死技术架构、数据流、接口契约，输出完整技术方案
- • 执行 `/plan-design-review` ，完成UI/UX设计评审，锁定产品交互细节

> 这一步的核心是： **所有方案全部文档化，后续所有开发严格对齐文档，从根源上避免AI写飞** 。

### 代码批量执行（Superpowers并发干活，保证质量）

方案确认后，交给Superpowers做批量落地：

- • 执行 `/superpowers:write-plan` ，基于gstack的方案文档，生成TDD微任务执行清单
- • 执行 `/superpowers:execute-plan` ，启动子代理并发执行任务，双Review把关代码质量
- • 执行过程中遇到复杂bug，用gstack的 `/investigate` 命令做系统性根因定位，修复后自动生成回归测试

### 全流程验收与安全审计（gstack专业角色兜底）

代码全部开发完成后，用gstack做上线前的完整验收：

- • 执行 `/review` ，让资深工程师做代码评审，自动修复简单bug，标记高风险问题
- • 执行 `/cso` ，让安全专家做OWASP Top 10+STRIDE威胁建模审计，杜绝安全漏洞
- • 执行 `/qa` ，启动真实浏览器做全流程端到端测试，自动修复发现的问题
- • 执行 `/benchmark` ，做性能基准测试，对比优化前后的页面加载、核心网页指标变化

### 一键上线与生产验证（gstack全自动化完成）

验收通过后，不用手动操作，一行命令完成上线全流程：

- • 执行 `/ship` ，自动跑全量测试、审计覆盖率、创建PR
- • PR审批通过后，执行 `/land-and-deploy` ，自动合并代码、等待CI/CD完成、验证生产环境可用性
- • 执行 `/canary` ，启动线上灰度监控，实时捕捉控制台报错、性能回退、页面故障
- • 最后执行 `/retro` ，自动生成项目复盘报告，统计代码产出、提交记录、测试覆盖率变化，做项目迭代优化

## 国内用户专属避坑指南：解决网络报错&API成本难题

工具再好，连不上网、API账单太贵也是白搭。这里针对国内开发者最头疼的两个问题，给出可直接落地的解决方案，同时解决你遇到的两个核心报错。

### 网络配置：彻底解决「invalid link」「403 Forbidden」报错

#### 核心报错1：127.0.0.1:7890 提示「invalid link」

**根本原因** ：Claude Code不会自动继承系统代理，很多人只配置了HTTP\_PROXY/HTTPS\_PROXY，却没配置NO\_PROXY白名单，导致gstack本地浏览器自动化服务、Claude Code的本地进程通讯流量被代理转发，无法建立本地连接，直接报错。

**正确可复制的代理配置方案** ：  
打开你的终端配置文件（.zshrc/.bash\_profile/.bashrc），粘贴以下配置（代理端口按你的实际情况修改）：

```
# 代理配置
export HTTPS_PROXY=http://127.0.0.1:7890
export HTTP_PROXY=http://127.0.0.1:7890
export ALL_PROXY=socks5://127.0.0.1:7890
# 【关键必填】本地流量白名单，少了一定会出现invalid link报错
export NO_PROXY="localhost,127.0.0.1,::1,.local,.internal"
```

配置完成后，执行 `source ~/.zshrc` （对应你的配置文件）生效，重启Claude Code，确保旧的环境变量缓存被清除。

#### 更稳妥的企业级方案：API中继网关

频繁切换IP极易导致Anthropic账号被封禁，实战中更推荐使用合规的API中继网关。  
**核心报错 https://api.your\_gateway.com 提示「link fetch error」**  
**根本原因&排查方案** ：

- • 网关地址填写错误，或中继服务不可用：先执行curl命令测试网关连通性，确认地址正确
- • API密钥无效或无对应权限：确认密钥不是只读密钥，拥有完整的API调用权限
- • 中继服务不兼容Claude Code：确认中继完整兼容Anthropic的所有API接口，尤其是工具调用、流式传输能力（Claude Code强依赖这两个能力）

**正确的网关配置方案** ：  
在终端配置文件中添加以下内容：

```
export ANTHROPIC_API_KEY=你的中继网关密钥
export ANTHROPIC_BASE_URL=你的中继网关完整地址
```

### API成本砍掉90%的实战绝招

像Superpowers这种动辄启动几十个子代理做反复评审的玩法，用Claude 3.5 Opus跑一天就能烧掉几十美金，这里给你两套实战省钱方案：

#### 方案：源头节流（最有效）

用gstack的 `/plan-ceo-review` 砍掉所有无效需求、无意义的功能迭代，从根源上减少token消耗。Garry Tan本人就是靠这个方法，把60万行代码的需求压缩到了最小可行版本，避免了海量无效开发。

#### 方案：国内中转

**https://www.gmini.xyz** 懂的都懂

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

## 五、新手5分钟快速上手路径

不用先学完所有命令，今天就能照着这5步，立刻感受到AI工程化的威力：

1. 1\. 按照本文的官方步骤，完成gstack的安装和CLAUDE.md配置
2. 2\. 打开Claude Code，输入你想做的项目需求，比如“我想做一个个人日历每日简报APP”
3. 3\. 执行 `/office-hours` ，让AI帮你拆解需求，生成完整设计文档
4. 4\. 执行 `/plan-ceo-review` ，把关需求范围，锁定最小可行版本
5. 5\. 如果你已有开发好的页面，直接执行 `/qa 你的页面地址` ，亲眼看着AI帮你做完整的自动化测试

## 结尾

AI时代的开发者，拼的不再是你能手写多少行代码，而是你能不能用好AI工具，搭建一套属于自己的工程化流程。

gstack给你完整的团队角色和标准化研发流程，Superpowers给你严格的代码执行纪律，再配好国内专属的网络和成本方案，你一个人，真的能顶得上一个20人的专业研发团队。

别再把Claude Code当聊天框用了，今天就照着这篇指南装起来，跑一遍完整流程，感受一下AI工程化的真正威力。

**欢迎大家在留言区沟通交流~~~**

**微信扫一扫赞赏作者**

Claude Code · 目录

继续滑动看下一个

全栈测试开发之路

向上滑动看下一个