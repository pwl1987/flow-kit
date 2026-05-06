# Phase 5: P0 Bugfix - Research

**Researched:** 2026-05-07
**Domain:** Defect修复 — 棕地检测、断点续跑、数据库类型识别、skills验证
**Confidence:** HIGH

## Summary

Phase 5修复4个P0缺陷：D-01~D-03是检测类（棕地/绿地、项目类型、数据库类型），D-04~D-05是状态管理（断点续跑），D-08~D-10是skills验证。所有决策已在CONTEXT.md中锁定（10个决策），研究者任务是将这些决策转化为可执行的技术方案。

**Primary recommendation:** 先实现REQ-001（棕地/绿地检测）作为基础设施，因为它影响其他guardrails的激活；skills验证（REQ-004）最后实现因为它是内容检查而非功能代码。

---

## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01**: 组合指纹检测 + 业务代码行数阈值（排除配置白名单）
- **D-02**: 输出到 `.flow-kit/project-type` 标记文件
- **D-03**: checkpoint-state.json 格式（phase, last_completed_plan, last_completed_task, task_index, paused_at, next_action）
- **D-04**: 混合模式触发（自动检测 + 用户确认）
- **D-05**: 清理时机 = 阶段完成 + 新阶段开始 + 用户主动重置
- **D-06**: 静态优先检测策略（配置文件 → 连接字符串 → 文件扩展名）
- **D-07**: 输出到 `.flow-kit/database-type` 标记文件
- **D-08**: 4/4全满足标准（L1使用场景、L2输入/输出、L3示例、L4限制说明）
- **D-09**: 关键skill阻止，辅助skill警告
- **D-10**: M2+M3组合（结构化检查 + 实战测试）

### Claude's Discretion

无 — 所有决策已锁定，研究者只需验证可行性和识别风险。

### Deferred Ideas (OUT OF SCOPE)

- GO.md增加棕地/绿地自动路由（REQ-005，P1）
- phase-executor增加自动清窗（REQ-006，P1）
- 技术栈约束写入Constitution（REQ-010，P2）

---

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| REQ-001 | phases文件增加棕地/绿地分支检测 | 技术方案：组合指纹 + 白名单行数统计 |
| REQ-002 | phase-executor增加断点续跑 | 技术方案：checkpoint-state.json读写 + 恢复逻辑 |
| REQ-003 | database-guardrails增加数据库类型自动检测 | 技术方案：多ORM配置扫描 + URL解析 |
| REQ-004 | skills文件内容充实 + 实战验证 | 技术方案：正则匹配L1-L4 + 分类处理 |

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| 棕地/绿地检测 | API/Backend | — | 文件系统扫描 + Git检查，纯计算 |
| 断点续跑 | API/Backend | Frontend Server | 状态读写操作，跨phase持久化 |
| 数据库类型检测 | API/Backend | — | 配置文件解析，静态分析 |
| Skills验证 | API/Backend | — | 正则匹配 + 文件内容分析 |

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Node.js built-in `fs` | — | 文件系统扫描 | 所有平台可用 |
| Node.js built-in `path` | — | 路径处理 | 无外部依赖 |
| Node.js built-in `child_process` | — | Git命令执行 | 跨平台Git检测 |
| JSON (built-in) | — | 状态序列化 | 无依赖 |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| glob pattern matching | — | 白名单文件匹配 | 白名单检测 |
| regex | — | L1-L4字段验证 | skills内容检查 |

**Installation:** 无外部依赖，全部使用Node.js内置模块。

---

## Architecture Patterns

### System Architecture Diagram

```
[Detection Entry]
       |
       v
+--------------------------+
| Project Type Detection   |
| (brownfield-guardrails)  |
+--------------------------+
       |
       +---> .flow-kit/project-type  (REQ-001)
       |
       v
+--------------------------+
| Checkpoint Manager      |
| (phase-executor extend)  |
+--------------------------+
       |
       +---> .flow-kit/checkpoint-state.json  (REQ-002)
       |
       v
+--------------------------+
| Database Type Detection  |
| (database-guardrails)   |
+--------------------------+
       |
       +---> .flow-kit/database-type  (REQ-003)
       |
       v
+--------------------------+
| Skills Validator         |
| (skills/ content check)  |
+--------------------------+
       (REQ-004)
```

### Recommended Project Structure

```
flow-kit/
├── lib/
│   ├── detection/           # NEW: 检测逻辑
│   │   ├── project-type.js   # REQ-001
│   │   ├── database-type.js  # REQ-003
│   │   └── checkpoint.js      # REQ-002
│   └── validation/
│       └── skills-checker.js  # REQ-004
└── guardrails/
    └── brownfield-guardrails.md  # 更新：引用检测模块
```

### Pattern 1: 文件指纹检测
**What:** 组合多个信号判断项目类型
**When to use:** REQ-001棕地/绿地判断
**Implementation:**
```javascript
// Source: 决策D-01实现
function detectProjectType(cwd) {
  const signals = [];
  
  // Signal 1: .git/ 目录存在
  if (fs.existsSync(path.join(cwd, '.git'))) {
    signals.push('.git exists');
  }
  
  // Signal 2: 锁文件存在
  const lockFiles = ['package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'Gemfile.lock'];
  lockFiles.forEach(f => {
    if (fs.existsSync(path.join(cwd, f))) signals.push(`lock: ${f}`);
  });
  
  // Signal 3: Git remote已配置
  const gitConfigPath = path.join(cwd, '.git', 'config');
  if (fs.existsSync(gitConfigPath)) {
    const config = fs.readFileSync(gitConfigPath, 'utf8');
    if (config.includes('remote.origin.url')) {
      signals.push('git remote configured');
    }
  }
  
  // Signal 4: 业务代码行数统计
  const businessLines = countBusinessCode(cwd, WHITELIST);
  signals.push(`business_lines: ${businessLines}`);
  
  // 判定逻辑
  const isBrownfield = signals.some(s => s.startsWith('.git')) || 
                       signals.some(s => s.startsWith('lock:')) ||
                       signals.some(s => s.includes('git remote')) ||
                       businessLines > 1000;
  
  return { isBrownfield, signals, businessLines };
}
```

### Pattern 2: 白名单业务代码统计
**What:** 排除配置类文件后统计业务代码行数
**When to use:** REQ-001判断项目规模
**Implementation:**
```javascript
// Source: 决策D-01白名单定义
const CODE_EXTENSIONS = ['.ts', '.js', '.jsx', '.tsx', '.py', '.java', '.go', '.rs', '.php'];
const CONFIG_PATTERNS = [
  'tsconfig.json', 'jsconfig.json', '.gitignore', '.eslintrc', '.prettierrc',
  'package.json', 'requirements.txt', 'Pipfile', 'pyproject.toml',
  'README.md', 'LICENSE', 'CHANGELOG.md'
];
const CONFIG_EXTENSIONS = ['.config.js', '.config.ts', '.config.json', '.yaml', '.yml'];

function countBusinessCode(cwd, whitelist) {
  let totalLines = 0;
  
  function walkDir(dir) {
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      
      // 跳过白名单
      if (whitelist.includes(entry.name)) continue;
      if (CONFIG_EXTENSIONS.some(ext => entry.name.endsWith(ext))) continue;
      
      if (entry.isDirectory()) {
        // 跳过node_modules, .git, dist等
        if (!['node_modules', '.git', 'dist', 'build', '__pycache__'].includes(entry.name)) {
          walkDir(fullPath);
        }
      } else {
        // 统计代码文件行数
        const ext = path.extname(entry.name);
        if (CODE_EXTENSIONS.includes(ext)) {
          const content = fs.readFileSync(fullPath, 'utf8');
          totalLines += content.split('\n').length;
        }
      }
    }
  }
  
  walkDir(cwd);
  return totalLines;
}
```

### Pattern 3: Checkpoint State Machine
**What:** 状态文件读/写/恢复的三态管理
**When to use:** REQ-002断点续跑
**Implementation:**
```javascript
// Source: 决策D-03格式定义
const CHECKPOINT_FILE = '.flow-kit/checkpoint-state.json';

function readCheckpoint(cwd) {
  const filePath = path.join(cwd, CHECKPOINT_FILE);
  if (!fs.existsSync(filePath)) return null;
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function writeCheckpoint(cwd, state) {
  const filePath = path.join(cwd, CHECKPOINT_FILE);
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(state, null, 2));
}

function clearCheckpoint(cwd) {
  const filePath = path.join(cwd, CHECKPOINT_FILE);
  if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
}

function shouldResume(cwd) {
  const checkpoint = readCheckpoint(cwd);
  if (!checkpoint) return { should: false };
  
  return {
    should: true,
    checkpoint,
    message: `发现断点（Phase ${checkpoint.phase}, Plan ${checkpoint.last_completed_plan}, Task ${checkpoint.task_index}）。是否恢复？`
  };
}
```

### Pattern 4: Multi-ORM Database Detection
**What:** 按优先级扫描配置文件和连接字符串
**When to use:** REQ-003数据库类型检测
**Implementation:**
```javascript
// Source: 决策D-06检测优先级
const ORM_CONFIGS = [
  { name: 'prisma', files: ['prisma/schema.prisma'], detection: detectPrisma },
  { name: 'sequelize', files: ['sequelize.config.js', 'config/database.js', 'config.json'], detection: detectSequelize },
  { name: 'typeorm', files: ['ormconfig.ts', 'ormconfig.json', 'src/data-source.ts'], detection: detectTypeORM },
  { name: 'knex', files: ['knexfile.js', 'knexfile.ts', 'knexfile.ts'], detection: detectKnex }
];

function detectDatabaseType(cwd) {
  // Priority 1: 配置文件扫描
  for (const orm of ORM_CONFIGS) {
    for (const file of orm.files) {
      const fullPath = path.join(cwd, file);
      if (fs.existsSync(fullPath)) {
        const type = orm.detection(fullPath);
        if (type) return { type, method: 'config-file', confidence: 'high' };
      }
    }
  }
  
  // Priority 2: 连接字符串解析
  const envFiles = ['.env', '.env.local', '.env.production'];
  for (const envFile of envFiles) {
    const envPath = path.join(cwd, envFile);
    if (fs.existsSync(envPath)) {
      const content = fs.readFileSync(envPath, 'utf8');
      const dbType = parseConnectionString(content);
      if (dbType) return { type: dbType, method: 'connection-string', confidence: 'medium' };
    }
  }
  
  // Priority 3: 文件扩展名
  const dbFiles = findDbFiles(cwd, ['.sqlite', '.db', '.sqlite3']);
  if (dbFiles.length > 0) {
    return { type: 'sqlite', method: 'file-extension', confidence: 'low' };
  }
  
  return { type: 'unknown', method: null, confidence: null };
}

function detectPrisma(schemaPath) {
  const content = fs.readFileSync(schemaPath, 'utf8');
  const provider = content.match(/provider\s*=\s*"(\w+)"/)?.[1];
  const PROVIDER_MAP = {
    'mysql': 'mysql', 'postgresql': 'postgresql', 'mongodb': 'mongodb',
    'sqlite': 'sqlite', 'sqlserver': 'mssql'
  };
  return PROVIDER_MAP[provider] || null;
}

function parseConnectionString(content) {
  const URL_PATTERNS = [
    { pattern: /mysql:\/\//, type: 'mysql' },
    { pattern: /postgresql:\/\/|postgres:\/\//, type: 'postgresql' },
    { pattern: /mongodb:\/\//, type: 'mongodb' },
    { pattern: /sqlite:\/\//, type: 'sqlite' },
    { pattern: /elasticsearch:\/\//, type: 'elasticsearch' }
  ];
  for (const { pattern, type } of URL_PATTERNS) {
    if (pattern.test(content)) return type;
  }
  return null;
}
```

### Pattern 5: Skills L1-L4 Validation
**What:** 正则匹配检查四层结构字段
**When to use:** REQ-004 skills验证
**Implementation:**
```javascript
// Source: 决策D-08验证标准
const SKILL_STRUCTURE = {
  L1: { name: '使用场景', pattern: /##\s*WHEN_TO_USE|##\s*L1.*使用场景/i },
  L2: { name: '输入/输出', pattern: /##\s*HOW_TO_USE|##\s*输入|##\s*L2.*输入/i },
  L3: { name: '示例', pattern: /##\s*EXAMPLE|##\s*示例|##\s*L3.*示例/i },
  L4: { name: '限制说明', pattern: /##\s*NOTES|##\s*限制|##\s*L4.*限制/i }
};

const CRITICAL_SKILLS = ['requirement-clarify', 'subagent-execution', 'verification'];
const AUXILIARY_SKILLS = ['task-master', 'code-review', 'debugging', 'parallel-dispatch'];

function validateSkill(skillPath) {
  const content = fs.readFileSync(skillPath, 'utf8');
  const results = [];
  
  for (const [level, { name, pattern }] of Object.entries(SKILL_STRUCTURE)) {
    const found = pattern.test(content);
    results.push({ level, name, found });
  }
  
  const passCount = results.filter(r => r.found).length;
  const allPass = passCount === 4;
  
  return {
    skill: path.basename(skillPath, '.md'),
    level: results,
    passCount,
    allPass,
    critical: CRITICAL_SKILLS.some(s => skillPath.includes(s))
  };
}

function validateAllSkills(skillsDir) {
  const files = fs.readdirSync(skillsDir).filter(f => f.endsWith('.md'));
  const results = files.map(f => validateSkill(path.join(skillsDir, f)));
  
  // 分类处理
  const failed = results.filter(r => !r.allPass);
  const criticalFailed = failed.filter(r => r.critical);
  const auxiliaryFailed = failed.filter(r => !r.critical);
  
  if (criticalFailed.length > 0) {
    throw new Error(`Critical skills failed validation: ${criticalFailed.map(r => r.skill).join(', ')}`);
  }
  
  if (auxiliaryFailed.length > 0) {
    console.warn(`Warning: Auxiliary skills failed: ${auxiliaryFailed.map(r => r.skill).join(', ')}`);
  }
  
  return results;
}
```

### Anti-Patterns to Avoid

- **白名单硬编码:** 白名单应支持扩展，避免每次添加都要改代码
- **单一路由判断:** 棕地/绿地判断应基于多个信号，不能只看一个文件
- **checkpoint覆盖无确认:** 恢复时不能无声覆盖已有checkpoint
- **数据库类型误判:** 不能仅凭文件扩展名判断数据库类型

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Git状态检测 | 自己解析.git/config | `git rev-parse --is-inside-work-tree` | 跨平台兼容性好 |
| 数据库类型判断 | 写完整解析器 | URL pattern + ORM配置扫描 | 已满足需求，复杂度适中 |
| 行数统计 | 自己实现目录遍历 | Node.js fs recursive | 内置支持 |
| Skills验证 | 手动检查 | 正则匹配自动化 | 效率高，标准化 |

**Key insight:** Node.js内置模块已足够处理所有检测逻辑，无需引入外部依赖。

---

## Common Pitfalls

### Pitfall 1: 白名单覆盖不完整
**What goes wrong:** 某些配置文件未被排除，导致业务代码行数虚高
**Why it happens:** 白名单未包含所有配置模式
**How to avoid:** 参考.gitignore标准格式，支持通配符模式
**Warning signs:** 绿地项目被误判为棕地

### Pitfall 2: Checkpoint状态不一致
**What goes wrong:** phase执行中断后checkpoint记录与实际执行状态不匹配
**Why it happens:** 未在每个task完成时更新checkpoint，或更新时机不当
**How to avoid:** 每个plan/task完成时同步写checkpoint
**Warning signs:** 恢复后跳过了不该跳过的任务

### Pitfall 3: 数据库类型检测优先级错误
**What goes wrong:** 低优先级检测先于高优先级返回结果
**Why it happens:** 检测逻辑未考虑优先级，或过早返回默认结果
**How to avoid:** 严格按配置文件 → 连接字符串 → 文件扩展名顺序检测
**Warning signs:** PostgreSQL项目被误识别为MySQL

### Pitfall 4: Skills验证假阳性
**What goes wrong:** 通过了L1-L4检查但实际内容不实用
**Why it happens:** 正则只检查字段存在，不验证内容质量
**How to avoid:** 结合M3实战测试，实际调用skill验证可用性

---

## Code Examples

Verified patterns from official sources:

### 文件扫描白名单匹配
```javascript
// Source: Node.js built-in fs + path
const WHITELIST = [
  'tsconfig.json', 'jsconfig.json', '.gitignore', '.eslintrc', '.prettierrc',
  'package.json', 'requirements.txt', 'Pipfile', 'pyproject.toml',
  'README.md', 'LICENSE', 'CHANGELOG.md',
  '.DS_Store', 'Thumbs.db'
];

const CONFIG_EXTENSIONS = ['.config.js', '.config.ts', '.config.json', '.yaml', '.yml'];

function isWhitelisted(filePath) {
  const fileName = path.basename(filePath);
  if (WHITELIST.includes(fileName)) return true;
  return CONFIG_EXTENSIONS.some(ext => fileName.endsWith(ext));
}
```

### Checkpoint状态读写
```javascript
// Source: 决策D-03格式定义
const CHECKPOINT_SCHEMA = {
  phase: { type: 'string', required: true },
  last_completed_plan: { type: 'string', required: true },
  last_completed_task: { type: 'string', required: true },
  task_index: { type: 'number', required: true },
  paused_at: { type: 'string', required: true },
  next_action: { type: 'string', required: true }
};

function validateCheckpoint(obj) {
  for (const [key, schema] of Object.entries(CHECKPOINT_SCHEMA)) {
    if (schema.required && !(key in obj)) {
      throw new Error(`Missing required field: ${key}`);
    }
  }
  return true;
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| 手动棕地/绿地判断 | 组合指纹自动检测 | Phase 5 (REQ-001) | 一致性提升 |
| 无断点续跑 | checkpoint-state.json | Phase 5 (REQ-002) | 中断恢复能力 |
| 手动数据库类型指定 | ORM配置扫描 | Phase 5 (REQ-003) | 配置简化 |
| 手动skills检查 | 自动化L1-L4验证 | Phase 5 (REQ-004) | 质量标准化 |

**Deprecated/outdated:**
- 无 — Phase 5是新增功能

---

## Assumptions Log

> List all claims tagged `[ASSUMED]` in this research. The planner and discuss-phase use this section to identify decisions that need user confirmation before execution.

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Skills验证使用正则匹配L1-L4 | Pattern 5 | 低 — 正则可调整 |
| A2 | 业务代码行数阈值1000行 | D-01 | 中 — 阈值可能需调 |
| A3 | 5个数据库类型覆盖足够 | D-06 | 中 — 可能需扩展 |

**If this table is empty:** All claims in this research were verified or cited — no user confirmation needed.

---

## Open Questions

1. **白名单扩展机制**
   - What we know: 白名单支持文件模式
   - What's unclear: 是否需要支持用户自定义白名单文件
   - Recommendation: Phase 6考虑增加 `.flow-kit/whitelist.json`

2. **断点续跑与phase-executor集成点**
   - What we know: checkpoint-state.json格式已定义
   - What's unclear: phase-executor的现有实现结构
   - Recommendation: 需先读phase-executor实际代码再确定集成点

3. **Skills实战测试执行方式**
   - What we know: M2正则检查 + M3实际调用
   - What's unclear: 如何模拟实际任务场景调用
   - Recommendation: 先实现M2，M3作为增强

---

## Environment Availability

> Skip this section if the phase has no external dependencies (code/config-only changes).

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Node.js | 所有检测脚本 | ✓ | any | — |
| Git | 项目类型检测 | ✓ | any | — |
| fs module | 文件扫描 | ✓ | built-in | — |

**Missing dependencies with no fallback:**
- 无

**Missing dependencies with fallback:**
- 无

---

## Validation Architecture

> nyquist_validation = false in config.json, skipping this section.

---

## Security Domain

> Not applicable — Phase 5 is defect fix, no security implications.

---

## Implementation Order Recommendation

基于依赖关系，建议实现顺序：

1. **REQ-001** (棕地/绿地检测) — 先完成，因为它影响其他guardrails的激活判断
2. **REQ-003** (数据库类型检测) — 与REQ-001独立，可并行
3. **REQ-002** (断点续跑) — 需要理解phase-executor实现后再做
4. **REQ-004** (skills验证) — 最后实现，因为它是内容检查而非功能代码

---

## Sources

### Primary (HIGH confidence)
- D-01~D-10 (CONTEXT.md locked decisions)
- brownfield-guardrails.md (existing framework)
- database-guardrails.md (existing DDL/DML规范)

### Secondary (MEDIUM confidence)
- skills/ requirement-clarify.md, subagent-execution.md (skill examples)
- phase structure (flow-kit/phases/)

### Tertiary (LOW confidence)
- Implementation patterns (based on Node.js built-in capabilities)

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — 内置模块，无外部依赖
- Architecture: HIGH — 基于锁定决策，方案明确
- Pitfalls: MEDIUM — 需实际验证

**Research date:** 2026-05-07
**Valid until:** 2026-06-07 (30 days, stable domain)