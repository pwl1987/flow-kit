# 13-REQUIREMENT.md — v1.3 Enhancement

## Change ID
v1.3-enhancement

## 需求清单

### R1: system-rules.md 完整性
- **R1.1** `config/system-rules.md` 包含 R1-R8 完整规则，每条规则有编号、描述、类别
- **R1.2** 文件开头有强制约束声明，明确与 constitution.md 的互补关系
- **R1.3** R1.5 重启协议包含 PROGRESS.md 写入格式要求

### R2: caveman-compress.md 压缩效果
- **R2.1** 包含 Lite/Full/Ultra 三级压缩规则表
- **R2.2** 明确必须删除项（礼貌用语、填充词等）和必须保留项（代码块、错误信息等）
- **R2.3** 触发时机与阶段对应：4-dev Full / 5-test Lite / 6-review Lite

### R3: failure-detector.md 懈怠检测
- **R3.1** 包含 5 大懈怠模式：蛮力重试、推卸责任、工具闲置、假忙、被动等待
- **R3.2** 包含 7 点强制排查清单，每点有明确执行要求
- **R3.3** L0-L4 压力升级机制与 verify 失败次数联动

### R4: dag-resolver.md DAG 解析
- **R4.1** 解析 TASK.md 中任务的 files read/write 声明
- **R4.2** 拓扑排序生成执行序列，标记并行组
- **R4.3** 用户 [P] 标记与 DAG 冲突时以 DAG 为准并警告

### R5: careful.md 三级护栏
- **R5.1** `/careful` 激活破坏性命令警告
- **R5.2** `/freeze` 限制文件编辑范围
- **R5.3** `/guard` 组合 /careful 和 /freeze
- **R5.4** `/unfreeze` 解除 freeze 限制

### R6: scale-level.md 规模评估
- **R6.1** L0 Quick Fix：1-2 文件，无公共接口
- **R6.2** L1 Feature：3-10 文件，涉及公共接口
- **L6.3** L2 Epic：10+ 文件，涉及数据库/核心框架
- **L6.4** L3 Architecture：跨系统变更，需要架构评审

### R7: constitution.md 规则链
- **R7.1** BEHAVIORAL PRINCIPLES 前插入规则链引用段
- **R7.2** 明确 system-rules.md 是实际执行层，优先级高于原则声明

### R8: 3-task.md DAG 集成
- **R8.1** [P] 标记后自动调用 DAG 解析器
- **R8.2** TASK.md 末尾追加 YAML 格式依赖图段
- **R8.3** 关键路径任务标记为 @critical

### R9: 4-dev.md 技能集成
- **R9.1** 子代理启动时加载 caveman-compress (Full 级别)
- **R9.2** failure-detector 自动触发条件监控
- **R9.3** R1.6 反重复检查联动

### R10: phase-executor.md R1.8 集成
- **R10.1** Pre-Requisite Gate 增加 R1.8 跨任务失败检查
- **R10.2** grep LESSONS.md 验证执行方案

### R11: GO.md 命令扩展
- **R11.1** 注册 `/careful` `/freeze` `/guard` `/unfreeze` `/scale` 命令
- **R11.2** 初始加载增加 system-rules.md
- **R11.3** 入场检测增加规模自动评估

## 验收标准

1. 所有 6 个新增文件存在且内容完整
2. 所有 5 个修改文件通过验收测试
3. GO.md 命令路由可正确解析 5 个新命令
4. 无语法错误，Markdown 格式正确
5. 术语与 GLOSSARY.md 一致
