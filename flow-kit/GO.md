# flow-kit v3.x 入口文档

> flow-kit v3.x — 精简版入口，22 个核心命令

## 22 个核心命令

| 命令                          | 说明         | Phase |
| ----------------------------- | ------------ | ----- |
| `/flow-kit:init`              | 初始化变更   | -     |
| `/flow-kit:health`            | 健康扫描     | -     |
| `/flow-kit:scan`              | 代码库扫描   | -     |
| `/flow-kit:scale`             | 评估变更规模 | -     |
| `/flow-kit:mode`              | 切换执行模式 | -     |
| `/flow-kit:guard`             | 启用护栏     | -     |
| `/flow-kit:hooks`             | Hooks 指南   | -     |
| `/flow-kit:register-commands` | 注册命令     | -     |
| `/flow-kit:generate-commands` | 生成命令     | -     |
| `/flow-kit:archive`           | 归档变更     | -     |
| `/flow-kit:next`              | 进入下一阶段 | -     |
| `/flow-kit:status`            | 查看状态     | -     |
| `/flow-kit:resume`            | 恢复会话     | -     |

### Phase 工作流命令

| 命令                | 说明     |
| ------------------- | -------- |
| `/flow-kit:phase-0` | 变更立项 |
| `/flow-kit:phase-1` | 需求澄清 |
| `/flow-kit:phase-2` | 架构设计 |
| `/flow-kit:phase-3` | 任务拆解 |
| `/flow-kit:phase-4` | 开发执行 |
| `/flow-kit:phase-5` | 测试验证 |
| `/flow-kit:phase-6` | 代码审查 |
| `/flow-kit:phase-7` | 集成归档 |
| `/flow-kit:phase-8` | 变更回滚 |

## Phase 条件路由

Phase 执行时自动检测项目类型，加载差异化工作流：

```bash
./flow-kit.sh phase-0   # 执行变更立项
```

**输出示例**：

```
[phase-exec] type=brownfield phase=0-change
[phase-exec] workflow=flow-kit/phases/0-change/brownfield.md

[phase-exec] guard: /flow-kit:guard full
```

### 护栏建议

| 项目类型 | 建议                      | 说明                  |
| -------- | ------------------------- | --------------------- |
| 棕地     | `/flow-kit:guard full`    | 启用全部护栏 B1-B6    |
| 绿地     | `/flow-kit:guard minimal` | 启用核心护栏 B2/B4/B6 |

## 执行模式

| 模式      | 命令                       | 说明                    |
| --------- | -------------------------- | ----------------------- |
| Autopilot | `/flow-kit:mode autopilot` | L0-L1 单 Agent 自主执行 |
| Team      | `/flow-kit:mode team`      | L2-L3 多 Agent 协作     |
| Ralph     | `/flow-kit:mode ralph`     | Team + 验证循环         |

## 快速开始

```bash
# 1. 初始化项目
/flow-kit:init "添加用户反馈功能"

/flow-kit:health          # 健康扫描
/flow-kit:phase-0        # 变更立项
/flow-kit:phase-1        # 需求澄清

# 2. 规模评估后选择模式
/flow-kit:scale           # 评估 L0-L3

# 3. 执行 Phase
/flow-kit:phase-2         # 架构设计
/flow-kit:phase-3         # 任务拆解
/flow-kit:phase-4         # 开发执行
/flow-kit:phase-5         # 测试验证
/flow-kit:phase-6         # 代码审查
/flow-kit:phase-7         # 集成归档
```

## CLI 用法

```bash
./flow-kit.sh help                      # 显示帮助
./flow-kit.sh status                    # 查看状态
./flow-kit.sh health                    # 健康扫描
./flow-kit.sh mode team                 # 切换模式
./flow-kit.sh phase-0                   # 执行 Phase 0
./flow-kit.sh change init "描述"        # 初始化变更
```

## v3.x 改进

- **精简命令**：154 → 22 个核心命令
- **条件路由**：phase-executor.sh 根据项目类型加载不同工作流
- **护栏建议**：自动输出棕地/绿地护栏建议
- **Phase 自动路由**：`./flow-kit.sh phase-N` 自动路由到对应工作流
