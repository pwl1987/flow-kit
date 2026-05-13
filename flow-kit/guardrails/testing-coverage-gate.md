# testing-coverage-gate.md — B6 测试覆盖率门禁

> v2.7.0 P2 新增：测试覆盖率质量门禁

## 覆盖率阈值

| 覆盖率 | 状态     | 操作                       |
| ------ | -------- | -------------------------- |
| <60%   | **阻断** | 必须增加测试，否则无法合并 |
| 60-80% | **警告** | 建议增加测试覆盖           |
| >80%   | **通过** | 满足要求                   |

---

## 增量覆盖率要求

**核心规则**：新增代码的覆盖率必须 >= 80%

### 增量覆盖率计算

```bash
# 1. 获取新增/修改的行数
git diff --stat HEAD~1 -- "*.ts" "*.js" | tail -1

# 2. 获取新增代码的覆盖率
npm run test -- --coverage --changedSince=HEAD~1
```

### 增量覆盖率判定

| 场景     | 要求                    |
| -------- | ----------------------- |
| 新功能   | 新增模块覆盖率 >= 80%   |
| Bug 修复 | 修复相关测试覆盖 >= 80% |
| 重构     | 重构部分测试覆盖保持    |
| 配置文件 | 可豁免覆盖率要求        |

---

## 与 M-health.md 健康扫描联动

测试覆盖率数据自动集成到健康报告：

```json
{
  "test_coverage": {
    "overall_coverage": 78,
    "status": "WARN",
    "trend": -2,
    "incremental": {
      "new_lines": 150,
      "covered_lines": 120,
      "coverage": "80%",
      "status": "PASS"
    },
    "files_below_threshold": [
      { "file": "src/api/auth.ts", "coverage": 45 },
      { "file": "src/core/worker.ts", "coverage": 52 }
    ]
  }
}
```

---

## 豁免规则

以下情况可豁免覆盖率要求：

### 1. 配置文件

```yaml
豁免文件类型：
- *.config.js / *.config.ts
- *.env* 文件
- settings.json
- constants.ts（纯常量定义）
```

### 2. 文档文件

```yaml
豁免文件类型：
- *.md 文件
- CHANGELOG
- README
```

### 3. 生成代码

```yaml
豁免文件类型：
- dist/ 目录
- build/ 目录
- node_modules/
- *.generated.ts
```

### 4. 第三方集成

```yaml
豁免场景：
- 外部 API 适配器（已由上游测试）
- 数据库迁移脚本（手动验证）
```

---

## 执行流程

```
代码变更提交
    │
    ▼
┌─────────────────┐
│ 运行覆盖率检测  │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
  整体     增量
  <60%     <80%
    │         │
    ▼         ▼
  阻断     阻断
  不可合并  不可合并
```

---

## 覆盖率提升指南

### 快速达标方法

1. **识别缺口**：查看 `coverage/lcov-report/index.html` 中的红色行
2. **优先高风险**：先覆盖核心业务逻辑和高复杂度函数
3. **边界条件**：补充空输入、最大值、异常情况的测试
4. **Mock 外部依赖**：隔离测试内部逻辑

### 工具推荐

| 语言                  | 工具            |
| --------------------- | --------------- |
| JavaScript/TypeScript | Jest + Istanbul |
| Python                | pytest-cov      |
| Go                    | go test -cover  |
| Rust                  | cargo-tarpaulin |
| Java                  | JaCoCo          |

---

## 参考来源

- [Jest Coverage](https://jestjs.io/docs/coverage) — Jest 覆盖率配置
- [pytest-cov](https://pytest-cov.readthedocs.io/) — Python 覆盖率插件
- [cargo-tarpaulin](https://github.com/xd009642/tarpaulin) — Rust 覆盖率工具
