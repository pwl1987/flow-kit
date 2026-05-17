原创 飞哥 *2026年4月10日 09:20*

> 不是教程的教程。把我最近三个月摸出来的最顺手的 Claude Code 配置一次说完：安装、配置、功能、场景、cheatsheet，全都可以直接抄。

![[_resources/实战篇 Claude Code + superpowers + gstack 开发流程实录，可直接复制使用，一篇文章讲清楚！/30738e6663f41d8f87843289ad64f4d6_MD5.webp]]

两个插件的威力

---

## 0\. 先讲个故事

三个月前，我的 Claude Code 装了 34 个插件。

每次启动都要等 skill 注册几秒钟，对话里写一句"帮我做个计划"，有时候触发 superpowers 的 writing-plans，有时候触发 feature-dev 的 same name skill，有时候触发 oh-my-claudecode 里的 planner agent。同一个 prompt 三次行为三种结果，任务中途经常漂移。

代码审查更夸张。三个插件都注册了 `code-review` ，你根本不知道跑的是谁的，输出风格也完全不一样。有一次我连续调了五次，每次 Claude 的审查视角都不同——有的挑风格，有的看安全，有的盯架构——拼起来像是五个不同的人在看代码，但没一个是系统化的。

最痛的那次是修一个生产 bug。我用 `debugger` agent 排查，agent 告诉我根因在 A，我改 A，没修好。换 `debugger` 再跑一次——居然说根因在 B，不一样的结论。我愣了一下才反应过来：第二次匹配到的是另一个 debugger skill，不是同一个。

那天晚上我把所有插件列出来数了数：

- ●34 个插件里有 11 组功能重叠
- ●4 个 plan 写作 skill
- ●3 个 code review skill
- ●2 个 debugger
- ●2 个 frontend-design
- ●还有若干个 planner / analyst / executor agent

问题不是我贪多——是 **没有人告诉我应该装什么、不应该装什么** 。每个插件都说自己能干这干那，合起来就成了一锅粥。

那天晚上我把 30 个插件全删了。只留下两个： **superpowers** 和 **gstack** 。

结果就是这篇文章要讲的东西。

---

## 1\. 为什么是这两个

先说最核心的一件事：这两个插件之所以能组合使用，不是因为它们功能强大，而是因为它们 **定位完全不重叠** 。

superpowers 只做一件事： **把软件工程的方法论编码成强制流程** 。

什么意思？它不写代码、不跑浏览器、不发布。它只做流程约束——你要加功能必须先 brainstorm，你要写代码必须先有 plan，你要调试必须先找根因，你要声明完成必须先收集证据，你要合并必须先独立审查。这些规则不是建议，是硬约束，Claude Code 只要装了 superpowers 就必须遵守。

gstack 也只做一件事： **把开发者每天要用的执行工具封装成一键命令** 。

浏览器？ `/browse` 。跑端到端测试？ `/qa` 。发布？ `/ship` 。部署？ `/land-and-deploy` 。上线监控？ `/canary` 。危险命令拦一下？ `/careful` 。它不告诉你怎么想，只帮你干活。

这两个插件一个管"想"一个管"做"，交集为零。

![[_resources/实战篇 Claude Code + superpowers + gstack 开发流程实录，可直接复制使用，一篇文章讲清楚！/3b3723646d23b3416391bcb74de2d620_MD5.webp]]

之前 vs 现在

这种分工的好处是 **一眼就能决定用谁** 。

你要写代码 → superpowers。你要看真实页面 → gstack。你要发布 → gstack。你要审查代码 → superpowers。你要修 bug 还没定位根因 → superpowers 的 `systematic-debugging` 。你要修完 bug 验证 → gstack 的 `/browse` 。

没有歧义，没有选择困难。每个动作都有唯一的归属。

---

## 2\. 安装三步（十分钟完成）

我尽量把命令写成可以直接粘贴的形式。先完整走一遍三步，细节后面再展开。

![[_resources/实战篇 Claude Code + superpowers + gstack 开发流程实录，可直接复制使用，一篇文章讲清楚！/a204a7f25ba52ce67d08cf7fe5e55ec1_MD5.webp]]

三步装好 superpowers + gstack

### 2.1 装 superpowers 四件套

```
claude plugin install superpowers@superpowers-marketplace
claude plugin install superpowers-chrome@superpowers-marketplace
claude plugin install superpowers-lab@superpowers-marketplace
claude plugin install superpowers-developing-for-claude-code@superpowers-marketplace
```

四个包的分工：

| 包 | 作用 | 必装吗 |
| --- | --- | --- |
| \`superpowers\` | 14 个核心方法论 skill，主干 | 必装 |
| \`superpowers-chrome\` | 底层 CDP 浏览器控制，gstack 不够用时的兜底 | 建议装 |
| \`superpowers-lab\` | Slack / Windows VM / tmux / 重复函数审计等实验工具 | 按需 |
| \`superpowers-developing-for-claude-code\` | 写 Claude Code 插件本身时用 | 按需 |

如果你不确定，四个一起装，占用空间很小。

### 2.2 装 gstack

gstack 不在 plugin marketplace，是直接 clone 仓库：

```
git clone --single-branch --depth 1 \
  https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup
```

三件事：clone 仓库到 `~/.claude/skills/gstack/` ，运行 setup 脚本，setup 把 28 个 skill 符号链接到 `~/.claude/skills/` 顶层。之后你在对话里用 `/browse` `/qa` `/ship` 就能触发。

setup 脚本依赖 bun，没装的话先装：

```
curl -fsSL https://bun.sh/install | bash
```

**如果你也用 OpenAI Codex CLI** ，再跑一次带参数的 setup：

```
cd ~/.claude/skills/gstack && ./setup --host codex
```

这会把 28 个 skill 生成到 `~/.codex/skills/` ，命名加 `gstack-` 前缀。两个环境共用一份 gstack 代码，不重复占用。

### 2.3 卸载所有冲突插件（这一步最关键）

很多人忘掉这步，结果发现新装的 skill 依然和旧的打架。对着下面这个名单全删一遍：

```
claude plugin uninstall oh-my-claudecode@omc
claude plugin uninstall feature-dev@claude-plugins-official
claude plugin uninstall code-review@claude-code-plugins
claude plugin uninstall code-review@claude-plugins-official
claude plugin uninstall ralph-loop@claude-plugins-official
claude plugin uninstall ralph-wiggum@claude-code-plugins
claude plugin uninstall code-simplifier@claude-plugins-official
claude plugin uninstall playwright@claude-plugins-official
claude plugin uninstall claude-session-driver@superpowers-marketplace
claude plugin uninstall commit-commands@claude-plugins-official
claude plugin uninstall document-skills@skills
claude plugin uninstall example-skills@skills
claude plugin uninstall claude-md-management@claude-plugins-official
claude plugin uninstall claude-code-setup@claude-plugins-official
claude plugin uninstall double-shot-latte@superpowers-marketplace
claude plugin uninstall frontend-design@claude-code-plugins
```

没装过的会报 "not found"，无视。删除的判断标准是： **凡是功能被 superpowers 或 gstack 覆盖的，一律删** 。

装完之后推荐留下的辅助插件：

| 插件 | 用途 |
| --- | --- |
| \`episodic-memory\` | 跨会话语义记忆（superpowers 没有） |
| \`elements-of-style\` | 写作规范 |
| \`claude-api\` | 写 Anthropic SDK 代码时 |
| \`context7\` | 库文档实时查询 |
| \`ui-ux-pro-max\` | UI 设计智库（50 风格 + 21 调色板） |
| \`frontend-design\` | 前端代码生成（和 ui-ux-pro-max 配套） |
| \`figma\` | Figma 集成（用 Figma 的项目装） |
| \`vercel\` / \`supabase\` | 项目相关时按需 |

这些都和 superpowers/gstack 零冲突，是补充不是替代。

---

## 3\. 配置 CLAUDE.md（比安装更关键）

装完插件只完成了一半。 **真正决定 Claude Code 行为的是 `~/.claude/CLAUDE.md`** 。

没有这份配置文件，Claude Code 启动时会把所有注册的 skill 都当成候选，遇到模糊需求时还是会乱匹配——装了 superpowers 又保留了 feature-dev 的结果就是两个 writing-plans skill 并存。

CLAUDE.md 的本质是一份 **裁决规则** ：告诉 Claude 遇到什么情况应该选哪个 skill，不选哪个。

下面这份是我正在用的完整版本，可以直接复制到 `~/.claude/CLAUDE.md` ：

```
# Claude Code 配置：superpowers + gstack

主干由两个插件组成：
- superpowers —— 思考与流程层（plan / brainstorm / debug / TDD / review / verify）
- gstack —— 执行与外部世界层（browser / QA / ship / deploy / canary / 护栏）

类比：superpowers 是大脑，gstack 是手脚。

## 核心原则

1. 流程归 superpowers：plan、brainstorm、debug、TDD、verify、code review
   默认走 superpowers，不走 OMC / feature-dev 等同名第三方 skill。
2. 执行归 gstack：浏览器、QA、ship、deploy、canary、retro 走 gstack。
3. 独立 reviewer 通道：verification 和 code-review 分两个 pass，
   不能在同一上下文里合并。
4. 证据优先：没有测试/截图/QA 报告不算完成。
5. 歧义先 brainstorm：任何创造性工作前先调用 brainstorming。
6. 最短路径优先：能用一个 skill 解决的，不升级为完整闭环。

## 任务分流

### 只读任务
分析、解释、架构说明、代码阅读 —— 直接处理。
真实 bug 排查但尚未修改 —— 用 systematic-debugging。

### 轻量任务
单文件或小范围修改、明确 bug 修复、配置/文案调整、小测试补充。
跳过完整 brainstorming / writing-plans / worktrees / 重 review 链。
直接实现 + 定向验证 + 必要时 /browse 看效果。

### 中任务
多文件但边界清晰，新功能或明确的重构。
简短 brainstorming + 短 writing-plans + 实现 + /browse 或 /qa + verification。

### 大任务
跨模块、共享逻辑、新架构、公共 API 变更。
完整闭环：brainstorming → writing-plans → /plan-*-review
  → executing-plans + worktrees + TDD → /qa → verification
  → code-review → finishing-branch → /ship → /land-and-deploy → /canary

## 浏览器规则

/browse 是唯一的浏览器入口。禁止使用 mcp__claude-in-chrome__*
和 mcp__computer-use__* 来操作浏览器。

## Subagent 策略

一定派子代理：
- 用户明说 "并行 / parallel / dispatch"
- 2-4 个边界清晰、独立验证、无共享状态的子任务
- 纯只读的多目标研究

一定不派：
- 任务有顺序依赖
- 多个子任务改同一文件 / contract / shared types
- package.json / lockfile / 根配置 / CI / schema / 总入口 默认串行
- 单一目标的 bug 修复
- 根因未明的调试

## 安全护栏

- rm -rf / DROP TABLE / force-push / git reset --hard / kubectl delete
  必须先过 /careful 或 /guard
- 调试敏感模块时用 /freeze <dir> 限定可改范围
- /ship 和 /land-and-deploy 必须用户明确确认
- 密钥/凭证/API Key 不得硬编码
- 数据库访问用参数化查询
- 不用不可信输入拼接 shell 命令或 SQL

## Change Delivery Gate

声明完成、准备 commit / push / PR 之前必须满足：

1. 已完成相关验证，并如实报告结果
2. 已过对应质量门禁（review / verification）
3. 关键验证无法执行时必须明确说明原因
4. 禁止虚构命令输出
5. 没有验证证据，不得声称"通过" / "完成"

## 不要重复造轮子

只走 superpowers：
- plan / brainstorm / writing-plans / executing-plans
- TDD / debugging / verification
- code review / subagent / worktrees / 分支收尾

只走 gstack：
- 浏览器、QA、ship、deploy、canary、retro、document-release
- 多视角 plan review (CEO / Eng / Design)
- 危险命令护栏 / freeze 沙箱
- 安全审计 / design-consultation / investigate
```

这份配置每一条都是防具体问题的。我拆开解释几条容易被误解的：

**核心原则第 3 条（独立 reviewer 通道）** 。这条最反直觉但最重要。同一个 Claude 上下文里写完代码之后立刻做代码审查，Claude 会下意识维护自己的工作——找到的问题偏向无关痛痒的小瑕疵，真正的设计缺陷会被自动忽略。必须新开一个 reviewer 上下文做独立判断。所以 superpowers 把 `requesting-code-review` 设计成强制新开上下文的 skill，这条规则就是把这个机制写进 CLAUDE.md 变成硬约束。

**任务分流** 。这条是防过度工程化。很多人用 superpowers 之后容易走极端——改个 typo 都要 brainstorming + writing-plans + TDD + code-review 全套走一遍，反而比裸用还慢。任务分流告诉 Claude：小任务直接干，中任务简化流程，大任务才走完整闭环。判断标准就是"改动范围 + 风险等级"。

**Subagent 策略** 。superpowers 的 `dispatching-parallel-agents` 会在"看起来像并行"时自动派子代理，但"看起来像"和"真的适合"是两回事。这条规则明确了触发条件：有顺序依赖的不派、改同一文件的不派、单一目标 bug 修复不派、根因未明的调试不派。用户也可以用关键词强制——说"并行"就派，说"串行"就不派。

**Change Delivery Gate** 。这条是防假完成。Claude 有时候会嘴上说"已经修好了 ✓"但其实没真跑测试。Gate 里第 4 条明确禁止虚构命令输出——不允许 Claude 写一个假的命令结果让你以为它跑过了。没跑就说没跑，允许诚实承认"这一步没法验证"，不允许编。

---

## 4\. 开发闭环：谁在什么时候干什么

![[_resources/实战篇 Claude Code + superpowers + gstack 开发流程实录，可直接复制使用，一篇文章讲清楚！/cd9526372b307ca5bc8f1373c1ee0421_MD5.webp]]

开发闭环 · 接力赛

把上面所有东西串起来就是完整的闭环。以一个大任务为例：

```
想法
  ↓
[superpowers] brainstorming              ← 想清楚要做什么
  ↓
[superpowers] writing-plans              ← 写可执行计划
  ↓
[gstack] /plan-eng-review                ← 多视角审查（可选）
  ↓
[superpowers] using-git-worktrees        ← 隔离工作环境
  ↓
[superpowers] executing-plans + TDD      ← 严格按计划执行
  ↓
[gstack] /browse 或 /qa                  ← 真实环境验证
  ↓
[superpowers] verification-before-       ← 收集完成证据
              completion
  ↓
[superpowers] requesting-code-review     ← 独立 reviewer 通道
  ↓
[superpowers] finishing-a-development-   ← 分支收尾
              branch
  ↓
[gstack] /ship                           ← 发布流水线
  ↓
[gstack] /land-and-deploy                ← 合并部署
  ↓
[gstack] /canary                         ← 上线监控
  ↓
[gstack] /document-release               ← 更新文档
  ↓
完成
```

注意四个 **关键交接点** ——这些是最容易出错的地方：

**交接点 1：executing-plans → /browse 或 /qa**

代码写完下一步必须用真实环境验证。superpowers 自己没有浏览器能力——它不会知道你的页面是不是渲染对了。这里必须让 gstack 接手。跳过这一步是绝大多数"我以为修好了"的根源。

**交接点 2：verification → requesting-code-review**

自检和他人审查是两个独立的 pass， **不能合并** 。verification 是作者确认证据齐全（测试跑了、截图有了），code-review 是新开上下文做独立判断。合在一起等于作弊。

**交接点 3：finishing-a-development-branch → /ship**

分支收尾是 superpowers 的最后一步，发布流水线是 gstack 的第一步。两个 skill 之间设计成无缝衔接——finishing 会告诉你"OK 现在可以 ship 了"，ship 接过来继续跑。

**交接点 4：/ship → /land-and-deploy → /canary**

gstack 内部流水线一条龙跑到底。ship 完不是结束，必须合并、部署、监控 30 分钟确认无 regression，才算真正 done。中途 canary 发现控制台报错就回滚，自动化链路完整。

---

## 5\. 真实场景：五个例子看具体怎么用

### 场景 A：完整新功能（深色模式切换）

**你** ：给官网加一个深色模式切换，要记住用户偏好，也跟系统主题联动。

这是典型的中到大任务，走完整闭环：

```
1. brainstorming — Claude 问三个问题
   - 只切根色板，还是逐元素精调？
   - 持久化用 localStorage 还是服务端？
   - 默认跟系统主题还是跟上次选择？

2. writing-plans — 产出 plan
   - 定义 CSS variables (--bg / --fg / --accent)
   - 添加 ThemeProvider (context + localStorage hook)
   - 添加 toggle 组件
   - 处理系统主题 media query 联动
   - e2e 测试：切换 → DOM class 变化 → 刷新后保留

3. /plan-design-review — 设计视角审查
   - 深色色板对比度够不够？
   - 切换动画会不会突兀？
   - 暗色下的图片处理？

4. using-git-worktrees — 建 worktree: dark-mode-feature

5. executing-plans + TDD — 每个改动先写测试再实现

6. /browse http://localhost:3000 — 手动切主题看渲染

7. /qa — 端到端：登录 → 切主题 → 发文章 → 退出 → 重登看偏好保留

8. verification-before-completion — 三件套：测试报告 + 截图 + QA 结果

9. requesting-code-review — 新开上下文
   （这次发现 ThemeProvider 没处理 SSR hydration 闪烁）

10. receiving-code-review — 修改，回跑测试

11. finishing-a-development-branch — 决定 merge 还是 PR

12. /ship — 跑测试 → bump version → 更 CHANGELOG → commit → push → PR

13. /land-and-deploy — 合 PR → 等 CI → 等部署 → 生产健康检查

14. /canary — 监控 30 分钟：控制台错误 + Core Web Vitals

15. /document-release — 更新 README 和 CHANGELOG
```

15 步看起来多，但 **每一步都有明确产物** ，不会中途漂移。superpowers 和 gstack 像接力赛交替工作，每次交接都有清晰的信号。

### 场景 B：快速 bug 修复（轻量路径）

**你** ：用户反馈登录后点"我的订单"会白屏。

这是轻量任务，走轻量路径：

```
1. systematic-debugging
   收集现象、复现、缩小范围
   → 定位根因：订单 API 响应 user.address 为 null 时组件 crash

2. 改代码（单文件）
   添加 null 安全访问

3. /browse
   打开 localhost 模拟该用户状态复现，验证修复

4. /ship
   快速发布
```

注意这种小改动 **不需要** brainstorming / writing-plans / TDD / 独立 code-review 全套。判断标准就是 CLAUDE.md 的任务分流规则：单文件、明确 bug、边界清晰 → 降级到轻量路径。

### 场景 C：UI 快速迭代

**你** ：首页 hero 区太闷，调一下让它更有活力。

UI 任务围绕 `/browse` 和 `/design-review` 迭代：

```
1. writing-plans 简版
   列几个候选方向（渐变、动画、配图、字号）

2. /plan-design-review
   设计师视角挑一个方向

3. 改代码

4. /browse
   看效果

5. /design-review
   UI QA：视觉一致性、响应式、对比度

6. 不满意就回第 3 步

7. /ship
```

循环到满意为止。 `/design-review` 比人眼更容易发现 AI slop 痕迹——比如同一个 padding 在不同组件里不一致、字号层级混乱、间距随机变化。这些肉眼扫过去注意不到， `/design-review` 会逐个标记。

### 场景 D：AI 生成代码的安全执行

**你** ：帮我跑一下 AI 生成的这段 Python 脚本。

不要直接跑。这类任务默认高风险：

```
1. /careful python sketchy-script.py
   警告这是外部代码、让用户看清楚再确认执行

2. 或者更保守：/freeze /tmp/sandbox
   把 Claude 的文件操作限定在沙箱目录

3. 最保守：先用 writing-plans 审查这段代码
   理解它在干什么、会改什么、能不能恢复
   再决定是否执行
```

`/freeze` 这个能力被很多人忽略，其实它是整个 gstack 里我最常用的护栏。调试任何涉及文件系统的问题之前先 `/freeze` 一下当前目录，Claude 就不可能越界改其它地方。

### 场景 E：周工程回顾

**你** ：给本周做一份工程回顾。

这是一条命令就能搞定的任务：

```
/retro
```

会自动分析本周 commit 历史、工作模式、代码质量趋势，按人拆分贡献，输出 markdown 报告。持久化历史让你每周跑一次，趋势一目了然。

---

## 6\. 五条铁律（每条都有血泪教训）

![[_resources/实战篇 Claude Code + superpowers + gstack 开发流程实录，可直接复制使用，一篇文章讲清楚！/c3dcf61f337b95bb0ae54122323eaf33_MD5.webp]]

五条铁律

前面散落在各节里的规则，汇总成五条：

**铁律 1：浏览器只走 `/browse`**

禁用 `mcp__claude-in-chrome__` 和 `mcp__computer-use__` 当浏览器用。

`/browse` 封装了完整链路——打开 → 验证 → 截图 → 差异对比 → 报告。其它两个是底层原语，没有证据收集机制。用它们意味着验证走过场、截图不会自动保留、diff 找不到、行为在不同 session 里不一致。

**铁律 2：作者不能审自己的代码**

`verification-before-completion` 和 `requesting-code-review` 是 **两个独立上下文** 。

Claude 写完代码后，在同一上下文里自审只会找无关痛痒的瑕疵。新开一个 reviewer 上下文相当于换了个人审，视角完全不同。这是 superpowers 最有价值的规则之一，别为了省事合并。

**铁律 3：没证据不算完成**

声明"完成"之前必须回答三个问题：测试跑了吗？ `/browse` 截图证明页面正常了吗？ `/qa` 报告没有红色警告吗？三个缺一不可。

做不到就降级表述。"已实现但未验证"不等于"完成"，诚实承认比假装完成重要十倍。

**铁律 4：歧义先 brainstorm**

任何"加功能 / 改行为 / 新组件"类任务开工前先 brainstorm。5 分钟头脑风暴能省 5 小时返工。

但也别过度——改 typo、改配色、改固定字符串、明确的 bug 修复（已知根因）、单文件 20 行以内小改动，这些可以跳过 brainstorming 直接干。判断标准：需求里有没有隐含假设。

**铁律 5：危险命令先 `/careful`**

`rm -rf` / `DROP TABLE` / `force-push` / `git reset --hard` / `kubectl delete` / 删 branch / 清 volume —— 一律先 `/careful <cmd>` 走一遍。

配合 `/freeze <dir>` 把 Claude 关在特定目录调试。生产环境操作前用 `/guard` （ `/careful` + `/freeze` 合体）。这些命令看起来啰嗦，但 **一次救命就值回全部成本** 。

---

## 7\. Cheatsheet（可以打印贴显示器）

这是我自己贴在显示器边上的那一张。需要时抄走。

```
┌──────────────────────────────────────────────────────────┐
│         superpowers + gstack 日常速查卡                   │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ◆ 想清楚      brainstorming                             │
│  ◆ 写计划      writing-plans                             │
│  ◆ 审计划      /plan-eng-review  /plan-ceo-review        │
│  ◆ 隔离        using-git-worktrees                       │
│  ◆ 执行        executing-plans                           │
│  ◆ 写测试      test-driven-development                   │
│  ◆ 查 bug      systematic-debugging                      │
│                                                          │
│  ──── superpowers → gstack ────                         │
│                                                          │
│  ◆ 看页面      /browse <url>                             │
│  ◆ 跑测试      /qa      只报告 /qa-only                  │
│  ◆ UI QA      /design-review                            │
│                                                          │
│  ──── gstack → superpowers ────                         │
│                                                          │
│  ◆ 收证据      verification-before-completion            │
│  ◆ 独立审      requesting-code-review                    │
│  ◆ 接审查      receiving-code-review                     │
│  ◆ 收分支      finishing-a-development-branch            │
│                                                          │
│  ──── superpowers → gstack ────                         │
│                                                          │
│  ◆ 发布        /ship                                    │
│  ◆ 合并部署    /land-and-deploy                         │
│  ◆ 上线监控    /canary                                  │
│  ◆ 发布文档    /document-release                        │
│  ◆ 周回顾      /retro                                   │
│                                                          │
│  ──── 安全护栏 ────                                      │
│                                                          │
│  ◆ 危险命令    /careful <cmd>                           │
│  ◆ 目录沙箱    /freeze <dir>      解锁 /unfreeze       │
│  ◆ 组合护栏    /guard                                   │
│                                                          │
│  ──── 五条铁律 ────                                      │
│                                                          │
│  1. 浏览器只走 /browse                                   │
│  2. 作者 ≠ 审查者（两个 pass）                            │
│  3. 没证据不算完成                                        │
│  4. 歧义先 brainstorm                                    │
│  5. 危险命令先 /careful                                  │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

Codex CLI 用户把所有 `/xxx` 换成 `gstack-xxx` 即可。superpowers 的 skill 名两边完全一样。

---

## 8\. 踩坑清单（我自己犯过的十个错）

十条血泪教训，每条都对应一次返工。

**坑 1：跳过 brainstorming 直接写**

写到一半发现需求理解错了，返工。

避：加功能类任务强制先 brainstorming。

**坑 2：作者审自己的代码**

verification 说"完成"但其实没真测。

避：verification 只做证据收集，必须另开 requesting-code-review。

**坑 3：绕过 `/browse` 用底层 MCP**

行为不一致、没截图、证据丢失。

避：CLAUDE.md 明确禁用 mcp\_\_claude-in-chrome 和 mcp\_\_computer-use。

**坑 4：插件抢 skill 匹配**

同名 skill 被别的插件截胡。

避：安装第三步的卸载列表一定要跑，CLAUDE.md 的"不要重复造轮子"段落二次防护。

**坑 5： `/ship` 之前没跑测试**

CI 红了才发现。

避： `/ship` 内置测试 gate，不跳过就不会出错。

**坑 6：Worktree 和主分支混着改**

改动互相污染。

避：启动任务前先 using-git-worktrees。

**坑 7：并行子任务冲突**

两个 agent 改同一个文件。

避：默认禁止两个子任务改同一文件、contract、shared types。

**坑 8：调试瞎猜**

越改越乱。

避：强制走 systematic-debugging 四阶段——investigate / analyze / hypothesize / implement。

**坑 9：大任务漂移**

执行到后面忘了初始目标。

避：用 executing-plans 的 checkpoint 机制。每个 step 对照 plan。

**坑 10：完成就完成了**

没证据就宣称"可合并"。

避：证据优先——测试输出 + 截图 + QA 报告三件套。

---

## 9\. 不适合装这套的三种情况

平衡一下：这套配置并非万能。下面三种情况别上这套：

**第一种：纯后端库 / SDK 开发，没有前端**

gstack 里一大半是给前端用的—— `/browse` / `/qa` / `/design-review` / `/plan-design-review` 。你写的是纯库代码，这些用不上。这种场景下只装 superpowers 就够。

**第二种：小团队没有正规发布流程**

gstack 的 `/ship` → `/land-and-deploy` → `/canary` 是为有 CI、有 PR 流程、有生产环境的项目设计的。如果你的发布方式是"手动 git push 到 main"，这些 skill 没用武之地。

**第三种：追求极简的资深开发者**

superpowers 的强制流程对资深开发者来说有时候会显得啰嗦——你已经知道该怎么做了还要走一遍 brainstorming，确实有点累。这种情况下可以只装 gstack，把 superpowers 当成"按需触发"的工具。

---

## 10\. 写在最后

这篇文章的所有内容——CLAUDE.md 模板、cheatsheet、路由表、安装命令——都是我自己正在用的版本，写出来就是希望你能直接抄走。不用自己摸索三个月，省下的时间拿去写真正的代码。

装插件这件事，最大的陷阱不是装错了什么，而是 **装了一堆没有分工** 。每个插件都能单独 work，合起来却互相打架。解决办法不是装更多，是 **想清楚谁负责什么** 。

superpowers + gstack 这套组合给了我一个最清晰的心智模型： **大脑 vs 手脚** 。任何任务过来，脑子里先分——这是想的事还是做的事？想的事给 superpowers，做的事给 gstack。没有中间地带。

> 插件不在多，在配合。十个打架的插件不如两个清晰分工的插件。

好了，命令都在上面，模板都在上面，cheatsheet 也在上面。剩下的就是打开 Claude Code 试一次。

如果你也有什么 Claude Code 配置坑，评论区聊。

---

**相关链接**

- ●superpowers：https://github.com/obra/superpowers
- ●gstack：https://github.com/garrytan/gstack