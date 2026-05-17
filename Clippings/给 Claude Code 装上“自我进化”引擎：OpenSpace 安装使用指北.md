---
title: "给 Claude Code 装上“自我进化”引擎：OpenSpace 安装使用指北"
source: "https://mp.weixin.qq.com/s/ZX8etUqnSi4U39yfVDl6EA"
author:
  - "[[智界深潜]]"
published:
created: 2026-05-15
description: "用了一段时间 Claude Code，感觉确实很强，但总有个小遗憾：每次让它帮我做点复杂的事儿，它都得从头摸索"
tags:
  - "clippings"
---
智界深潜 *2026年5月13日 15:12*

用了一段时间 Claude Code，感觉确实很强，但总有个小遗憾： **每次让它帮我做点复杂的事儿，它都得从头摸索一遍** 。  
比如上周我让它写一个 React 组件的单元测试，今天换个项目又得再教一次。一来二去，我发现自己像是在给它“打零工”，而不是用它打工。

直到群里有人提了一嘴 **OpenSpace** ——一个让 AI 助手能 **越用越聪明** 的自进化引擎。  
简单说，它能让 Claude Code **从每一次任务中积累经验** ，以后遇到类似问题就能直接“复用”之前的解法，不用每次都重头来。

实测了几周，确实有改善。最直观的感受是：同样写一个 API 网关的鉴权逻辑，之前要来回修正三四轮，现在一次就能成型。而且它生成的代码风格越来越像我自己写的，连注释习惯都学去了。

这篇就是我的完整折腾记录，希望对你有帮助。

![[_resources/给 Claude Code 装上“自我进化”引擎：OpenSpace 安装使用指北/98338f0b98cb45b5ebdb215d2baeca37_MD5.webp]]

### OpenSpace 到底解决了什么痛点？

Claude Code 本身很棒，但它是“静态”的。  
每次对话都是新的上下文，过去踩过的坑、总结出的最佳实践，它转身就忘。

OpenSpace 的思路很直接： **让 AI 拥有“长期记忆”和“技能进化”的能力** 。  
它把你的操作记录、成功的代码片段、甚至错误修复的过程，都整理成可复用的 **Skills** 。  
下次遇到类似任务，Claude 会主动调用这些技能，而不是从头开始猜。

官方给了一组数字：

- 任务完成效率提升 4.2 倍
- Token 消耗降低 46%

我自己用下来，效率提升没有这么夸张，但 **Token 省了一半** 是真的。特别是写重复性代码（CRUD、表单校验、分页组件），Claude 现在的产出几乎不用改。

---

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

### 安装 OpenSpace（Claude Code 版）

我是在 macOS 上操作的，Windows/Linux 步骤基本一样。

**1\. 确认 Python 版本**  
OpenSpace 需要 Python 3.10 以上。

```css
python3 --version
```

如果版本不够，用 pyenv 或者官网装一个。

**2\. 克隆项目并安装**

```bash
git clone https://github.com/HKUDS/OpenSpace.gitcd OpenSpacepip install -e .
```

`-e` 是开发模式安装，方便以后更新。

**3\. 把两个核心技能复制到 Claude 的技能目录**

```bash
cp -r openspace/host_skills/delegate-task ~/.claude/skills/cp -r openspace/host_skills/skill-discovery ~/.claude/skills/
```

这两个技能很重要：

- `delegate-task` ：让 Claude 能把复杂任务拆分给 OpenSpace 处理
- `skill-discovery` ：当遇到不熟悉的任务时，自动搜索本地或云端已有的技能

---

### 配置 MCP 服务器

OpenSpace 通过 MCP（模型上下文协议）和 Claude Code 通信，需要把它注册成一个 MCP server。

编辑 Claude Code 的配置文件（一般在 `~/.claude/settings.json` 或项目根目录的 `.claude/mcp.json` ），加入：

```json
{  "mcpServers": {    "openspace": {      "command": "openspace-mcp",      "env": {        "OPENSPACE_WORKSPACE": "/你的实际路径/OpenSpace",        "OPENSPACE_API_KEY": "你的API密钥（可选）"      }    }  }}
```

- `OPENSPACE_WORKSPACE` ：填你刚才克隆 OpenSpace 的绝对路径
- `OPENSPACE_API_KEY` ：如果你想跟社区 `open-space.cloud` 同步技能，可以去官网注册一个。 **如果只用本地进化，这个可以不填** 。

如果你不想手动改文件，也可以在 Claude Code 里用命令添加：

```cs
claude mcp add openspace openspace-mcp
```

添加成功后，输入 `/mcp` ，找到 `openspace` ，确保状态是 `connected` 且 `authorized` 。  
第一次连接可能需要确认授权，按照提示点一下就好。

---

### 它到底怎么用？

配置好之后， **你几乎感觉不到它的存在** 。  
正常使用 Claude Code 就行，OpenSpace 会在后台悄悄工作。

举几个我实际遇到的场景：

- **写一个通用的数据表格组件**  
	之前我写过一个带排序、筛选、分页的表格，OpenSpace 把它记录成一个 `data-table-generator` 技能。  
	现在只要说“帮我生成一个用户列表表格，需要筛选和分页”，它直接调用技能，几秒钟就出代码，而且布局逻辑跟上次几乎一样。
- **修复一个棘手的竞态 Bug**  
	上周用 React Query 时出了个请求覆盖的问题，我配合 Claude 改了好几轮才修好。  
	第二天又遇到类似的并发请求场景，Claude 直接说：“根据之前的修复经验，这里需要加一个 AbortController，在 useEffect 里清理。”——这句话就是 OpenSpace 在起作用。
- **生成符合团队规范的 API 文档**  
	我们团队有一套自己的 Markdown 格式，我把规范写了一次让它记住。  
	现在生成接口文档，Claude 自动按照那个模板输出，不用我再改一遍。

你不需要主动调用任何命令，也不需要学习新语法。  
**它就像给 Claude 装了一个后台“学习模块”** ，你干得越多，它就越懂你。

---

### 注意事项 & 踩坑记录

1. **云同步不是必须的**  
	OpenSpace 支持把技能上传到社区（群体智能），但上传前会有确认弹窗，不是偷偷上传。  
	如果你比较在意隐私，可以完全不填 API\_KEY，它就只在本地存储技能。
2. **MCP 连接不上怎么办？**
- 检查 `OPENSPACE_WORKSPACE` 路径是否正确
	- 运行 `which openspace-mcp` 确认命令可用
	- 在 Claude Code 里执行 `/mcp` 重启一下服务
	- 实在不行，重启 Claude Code 窗口
4. **技能发现不够灵敏**  
	有时候 Claude 不会主动使用已有技能，需要你稍微提示一下。  
	可以在提问时说：“用我之前总结过的方式处理…” 它就会去翻技能库。
5. **资源消耗**  
	OpenSpace 本身很轻，几乎不占额外内存。  
	但第一次学习某个任务时，Claude 的 Token 会多一些（因为要在后台记录技能）。  
	长期来看，省下的 Token 远多于学习成本。

---

### 最后说两句

OpenSpace 不是什么黑魔法，它只是让 AI 助手变得 **像人一样可以积累经验** 。  
对于每天要写大量重复代码、维护复杂项目的开发者来说，这可能是目前 Claude Code 生态里最实用的插件之一。

如果你也厌倦了“教一次、忘一次”的循环，不妨花十分钟试试 OpenSpace。  
配置一次，之后它就默默在后台帮你省钱、省时间。

**你踩过的坑，它再也不会踩第二遍。**

继续滑动看下一个

智界深潜

向上滑动看下一个