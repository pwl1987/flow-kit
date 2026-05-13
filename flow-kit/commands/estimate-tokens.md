# estimate-tokens

> flow-kit v2.7.0 命令

基于 LOC 估算 token 使用量。

## 使用方法

```
`bash flow-kit/lib/token-estimator.sh` [目标目录]
```

## 参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| 目标目录 | 要估算的目录路径 | .planning/phases |

## 示例

```
`bash flow-kit/lib/token-estimator.sh`
`bash flow-kit/lib/token-estimator.sh` .planning/phases
`bash flow-kit/lib/token-estimator.sh` ./src
```

## 功能说明

1. 统计指定目录中所有 `.md` 文件的行数
2. 根据语言类型（中文/英文/代码）应用不同系数估算 token
3. 计算总 token 与预算（100000）的比例
4. 显示每个 phase 的详细统计

## Token 估算规则

| 类型 | 系数 |
|------|------|
| 中文 | 1.5 |
| 英文 | 0.25 |
| 代码 | 0.35 |

## 状态码

- `0`: 健康，token 在预算内
- `1`: 警告，token 接近预算（≥80%）
- `2`: 阻断，token 超出预算