---
title: "Claude Code Token 优化 2026：把 API 账单砍 60-90% 的 5 个策略"
source: "https://ofox.ai/zh/blog/claude-code-token-optimization-5-strategies-2026/"
author:
  - "[[Ofox.ai]]"
published: 2026-05-13
created: 2026-05-15
description: "一份不讲套话的 Claude Code 省钱手册：prompt caching、模型分级、上下文卫生、thinking 预算、hooks 和 Batch API 怎么叠加用，把每天 13 美金的开发者预算压到个位数。"
tags:
  - "clippings"
---
**TL;DR** — Claude Code 烧钱的根源不是模型贵，而是同一段 context 反复送进去、Opus 当默认用、extended thinking 没设上限。叠加 prompt caching（命中 token 9 折）、模型分级（Haiku 干杂活、Sonnet 干活、Opus 留给硬骨头）、上下文卫生（瘦 CLAUDE.md + `/compact` + skills）、thinking 预算控制、hooks 预处理 + 子智能体外包，账单能压到原来的 10-40%。下面把每条策略拆到可以照抄的程度。

## 为什么 Claude Code 容易超支

Claude Code 按 token 计费，而它每次对话默认会把 CLAUDE.md、MCP tool 定义、对话历史、文件 read 结果整包发给 Sonnet 4.6 或 Opus 4.7。看一组官方数字：

- Anthropic 披露的企业部署平均成本是 **每位开发者每个活跃日 13 美金** 、每月 150-250 美金
- 用 `/usage` 看一次 token 分布就会发现，70%-90% 的 input token 来自重复的 system prompt + CLAUDE.md + 文件历史
- Opus 4.7 输入 $5/MTok、输出 $25/MTok；Sonnet 4.6 是 $3/$15；Haiku 4.5 是 $1/$5 —— **同样的任务跑 Opus 比 Haiku 贵 5 倍 input、5 倍 output**

省钱不是单点优化，是把这五件事叠起来用。

## 策略 1：把 prompt caching 用满，吃掉 90% 的输入成本

**做什么** ：在 system prompt、tool 定义、长文档、对话历史这些”几乎不变”的内容末尾放一个 `cache_control` 断点。Claude Code 默认已经开启了 cache，但 SDK 调用要手动加。

**为什么管用** ：cache 命中只收 0.1× 基础 input 价。Opus 4.7 input $5/MTok，cache hit 只要 $0.50/MTok。

| 模型 | Input | 5m cache write | 1h cache write | Cache hit |
| --- | --- | --- | --- | --- |
| Opus 4.7 | $5 | $6.25 (1.25×) | $10 (2×) | $0.50 (0.1×) |
| Sonnet 4.6 | $3 | $3.75 | $6 | $0.30 |
| Haiku 4.5 | $1 | $1.25 | $2 | $0.10 |

**回本门槛** ：5 分钟档复用 1 次就划算；1 小时档需要复用 2 次。

**最小 token 门槛** （不到就静默跳过 cache）：

- Opus 4.7 / 4.6 / Haiku 4.5：4096 token
- Sonnet 4.6：2048 token

**SDK 怎么写** （Anthropic Python SDK）：

```python
client.messages.create(
    model="claude-opus-4-7",
    max_tokens=2048,
    system=[
        {
            "type": "text",
            "text": LONG_SYSTEM_PROMPT,   # 长 system + 项目说明
            "cache_control": {"type": "ephemeral"}
        }
    ],
    messages=[{"role": "user", "content": user_query}]
)
```

**最容易踩的坑** ：

- 在 cache 前缀里塞 `Current time: 2026-05-13T14:32:15Z` —— 每次都变，cache 直接作废。日期截断到天，或者干脆放到 cache 断点之后
- 把用户 ID、session ID 写进 system —— 每个用户都是 cache miss
- 内容不到最小门槛 —— 检查 response 里 `cache_read_input_tokens` 是不是 0，是 0 就是没生效

**实战监控** ：把每次响应的 `cache_creation_input_tokens` / `cache_read_input_tokens` / `input_tokens` 三个字段写进日志，盯住 cache hit ratio。稳定 agent 工作流跑到 70%-85% 不算难事。

如果你直接走 Claude Code，cache 是自动开的；要做的是别让 CLAUDE.md 和 MCP tool 列表一直被改动失效（见策略 3）。

## 策略 2：模型分级，别拿 Opus 写 commit message

**做什么** ：默认 Sonnet 4.6，子智能体跑 Haiku 4.5，Opus 4.7 只在多步推理、架构决策、复杂 debug 时切上去。

**价格对比** （每百万 token）：

```plaintext
Haiku 4.5   : input $1   / output $5    （cache hit $0.10）
Sonnet 4.6  : input $3   / output $15   （cache hit $0.30）
Opus 4.7    : input $5   / output $25   （cache hit $0.50）
```

**几个常被忽略的点** ：

- Opus 4.7 用了新 tokenizer， **相同文本可能比 4.6 多用最多 35% token** 。账单不光看单价，看实际 token 量
- Opus 4.7 当下不是所有任务都”性能高 5 倍”，简单 refactor、写测试、生成 docstring 用 Haiku 4.5 几乎看不出差距
- Anthropic 官方披露：单 agent 大约用 **4× 单轮 chat** 的 token，多 agent 协作系统（agent team）大约用 **15× 单轮 chat** 。团队成员请直接指定 `model: haiku` 压成本

**Claude Code 里怎么切** ：

```bash
# 当前会话切换
/model

# 设默认模型
/config

# 子智能体专门指定
# 在 subagent frontmatter 里：
model: haiku
```

**判断口诀** ：写代码 → Sonnet；读 log / 格式化 / commit message / 文件搜索 → Haiku；改架构、多步推理、复杂 bug 排查 → Opus。

## 策略 3：上下文卫生，CLAUDE.md 砍到 200 行以内

**做什么** ：CLAUDE.md 越长，每次对话都要为它付输入费。把”特定工作流”的指令从 CLAUDE.md 挪到 skills，让它们按需加载。

**几条硬规则** ：

1. **CLAUDE.md 控制在 200 行以内** 。5000 token 的 CLAUDE.md = 没打第一个字之前，每轮对话都先付 $0.025（Sonnet 4.6 input 价）
2. **任务切换用 `/clear`** 。聊完登录功能去改支付逻辑，不 clear 就一直拖着登录的 context
3. **`/compact` 带焦点** ：
```plaintext
/compact Focus on test output and code changes
```

或者在 CLAUDE.md 里固化：

```markdown
# Compact instructions
压缩对话时聚焦：测试结果、代码改动、未完成的 TODO
```
4. **MCP server 不用的就关** 。 `/mcp` 看列表，工具定义虽然走 deferred 加载，但服务器连接本身也吃 context。CLI 工具（ `gh` 、 `aws` 、 `gcloud` ）能用就别上 MCP
5. **把领域知识做成 skill** 。“PR review 检查清单”、“数据库迁移流程”这种长指令放进 skill，需要时才进入 context

**进阶** ：用 `/usage` 或自定义 statusline 实时盯 context 占用，超过 60% 就 `/compact` 。等到 95% auto-compact 触发时，压缩质量已经掉下来了。

## 策略 4：给 extended thinking 设上限

**做什么** ：把 `MAX_THINKING_TOKENS` 调到 8000-10000，或者对简单任务直接 `/effort low` 。

**为什么** ：extended thinking 默认开着，thinking token 按 output 价计费（Opus 4.7 $25/MTok、Sonnet 4.6 $15/MTok）。一个复杂任务的 thinking 默认能跑到几万 token，一次请求轻松吃掉 $1+。

**配置方法** ：

```bash
# 环境变量（永久）
export MAX_THINKING_TOKENS=8000

# 当前会话临时切档
/effort low      # 思考预算最小
/effort medium
/effort high     # 默认

# 完全关 thinking
/config          # 在配置里关
```

**用法准则** ：

- 写代码、格式化、查文档 → `/effort low` 或关 thinking
- 多步重构、跨文件追逻辑 → `/effort medium`
- 系统设计、复杂算法、性能调优 → `/effort high`

跑一周 `low` + `medium` 混用，账单一般能再降 20%-30%。

## 策略 5：Hooks 预处理 + 子智能体 + Batch API

**做什么** ：把”会产生大量 token 但 Claude 实际只需要一小部分”的操作外包出去。

### Hook 预处理：把 10000 行日志砍到 100 行

PreToolUse hook 在命令真正执行前修改它。下面这段在 `settings.json` 里加上，跑测试时只把失败的部分喂回 Claude：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/filter-test-output.sh"
          }
        ]
      }
    ]
  }
}
```

配套脚本：

```bash
#!/bin/bash
input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command')

if [[ "$cmd" =~ ^(npm test|pytest|go test) ]]; then
  filtered="$cmd 2>&1 | grep -A 5 -E '(FAIL|ERROR|error:)' | head -100"
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"allow\",\"updatedInput\":{\"command\":\"$filtered\"}}}"
else
  echo "{}"
fi
```

一次测试日志从几万 token 砍到几百，且不会影响主对话 context。

### 子智能体：脏活在副线程跑

跑测试、抓文档、处理 log 这种高 token 输出，丢给 subagent。verbose output 留在子智能体的 context 里，主对话只接收摘要。

```bash
# 在 Claude Code 里调用
请用一个 haiku subagent 把这份 100k 行的 access log 里的 5xx 错误抽出来，按 endpoint 分组统计
```

子智能体显式指定 Haiku 4.5，main session 还在跑 Sonnet。

### Batch API：把可异步任务扔进 50% 折扣通道

Claude Code 本身是交互式，不能走 Batch API。但你完全可以把以下任务拆出去用 SDK 跑 Batch：

- 批量生成测试数据 / fixture
- 全仓库批量重构、批量加注释
- 跑一遍 lint 修复
- 翻译整个文档库

Batch API 在 input + output 上都给 **50% 折扣** ，且能和 prompt caching 叠加。计算下来：

```plaintext
Opus 4.7 + Batch + Cache hit
input:  $5  × 50% × 10% = $0.25/MTok
output: $25 × 50%        = $12.5/MTok
```

适合凌晨自动跑、白天看结果的场景。

## 把这 5 条堆起来：一个真实的成本曲线

假设原来 Sonnet 4.6 跑一个 200-message 的项目对话，全程没优化：

```plaintext
基础 input token：   2,000,000  → $6.00
output token：         600,000  → $9.00
thinking 默认：        300,000  → $4.50
单次成本：约 $19.50
```

叠加 5 条策略后（保守估算）：

```plaintext
缓存命中 70% input：1,400,000 × $0.30/MTok = $0.42
剩余 input：         600,000 × $3/MTok    = $1.80
output（精简后）：    400,000 × $15/MTok  = $6.00
thinking 限到 100k： 100,000 × $15/MTok  = $1.50
约一半子任务下沉到 Haiku：再省 ~$1.50
总计：约 $8.22
```

**净节省约 58%** ，且没换模型 tier。把不紧急的批量任务拆到 Batch API 再省 50%，账单基本就压到原来的 30%-40%。

## 写在最后

省钱不等于少用 Claude Code，是别让它做无谓的活。重复的东西缓存，简单的东西降配，没用的东西不要塞进 context。就这三件事。

如果你调用 Claude API 嫌延迟高、走信用卡麻烦，ofox.ai 提供 OpenAI 兼容接口直连 Claude Opus 4.7 / Sonnet 4.6 / Haiku 4.5，prompt caching 透传，价格按官方 token 比例计算。Claude Code 里改 `ANTHROPIC_BASE_URL` 就能切，本文所有策略一样生效。

相关文章：

- 选 Opus 还是 Sonnet 看这篇： [Claude Opus 4.6 vs Sonnet 4.6 怎么选](https://ofox.ai/zh/blog/claude-opus-4-6-vs-sonnet-4-6-model-selection-guide-2026)
- 最新 Opus 4.7 完整介绍： [Claude Opus 4.7 完全指南](https://ofox.ai/zh/blog/claude-opus-4-7-complete-guide-2026)
- Claude Code 上手实操： [Claude Code 国内使用 + Opus 编程体验](https://ofox.ai/zh/blog/claude-code-china-opus-4-6-coding-experience-2026)
- 报错排查： [Claude API 报错汇总（429/401/529）](https://ofox.ai/zh/blog/claude-api-error-guide-429-401-529-2026)
- 想全局降本： [企业 AI API 接入避坑指南](https://ofox.ai/zh/blog/enterprise-ai-api-pitfalls-selection-guide-2026)