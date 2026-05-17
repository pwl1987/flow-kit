---
title: "介绍一些我正在使用 claude code 的 skill 和 MCP"
source: "https://mp.weixin.qq.com/s/w2gsQPhEOHKwE2tllETieQ"
author:
  - "[[独元殇]]"
published:
created: 2026-05-15
description: "推荐的 mcp这个 MCP 我用的不多。平常还是 skill 更实用一点。怎么配置呢？有的你修改 mcp.json 就可以。有的你还需要额外安装。"
tags:
  - "clippings"
---
独元殇 *2026年3月27日 00:15*

> ⭐️ 博主我会 **每天** 在公众号发布一些关于建网站、编程、SEO、AI 类的 **原创小文章** ，纯手打，无 AI 辅助，篇篇力求值得收藏，欢迎大家关注本公众号！祝大家开心每一天！⭐️

直接安装 claude code 完成后，是裸机，只能写一些简单的代码，干一些简单的事，增删查改一些文件，运行一些简单的 bash 命令。

所以必须得安装 MCP 和 skill ，前者是直接可以让 AI 去干的比较确定的事情，后者是一些工作流。虽然各路大佬都说两者不同，但其实也差不太多，在我眼里，skill 是高级版本的 mcp ，因为 skill 之所以会出现，是因为 mcp 当年有很多不足。不过 MCP 是一个程序进程，有自己的端口，对接外部服务还需要 key 等。

这些东西本质上，就是一套封装好的文本文档。只不过是经过验证，可以满足需求。

大部分的技能，会在需要的时候自动调用。少部分需要手动去和大模型提出，然后才能调用。

## 如何查找、安装 skill ？

查找，是一个官方网址： https://skills.sh/ 。这个是比较权威的。当然还有大量的第三方 skill 库，大家感兴趣可以去找找。

如果想知道自己本地都安装了哪些 skill ？可以执行下面的命令：

```
# windows 
dir C:\Users\你的用户名.claude\skills\

# Mac/Linux 路径
ls ~/.claude/skills/
ls ~/.agents/skills/
```

如果是在 skill 网站上，看到一些好玩的 skill 的话，可以用下面的代码来查找、安装、更新：

```
# 搜索技能（关键词匹配）
npx skills find <关键词>

# 安装技能（-y 跳过确认，-g 全局安装，必加！）
npx skills add <owner/repo@skill> -y -g

# 比如安装 frontend-design
npx skills add frontend-design -y -g

# 查看已安装的全部技能
npx skills list -g

# 检查技能更新
npx skills check

# 更新所有已安装技能
npx skills update
```

## 推荐的一些 skill

首先是最最古老和出名的 前端设计专家。 frontend-design ，然后是其他的我一直在用的。

1. frontend-design ，这是最经典的 skill ，老生常谈。加上这个技能，会在写前端网页时自动触发，可以写出比较高质量的前端页面。
2. skill-creator ，引导你，帮你创建自定义技能的，也是必须要安装的。还能一键发布到社区。
3. memory-intake ，这个是解决 新开会话，全忘 这个问题的，能把之前的各种经验自动记录下来，然后分类存档，方便后续读写，让 CC 越用越顺！
4. memory-audit 、memory-evolution ，辅助上面的 skill 的，前者可以清理无用的记忆，后者是优化。
5. audit-website ，网站漏洞扫描，可以在你发布网站前，帮你扫描以下有没有安全漏洞。
6. test-driven-development ，著名的 TDD 模式开发辅助工具，它可以引导你做出恰当的测试用例，还是很实用的，建议大家也养成 TDD 模式。
7. brainstorming ，头脑风暴！帮你打开思路，给你创意。
8. technical-writer ，帮你写出更专业标准的 API 文档，甚至 readme.md 。
9. canvas-design ， 绘制 架构图、流程图、简单的报告封面图 必备，还能直接导出 PNG 和PDF 格式。
10. vercel-react-native-skills ，辅助编写React Native 跨平台用的。
11. web-artifacts-builder ，我们大部分前端人，都是基于模块化、单页应用开发。这个会改良单页应用开发，适配Tailwind、shadcn/ui、react 。
12. vercel-react-best-practices ，写 react 必备。这个是我们大量使用 nextjs 的官方 vercel 出品的，非常 nice 。能写出非常好的 react 应用。
13. vercel-composition-patterns ，解决复杂组件拆分不合理，复用性差，状态管理混乱的问题，帮你写出更优雅、复用性更强的组件代码。
14. docx ，处理 Word 文档使用，包括创建、读取、编辑、转化等等，大部分 Word 的功能都能搞定了。虽然程序员用的不多，但也会用到的。
15. pptx、pdf、xlsx ， 跟上面一样，都是办公场景必备的。
16. planning-with-files、project-planner ，都是在写代码前，优化规划用的，还能生成很专业的标准需求文档、评估等等。
17. architecture-patterns、architecture-decision-records 这两个技能，一个是 架构设计专家，一个是建构记录专家，两者同时安装，架构上无忧。

然后安装 bash 命令如下，大家按需安装。

```
npx skills add frontend-design -y -g
npx skills add skill-creator -y -g
npx skills add memory-intake -y -g
npx skills add test-driven-development -y -g
npx skills add memory-audit -y -g
npx skills add memory-evolution -y -g
npx skills add audit-website -y -g
npx skills add brainstorming -y -g
npx skills add technical-writer -y -g
npx skills add canvas-design -y -g
npx skills add vercel-react-native-skills -y -g
npx skills add web-artifacts-builder -y -g
npx skills add vercel-react-best-practices -y -g
npx skills add vercel-composition-patterns -y -g
npx skills add docx -y -g
npx skills add pptx -y -g
npx skills add pdf -y -g
npx skills add xlsx -y -g
npx skills add planning-with-files -y -g
npx skills add project-planner -y -g
npx skills add architecture-patterns -y -g
npx skills add architecture-decision-records -y -g
```

## 推荐的 mcp

这个 MCP 我用的不多。平常还是 skill 更实用一点。

怎么配置呢？

有的你修改 mcp.json 就可以。有的你还需要额外安装。

```
# Windows
C:\Users\你的用户名.claude\mcp.json

# Mac/Linux
~/.claude/mcp.json
~/.claude/mcp.local.json

# 格式说明
{
  "mcpServers": {
    "服务器名称": {
      "command": "执行命令",
      "args": ["命令参数"],
      "env": {
        "环境变量名": "环境变量值"
      }
    }
  }
}
# 注意，每次安装完，都需要重启 Claude Code 。
```

第一个： playwright ，作为全栈程序员，这个能给你强大的 浏览器 控制能力。必备。

```
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

第二个：4\_5v\_mcp ，是 让 Claude 分析图片内容、识别 UI 组件、描述图片场景 。

```
{
  "mcpServers": {
    "4_5v_mcp": {
      "command": "npx",
      "args": ["-y", "4_5v_mcp"]
    }
  }
}
```

其余的就没有了，MCP 没有 skill 实用。

参考资料 ：

1. https://www.zhihu.com/question/2016657901549266060/answer/2020649000739554581
2. https://juejin.cn/post/7620060655607857178

编程与网站建设 · 目录

阅读原文

继续滑动看下一个

独元殇

向上滑动看下一个