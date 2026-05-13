--- BEGIN flow-kit/commands/M-health.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】

## 优先级加载（任何逻辑不得违反）

1. **立即加载** `@flow-kit/config/constitution.md`（全局最高优先级）
2. **立即加载** `@flow-kit/config/default-user-config.md`，若存在 `.flow-kit/user-config.md` 则优先加载用户自定义配置
3. 后续所有逻辑必须遵守这两份配置

---

# 代码健康扫描

## 命令

`/flow-kit:health`

## 目的

执行全面的代码健康扫描，检测技术栈、测试覆盖率、Lint 状态和依赖健康状况。按类别生成带评分的健康报告。

## 执行

### 1. 技术栈检测

扫描项目类型文件：

- `package.json` → Node.js/npm 生态
- `go.mod` → Go
- `pom.xml` → Java/Maven
- `Cargo.toml` → Rust
- `pyproject.toml` → Python
- `composer.json` → PHP
- `*.sln` 或 `*.csproj` → .NET

报告检测到的技术栈。

### 2. 测试覆盖率分析

**阈值：**
| 覆盖率 | 状态 | 操作 |
|--------|------|------|
| >80% | 通过 | 健康 |
| 60-80% | 警告 | 需改进 |
| <60% | 失败 | 严重 |

**按技术栈的检测方法：**

- **Node.js**: `npm test` + `coverage/` 报告 (Istanbul/NYC)
- **Go**: `go test -cover` → 解析 coverage.out
- **Python**: `pytest --cov` → `.coverage` (Coverage.py)
- **Rust**: `cargo test --lib` → llvm-coverage
- **Java**: `mvn test` → `target/site/jacoco/`
- **.NET**: `dotnet test /p:CollectCoverage=true` → `TestResults/`

**输出格式：**

```json
{
  "coverage": 78,
  "status": "WARN",
  "trend": -2,
  "files_below_threshold": [
    { "file": "src/api/auth.ts", "coverage": 45 },
    { "file": "src/core/worker.ts", "coverage": 52 }
  ]
}
```

**趋势计算：** 与上次扫描结果对比（存储在 `.flow-kit/health-history.json`）

### 2.1 B5/B6 护栏联动（v2.7.0 新增）

**B5 性能护栏结果集成：**

```json
{
  "performance_guardrails": {
    "P1_nested_loops": { "found": 2, "status": "WARN" },
    "P2_n1_queries": { "found": 0, "status": "PASS" },
    "P3_missing_indexes": { "found": 1, "status": "FAIL" },
    "P4_sync_io": { "found": 0, "status": "PASS" }
  }
}
```

**B6 测试覆盖率结果集成：**

```json
{
  "test_coverage": {
    "overall_coverage": 78,
    "status": "WARN",
    "incremental": {
      "new_lines": 150,
      "covered_lines": 120,
      "coverage": "80%",
      "status": "PASS"
    }
  }
}
```

### 3. Lint 状态

**错误分类：**
| 类型 | 标识 | 修复命令 |
|------|------|---------|
| 语法 | Unexpected token, missing } | 手动修复 |
| 风格 | 缩进、分号、引号 | `eslint --fix` |
| 类型 | Type 'X' not assignable to 'Y' | `tsc --noEmit` |

**按技术栈的命令：**

- **Node.js**: `npm run lint` 或 `npx eslint . --format json`
- **Go**: `go vet ./...` → stderr 解析
- **Python**: `flake8 . --statistics` 或 `pylint . --output-format=text`
- **Rust**: `cargo clippy -- -D warnings` → stderr 解析
- **Java**: `mvn checkstyle:check`
- **.NET**: `dotnet format --verify-no-changes`

**输出格式：**

```json
{
  "errors": 3,
  "breakdown": { "syntax": 0, "style": 2, "type": 1 },
  "top_errors": [
    { "file": "src/api/auth.ts", "line": 45, "error": "Unexpected token" }
  ],
  "status": "PASS"
}
```

**趋势：** 与上次扫描的错误数对比。-5 = 改善，+3 = 恶化。

### 4. 依赖健康

**按技术栈的命令：**

- **Node.js**: `npm audit --json` → 解析 `vulnerabilities`
- **Go**: `go list -m all | xargs go mod graph` → 检查冲突
- **Python**: `pip-audit` 或 `safety check --json`
- **Rust**: `cargo audit` → stderr/JSON
- **Docker**: `trivy image .`（若存在 Dockerfile）

**严重度表：**

```markdown
| 严重度 | 数量 | 操作                    |
| ------ | ---- | ----------------------- |
| 严重   | 2    | `npm audit fix --force` |
| 高     | 5    | `npm audit fix`         |
| 中     | 12   | 审查并修复              |
| 低     | 23   | 可选                    |
```

**输出格式：**

```json
{
  "total": 42,
  "breakdown": { "critical": 2, "high": 5, "medium": 12, "low": 23 },
  "critical_items": [
    { "package": "json5@1.0.1", "cve": "CVE-2022-46175", "fix": ">=2.0.0" }
  ],
  "status": "WARN"
}
```

**评分计算：**

- 严重: 每个 -20 分
- 高: 每个 -10 分
- 中: 每个 -5 分
- 低: 每个 -1 分
- 从 100 中扣除

### 5. 代码质量指标

**复杂度检测：**

- 使用 `eslint --print-config` 或语言特定工具
- **阈值**：圈复杂度 >50 = 热点

```markdown
| 复杂度 | 文件                  | 函数            |
| ------ | --------------------- | --------------- |
| 127    | src/core/processor.ts | processItems()  |
| 89     | src/api/handler.ts    | handleRequest() |
```

**重复代码检测：**

- **Node.js**: `npx jscpd .` 或 `pmd cpd`
- **Python**: `pylint --disable=all --enable=DuplicationDefinedName`
- **Go**: `mvdan.cc/gofumpt` + 自定义分析

```markdown
| 行数 | 文件              | 相似文件                      |
| ---- | ----------------- | ----------------------------- |
| 47   | src/utils/auth.ts | src/compat/legacy-auth.ts:124 |
| 23   | src/api/users.ts  | src/api/accounts.ts:89        |
```

**死代码检测：**

- **Node.js**: `ts-prune` 或 `depcheck`
- **Python**: `vulture`
- **未使用的导出**：AST 分析

```markdown
**死代码（5 项）：**

- `src/core/legacy.ts` - 未使用的导出: `processLegacy`
- `src/api/v1/users.ts` - 未使用: `getUserStats`
```

**输出格式：**

```json
{
  "complexity_hotspots": 3,
  "duplication_blocks": 5,
  "dead_code_items": 7,
  "score": 85,
  "status": "PASS"
}
```

## 输出格式

````markdown
## 健康报告

**技术栈**: TypeScript, React, Node.js
**扫描时间**: 2026-05-07 10:30:00
**耗时**: 45s

### 摘要

| 类别       | 评分     | 状态 | 趋势 |
| ---------- | -------- | ---- | ---- |
| 测试覆盖率 | 78%      | 警告 | -2%  |
| Lint 状态  | 3 errors | 通过 | -5   |
| 依赖健康   | 2 高     | 警告 | -1   |
| 代码质量   | 85       | 通过 | +3   |

**总体**: 通过（1 个警告）

### 详情

[测试覆盖率]

- 低于 60% 的文件: src/api/auth.ts (45%), src/core/worker.ts (52%)
- 趋势: 较上次扫描下降 2%

[依赖]

- 严重: json5@1.0.1 (CVE-2022-46175)
- 高: express@4.18.0 (CVE-2022-44946)

[代码质量]

- 热点: src/core/processor.ts (127 复杂度)
- 死代码: 7 个未使用的导出

### 操作项

1. [警告] 测试覆盖率低于 80% 目标
2. [严重] 修复 2 个严重漏洞
3. [低] 移除 7 个死代码导出

### JSON 输出（用于自动化）

```json
{
  "scan_time": "2026-05-07T10:30:00Z",
  "stack": ["TypeScript", "React", "Node.js"],
  "duration_seconds": 45,
  "summary": {
    "test_coverage": { "score": 78, "status": "WARN", "trend": -2 },
    "lint_status": { "errors": 3, "status": "PASS", "trend": -5 },
    "dependencies": { "critical": 0, "high": 2, "status": "WARN", "trend": -1 },
    "code_quality": { "score": 85, "status": "PASS", "trend": 3 }
  },
  "overall": { "status": "PASS", "score": 82, "warnings": 1 }
}
```

## 评分

| 评分   | 状态 | 含义         |
| ------ | ---- | ------------ |
| 90-100 | 优秀 | 健康状况最佳 |
| 70-89  | 通过 | 轻微问题     |
| 50-69  | 警告 | 需要关注     |
| <50    | 失败 | 严重问题     |

## 用法

```bash
@flow-kit/commands/M-health.md
```
````
