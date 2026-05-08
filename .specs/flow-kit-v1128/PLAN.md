# flow-kit v1.12.8 代码质量强化方案

## 一、Context

v1.12.7 代码评审发现多项架构设计、错误处理和安全护栏问题，需要在 v1.12.8 中系统修复。

---

## 二、评审摘要 (v1.12.7)

### 2.1 高严重度问题 (P0)

| 问题                   | 文件                   | 行号   | 描述                                                     |
| ---------------------- | ---------------------- | ------ | -------------------------------------------------------- |
| 除零错误               | `stop-quality-gate.sh` | L25-28 | `incremental_lines=0` 时 `$((covered*100/0))` 崩溃       |
| grep -oP 移植性        | `context-budget.sh`    | L56-57 | `\x{4e00}-\x{9fff}` 仅 GNU grep 支持，BSD/macOS 静默失败 |
| set -e + jq 回退       | `dispatch.sh`          | L5     | 不可预测的脚本终止                                       |
| 锁冲突仅警告           | `dispatch.sh`          | L235   | 并发运行互相覆盖结果                                     |
| 无信号处理             | `dispatch.sh`          | 全文   | 提前退出时子进程 orphaned                                |
| result validation 缺失 | `dispatch.sh`          | L658   | wait_for_subagents 仅检查文件存在                        |

### 2.2 中严重度问题 (P1)

| 问题              | 文件                   | 行号   | 描述                              |
| ----------------- | ---------------------- | ------ | --------------------------------- | --- | ------------ |
| prettier 错误静默 | `post-edit-format.sh`  | L28    | `2>/dev/null` 隐藏调试信息        |
| Windows 实现空    | `notification.sh`      | L16-19 | `                                 |     | true` 空操作 |
| DDL 正则不完整    | `pre-tool-guard.sh`    | L36-40 | 未覆盖 `RENAME TO` 格式           |
| stat -c%s 移植性  | `health-rotation.sh`   | L24    | BSD/macOS 使用 `stat -f%z`        |
| date 格式非 POSIX | `error-handler.sh`     | L22    | GNU-specific `%Y-%m-%dT%H:%M:%SZ` |
| npm test 硬编码   | `stop-quality-gate.sh` | L48    | Java/Make 项目不适用              |
| bc 未验证依赖     | `validate-phase.sh`    | L162   | bc 不存在时静默失败               |

### 2.3 低严重度问题 (P2)

| 问题                   | 文件                     | 行号     | 描述                                 |
| ---------------------- | ------------------------ | -------- | ------------------------------------ |
| 变量未加引号           | 多文件                   | 49,46    | `rm -f $archives` 应为 `"$archives"` |
| set -euo pipefail 缺失 | hooks 多数               | 全文     | 错误传播不完整                       |
| 版本头不一致           | `dispatch.sh`            | L1       | 头为 v1.12.4，实际为 v1.12.7         |
| GO.md 路由不一致       | `GO.md` vs `flow-kit.sh` | L139-144 | 映射规则矛盾                         |

---

## 三、v1.12.8 范围

### 3.1 P0: 安全修复 (5项)

| #   | 文件                   | 修复内容                                          |
| --- | ---------------------- | ------------------------------------------------- | --- | -------------------- |
| 1   | `stop-quality-gate.sh` | 修复除零错误，添加 `incremental_lines -eq 0` 检查 |
| 2   | `context-budget.sh`    | 替换 `grep -oP` 为 `awk` UTF-8 范围检测           |
| 3   | `dispatch.sh`          | 添加 `trap` 清理子进程，锁冲突改为 blocking       |
| 4   | `dispatch.sh`          | wait_for_subagents 增加 result JSON 有效性验证    |
| 5   | `dispatch.sh`          | 移除 `set -e` 或重构所有 `jq                      |     | echo` 为显式错误处理 |

### 3.2 P1: 可靠性增强 (5项)

| #   | 文件                  | 修复内容                        |
| --- | --------------------- | ------------------------------- |
| 6   | `post-edit-format.sh` | prettier 错误写入日志而非丢弃   |
| 7   | `notification.sh`     | Windows 实现实际发送 Toast 通知 |
| 8   | `pre-tool-guard.sh`   | 补全 DDL 正则覆盖 `RENAME TO`   |
| 9   | `health-rotation.sh`  | 统一 `stat` 命令 Linux/BSD 检测 |
| 10  | `error-handler.sh`    | 添加 POSIX date 回退格式        |

### 3.3 P2: 代码质量 (4项)

| #   | 文件                     | 修复内容                     |
| --- | ------------------------ | ---------------------------- |
| 11  | 所有 hooks               | 统一添加 `set -euo pipefail` |
| 12  | 所有 hooks               | 变量引用加引号               |
| 13  | `dispatch.sh`            | 版本头更新为 v1.12.8         |
| 14  | `GO.md` vs `flow-kit.sh` | 路由规则同步                 |

---

## 四、关键文件

| 文件                                  | 优先级 | 说明                              |
| ------------------------------------- | ------ | --------------------------------- |
| `flow-kit/hooks/stop-quality-gate.sh` | P0     | 除零错误修复                      |
| `flow-kit/lib/context-budget.sh`      | P0     | grep -oP 替换                     |
| `flow-kit/scripts/dispatch.sh`        | P0     | trap + 锁冲突 + result validation |
| `flow-kit/hooks/pre-tool-guard.sh`    | P1     | DDL 正则补全                      |
| `flow-kit/hooks/post-edit-format.sh`  | P1     | prettier 错误日志                 |
| `flow-kit/hooks/notification.sh`      | P1     | Windows 实现                      |
| `flow-kit/lib/health-rotation.sh`     | P1     | stat 移植性                       |
| `flow-kit/lib/error-handler.sh`       | P1     | POSIX date                        |

---

## 五、执行策略

### 阶段 1: P0 安全修复 (并行)

```
[agent-1] stop-quality-gate.sh 除零修复
[agent-2] context-budget.sh grep替代
[agent-3] dispatch.sh trap + 锁blocking
[agent-4] dispatch.sh result validation
[agent-5] dispatch.sh set -e 重构
```

### 阶段 2: P1 可靠性增强 (并行)

```
[agent-6] post-edit-format.sh 日志
[agent-7] notification.sh Windows
[agent-8] pre-tool-guard.sh DDL
[agent-9] health-rotation.sh stat
[agent-10] error-handler.sh date
```

### 阶段 3: P2 代码质量 (并行)

```
[agent-11] 所有hooks set -euo pipefail
[agent-12] 所有hooks 引号
[agent-13] dispatch.sh 版本头
[agent-14] GO.md vs flow-kit.sh 路由
```

### 阶段 4: 版本号统一

```
更新 VERSION, CLAUDE.md, README.md, CHANGELOG.md → v1.12.8
```

---

## 六、验收标准

```bash
# 1. set -euo pipefail 覆盖所有 hooks
grep -c "set -euo pipefail" flow-kit/hooks/*.sh

# 2. 语法检查通过
bash -n flow-kit/hooks/stop-quality-gate.sh

# 3. E2E 测试全通过
bash flow-kit/tests/e2e-test-harness.sh

# 4. 版本号统一
grep "v1.12.8" flow-kit/VERSION flow-kit/CLAUDE.md

# 5. DDL 正则补全
grep "RENAME TO" flow-kit/hooks/pre-tool-guard.sh

# 6. grep -oP 已替换
grep "AWK" flow-kit/lib/context-budget.sh
```

---

## 七、详细修复方案

### 7.1 stop-quality-gate.sh 除零修复

**位置**: L25-28

**问题代码**:

```bash
local coverage_pct=$((incremental_covered * 100 / incremental_lines))
```

**修复方案**:

```bash
if [ "$incremental_lines" -eq 0 ]; then
    echo "[stop-quality-gate] ⚠️  无新增代码，跳过覆盖率检查"
    return 0
fi
local coverage_pct=$((incremental_covered * 100 / incremental_lines))
```

### 7.2 context-budget.sh grep 替代

**位置**: L56-57

**问题代码**:

```bash
local chinese_count=$(echo "$text" | grep -oP '[\x{4e00}-\x{9fff}]' 2>/dev/null | wc -l || echo 0)
```

**修复方案**:

```bash
# 使用 awk 替代 grep -oP（POSIX 兼容）
local chinese_count=$(echo "$text" | awk '{for(i=1;i<=length;i++){c=substr($0,i,1);if(c ~ /[一-龥]/) count++}} END{print+count}')
```

### 7.3 dispatch.sh trap 清理

**位置**: 函数定义后

**修复方案**:

```bash
# 清理子进程函数
cleanup_children() {
    for pid in "${pids[@]}"; do
        kill -0 "$pid" 2>/dev/null && kill "$pid" 2>/dev/null
    done
}
trap cleanup_children EXIT INT TERM
```

### 7.4 dispatch.sh 锁冲突 blocking

**位置**: L235

**问题代码**:

```bash
if [ ${#conflicting_locks[@]} -gt 0 ]; then
    echo "[dispatch] ⚠️  检测到锁冲突..."
    # 仅警告，继续执行
fi
```

**修复方案**:

```bash
if [ ${#conflicting_locks[@]} -gt 0 ]; then
    echo "[dispatch] 🚫 检测到锁冲突，等待解锁..."
    # 等待锁释放或超时
    wait_for_lock_timeout "$lock_dir" 30 || {
        echo "[dispatch] ❌ 锁冲突超时"
        exit 1
    }
fi
```

### 7.5 dispatch.sh result validation

**位置**: wait_for_subagents 函数

**修复方案**:

```bash
# 验证 result JSON 有效性
if ! jq -e '.status' "$result_file" >/dev/null 2>&1; then
    echo "[dispatch] ❌ result JSON 无效: $result_file"
    continue
fi
```

---

## 八、参考来源

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) — set -euo pipefail 规范
- [bash-hackers/wiki](https://wiki.bash-hackers.org/scripting/posparams) — trap 清理子进程
- [POSIX grep](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/grep.html) — UTF-8 范围检测替代方案
- [shellcheck](https://www.shellcheck.net/) — Shell 脚本静态分析

---

## 九、变更记录

| 版本    | 日期       | 描述                 |
| ------- | ---------- | -------------------- |
| v1.12.8 | 2026-05-08 | 代码质量强化方案创建 |
