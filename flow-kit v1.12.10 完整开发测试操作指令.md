# flow-kit v1.12.10 完整开发测试操作指令

以下指令可直接在终端或 Claude Code 会话中逐项执行。  
**在 Claude Code 中调用 flow‑kit 的正确方式：**
- 启动完整流程：`@flow-kit/GO.md`
- 执行特定命令：`/flow-kit:dispatch`、`/flow-kit:minimal`、`/flow-kit:health` 等
- **对本 AI 发出开发任务**：直接用自然语言说明要求（例如：“请帮我为 validate-phase.sh 添加 jq 检查”），flow‑kit 的 hooks 和 guardrails 会自动约束执行。


## 一、环境初始化（一次性操作）

```bash
# 0. 确认当前版本
cat flow-kit/VERSION
# 预期输出：v1.12.9

# 1. 创建开发分支
git checkout -b feat/v1.12.10

# 2. 赋予所有脚本执行权限
chmod +x flow-kit/hooks/*.sh flow-kit/scripts/*.sh flow-kit/lib/*.sh flow-kit/tests/*.sh 2>/dev/null

# 3. 检查必需依赖
echo "=== 依赖检查 ==="
for cmd in jq git shellcheck; do
    if command -v $cmd &>/dev/null; then
        echo "✅ $cmd 已安装"
    else
        echo "❌ $cmd 缺失——请安装后重试"
    fi
done

# 4. 运行现有基线测试（确保环境正确）
cd flow-kit/tests
bash test-dispatch.sh && echo "✅ test-dispatch 通过"
bash test-hooks.sh     && echo "✅ test-hooks 通过"
bash test-validate.sh  && echo "✅ test-validate 通过"
cd ../..
```


## 二、P0 核心修复与实现

### 2.1 为 validate-phase.sh 添加 jq 前置检查

**问题**：jq 缺失时脚本静默退出，用户无感知。  
**修改文件**：`flow-kit/scripts/validate-phase.sh`

在 `set -euo pipefail` 之后插入以下代码：

```bash
# 依赖检查：jq 必须可用
if ! command -v jq &>/dev/null; then
    printf "[错误] jq 未安装，无法执行 JSON Schema 验证。\n"
    printf "请安装 jq 后重试：brew install jq 或 apt install jq\n"
    exit 3
fi
```

**验证**：
```bash
# 模拟 jq 缺失环境
bash -c 'PATH=/usr/bin command -v jq || echo "模拟缺失成功"'
# 应看到“模拟缺失成功”

# 正常运行脚本
bash flow-kit/scripts/validate-phase.sh --help
# 应显示帮助信息而非报错
```

---

### 2.2 dispatch.sh 并发控制改用 flock

**问题**：`acquire_slot()` 使用 `sleep 0.5` 轮询，高并发下浪费 CPU 且存在潜在竞态。  
**修改文件**：`flow-kit/scripts/dispatch.sh`

用以下新函数替换原有的 `acquire_slot()` 和 `release_slot()`：

```bash
# 使用 flock 实现无竞态槽位管理
acquire_slot() {
    local max_conc="$1"
    local lockfile fd
    for ((i=0; i<max_conc; i++)); do
        lockfile="$TMP_DIR/slot-$i.lock"
        exec {fd}>"$lockfile" 2>/dev/null || continue
        if flock -n "$fd" 2>/dev/null; then
            echo "$fd" > "$TMP_DIR/slot-$$.fd"      # 保存文件描述符编号
            echo "$i"   > "$TMP_DIR/slot-$$.id"      # 保存槽位编号
            return 0
        fi
        exec {fd}>&-                                 # 关闭未获得的 fd
    done
    return 1
}

release_slot() {
    local fd_file="$TMP_DIR/slot-$$.fd"
    if [[ -f "$fd_file" ]]; then
        local fd=$(cat "$fd_file")
        flock -u "$fd" 2>/dev/null || true
        exec {fd}>&- 2>/dev/null || true
        rm -f "$fd_file" "$TMP_DIR/slot-$$.id"
    fi
}
```

**验证**：
```bash
# 1. 静态检查
shellcheck flow-kit/scripts/dispatch.sh

# 2. 单元测试
cd flow-kit/tests
bash test-dispatch.sh
cd ../..

# 3. 并发压力测试（创建 10 个任务竞争 3 个槽位）
cat > /tmp/test-tasks.json << 'EOF'
{
  "tasks": [
    {"agent":"a1","prompt":"sleep 3 && echo done1"},
    {"agent":"a2","prompt":"sleep 3 && echo done2"},
    {"agent":"a3","prompt":"sleep 3 && echo done3"},
    {"agent":"a4","prompt":"sleep 3 && echo done4"},
    {"agent":"a5","prompt":"sleep 3 && echo done5"},
    {"agent":"a6","prompt":"sleep 3 && echo done6"},
    {"agent":"a7","prompt":"sleep 3 && echo done7"},
    {"agent":"a8","prompt":"sleep 3 && echo done8"},
    {"agent":"a9","prompt":"sleep 3 && echo done9"},
    {"agent":"a10","prompt":"sleep 3 && echo done10"}
  ]
}
EOF
bash flow-kit/scripts/dispatch.sh --tasks /tmp/test-tasks.json --max-concurrent 3
# 观察输出：任务应被分为 3 批执行，无进程残留
ps aux | grep -E "sleep|subagent" | grep -v grep   # 应无输出
```

---

### 2.3 实现 5 个核心命令的可执行脚本

按顺序在对话中对本 AI 说（或直接创建文件）：

1. **“请创建 flow-kit/lib/token-estimator.sh，实现基于 LOC 的 Token 估算，支持 80%/100% 预算警告”**
2. **“请创建 flow-kit/lib/expiry-checker.sh，检查上下文过期（15 天警告，30 天阻断）”**
3. **“请创建 flow-kit/lib/cost-reporter.sh，按阶段生成 Token 消耗 Markdown 报告”**
4. **“请创建 flow-kit/lib/context-updater.sh，用 awk 向 CONTEXT.md 的变更日志插入新记录”**
5. **“请创建 flow-kit/lib/pr-generator.sh，基于 git diff --stat 和 git log 生成标准 PR 描述”**

**验证**（全部创建完成后）：
```bash
# 测试 Token 估算（使用当前项目文件）
bash flow-kit/lib/token-estimator.sh .planning/phases 2>/dev/null || \
  echo "若无 .planning/phases，请手动创建测试目录并重试"

# 测试上下文过期检测
bash flow-kit/lib/expiry-checker.sh .planning/phases 2>/dev/null || \
  echo "同上"

# 测试成本报告生成
bash flow-kit/lib/cost-reporter.sh .planning/phases .flow-kit/reports/test-cost.md 2>/dev/null
cat .flow-kit/reports/test-cost.md   # 预览内容

# 测试上下文更新
touch .planning/CONTEXT.md 2>/dev/null || mkdir -p .planning && touch .planning/CONTEXT.md
bash flow-kit/lib/context-updater.sh .planning/CONTEXT.md "新增 v1.12.10 测试" "4-dev"
grep "v1.12.10" .planning/CONTEXT.md   # 应看到新记录

# 测试 PR 描述生成（需在 git 仓库中）
bash flow-kit/lib/pr-generator.sh main HEAD > /tmp/pr-test.md
head -20 /tmp/pr-test.md
```

---

## 三、P1 功能增强与测试扩展

### 3.1 扩展 post-edit-format.sh 支持多语言格式化

**修改文件**：`flow-kit/hooks/post-edit-format.sh`

在文件末尾追加以下函数，并在 `main` 中调用 `format_file` 替换原 prettier 单一调用：

```bash
format_file() {
    local file="$1"
    case "${file##*.}" in
        js|mjs|cjs|ts|jsx|tsx|json|css|scss|html|md|yaml|yml)
            npx prettier --write "$file" 2>/dev/null || true ;;
        py)   python3 -m black --quiet "$file" 2>/dev/null || true ;;
        rs)   rustfmt "$file" 2>/dev/null || true ;;
        go)   gofmt -w "$file" 2>/dev/null || true ;;
    esac
}
```

**验证**：
```bash
# 创建测试文件并格式化
echo 'print(1+2)' > /tmp/test_format.py
bash flow-kit/hooks/post-edit-format.sh /tmp/test_format.py 2>/dev/null
cat /tmp/test_format.py   # 应变为 print(1 + 2)
rm /tmp/test_format.py
```

---

### 3.2 创建安全自动检测脚本

直接对 AI 发出如下指令（或手动创建文件）：

1. **“创建 flow-kit/lib/security-scanner.sh，用 grep 扫描硬编码密钥和 SQL 注入模式”**
2. **“创建 flow-kit/scripts/p0-check.sh，检测 BREAKING-CHANGE.md 或数据库迁移文件以自动阻断 P0 变更”**

**验证**：
```bash
# 1. 安全扫描（若无危险代码，返回空为正常）
bash flow-kit/lib/security-scanner.sh

# 2. P0 检测测试
echo "test" > BREAKING-CHANGE.md
bash flow-kit/scripts/p0-check.sh "BREAKING-CHANGE.md" && echo "不应为 P0" || echo "正确拦截 P0"
rm BREAKING-CHANGE.md
```

---

### 3.3 扩展测试覆盖

**操作**：按顺序在对话中说：
1. **“请创建 tests/test-context-budget.sh，测试 float_cmp 精度、预算阈值触发和 bc/awk 回退”**
2. **“请创建 tests/test-error-handler.sh，测试 log_info/log_error/check_dependencies 等函数”**
3. **“请创建 tests/test-paths.sh，测试 rotate_logs 和路径变量”**
4. **“请创建 tests/e2e-full-flow.sh，模拟 Phase 1 到 Phase 7 的完整流程”**

**验证**：
```bash
cd flow-kit/tests
bash test-context-budget.sh
bash test-error-handler.sh
bash test-paths.sh
bash e2e-full-flow.sh
cd ../..
```

---

## 四、P2 补充优化

### 4.1 实现 caveman-compress.sh

直接对 AI 说：  
**“请创建 flow-kit/lib/caveman-compress.sh，用 sed 实现三级压缩：Lite（去问候）+ Full（去冠词）+ Ultra（去所有虚词和空白）”**

**验证**：
```bash
echo "当然，这是一个好主意。让我解释一下。" | bash flow-kit/lib/caveman-compress.sh lite
# 应移除“当然”“好主意”“让我解释一下”
```

### 4.2 强化 error-handler.sh 并与核心脚本集成

**操作**：
1. 对 AI 说：  
   **“请扩展 flow-kit/lib/error-handler.sh，添加 check_dependencies() 和 pre_flight_check() 函数，并完善错误码常量”**
2. 然后说：  
   **“请在 flow-kit/scripts/dispatch.sh 和 validate-phase.sh 开头 source error-handler.sh，并用 check_dependencies 代替原来的零散检查”**

**验证**：
```bash
bash flow-kit/scripts/dispatch.sh --help   # 应看到无错误
bash flow-kit/scripts/validate-phase.sh --help
```

---

## 五、质量检查与版本发布

### 5.1 代码规范检查

```bash
# 对所有 Shell 脚本执行规范扫描
find flow-kit -name "*.sh" -exec shellcheck {} \;
# 应无 error 和 warning（允许 SC1091 等因路径问题产生的 info）
```

### 5.2 全量测试

```bash
cd flow-kit/tests
for t in test-*.sh e2e-*.sh; do
    echo "===== 运行 $t ====="
    bash "$t" || echo "❌ $t 失败"
done
cd ../..
```

### 5.3 版本提交

```bash
echo "1.12.10" > flow-kit/VERSION

# 更新变更日志（直接在 CHANGELOG.md 顶部插入）
cat >> flow-kit/CHANGELOG.md << 'EOF'

# v1.12.10 (2026-05-08)
## 新增
- lib/token-estimator.sh, expiry-checker.sh, cost-reporter.sh, context-updater.sh, pr-generator.sh（P0-03）
- lib/security-scanner.sh, scripts/p0-check.sh（P1-01）
- lib/caveman-compress.sh（P2-01）
- tests/test-context-budget.sh, test-error-handler.sh, test-paths.sh, e2e-full-flow.sh（P1-02）
## 修复
- validate-phase.sh 添加 jq 前置检查（P0-01）
- dispatch.sh 并发控制改用 flock（P0-02）
- error-handler.sh 增强并集成到 dispatch.sh / validate-phase.sh（P2-02）
## 增强
- post-edit-format.sh 支持 python/rust/go 格式化（P1-03）
EOF

git add -A
git commit -m "feat(v1.12.10): 核心命令实现 + 并发加固 + 测试扩展

- validate-phase.sh: 添加 jq 前置检查
- dispatch.sh: 并发控制改为 flock，消除轮询
- lib/token-estimator.sh, expiry-checker.sh, cost-reporter.sh,
  context-updater.sh, pr-generator.sh: 5 个核心命令脚本
- lib/security-scanner.sh, scripts/p0-check.sh: 安全自动检测
- lib/caveman-compress.sh: 三级输出压缩
- error-handler.sh: 新增 check_dependencies/pre_flight_check
- post-edit-format.sh: 支持 black/rustfmt/gofmt
- tests/: 新增 4 个测试文件（context-budget, error-handler, paths, e2e）"

git push origin feat/v1.12.10
```


## 六、典型问题复现步骤

### 6.1 复现 jq 缺失导致的静默失败（修复前）

```bash
# 1. 临时移除 jq 的路径
mv $(which jq) /tmp/jq_backup

# 2. 运行验证脚本（修复前应静默退出）
bash flow-kit/scripts/validate-phase.sh --phase 1 --file any.json
echo "退出码：$?"   # 修复前为 0，修复后为 3 且输出错误信息

# 3. 恢复环境
mv /tmp/jq_backup $(which jq 2>/dev/null || echo /usr/local/bin/jq)
```

### 6.2 复现 dispatch 并发残留进程（修复前）

```bash
# 1. 回退到 v1.12.9（若已修复则先 stash）
git stash
git checkout v1.12.9

# 2. 创建 10 个任务，限制 3 个槽位
# 使用上面 2.2 节创建的 test-tasks.json
bash flow-kit/scripts/dispatch.sh --tasks /tmp/test-tasks.json --max-concurrent 3 &

# 3. 等待 2 秒后强制杀死主进程
sleep 2
kill $!

# 4. 检查残留子进程（修复前可能残留 sleep 进程）
ps aux | grep "sleep" | grep -v grep
# 若有输出，说明存在残留

# 5. 切回开发分支
git checkout feat/v1.12.10
```

---

以上所有步骤可在 **Claude Code 会话中直接对话实现**（例如说“请帮我做 P0-02 的修改”），也可在 **终端逐项执行**。每完成一个阶段建议立即 `/flow-kit:commit` 保存进度。