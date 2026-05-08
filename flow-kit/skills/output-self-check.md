> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本技能实现 R8.3 产物自检清单，借鉴 rihebty/flow-kit 的阶段输出验证机制。

# R8.3 产物自检清单

> v1.11 新增，v1.12 增强：每项增加可执行检查命令

## 概述

每个 phase 输出完成后，AI 必须对照本清单逐项验证，确保产物符合规范。

## 6 项自检清单

> v1.12.2 新增：动态 change-id 路径支持

```bash
# 动态 change-id 变量（自动从 .flow-kit/current-change 读取）
CHANGE_ID=$(cat .flow-kit/current-change 2>/dev/null || echo "")
# 回退逻辑：若不存在，提示用户手动设置
if [ -z "$CHANGE_ID" ]; then
    echo "[R8.3] 警告: .flow-kit/current-change 不存在，请手动设置: export CHANGE_ID=xxx"
fi
```

### 1. 文件存在性检查

```
验证：阶段输出文件是否全部存在
- 检查所有预期的输出文件（.md/.json/.sql 等）是否已创建
- 检查文件命名是否符合 change-id 规范
- 检查文件路径是否符合 .specs/{change-id}/ 结构
```

**可执行命令**：

```bash
# 检查输出文件是否存在（动态 change-id）
CHANGE_ID=$(cat .flow-kit/current-change 2>/dev/null || echo "")
ls -la ".specs/$CHANGE_ID/"*.md 2>/dev/null || echo "[R8.3] 错误: 目录不存在，请设置 CHANGE_ID"

# 检查 SPEC 文件命名规范
grep -l "change-id" ".specs/$CHANGE_ID/"*.md 2>/dev/null
```

### 2. 命名规范检查

```
验证：文件名是否符合 change-id 规范
- 所有产出物必须在 .specs/{change-id}/ 目录下
- 文件名应包含 change-id 前缀（如 v111-xxx.md）
- 禁止在非规格目录下创建变更产物
```

**可执行命令**：

```bash
# 检查是否有文件在规格目录外
find . -name "*.md" -path "./*" ! -path "./.specs/*" ! -path "./flow-kit/*"

# 检查 change-id 前缀
grep -r "v[0-9]*-" .specs/ | head -10
```

### 3. 验收标准可勾选性

```
验证：每条验收标准是否可客观衡量
- 每条标准必须有明确的完成/未完成判定
- 禁止：模糊描述（"完成"、"处理好"）
- 允许：具体指标（"测试通过"、"文件存在"、"API 返回 200"）
```

**可执行命令**：

```bash
# 检查是否包含模糊描述
grep -E "^\s*[-*]\s*(完成|处理好|差不多了|基本完成)" *.md

# 检查是否有可量化指标
grep -E "(通过|失败|存在|返回|生成)" *.md | wc -l
```

### 4. 依赖声明完整性

```
验证：阶段产物的依赖是否已声明
- 外部依赖（npm 包、库版本）是否记录
- 内部依赖（其他 phase 产物）是否引用
- 隐式假设是否显式化
```

**可执行命令**：

```bash
# 检查是否有未声明的 npm 依赖
grep -r "require(" --include="*.js" | grep -v node_modules

# 检查 package.json 是否有新依赖
git diff package.json
```

### 5. 无硬编码默认值

```
验证：配置值和阈值是否有明确来源
- 禁止硬编码的数字魔法值（如 86400、1024）
- 配置值必须引用 ENV 或配置文件
- 超参阈值必须说明来源或依据
```

**可执行命令**：

```bash
# 检测魔法数字（可配置阈值）
grep -rnE "^[^-]*\b(86400|1024|3600|7200|1000)\b" --include="*.js" --include="*.ts"

# 检测 ENV 引用缺失
grep -rn "process.env" --include="*.js" --include="*.ts" | grep -v "require"
```

### 6. 变更范围无越界

```
验证：本次变更是否严格限定在范围内
- 检查是否有修改范围外的文件
- 检查是否有"顺便重构"（未申报的修改）
- 检查 R7.1-R7.4 范围控制规则遵守情况
```

**可执行命令**：

```bash
# 检查 git diff 是否在范围内
git diff --name-only | grep -v ".specs/"

# 检查是否有未申报的文件变更
git status --porcelain | grep -v "^\?\?"
```

## 自检流程

```
阶段输出完成 →
  执行 6 项自检清单 →
  全部通过 → 更新 STATE.md，阶段标记为完成
  任一失败 → 暂停，输出失败项，等待修复后重检
```

## 输出格式

```markdown
## R8.3 产物自检

| 检查项         | 状态  | 说明   |
| -------------- | ----- | ------ |
| 文件存在性     | ✅/❌ | [说明] |
| 命名规范       | ✅/❌ | [说明] |
| 验收标准可勾选 | ✅/❌ | [说明] |
| 依赖声明完整   | ✅/❌ | [说明] |
| 无硬编码默认值 | ✅/❌ | [说明] |
| 变更范围无越界 | ✅/❌ | [说明] |

**结论**：✅ 全部通过 / ❌ 暂停等待修复
```

## 触发时机

- 每个 phase 完成时自动触发
- 用户可手动调用：`/flow-kit:skill output-self-check`

## 参考来源

- [rihebty/flow-kit](https://github.com/rihebty/flow-kit) — R8.3 产物自检清单（RULES.md）
