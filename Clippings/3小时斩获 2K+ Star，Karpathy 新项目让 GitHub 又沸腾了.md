---
title: "3小时斩获 2K+ Star，Karpathy 新项目让 GitHub 又沸腾了"
source: "https://mp.weixin.qq.com/s/RpHWmWz39kMn-ujobo0qtQ"
author:
  - "[[小华]]"
published:
created: 2026-05-15
description:
tags:
  - "clippings"
---
小华 *2026年4月2日 19:28*

嗨，我是小华同学，专注解锁高效工作与前沿AI工具！每日精选开源技术、实战技巧，助你省时50%、领先他人一步。👉免费订阅，与10万+技术人共享升级秘籍！

你有没有想过，前沿的AI研究是怎么做出来的？

在过去，那是「肉脑计算机」（也就是我们人类）在吃饭、睡觉、娱乐的间隙，偶尔通过「组会」这种声波互联仪式同步一下进度。一次实验可能要跑几天，中间需要不断调参、改代码、等结果……研究人员的大部分时间都在等待中度过。

**Karpathy 说：这个时代已经结束了。**

## 一句话核心价值

**AutoResearch 是 AI 自主研究框架，它让开发者能够让 AI 代理在单张 GPU 上全自动运行 LLM 训练实验，相比传统人工调参，它能在 8 小时内完成约 100 次实验，让模型在你睡觉时自动进化。**

这不是概念，这是 Andrej Karpathy（前 OpenAI 创始成员、前 Tesla AI 总监）刚刚开源的实战项目。

---

## 核心功能：三文件搞定自主研究

### 功能一：极简架构，极致专注

整个项目只有三个核心文件：

| 文件 | 作用 | 谁修改 |
| --- | --- | --- |
| `prepare.py` | 数据准备、常量定义、运行时工具 | ❌ 固定不变 |
| `train.py` | 模型架构、优化器、训练循环 | ✅ AI 代理修改 |
| `program.md` | AI 代理的指导说明书 | ✅ 人类修改 |

**设计理念** ：

- • 单文件修改：AI 只动 `train.py` ，保持范围可控、diff 可审查
- • 固定时间预算：每次训练严格跑 5 分钟，确保实验可比性
- • 自包含：除 PyTorch 外无外部依赖，单 GPU、单文件、单指标

配图建议：项目文件结构截图

---

### 功能二：AI 代理全自动实验循环

**工作流程** ：

```
读取 program.md → 修改 train.py → 训练 5 分钟 
→ 检查 val_bpb 指标 → 改进或回滚 → 重复
```

**关键设计** ：

- • **val\_bpb** （validation bits per byte）：验证集每字节比特数，越低越好，与词表大小无关，确保架构变更公平比较
- • **5 分钟固定时长** ：无论模型大小、批次大小如何变化，训练时间都固定为 5 分钟
- • **约 100 次实验/晚** ：按 8 小时睡眠计算，一晚可跑约 100 个实验

配图建议：Karpathy 推文截图或实验日志示例

---

### 功能三：可迭代的「研究组织代码」

`program.md` 是整个系统的「灵魂文件」：

```
# 研究目标
在 5 分钟时间预算内，最小化 val_bpb

# 当前最佳
- 架构：Transformer，深度 8
- 优化器：Muon + AdamW
- 当前最优 val_bpb：2.35

# 建议尝试
1. 调整学习率 schedule
2. 尝试不同的注意力模式
3. 优化 batch size
```

**精髓** ：你不是在写 Python 代码，而是在写「如何指导 AI 做研究的说明书」。随着实验进行，你可以不断迭代 `program.md` ，找到最高效的「研究组织代码」。

配图建议：program.md 示例内容

---

## 应用场景：谁能从中受益？

### 场景一：个人研究者的高效实验

**痛点** ：研究人员 90% 的时间花在运行实验、调参、记录结果上。 **方案** ：晚上启动 AutoResearch，早上查看实验日志和最优模型。 **效果** ：一晚完成 100 次实验，相当于传统方式一周的工作量。

### 场景二：超参数自动搜索

**痛点** ：手动 grid search 耗时且难以覆盖全部组合。 **方案** ：AI 代理基于实验结果智能选择下一个实验方向。 **效果** ：更快的收敛到最优配置，减少无效实验。

### 场景三：模型架构探索

**痛点** ：尝试新架构需要大量工程工作。 **方案** ：让 AI 代理在 `train.py` 中自由修改架构、优化器、训练策略。 **效果** ：快速验证疯狂想法，比如「如果我用 Muon 优化器会怎样？」

配图建议：实验对比图表

---

## 使用方法：三步启动自主研究

### 环境要求

- • 单张 NVIDIA GPU（H100 测试通过）
- • Python 3.10+
- • uv 包管理器

### 快速开始

```
# 1. 安装 uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. 安装依赖
uv sync

# 3. 数据准备（约 2 分钟，一次性）
uv run prepare.py

# 4. 手动测试运行（约 5 分钟）
uv run train.py
```

### 启动自主研究模式

1. 1\. 在仓库中启动 Claude/Codex（禁用所有权限）
2. 2\. 输入提示：

```
Hi have a look at program.md and let&#x27;s kick off a new experiment! 
let&#x27;s do the setup first.
```

1. 3\. 去睡觉，让 AI 自己折腾
2. 4\. 早上查看 `train.py` 的修改历史和最佳结果

配图建议：终端运行截图

---

## 小算力适配指南

Karpathy 也考虑到了没有 H100 的普通人：

| 配置项 | H100 默认 | 小算力建议 |
| --- | --- | --- |
| 数据集 | FineWeb | TinyStories（低熵） |
| vocab\_size | 8192 | 256-4096 |
| MAX\_SEQ\_LEN | 1024 | 256 |
| DEPTH | 8 | 4 |
| WINDOW\_PATTERN | SSSL | L（标准注意力） |
| TOTAL\_BATCH\_SIZE | 2^18 | 2^14 |

---

## 项目地址

https://github.com/karpathy/autoresearch

热门阅读

[飞书官方出手了！200+命令+19个AI技能，这个CLI工具让效率提升10倍](https://mp.weixin.qq.com/s?__biz=Mzk0MjcxOTM2Nw==&mid=2247502702&idx=1&sn=e8198f09cc6b1d6389f34ff01c67125e&scene=21#wechat_redirect)

[Paperclip：用AI代理组建零人力公司的开源神器](https://mp.weixin.qq.com/s?__biz=Mzk0MjcxOTM2Nw==&mid=2247502711&idx=1&sn=ab832b7835ecb1bbbf5377fca9e8e70a&scene=21#wechat_redirect)

[告别单打独斗！ClawTeam-OpenClaw 一键 spawn 整个 AI 开发团队](https://mp.weixin.qq.com/s?__biz=Mzk0MjcxOTM2Nw==&mid=2247502672&idx=1&sn=a8fb21d905646ba8f5d7093c84fd0636&scene=21#wechat_redirect)

[一个程序员失业了：他用AI重构了整个公司，结果杀疯了！](https://mp.weixin.qq.com/s?__biz=Mzk0MjcxOTM2Nw==&mid=2247502657&idx=1&sn=d2f0a6c4acd7970bc5815a9d97a3673f&scene=21#wechat_redirect)

[CapCut Mate：开源剪映自动化神器，让AI替你剪视频！](https://mp.weixin.qq.com/s?__biz=Mzk0MjcxOTM2Nw==&mid=2247502624&idx=1&sn=ffc2de046a819f28066b980c703ea7f4&scene=21#wechat_redirect)

开源 · 目录

作者提示: 个人观点，仅供参考

继续滑动看下一个

小华同学ai

向上滑动看下一个