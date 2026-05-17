---
title: "上班族必装！7个让Claude Code原地起飞的神级Skill"
source: "https://mp.weixin.qq.com/s/Ji0OxgE5juCJ8Uw4bYQA4g"
author:
  - "[[AI必选项]]"
published:
created: 2026-05-15
description: "2026年3月推荐 · 适用于 Claude Code/ Open Code"
tags:
  - "clippings"
---
AI必选项 *2026年3月26日 14:05*

Claude Code 自带的能力已经很强，但 Skill 是另一回事。Skill 是预先写好的操作手册，告诉 Claude 遇到特定任务时该怎么做、用什么工具、走什么流程。装对了，省的不是一两次对话，是重复性工作里每一次的摩擦。这 7 个，是上班族最容易用到的。

公共 SKILL（官方维护）

01

DOCX — Word 文档生成器

public/docx 文档处理

让 Claude 生成真正可用的.docx 文件：有目录、有页码、有表头，格式符合职场规范。不是 Markdown，不是纯文本，是打开就能交给老板的 Word 文件。

**💡 为什么推荐**  

你让 Claude 写报告，它默认给你 Markdown。这个 Skill 改变这件事。撰写会议纪要、项目方案、工作总结，Claude 会直接输出.docx，格式一次到位。

安装方法

① 打开终端，进入 Claude Code  
② 输入： `/skills add public/docx` （或从 Settings → Skills 界面添加）  
③ 对话中说「帮我写一份 Word 格式的报告」即可触发

02

PPTX — 幻灯片生成器

public/pptx 演示文稿

输入主题或大纲，输出可编辑的.pptx 文件。支持多种布局、Speaker Notes、主题色配置，不需要你一页页手动排。

**💡 为什么推荐**  

做 PPT 最耗时的不是想内容，是排版。这个 Skill 把结构和排版这两件事一并接管。临时要做汇报？把要点丢给 Claude，10 分钟内有草稿。

安装方法

① 终端运行： `/skills add public/pptx`  
② 说「帮我做一个关于 Q3 进展的 PPT」即触发  
③ 生成后直接下载.pptx，用 PowerPoint 或 Keynote 打开微调

03

XLSX — 表格处理器

public/xlsx 数据处理

读取、清洗、改写 Excel 文件。可以合并多张表、重组列、修复格式错误、计算新字段，输出是真实可用的.xlsx，不是截图不是文字。

**💡 为什么推荐**  

同事发来格式乱糟糟的数据表？上传给 Claude，说「把这个整理成标准格式」，几秒内给你一份干净的 Excel，比你手动整半小时快得多。

安装方法

① 运行： `/skills add public/xlsx`  
② 上传.xlsx 或.csv 文件后，用自然语言描述操作  
③ 输出结果直接下载

04

PDF — PDF 全能工具

public/pdf 文件管理

合并多个 PDF、拆分页面、加水印、填写表单、提取表格内容、对扫描件做 OCR。不用再为找不到合适工具付费。

**💡 为什么推荐**  

职场上 PDF 绕不过去。合同要签、报告要交、证件要上传，各种格式处理需求不断。这个 Skill 把大多数 PDF 操作都覆盖了，而且完全在本地处理。

安装方法

① 运行： `/skills add public/pdf`  
② 上传 PDF 后描述需求，如「合并这三个文件」或「提取第 2-5 页」  
③ 还可配合 `public/pdf-reading` 一起装，读取分析 PDF 内容

· · ·

社区 SKILL（第三方出品）

**安装说明**

以下 Skill 来自社区作者，以.skill 文件格式发布。安装方式：在 Claude Code 的 Settings → Skills 页面点击「Upload Skill」，上传对应的.skill 文件即可。部分 Skill 依赖 `bun` 运行时，首次使用前需提前安装： `npm install -g bun`

05

baoyu-translate — 精品翻译器

社区作者：宝玉 JimLiu 语言处理

三档翻译模式：快翻（直接出结果）、普通翻译（先分析语境再翻）、精翻（分析 → 翻译 → 审校 → 润色，适合发表级内容）。支持自定义术语表，保持专业词汇一致。

**💡 为什么推荐**  

普通 Claude 翻译凑合能用，这个 Skill 是另一个量级。精翻模式下，它会先理解文章结构和语气，再动手翻，最后还会自我审校。翻出来的中文读起来像人写的，不是机器腔。经常需要翻译英文资料或对外发内容的同学，值得装。

安装方法

① 访问 github.com/JimLiu/baoyu-skills 下载 `baoyu-translate.skill`  
② 在 Claude Code 中进入 Settings → Skills → Upload Skill  
③ 说「精翻这篇文章」或「快速翻译一下」即可触发对应模式

06

baoyu-youtube-transcript — YouTube 字幕提取

社区作者：宝玉 JimLiu 内容提取

粘贴一个 YouTube 链接，自动下载字幕、抓取封面图。支持多语言字幕、自动翻译，还能识别章节节点和发言人。不需要 API Key，不需要挂代理工具，直连 YouTube 内部接口。

**💡 为什么推荐**  

刷到一个有价值的英文演讲或技术视频，不想从头看完？扔给 Claude，让它提取字幕再总结要点，5 分钟掌握一小时内容。做竞品调研、跟进行业动态，效率翻倍。

安装方法

① 从 baoyu-skills 仓库下载 `baoyu-youtube-transcript.skill`  
② 上传至 Claude Code Skills 页面  
③ 对话中粘贴 YouTube 链接，说「帮我获取这个视频的字幕」

07

stop-slop — AI 写作去味剂

社区作者：Hardik Pandya 写作润色

专门消除 AI 写作的「机器味」：去掉堆叠感叹、删除冗余过渡词、打破固定句式、改被动为主动，让文字读起来像真人写的。

**💡 为什么推荐**  

用 Claude 写完文案或报告，总有一股说不清的 AI 腔？这个 Skill 就是来解决这个问题的。它有一套具体的检查清单：有没有副词、有没有被动语态、有没有「这说明了…」这类废话套路，逐条审查，逐条清除。写对外内容的人必备。

安装方法

① 从作者 hvpandya.com 或其 GitHub 获取 `stop-slop.skill`  
② 上传至 Claude Code Skills 页面  
③ 写完内容后说「帮我去掉 AI 腔」或「polish this text」即触发

|  | **🔄 OpenCode 用户同样适用**  以上 7 个 Skill 在 OpenCode 中完全可用，Skill 文件格式完全相同，无需修改。安装时无需命令行，将 Skill 文件手动放入 `~/.claude/skills/` 目录即可，Claude Code 与 OpenCode 共享该目录，装一次两边通用。baoyu-translate 和 baoyu-youtube-transcript 依赖 `bun` 运行时，两个工具下使用前均需提前安装。 |
| --- | --- |

Skill 的核心价值不是让 Claude 变聪明，而是减少每次使用时的摩擦。不用反复解释「我要的是 Word 格式」，不用每次翻译完再追加「帮我润色一下」，Skill 把这些默认行为固化下来。

装 Skill 也有一个建议：别贪多。先装用得上的，观察一两周，确认真的融入了工作流，再考虑下一个。工具列表长不代表效率高，用熟了一个顶十个。

省时间最好的办法，  
是把重复的事情变成不需要思考的事情。

继续滑动看下一个

AI 必选项

向上滑动看下一个