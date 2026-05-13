> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件实现离线模式检测和内置lint降级逻辑。
> D4-3: Offline Mode Implementation

# Offline Mode

## 状态跟踪

| 状态字段 | 类型 | 默认值 | 说明 |
|---------|------|---------|------|
| `isOffline` | boolean | false | 是否处于离线模式 |
| `offlineReason` | string | null | manual / auto-failover |

## 触发方式

### 手动触发

```
/flow-kit:offline
```

效果：
- `isOffline = true`
- `offlineReason = "manual"`
- 输出确认：`[INFO] Offline mode activated. Using built-in lint adapter.`

### 自动故障转移

当以下错误发生时自动触发：
- 外部lint工具超时（>30s）
- 网络不可达（curl失败）
- 工具命令执行失败（非lint问题）

效果：
- `isOffline = true`
- `offlineReason = "auto-failover"`
- 输出：`[INFO] Auto-switching to offline mode due to: {error}`

### 恢复在线

```
/flow-kit:online
```

## 内置Lint适配器

离线时使用以下内置检查替代外部工具：

### lintPlaceholderCompleteness(files)

检查文件内容中是否存在未填充的占位符：
- 匹配模式：`{{PLACEHOLDER}}`
- 返回：`{valid: boolean, issues: string[]}`

### lintRequiredFiles(phase, files)

验证阶段必需文件是否存在：
- 读取 `.planning/PROJECT.md` 和各phase要求
- 对比实际文件列表
- 返回：`{valid: boolean, missing: string[]}`

### lintYamlJsonFormat(files)

YAML/JSON格式验证：
- 尝试解析YAML/JSON文件
- 捕获语法错误
- 返回：`{valid: boolean, errors: string[]}`

## 与phase-executor集成

在 `flow-kit/lib/phase-executor.sh` 中的集成点：

```
1. Before running external lint tools:
   - Check isOffline flag
   - If isOffline == true:
     - Invoke built-in lint adapter
     - Log: "Running in offline mode (built-in lint)"
   - Else:
     - Run external linters as normal

2. On external tool failure:
   - Set isOffline = true
   - Set offlineReason = "auto-failover"
   - Retry with built-in lint
```

## 安全保证

**Constitution规则始终强制执行**：
- SEC规则（安全检查）：始终运行
- DATA规则（数据保护）：始终运行
- DEPLOY规则（部署安全）：始终运行
- GIT规则（git操作安全）：始终运行

离线模式仅影响：
- 外部工具检测
- 代码质量lint

不影响：
- Constitution安全检查
- 文件存在性验证

## 使用场景

| 场景 | 检测方式 | 行为 |
|------|----------|------|
| 飞机上工作 | 手动执行 `/flow-kit:offline` | 使用内置lint |
| 网络工具超时 | 自动故障转移 | 切换到内置lint |
| CI/CD环境 | 手动执行 `/flow-kit:offline` | 跳过外部依赖 |
| Git操作 | 始终可用 | Constitution检查不受影响 |

---

**关联文件**：
- `@flow-kit/GO.md` (命令路由)
- `@flow-kit/lib/phase-executor.sh` (执行器集成)