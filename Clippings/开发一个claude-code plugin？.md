---
title: "开发一个claude-code plugin？"
source: "https://mp.weixin.qq.com/s/fIhT-FGJLN5KsNOdpbxchg"
author:
  - "[[Star]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
Star *2026年4月12日 23:05*

/plugin-dev:create-plugin 创建一个插件，用于管理日常开发使用的skills,agent等，比如广告后台开发流程，需求分析等.

![[_resources/开发一个claude-code plugin？/034fa1f9443fb0dfa164aa514776be75_MD5.png]]

\---

在进入组件规划之前，我需要了解更多细节，请回答以下问题：

🎯 关于插件定位

1\. 业务场景：这个插件主要服务于哪类开发工作？

\- 广告后台系统开发（前后端）

\- 还是更通用的后台系统开发？

\- 是否有特定技术栈（Java/Go/TypeScript？）

2\. 日常开发流程包括哪些典型环节？例如：

\- 需求分析（PRD 解读、拆解任务）

\- 技术方案设计

\- 代码开发（API 设计、数据库设计等）

\- Code Review

\- 测试（单元测试、接口测试）

\- 上线部署流程

🛠️ 关于具体 Skills/Agents

3\. 你最希望优先实现哪 3-5 个功能？ 比如：

\- /ad-backend:analyze-prd — 解析需求文档，输出任务拆解

\- /ad-backend:design-api — 根据需求设计 RESTful API

\- /ad-backend:review-code — 广告后台专项 Code Review

\- 其他？

4\. 需求分析具体指什么？

\- 输入是 PRD 文档/TAPD 需求？

\- 输出是技术任务列表、接口设计草稿、还是其他？

5\. 是否需要与外部工具集成？（MCP 服务器）

\- TAPD/Jira 需求系统

\- 内部文档系统

\- CI/CD 系统

\- 或者完全本地使用即可

📦关于插件范围

6\. 插件名称你有偏好吗？例如：

\- ad-backend-dev（广告后台开发工具包）

\- biz-dev-toolkit（业务开发工具包）

\- 其他名字？

7\. 是否有参考资料？ 比如团队内部的开发规范文档、流程说明、或者你希望把某些现有文档内化到插件中？

请尽量回答以上问题，即使是大概方向也好，这样我可以为你设计一个真正贴合实际工作的插件！

项目地址： https://github.com/ForrestSu/star-plugin

继续滑动看下一个

程序员的冷浪漫

向上滑动看下一个