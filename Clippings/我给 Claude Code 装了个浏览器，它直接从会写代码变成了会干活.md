---
title: "我给 Claude Code 装了个浏览器，它直接从\"会写代码\"变成了\"会干活\""
source: "https://mp.weixin.qq.com/s/9ROaDK2qzDre9Q7v7e87vg"
author:
  - "[[melong]]"
published:
created: 2026-05-15
description: "一：简介agent-browser（https://github.com/vercel-labs/agent"
tags:
  - "clippings"
---
melong *2026年4月22日 07:00*

## 一：简介

agent-browser（https://github.com/vercel-labs/agent-browser ） 用于打通Agent和浏览器Browser，简单的说可以让AI 可以操作浏览器。

> 它可以先打开页面，再识别交互元素，然后点击、输入、等待页面更新，最后把结果拉回来。  
> 做测试的人会用到，做调研的人会用到，做运营、抓取、后台操作的人也会用到。

agent-browser 支持多种主流的AI 编码工具： Claude Code 、Cursor、Codex、GitHub Copilot、Windsurf、Gemini CLI 等等。  

在这里插入图片描述

## 核心能力

agent-browser 提供了 **15 个以上的命令类别** ，覆盖了你能想到的几乎所有浏览器操作场景。

### 1\. 基础导航与交互

这是最常用的一组命令，也是入门的起点：

```
agent-browser open https://example.com     # 打开页面
agent-browser snapshot                      # 获取页面无障碍树（核心！）
agent-browser click @e2                     # 点击某个元素
agent-browser fill @e3 "test@example.com"  # 填写输入框
agent-browser press Enter                   # 按回车
agent-browser screenshot page.png           # 截图
agent-browser close                         # 关闭浏览器
```

**这里有个关键概念： `@eN` 引用。**

当你执行 `snapshot` 时，agent-browser 会把整个页面解析成一棵无障碍树（Accessibility Tree），并给每个可交互元素分配一个编号，比如 `@e1` 、 `@e2` 、 `@e3` 。后续所有操作都可以用这个编号精确定位，不需要写复杂的 CSS 选择器。

这对 AI 来说太友好了——它不用"猜"元素在哪，看一眼快照就知道该点哪个。

### 2\. 信息提取

```
agent-browser get text @e1          # 获取某元素的文本
agent-browser get html @e1          # 获取 innerHTML
agent-browser get value @e3         # 获取输入框的值
agent-browser get title             # 获取页面标题
agent-browser get url               # 获取当前 URL
agent-browser get attr @e1 href     # 获取某个属性值
```

### 3\. 智能等待

实际操作中，页面加载、Ajax 请求、动画过渡都需要等待。agent-browser 提供了多种等待方式：

```
agent-browser wait "#loading"              # 等待某元素出现
agent-browser wait 2000                     # 等待 2 秒
agent-browser wait --text "加载完成"        # 等待特定文字出现
agent-browser wait --url "**/dashboard"    # 等待 URL 变化
agent-browser wait --load networkidle      # 等待网络空闲
```

### 4\. 截图与标注

```
agent-browser screenshot                       # 普通截图
agent-browser screenshot --full                # 全页面截图
agent-browser screenshot --annotate            # 带元素编号标注的截图
agent-browser pdf report.pdf                   # 导出 PDF
```

`--annotate` 特别好用：截图上会叠加编号标签，每个标签 `[N]` 对应 `@eN` ，这样多模态 AI 模型可以直接看图识别该点哪里。

### 5\. Cookie 与认证管理

这是真正让它实用的杀手级功能：

```
# 用已有的 Chrome 配置文件（复用你已登录的状态）
agent-browser profiles                              # 列出可用配置
agent-browser --profile Default open https://gmail.com

# 持久化会话（跨重启保留登录状态）
agent-browser --session-name myapp open https://myapp.com

# 认证保险库（加密存储密码，AI 看不到明文）
agent-browser auth save mysite
agent-browser auth login mysite
```

这意味着你可以让 Claude Code 操作需要登录的后台系统，而且 **不用每次重新登录，密码还是加密存储的** 。

### 6\. 多标签页与多会话

```
# 多标签页
agent-browser tab new https://docs.example.com    # 新开标签
agent-browser tab new --label api https://api.example.com
agent-browser tab api                               # 按名称切换

# 多会话（完全隔离的浏览器实例）
agent-browser --session agent1 open site-a.com
agent-browser --session agent2 open site-b.com
agent-browser session list
```

### 7\. 网络拦截与模拟

```
agent-browser network route "*/api/user" --body '{"name":"test"}'  # 模拟 API 响应
agent-browser network route "*/ads/*" --abort                       # 拦截广告请求
agent-browser network requests --status 4xx                         # 查看失败请求
agent-browser network har start                                     # 开始 HAR 录制
```

### 8\. 批量执行

当你需要连续执行多条命令时，可以用 `batch` 一次性搞定，避免每条命令单独启动进程的开销：

```
agent-browser batch \
  "open https://example.com" \
  "wait --load networkidle" \
  "snapshot -i" \
  "screenshot result.png"
```

## 三种浏览器模式，覆盖所有场景

| 模式 | 说明 | 适用场景 |
| --- | --- | --- |
| 无头 Chromium（默认） | 不弹窗，后台静默运行 | 日常自动化、CI/CD |
| 有头模式（ `--headed` ） | 弹出浏览器窗口 | 调试、演示 |
| 云端远程浏览器 | 连接 Browserless / Browserbase 等服务 | 大规模并发、无本地浏览器环境 |

云端模式支持多家厂商：

```
agent-browser -p browserless open https://example.com   # Browserless
agent-browser -p browserbase open https://example.com   # Browserbase
agent-browser -p agentcore open https://example.com     # AWS AgentCore
```

## 二：安装

```
npm i -g agent-browser
agent-browser install
npx skills add vercel-labs/agent-browser@agent-browser -g -y
```

在这里插入图片描述

## 三：实战

## 场景一：自动化测试 Web 应用

```
帮我测试一下登录功能：https://ruoyi.eleadmin.com/
```

只需数一句话，会自动调用agent-browser提供的核心能力，自动完成。

1. 1\. 打开登录页
2. 2\. 获取页面快照，找到用户名和密码输入框
3. 3\. 填入测试账号
4. 4\. 点击登录按钮
5. 5\. 等待跳转
6. 6\. 截图保存，确认登录成功  
	在这里插入图片描述
	在这里插入图片描述

## 场景二：批量抓取页面信息

需要从多个页面提取特定数据时，我让 Claude Code 写一个循环：逐个打开链接、用 snapshot 读取页面结构、用 get text 提取关键字段，最后汇总成 CSV。

```
请使用 agent-browser 帮我完成以下任务：

我需要调研国内主流大模型产品的定价信息。请依次打开以下页面：

 1. https://platform.minimaxi.com/docs/pricing/overview （MiniMax）
 2. https://open.bigmodel.cn/pricing （智谱 GLM）
 3. https://dashscope.console.aliyun.com/billing （阿里通义千问）

对每个页面执行以下操作：
 - 打开页面，等待加载完成
  - 获取页面快照，找到定价表格或价格相关区域
 - 提取模型名称、输入价格、输出价格等关键字段
 - 如果页面有多个模型版本，全部提取
 - 截图保存到当前目录，文件名格式：\`pricing_厂商名_日期.png\`

最后把所有数据汇总成一个 Markdown 表格，包含字段：厂商、模型名称、输入价格（元/千tokens）、输出价格（元/千tokens），保存为 \`大模型定价对比.md\`。
```

在这里插入图片描述

在这里插入图片描述

在这里插入图片描述

## 场景三：辅助前端开发调试

写完前端代码后，直接让 Claude Code 打开本地开发服务器，操作页面验证功能是否正常，还能用 `vitals` 命令检查 Web 性能指标：

```
agent-browser vitals http://localhost:3000   # 检查 LCP/CLS/TTFB 等
```

甚至可以开启 React DevTools 集成：

```
agent-browser open --enable react-devtools http://localhost:3000
agent-browser react tree                     # 查看组件树
agent-browser react inspect <fiberId>        # 检查组件的 props 和 state
```

**小米招聘内推**

| 部门 | 岗位名称 | 拟定需求职级 | base地 |
| --- | --- | --- | --- |
| AI应用研发中心 | 大模型算法工程师-研产供AI | 17 | 北京 |
| AI应用研发中心 | 大模型算法专家-情景演练 | 17 | 北京 |
| AI应用研发中心 | 大模型算法-北京 | 17 | 北京 |
| AI应用研发中心 | AI算法工程师 | 16 | 武汉 |
| AI应用研发中心 | 大模型高级算法工程师（武汉） | 16/17 | 武汉 |
| 研产供数字化部 | 高级产品经理 | 16 | 北京 |
| 研产供数字化部 | 【IPD项目管理】低代码平台高级产品经理 | 17 | 北京 |
| 研产供数字化部 | 【IPD数字化】用户体验高级产品经理 | 17 | 北京/武汉 |
| 研产供数字化部 | 【IPD项目管理】AI集成与应用高级产品经理 | 17 | 北京 |
| 研产供数字化部 | 解决方案架构师 | 17 | 北京 |
| 研产供数字化部 | 架构师及专家 | 17 | 武汉 |
| 研产供数字化部 | 测试工程师--支持IPD业务测试 | 17 | 武汉 |
| 研产供数字化部 | 高级软件研发工程师 | 17 | 武汉 |
| 研产供数字化部 | 供应链数字化解决方案专家 | 17 | 武汉 |
| 技术发展与质量管理部 | 高级软件研发工程师 | 17 | 北京 |
| 技术发展与质量管理部 | 平台型产品专家-研发效能方向 | 17 | 北京 |
| 技术发展与质量管理部 | 效能研发工程师 | 17 | 北京 |
| 技术发展与质量管理部 | 高级后端研发工程师 | 17 | 武汉 |
| 零售研发部 | 交易产品经理 | 17 | 北京 |
| 零售研发部 | 交易产品专家 | 17 | 北京 |
| 零售研发部 | 高级运营产品经理 | 17 | 北京 |
| 零售研发部 | 高级测试开发工程师 | 17 | 武汉 |
| 服务研发部 | 后端研发工程师 | 17 | 武汉 |
| 服务研发部 | 后端研发工程师 | 17 | 武汉 |
| 服务研发部 | 技术专家 | 17 | 武汉 |
| 服务研发部 | 高级软件开发工程师 | 17 | 武汉 |
| 中国区销服数字化部 | 数据产品经理 | 17 | 北京 |
| 国际销服数字化部 | 高级零售产品经理 | 17 | 北京 |
| 国际销服数字化部 | CRM产品经理 | 16 | 北京 |
| 国际销服数字化部 | 国际-仓储物流产品经理 | 16 | 北京 |
| 交付履约部 | 进销存产品经理 | 17 | 武汉 |
| 交付履约部 | Java 后端研发工程师 | 17 | 武汉 |
| 交付履约部 | JAVA技术专家 | 17 | 武汉 |
| 交付履约部 | JAVA技术专家(供应链方向) | 17 | 武汉 |
| 交付履约部 | 供应链高级JAVA工程师 | 17 | 武汉 |
| 汽车销交服数字化部 | 汽车出海销交服数字化产品专家 | 17 | 北京 |
| 汽车销交服数字化部 | 汽车零售数字化产品经理 | 17 | 北京 |
| 企业效率部 | 财务xAI产品经理 | 17 | 北京 |
| 企业效率部 | 财务产品经理-（财务运营提效方向） | 17 | 武汉 |
| 企业效率部 | 人力xAI产品经理 | 17 | 北京 |
| 企业效率部 | 高级产品经理（协同基建方向） | 16-17 | 武汉 |
| 企业效率部 | 高级产品经理（资产、行政方向） | 16-17 | 武汉 |
| 企业效率部 | 高级软件开发工程师（财经系统） | 17 | 武汉 |
| 作战室 | 文化运营专员 | 14-15 | 北京 |
| 战略规划与运营部 | 高级用户体验设计师 | 17 | 北京 |
| 数据部 | Java开发工程师 | 17 | 北京 |
| 数据部 | 大数据开发工程师（国际） | 17 | 北京 |
| 数据部 | 大数据开发工程师（中国区） | 17 | 北京 |
| 数据部 | 大数据开发工程师（汽车） | 17 | 北京 |
| 数据部 | 大数据开发工程师（研产供） | 17 | 北京 |
| 数据部 | 大数据开发工程师（中国区） | 17 | 武汉 |
| 数据部 | 大数据研发工程师（设备） | 17 | 武汉 |
| 数据部 | 高级软件研发工程师 | 17 | 武汉 |
| 数据部 | 前端开发工程师 | 17 | 武汉 |

**交个朋友，进AI交流群**

![图片](data:image/svg+xml,%3C%3Fxml version='1.0' encoding='UTF-8'%3F%3E%3Csvg width='1px' height='1px' viewBox='0 0 1 1' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Ctitle%3E%3C/title%3E%3Cg stroke='none' stroke-width='1' fill='none' fill-rule='evenodd' fill-opacity='0'%3E%3Cg transform='translate(-249.000000, -126.000000)' fill='%23FFFFFF'%3E%3Crect x='249' y='126' width='1' height='1'%3E%3C/rect%3E%3C/g%3E%3C/g%3E%3C/svg%3E)

**关注公众号**

****每天分享 ****最新******** **小米AI** ****内部培训资料****

关注公众号-私信回复：

ai资料：获取AI完整资料包

**全家桶** ：获取激活码

**小龙虾：** 获取安装教程

**md** ：获取激活码

继续滑动看下一个

AI软件产品经理

向上滑动看下一个