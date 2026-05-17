---
title: "被安装43万次的“自我进化”skill，为什么在你的Agent身上毫无作用？"
source: "https://mp.weixin.qq.com/s/WL7aQMT09glrSsDTA7qQ2g"
author:
  - "[[数字莫伊拉]]"
published:
created: 2026-05-15
description: "我见过最让人沉默的数据，来自 ClawHub，被标榜为“让AI从错误中学习”的自我进化引擎，下载量超过43万次"
tags:
  - "clippings"
---
数字莫伊拉 *2026年5月12日 21:39*

我见过最让人沉默的数据，来自 ClawHub，

被标榜为“让AI从错误中学习”的自我进化引擎，下载量超过43万次，几乎每个玩OpenClaw的人都装过的skill：self-improving-agent。

评论区最有效的回复是：“没啥用”“嘴巴级”“还是笨”

![[_resources/被安装43万次的“自我进化”skill，为什么在你的Agent身上毫无作用？/2b5276a7a1ba4b9c8c9476405e2f14b9_MD5.webp]]

我挨个翻了十几个博文和社区帖子，得出一个粗略但诚实的估算：真正把这套技能跑通、形成完整进化闭环的用户，可能不到三成。

这不是技能质量的问题。self-improving-agent 的 SKILL.md 我认真读过，设计堪称教科书级别。

设计逻辑简单清晰：每次犯错、纠正、发现，都是一次学习机会，在发生的那一刻捕捉下来，沉淀成可检索的结构，让未来的自己不再犯同样的错误，还定期抽象高频规则Skill化。

问题在于，绝大多数人——包括最初的我——都把它当成“安装即用”的插件，或者有稍微好一点的，加了Hook，但作用同样微乎其微，而真正需要的是一套需要打通五个断裂点的微型工程。

我刚装完时也属于沉默的大多数。Hook显示✓ready，.learnings/ 目录三个文件整整齐齐。理论上，每次bootstrap都会收到学习提醒，每次犯错都会被记录，每次教训都会沉淀。

但实际上？.learnings/是空的。整整三个月。

直到我决定认真复盘这个问题，才发现：Hook开着 ≠ 学习在发生。文件存在 ≠ 内容在积累。很多人装了，真的只是装上了，学习闭环从未建立。问题不是技能不行，而是断了太多我们忽略的节点。

## 一、五个断裂点，你的Agent至少踩中了三个

我花了两个晚上，把“安装”到“真正生效”之间所有断裂点梳理了出来。如果你是那七成用户，大概率至少踩中了其中三个。

- 断裂点1：Hook提醒是“软”的，Agent忙完就忘了。Hook启动时会提醒“做完任务后评估是否有可提炼的知识”，但提醒只是提醒。Agent在忙完后如果不被明确要求“现在写入.learnings/”，它大概率不会主动做。我检查了安装第一周的所有会话日志——提醒每次都出现，但没有一次转化为实际写入。
- 断裂点2：纠正发生了，但没被记录下来。我告诉Agent“项目用pnpm，不是npm”，它回了一句“好的记住了”，继续生成下一个回复。后来去查LEARNINGS.md——什么也没写。如果没刻意用WAL协议去捕获这条修正，它就跟着上下文一起蒸发了。
- 断裂点3：错误记在了日记里，但没记在“错题本”里。Docker build失败当晚被复盘Cron写进了每日日志，但ERRORS.md里什么都没多。每日日志记录的是“发生过什么”，.learnings/记录的是“要学会什么”。前者做到了，后者断了。
- 断裂点4：Recurrence-Count永远停在1。因为上面三个断裂点，同一个错误每次都被当作新的“第一次”。我cron edit的--id参数问题遇到过四次，但Recurrence-Count始终积累不起来。VFM评分永远没机会触发，规则提升就更别提了。
- 断裂点5：Promote到底写去哪，Agent自己不知道。即便Recurrence-Count到了3、VFM通过了，Agent依然面临最后一个岔路口：该写入SOUL.md、AGENTS.md还是TOOLS.md？SKILL.md里有分类规则，但没有映射表。Agent需要被明确告知：行为准则→SOUL.md，工作流规则→AGENTS.md，工具坑点→TOOLS.md。

这五个断裂点连在一起，形成了典型的“假闭环”——所有环节的文件都在，但一个都没真正接通。

## 二、我的完整闭环是怎么搭起来的

以下是我实际操作的复盘，不是网上抄的配置。基于OpenClaw平台，self-improving-agent 3.0.21 + Proactive-Agent 3.1.0。

## 3.1 第一步：修正状态元数据

装完self-improving-agent后，检查Hook状态：

```ruby
$ openclaw hooks list | grep self-improvement✓ ready  │ 🧠 self-improvement  │ Injects self-improvement reminder during agent bootstrap
```

Hook是好的。但SESSION-STATE.md里写的是：

```objectivec
| self-improving-agent | 3.0.21 | ❌ 未启用 |
```

这不对。Hook显示ready，但状态文件说未启用。这种不一致会误导后续所有判断——Agent自己都认为技能没启用，怎么可能自动执行写入？

我修正为：

```objectivec
| self-improving-agent | 3.0.21 | ✅ 已启用（Hook）| Hook 状态: ✓ ready，bootstrap 时注入 reminder |
```

接着在AGENTS.md中建立硬触发规则，直接对标六大学习场景：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

这几条遵循了WAL协议的原则：先写入，再回复。不是“建议”，是“硬约束”。我在测试中故意说“不对，应该是用pnpm”，然后立即查看LEARNINGS.md——文件末尾已多了一条LRN条目，时间戳在我收到回复之前。

教训：安装完要检查实际状态，别只看Hook列表。状态不一致是第一个沉默的元凶。

## 3.2 第二步：增强heartbeat-state.json

heartbeat-state.json是Proactive-Agent的状态追踪文件。原来只有lastChecks下的null值，我需要让它也能追踪self-improving-agent的学习情况。

在文件中增加了三个关键字段：

```json
{  "lastLearningsReview": "2026-05-12T08:24:00+08:00",  "pendingLearningsCount": 1,  "promotedLearningsCount": 0,  "learningsStatus": {    "LEARNINGS.md": { "total": 2, "pending": 1, "resolved": 1, "recurring": 0 },    "ERRORS.md": { "total": 1, "pending": 0, "resolved": 1, "recurring": 0 },    "FEATURE_REQUESTS.md": { "total": 1, "pending": 1, "resolved": 0, "recurring": 0 }  }}
```

教训：两个系统要协同，必须共享状态文件。否则你根本不知道学习积累到什么程度。这是微观引擎和宏观引擎之间的唯一桥梁。

## 3.3 第三步：让Cron能读.learnings/

这是最关键的一步，也是90%的人没做的一步。

Proactive-Agent有每日复盘Cron（23:00），但它的步骤里没有读取.learnings/的逻辑。这意味着微观引擎产出再多，也不会有任何提炼。我修改Cron prompt，增加了11个步骤，以下是完整流程：

```diff
步骤1: 读取所有源文件- memory/ 今天和昨天的日志- notes/areas/ 下三个文件- SESSION-STATE.md 知识出口区块- heartbeat-state.json步骤2: 提炼洞察- 识别今天的重要决策和事件- 将每个教训提炼成一行Lesson（格式：当 [条件] 时，执行 [动作]）步骤3: 写入 memory/YYYY-MM-DD.md步骤4: 更新 notes/areas/recurring-patterns.md- 如果发现新模式 → 追加新条目，Recurrence-Count = 1- 如果匹配已有模式 → Recurrence-Count +1步骤5: 更新 notes/areas/outcome-journal.md步骤6: 更新 notes/areas/proactive-tracker.md步骤7: 更新 SESSION-STATE.md pending-actions步骤8: 提炼长期洞察 → 更新 MEMORY.md步骤9: 读取 .learnings/ 三文件- 统计 pending 条目（按 priority）- 识别 Recurrence-Count >= 3 的条目步骤10: 处理 pending learnings- High/Critical → 评估是否 promote- Recurrence >= 3 → 执行 VFM 评分- 评分 >= 50 → promote 到 SOUL/AGENTS/TOOLS步骤11: 更新 .learnings/ 条目状态- resolved → 添加 Resolution block- promoted → 更新 Status + Promoted 字段- 更新 heartbeat-state.json- 有 high/critical pending 或新 promote → 通知用户
```

同时，Proactive-Agent的Heartbeat每4小时执行轻量检查：扫描超过7天未处理的pending条目，发现即通知。

教训：Cron不会自动读.learnings/，必须显式配置。这就是微观引擎和宏观引擎之间的齿轮——不装上它，两个引擎永远各跑各的。

## 3.4 第四步：给.learnings/文件注入“活”模板，建立写入触发

很多人认为创建了文件就万事大吉，但空模板等于不存在。我给每个文件补充了最小示例，让Agent看到一条真实记录长什么样，解决“空白页恐惧症”。

同时改造原来的Hook提醒——原来只是一段英文提示“做完任务后，评估是否有可提炼的知识”。我把它改写成条件判断流：

```markdown
任务收尾检查：1. 刚才的任务中是否出现了命令执行失败？2. 用户是否纠正了我的某个行为或输出？3. 我是否发现了某个非显而易见的解决方案？如果任一答案为“是”，立即：  a. 确定 category 和 target 文件  b. 按标准格式写入 .learnings/  c. 更新 Metadata 中的 Recurrence-Count（如果为重复模式）  d. 完成后，再结束当前任务。
```

这不是“你考虑一下”，而是“如果X，就做Y”。Agent最需要的就是这种明确。

## 3.5 第五步：配置月度人工复盘

除了每日Cron，我设置了每月最后周五执行人工复盘——catch Cron无法处理的情况：

```markdown
每月最后周五：1. 检查 .learnings/ 是否有 Recurrence >= 2 但 < 3 的条目2. 检查是否有 high/critical status=pending 超过 14 天的3. 检查用户是否表达“这个经常用到”的反馈4. 人工判断：此 skill 能否在未来节省超过 30 分钟调试时间？5. 如满足 → 手动 promote 或创建独立 skill
```

这个机制catch了低频但高价值的模式、用户反馈驱动的临时需求、跨时间段的趋势判断——这些是纯自动化无法处理的灰度区域。

## 三、触发机制：什么时候应该记录？

这是闭环的起点。没有触发，就没有写入；没有写入，闭环就是空转。

## 4.1 六大触发场景

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

## 4.2 核心原则：立即写入，不等待

触发后做的第一件事，不是回应用户，是写入。

```css
检测到触发条件 → 【STOP】不要立即响应 → 写入 .learnings/ → 【THEN】响应用户
```

为什么？因为context最鲜活的时候就是事件发生那一刻。事后补写，细节会丢失。

## 4.3 两个真实案例

案例一：命令失败

```bash
$ openclaw cron edit --id 0b45fdb1... --message "..."error: unknown option '--id'
```

立即写入：

```bash
[ERR-20260512-001] cron-edit-idLogged: 2026-05-12T07:45:00+08:00Priority: medium | Status: resolved | Area: infra### Summaryopenclaw cron edit 不支持 --id 参数，job id 是 positional argument### Errorerror: unknown option '--id'### Context正确语法：openclaw cron edit &lt;<span class="code-snippet__built_in">id</span>&gt; --message&nbsp;<span class="code-snippet__string">"..."</span>
```

案例二：用户纠正

用户说：“不对，项目用的是pnpm，不是npm。”

立即写入：

```markdown
[LRN-20260512-XXX] correctionLogged: 2026-05-12TXX:XX:00+08:00Priority: high | Status: pending | Area: config### Summary项目使用 pnpm，不是 npm### Details用户纠正：项目使用 pnpm workspaces，lock 文件是 pnpm-lock.yaml### Suggested Action在项目根目录使用 pnpm install，不要使用 npm install### Metadata- Source: user_feedback- Pattern-Key: self-improving.pnpm-not-npm- Recurrence-Count: 1
```

每个条目都有唯一ID：TYPE-YYYYMMDD-XXX。标准结构包含Logged时间戳、Priority、Status、Area、Summary、Details、Suggested Action、Metadata。关键字段：Recurrence-Count、Pattern-Key、See Also，用于自动去重和关联。

## 五、一条Docker错误的进化之路

说一个真实的例子。M3 MacBook上跑老项目，docker build报错：no match for platform linux/arm64.

命令失败那一刻，Agent在回复我之前，先在ERRORS.md追加了一条记录，Pattern-Key为infra.docker\_build\_apple\_silicon，Recurrence-Count标为1。我纠正它：“加--platform linux/amd64。”它再次停下手里的回复，更新Recurrence-Count为2，并写入具体命令。两天后另一个项目再次遇到——Recurrence-Count达到3。

当晚23点，Cron扫描到这条记录，执行VFM评分：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

总分44，差6分，按阈值不会提升。但我人工复核时判断，它在Apple Silicon场景中确实高频高风险——换一台M系列机器、换一个老项目几乎必现。于是把高频度调至满分，最终得分50，刚好过线。

这件事提醒我：VFM评分不是一锤子买卖，对infra类型错误需要偏向性加权。我给Cron增加了一条注释规则：infra错误，高频度和失败减少各上浮1分。

最终，这条教训被浓缩为TOOLS.md中的一条规则：

```markdown
### Docker Build on Apple Silicon- 任何Apple Silicon上执行的 \`docker build\`，自动追加 \`--platform linux/amd64\`- 来源：ERR-20260512-001，Promoted: 2026-05-12
```

下一次，不管在哪个项目里跑docker build，Agent都会在启动时加载这条规则，自动加上正确的参数。我一句话都没再说。

这就是真正的进化闭环——不是“记住了”，是行为被永久改变了。第一个场景，AI说“记住了”但没有变成行为；第二个场景，AI把教训变成了规则，规则影响了行为。

## 六、为什么70%的人装了就废

回到43万次安装、不足三成生效的数据。我把自己踩过的坑和社区反馈对照后，总结出四个核心原因：

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

核心问题一句话：安装 ≠ 使用，使用 ≠ 闭环。

self-improving-agent不是一个安装包，而是一套需要被亲手装配的进化框架。它的设计者把零件全部给了——Hook、日志格式、VFM模型、状态流转——但组装说明书需要你自己写。

## 七、完整检查清单

1. Hook显示 ✓ ready，且SESSION-STATE.md中状态标记为“已启用”
2. heartbeat-state.json包含learnings统计字段
3. 每日Cron包含步骤9-13（读取.learnings/ + VFM + 提升 + 回写）
4. AGENTS.md中有触发规则索引（什么场景→写入哪个文件）
5. .learnings/三个文件中有真实条目（非测试数据，非空模板）
6. 至少有一条条目的Recurrence-Count ≥ 2
7. 月度人工复盘已配置（每月最后周五）

全绿了，你的Agent才真正拥有了从错误中进化的能力。

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

别让它成为43万次安装里沉默的大多数。给它装上腿，让它自己走完进化的每一段路。

\------

感谢阅读

真实经历，真诚分享

关注我，一个只分享 AI 实战记录的人类

**微信扫一扫赞赏作者**

openclaw实战记录 · 目录

继续滑动看下一个

数字莫伊拉

向上滑动看下一个