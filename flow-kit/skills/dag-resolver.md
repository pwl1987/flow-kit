# DAG 任务依赖解析器

## 概述

DAG Resolver 用于解析 TASK.md 中的任务依赖关系，生成执行序列、并行组和关键路径。

## 核心功能

### 1. 文件声明解析

每个任务可声明其读写的文件：

```markdown
## task-1
files:
  read: ["config.yaml", "src/aa.ts"]
  write: ["dist/aa.js"]
```

### 2. 依赖图构建

**冲突检测逻辑：**
- 两任务冲突：两任务都读写同一文件
- 任务依赖：任务 A 读取任务 B 写入的文件
- 无依赖任务：可并行执行

**依赖关系矩阵：**

```
       | task-1 | task-2 | task-3
task-1 |   -   |   +   |   -
task-2 |   -   |   -   |   +
task-3 |   -   |   -   |   -
```

+ 表示强依赖（task-2 依赖 task-1）
- 表示无依赖（可并行）

### 3. 拓扑排序（Kahn 算法）

1. 计算所有节点入度
2. 入度为 0 的节点入队
3. 弹出节点，加入执行序列
4. 更新相邻节点入度，减为 0 则入队
5. 重复直到队列为空

### 4. 并行组检测（BFS 层序）

1. 从入度为 0 的节点开始 BFS
2. 同层节点组成并行组
3. 记录每个任务的层深（用于关键路径）

### 5. 关键路径计算

关键路径 = 从起点到终点最长路径上的任务序列

计算方法：
- 对每个节点，计算从起点到该节点的最长路径
- 回溯确定关键路径

## 输出格式

```yaml
## 依赖图

### 执行序列
- task-1 → task-2 → task-3
- task-4 (并行组 A，可与 task-3 并行)

### 并行组
- 组 A: [task-4, task-5]
- 组 B: [task-7]

### 关键路径
@critical: task-1 → task-2 → task-3

### 冲突警告
⚠️ task-6 用户标记 [P] 但 DAG 检测到文件冲突（与 task-3 共用 `auth/middleware.ts`），以 DAG 检测为准
```

## [P] 标记冲突处理

当用户手动标记 `[P]`（并行）但 DAG 检测到冲突时：

**处理规则：**
1. DAG 检测结果优先
2. 警告用户冲突详情
3. 建议修正方案

**警告格式：**
```
⚠️ 用户 [P] 标记与 DAG 检测冲突：task-X 与 task-Y 文件冲突，以 DAG 检测为准
```

**示例：**
```
⚠️ task-6 用户标记 [P] 但 DAG 检测到文件冲突（与 task-3 共用 `auth/middleware.ts`），以 DAG 检测为准
```

## 算法实现

### 依赖图构建

```typescript
interface TaskFileAccess {
  read: string[];
  write: string[];
}

interface DependencyGraph {
  tasks: string[];
  edges: Map<string, Set<string>>; // task -> dependent tasks
  conflicts: Map<string, string[]>; // task -> conflicting tasks
}

// 构建依赖图
function buildGraph(tasks: Map<string, TaskFileAccess>): DependencyGraph {
  const edges = new Map<string, Set<string>>();
  const conflicts = new Map<string, string[]>();

  for (const [t1, access1] of tasks) {
    for (const [t2, access2] of tasks) {
      if (t1 === t2) continue;

      // 依赖检测：t1 依赖 t2（t1 读 t2 写的文件）
      const t1ReadsT2Writes = access1.read.some(f => access2.write.includes(f));
      if (t1ReadsT2Writes) {
        if (!edges.has(t2)) edges.set(t2, new Set());
        edges.get(t2)!.add(t1);
      }

      // 冲突检测：两任务读写同一文件
      const hasConflict = access1.read.some(f => access2.read.includes(f)) ||
                          access1.read.some(f => access2.write.includes(f)) ||
                          access1.write.some(f => access2.write.includes(f));
      if (hasConflict && t1ReadsT2Writes === false) {
        conflicts.set(t1, [...(conflicts.get(t1) || []), t2]);
      }
    }
  }

  return { tasks: [...tasks.keys()], edges, conflicts };
}
```

### Kahn 拓扑排序

```typescript
function topologicalSort(graph: DependencyGraph): string[] {
  const inDegree = new Map<string, number>();
  const result: string[] = [];

  // 初始化入度
  for (const task of graph.tasks) {
    inDegree.set(task, 0);
  }
  for (const [, deps] of graph.edges) {
    for (const dep of deps) {
      inDegree.set(dep, (inDegree.get(dep) || 0) + 1);
    }
  }

  // 入度为 0 的节点队列
  const queue = graph.tasks.filter(t => inDegree.get(t) === 0);

  while (queue.length > 0) {
    const node = queue.shift()!;
    result.push(node);

    for (const neighbor of graph.edges.get(node) || []) {
      inDegree.set(neighbor, inDegree.get(neighbor)! - 1);
      if (inDegree.get(neighbor) === 0) {
        queue.push(neighbor);
      }
    }
  }

  return result;
}
```

### BFS 并行组检测

```typescript
interface ParallelGroups {
  groups: Map<string, string[]>; // group name -> tasks
  depths: Map<string, number>;   // task -> depth
}

function detectParallelGroups(graph: DependencyGraph): ParallelGroups {
  const inDegree = new Map<string, number>();
  const depths = new Map<string, number>();

  // 初始化
  for (const task of graph.tasks) {
    inDegree.set(task, 0);
    depths.set(task, 0);
  }
  for (const [, deps] of graph.edges) {
    for (const dep of deps) {
      inDegree.set(dep, (inDegree.get(dep) || 0) + 1);
    }
  }

  const groups = new Map<string, string[]>();
  let currentGroup = 0;
  const queue: string[] = graph.tasks.filter(t => inDegree.get(t) === 0);

  while (queue.length > 0) {
    const levelSize = queue.length;
    const groupKey = `组 ${String.fromCharCode(65 + currentGroup)}`; // A, B, C...

    for (let i = 0; i < levelSize; i++) {
      const node = queue.shift()!;
      depths.set(node, currentGroup);

      if (!groups.has(groupKey)) groups.set(groupKey, []);
      groups.get(groupKey)!.push(node);

      for (const neighbor of graph.edges.get(node) || []) {
        inDegree.set(neighbor, inDegree.get(neighbor)! - 1);
        if (inDegree.get(neighbor) === 0) {
          queue.push(neighbor);
        }
      }
    }
    currentGroup++;
  }

  return { groups, depths };
}
```

### 关键路径计算

```typescript
function findCriticalPath(graph: DependencyGraph, topoOrder: string[]): string[] {
  const dist = new Map<string, number>();
  const prev = new Map<string, string | null>();

  // 初始化
  for (const task of graph.tasks) {
    dist.set(task, 0);
    prev.set(task, null);
  }

  // 拓扑顺序遍历，计算最长路径
  for (const task of topoOrder) {
    for (const neighbor of graph.edges.get(task) || []) {
      const newDist = dist.get(task)! + 1;
      if (newDist > dist.get(neighbor)!) {
        dist.set(neighbor, newDist);
        prev.set(neighbor, task);
      }
    }
  }

  // 找到终点（无后继节点）
  const hasSuccessor = new Set<string>();
  for (const [, deps] of graph.edges) {
    for (const dep of deps) hasSuccessor.add(dep);
  }
  const endpoints = graph.tasks.filter(t => !hasSuccessor.has(t));

  // 从终点回溯找最长路径
  let maxDist = 0;
  let endNode = endpoints[0];
  for (const ep of endpoints) {
    if (dist.get(ep)! > maxDist) {
      maxDist = dist.get(ep)!;
      endNode = ep;
    }
  }

  // 回溯关键路径
  const criticalPath: string[] = [];
  let current: string | null = endNode;
  while (current) {
    criticalPath.unshift(current);
    current = prev.get(current)!;
  }

  return criticalPath;
}
```

## 使用流程

1. **读取 TASK.md**：解析所有任务的文件声明
2. **构建图**：建立依赖边和冲突关系
3. **拓扑排序**：获得执行序列
4. **并行组检测**：标记可并行任务
5. **关键路径**：计算最长依赖链
6. **冲突检查**：对比用户 [P] 标记与 DAG 结果
7. **输出 YAML**：追加到 TASK.md

## 示例

### 输入 TASK.md

```markdown
## task-1
files:
  write: ["config.yaml"]

## task-2
files:
  read: ["config.yaml"]
  write: ["src/aa.ts"]

## task-3
files:
  read: ["src/aa.ts"]
  write: ["dist/aa.js"]

## task-4
files:
  write: ["dist/aa.js"]
[P]
```

### 输出

```yaml
## 依赖图

### 执行序列
- task-1 → task-2 → task-3
- task-4 (并行组 A，可与 task-3 并行)

### 并行组
- 组 A: [task-4]
- 组 B: [task-1]

### 关键路径
@critical: task-1 → task-2 → task-3

### 冲突警告
⚠️ task-4 用户标记 [P] 但 DAG 检测到文件冲突（与 task-3 共用 `dist/aa.js`），以 DAG 检测为准
```

## 注意事项

1. **循环依赖**：如果存在循环，Kahn 算法会提前终止，报告错误
2. **隐式依赖**：仅检测文件级别的依赖，不跟踪函数调用
3. **[P] 标记优先级**：用户 [P] 标记仅作建议，DAG 检测为最终依据
4. **性能**：对于 100+ 任务的文件，图构建复杂度为 O(n²)，可考虑空间换时间的优化
