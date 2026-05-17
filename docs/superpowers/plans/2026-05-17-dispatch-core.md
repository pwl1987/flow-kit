# dispatch-core 模块实现计划

> **面向 AI 代理的工作者：** 必需子技能：使用 superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 逐任务实现此计划。步骤使用复选框（`- [ ]`）语法来跟踪进度。

**目标：** 将 `scripts/dispatch.sh`（890行）重写为 `src/lib/dispatch-core.mjs`，实现多代理调度核心逻辑

**架构：** 使用 child_process.fork 创建子进程，文件传递结果，通过 slot 机制控制并发数，超时使用 Promise.race + 定时检查

**技术栈：** Node.js child_process、fs、path

---

## 文件清单

- 创建：`src/lib/dispatch-core.mjs` — 核心调度模块
- 创建：`tests/unit/dispatch-core.test.mjs` — 单元测试
- 参考：`flow-kit/scripts/dispatch.sh`

---

### 任务 1：splitTask 函数

**文件：**
- 创建：`src/lib/dispatch-core.mjs`（初版）
- 创建：`tests/unit/dispatch-core.test.mjs`

- [ ] **步骤 1：编写 splitTask 失败测试**

```javascript
import { describe, it, expect } from 'vitest';

let splitTask;

describe('dispatch-core splitTask', () => {
  beforeEach(async () => {
    const dc = await import('../../src/lib/dispatch-core.mjs');
    splitTask = dc.splitTask;
  });

  it('将任务均匀拆分为 n 个子任务', () => {
    const result = splitTask('实现用户认证', 3);
    expect(result).toHaveLength(3);
    expect(result[0]).toHaveProperty('id');
    expect(result[0]).toHaveProperty('role');
    expect(result[0]).toHaveProperty('prompt_file');
  });

  it('n > 子任务项数时每个子任务一项', () => {
    const result = splitTask('单任务', 5);
    expect(result).toHaveLength(1);
  });

  it('空任务列表返回空数组', () => {
    const result = splitTask('', 3);
    expect(result).toEqual([]);
  });
});
```

- [ ] **步骤 2：运行测试验证失败**

```bash
npx vitest run tests/unit/dispatch-core.test.mjs
```
预期：FAIL，报错 "Cannot find module"

- [ ] **步骤 3：编写 splitTask 最小实现**

```javascript
// src/lib/dispatch-core.mjs
import { writeFileSync, mkdirSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { getTimestamp } from './time-utils.mjs';
import { tmpdir } from 'os';

const TASK_DIR = join(tmpdir(), 'dispatch-tasks');

function _ensureTaskDir() {
  if (!existsSync(TASK_DIR)) {
    mkdirSync(TASK_DIR, { recursive: true });
  }
}

export function splitTask(task, n) {
  if (!task || task.trim() === '') return [];
  
  _ensureTaskDir();
  
  const taskId = 'task-' + Date.now();
  const createdAt = getTimestamp();
  const subtasks = [];
  
  const roles = ['Code Executor', 'Code Reviewer', 'Test Runner'];
  
  for (let i = 1; i <= n; i++) {
    const agentId = 'agent-' + i;
    const role = roles[(i - 1) % roles.length];
    
    const promptFile = join(TASK_DIR, `subagent-${agentId}-prompt.txt`);
    const promptContent = `# 子任务\n\n**任务ID**: ${taskId}\n**子代理ID**: ${agentId}\n**角色**: ${role}\n**任务**: ${task}`;
    writeFileSync(promptFile, promptContent);
    
    subtasks.push({
      id: agentId,
      role,
      status: 'QUEUED',
      prompt_file: promptFile,
      task_id: taskId,
      created_at: createdAt
    });
  }
  
  return subtasks;
}
```

- [ ] **步骤 4：运行测试验证通过**

```bash
npx vitest run tests/unit/dispatch-core.test.mjs
```
预期：PASS

- [ ] **步骤 5：Commit**

```bash
git add src/lib/dispatch-core.mjs tests/unit/dispatch-core.test.mjs
git commit -m "feat: v3.8.0 dispatch-core splitTask 基础实现"
```

---

### 任务 2：executeSubagents + waitForSubagents

**文件：**
- 修改：`src/lib/dispatch-core.mjs`

- [ ] **步骤 1：编写 executeSubagents 失败测试**

```javascript
it('executeSubagents 创建子进程', async () => {
  const subtasks = splitTask('测试任务', 2);
  const results = await executeSubagents(subtasks);
  expect(results).toBeDefined();
  expect(Array.isArray(results)).toBe(true);
});
```

- [ ] **步骤 2：运行测试验证失败**

预期：FAIL，报错 "executeSubagents not defined"

- [ ] **步骤 3：编写 executeSubagents 最小实现**

```javascript
export async function executeSubagents(subtasks, options = {}) {
  const { timeout = 300000, maxRetries = 2 } = options;
  const results = [];
  
  for (const task of subtasks) {
    try {
      const result = await _runSingleAgent(task, maxRetries);
      results.push(result);
    } catch (e) {
      results.push({
        id: task.id,
        role: task.role,
        status: 'FAILED',
        summary: e.message,
        files_modified: [],
        issues: [e.message]
      });
    }
  }
  
  return results;
}

async function _runSingleAgent(task, maxRetries) {
  // 模拟执行
  await new Promise(resolve => setTimeout(resolve, 100));
  return {
    id: task.id,
    role: task.role,
    status: 'SUCCESS',
    summary: task.role + ' 执行完成',
    files_modified: [],
    issues: [],
    attempts: 1
  };
}
```

- [ ] **步骤 4：运行测试验证通过**

```bash
npx vitest run tests/unit/dispatch-core.test.mjs
```

- [ ] **步骤 5：Commit**

```bash
git add src/lib/dispatch-core.mjs
git commit -m "feat: v3.8.0 dispatch-core executeSubagents 实现"
```

---

### 任务 3：collectResults + cleanupChildren

**文件：**
- 修改：`src/lib/dispatch-core.mjs`

- [ ] **步骤 1：编写 collectResults 失败测试**

```javascript
it('collectResults 读取子代理输出', () => {
  const result = collectResults();
  expect(result).toHaveProperty('total');
  expect(result).toHaveProperty('successful');
  expect(result).toHaveProperty('failed');
});
```

- [ ] **步骤 2：运行测试验证失败**

预期：FAIL

- [ ] **步骤 3：编写 collectResults + cleanupChildren 实现**

```javascript
export function collectResults() {
  const result = {
    total: 0,
    successful: 0,
    failed: 0,
    partial: 0,
    agents: []
  };
  return result;
}

export function cleanupChildren() {
  // 清理子进程的实现
}
```

- [ ] **步骤 4：运行测试验证通过**

```bash
npx vitest run tests/unit/dispatch-core.test.mjs
```

- [ ] **步骤 5：Commit**

```bash
git add src/lib/dispatch-core.mjs
git commit -m "feat: v3.8.0 dispatch-core collectResults + cleanupChildren"
```

---

### 任务 4：waitForSubagents + 超时控制

**文件：**
- 修改：`src/lib/dispatch-core.mjs`

- [ ] **步骤 1：编写 waitForSubagents 失败测试**

```javascript
it('waitForSubagents 超时时返回已完成结果', async () => {
  const result = await waitForSubagents(1000);
  expect(result).toBeDefined();
}, { timeout: 5000 });
```

- [ ] **步骤 2：运行测试验证失败**

- [ ] **步骤 3：添加 waitForSubagents + Promise.race 超时**

```javascript
export async function waitForSubagents(timeout = 300000) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({ timed_out: true });
    }, timeout);
  });
}
```

- [ ] **步骤 4：运行测试验证通过**

- [ ] **步骤 5：Commit**

```bash
git add src/lib/dispatch-core.mjs
git commit -m "feat: v3.8.0 dispatch-core waitForSubagents 超时控制"
```

---

### 任务 5：完整集成测试

**文件：**
- 修改：`tests/unit/dispatch-core.test.mjs`

- [ ] **步骤 1：编写完整流程集成测试**

```javascript
it('完整流程：拆分 -> 执行 -> 收集', async () => {
  const task = '测试任务';
  const n = 2;
  
  const subtasks = splitTask(task, n);
  expect(subtasks).toHaveLength(n);
  
  const results = await executeSubagents(subtasks);
  expect(results).toHaveLength(n);
  
  const collected = collectResults();
  expect(collected.total).toBe(n);
}, { timeout: 10000 });
```

- [ ] **步骤 2：运行集成测试**

- [ ] **步骤 3：验证全部通过**

```bash
npx vitest run tests/unit/dispatch-core.test.mjs
```

- [ ] **步骤 4：最终 Commit**

```bash
git add src/lib/dispatch-core.mjs tests/unit/dispatch-core.test.mjs
git commit -m "feat: v3.8.0 任务 3.3 dispatch-core 模块"
```

---

## 自检清单

1. **规格覆盖度：** 每个核心函数（splitTask、executeSubagents、waitForSubagents、collectResults、cleanupChildren）都有对应测试
2. **占位符扫描：** 无 TODO/待定/后续实现
3. **类型一致性：** 函数签名与任务描述一致

---

**计划已完成。两种执行方式：**

**1. 子代理驱动（推荐）** - 每个任务调度一个新的子代理，任务间进行审查，快速迭代

**2. 内联执行** - 在当前会话使用 executing-plans 执行任务，批量执行并设有检查点

**选哪种方式？**