# flow-kit 最终开发规范

> **本规范用于指导 Claude Code 从零生成完整 flow-kit 工具包。**  
> 所有文件以 Markdown 形式存放，零依赖，复制即用。  
> 你（Claude Code）将严格按照本规范逐文件生成，不可遗漏任何关键机制。  
>
> **强制约束：**  
> 1. 所有文件必须严格遵守指定的路径和核心内容。  
> 2. 每个文件开头必须有 `> 【CLAUDE CODE INSTRUCTION 强制约束】` 块，写明执行优先级。  
> 3. 输出工件使用 `--- BEGIN 文件名 ---` 和 `--- END 文件名 ---` 包裹。  
> 4. 严格按阶段顺序生成，先建目录结构，再逐文件写入。

---

## 一、整体目录结构（必须创建）

```
flow-kit/
├── GO.md                          # 唯一入口
├── README.md                      # 快速上手 + 成本说明 + 场景决策表
├── core/                          # 8 阶段流程 + 回滚
│   ├── 0-change.md
│   ├── 1-requirement.md
│   ├── 2-design.md
│   ├── 2a-ui-design.md
│   ├── 3-task.md
│   ├── 4-dev.md
│   ├── 5-test.md
│   ├── 6-review.md
│   ├── 7-integration.md
│   └── 8-rollback.md
├── guardrails/                     # 护栏规则
│   ├── brownfield-guardrails.md   # B1～B6 总纲
│   ├── breaking-change.md          # 破坏性变更分级管控
│   ├── database-guardrails.md      # 数据库变更护栏
│   ├── security-checklist.md       # 安全检查清单（YAML）
│   └── ui-guardrails.md            # UI 视觉语汇对齐
├── skills/                         # 元技能包
│   ├── requirement-clarify.md
│   ├── task-master.md
│   ├── subagent-execution.md
│   ├── code-review.md
│   ├── debugging.md
│   ├── parallel-dispatch.md
│   └── verification-before-completion.md
├── commands/                       # 横向命令
│   ├── M-health.md
│   ├── I-intel-scan.md
│   └── update-context.md
│   └── sync-team-config.md
├── mcp/                            # MCP 工具适配
│   ├── mcp-tools-config.md
│   ├── git-integration.md
│   └── external-lint-adapter.md
├── reference/                      # 工程硬规则
│   ├── frontend-engineer-rules.md
│   ├── backend-engineer-rules.md
│   ├── tdd-standard.md
│   ├── adr-template.md
│   └── language-specs/             # 多语言栈规则
│       ├── typescript.md
│       ├── python.md
│       ├── java.md
│       ├── go.md
│       ├── rust.md
│       └── php.md
├── templates/                      # 工件模板
│   ├── CONTEXT.md.template
│   ├── REQUIREMENT.md.template
│   ├── DESIGN.md.template
│   ├── TASK.md.template            # XML 格式
│   ├── SUMMARY.md.template
│   ├── REVIEW.md.template
│   ├── LESSONS.md.template
│   └── ROLLBACK.md.template
├── config/
│   ├── constitution.md             # 全局最高约束
│   └── default-user-config.md      # 默认配置（用户可在项目根 .flow-kit/ 覆盖）
└── archive/
    └── archive-change.md           # 归档逻辑
```

**项目侧目录（自动创建）：**
```
.specs/                           # 所有变更工件
├── CONTEXT.md                    # 老项目上下文
├── LESSONS.md                    # 全局经验库
├── COST-REPORT.md                # 月度成本报告
├── pending-approvals/            # 审批文件
└── archive/                      # 历史归档
```

---

## 二、第一阶段：核心骨架（1～2 天）
### 阶段目标
完成目录创建、入口路由、8阶段基础模板、核心模板文件，并在一个新项目上跑通最小闭环。

### 生成文件规范

#### 1. 首先创建所有目录
```
flow-kit/
flow-kit/core/
flow-kit/guardrails/
flow-kit/skills/
flow-kit/commands/
flow-kit/mcp/
flow-kit/reference/
flow-kit/reference/language-specs/
flow-kit/templates/
flow-kit/config/
flow-kit/archive/
```

#### 2. `flow-kit/GO.md` — 唯一入口
**核心逻辑：**
```
> 【CLAUDE CODE INSTRUCTION 强制约束·第一步】
> 1. 立即加载 @flow-kit/config/constitution.md（全局最高优先级，任何逻辑不得违反）
> 2. 立即加载 @flow-kit/config/default-user-config.md，若存在 .flow-kit/user-config.md 则优先加载用户自定义配置
> 3. 后续所有逻辑必须遵守这两份配置

> 【CLAUDE CODE INSTRUCTION 强制约束·全局命令解析】
> 若用户输入以下快捷指令，直接路由：
> /flow-kit:health → @flow-kit/commands/M-health.md
> /flow-kit:scan → @flow-kit/commands/I-intel-scan.md
> /flow-kit:update-context → @flow-kit/commands/update-context.md
> /flow-kit:sync-config → @flow-kit/commands/sync-team-config.md
> /flow-kit:archive → @flow-kit/archive/archive-change.md

--- 入场检测 ---
1. 检测项目根目录是否存在 .specs/ 目录，否则自动创建。
2. 检测 .specs/CONTEXT.md 是否存在 → 老项目存量上下文模式。
3. 否则检测项目是否包含源代码（src/、package.json 等）→ 老项目首次使用：
   提示选择：
     1. 综合扫描 + 现有 AI 文档（AGENTS.md、.cursor/rules/ 等）生成 CONTEXT.md（推荐）
     2. 以现有文档为准，跳过扫描
     3. 跳过（不推荐）
   若选择1，立即调用 @flow-kit/guardrails/brownfield-guardrails.md 执行 B1 入场扫描，生成 CONTEXT.md。
4. 否则 → 绿地新项目。

5. 记录全局变量 PROJECT_TYPE = greenfield / brownfield。

--- 场景路由 ---
- 若用户需求代码量 < 50行 或 明确是一次性脚本、原型验证：
   警告 “不建议使用 flow-kit，裸跑更高效”，若用户强行启用则进入**极简模式**（跳过5-test、6-review）。
- 新项目 MVP / 周末小工具：极简模式。
- 生产代码 / 老项目迭代：完整8阶段。
- 金融/医疗/安全关键场景：完整8阶段 + 强制所有护栏 + 提示安装外部 lint 工具。

--- 变更立项 ---
调用 @flow-kit/core/0-change.md 生成 change-id 并创建 .specs/{change-id}/ 目录。

--- 状态管理 ---
- 每个阶段结束后更新 .STATE 文件，记录当前阶段与任务状态。
- 中断后再启动，自动检测 .STATE，从断点继续。
- 每个阶段完成后执行**强制清窗**：
   保留：输出工件 @链接、.STATE、全局配置
   清除：详细规则、中间对话、调试细节
   主上下文 token 控制在 50k 以内。

--- 回滚支持 ---
若用户输入包含 --rollback {change-id}，调用 @flow-kit/core/8-rollback.md。
```

#### 3. `flow-kit/README.md`
包含：项目定位、成本估算表（裸跑 vs 完整 vs 极简）、场景决策流程图、使用方法、版本信息与参考基线。

#### 4. `flow-kit/core/0-change.md` — 变更立项
```
> 【CLAUDE CODE INSTRUCTION 强制约束·change-id 生成规则】
> 1. 从用户需求提取核心功能关键词，转小写、数字、短横线组合（slugify）。
>    中文转拼音首字母或直译英文，移除特殊字符。
>    示例：“添加通知中心” → “notification-center”
> 2. 最终格式：{slugified-function}-{YYYYMMDD}
> 3. 生成 .specs/{change-id}/ 目录，内部创建 CHANGE.md 和 .STATE。
```

#### 5. `flow-kit/core/1-requirement.md` — 需求澄清
- 优先加载 `@flow-kit/skills/requirement-clarify.md`。
- 执行 grill-me：目标用户、核心场景、验收标准、非功能需求。
- 若项目有已有文档，执行 grill-with-docs。
- **历史教训预警**：扫描 `.specs/LESSONS.md` 中与当前变更关键词、技术栈匹配的记录，按本文后续规定的匹配规则展示，用户确认后继续。
- 输出 `REQUIREMENT.md`（可勾选验收项），用户确认后进入下一阶段。

#### 6. `flow-kit/core/2-design.md` — 架构设计
```
> 【CLAUDE CODE INSTRUCTION 强制约束·按项目类型适配】
> 若 PROJECT_TYPE=greenfield：可自由推荐5套技术栈，允许引入新技术。
> 若 PROJECT_TYPE=brownfield：
>   - 技术栈必须优先从 CONTEXT.md 选取，禁止引入新技术栈，除非用户明确书面同意。
>   - 强制激活 B2 架构对齐护栏：列清复用/修改/新增模块，校验架构一致性。
```
- 输出5张技术栈卡片，用户选择或由AI推荐。
- 生成 `DESIGN.md`，必要时用 `adr-template.md` 生成 ADR。
- 若检测到前端变更，自动提示进入 `2a-ui-design`。
- 扫描 LESSONS.md 相关架构教训并提醒。

#### 7. `flow-kit/core/2a-ui-design.md` — UI 专项设计
- 老项目前端变更时，先触发 B6 视觉语汇对齐（调用 `@guardrails/ui-guardrails.md`）：扫描当前项目 CSS token、hover、缓动、elevation、图标库、文案调性，生成视觉观察报告，用户确认后继续。
- 输出 v0 草稿（调性、主色、字体、布局假设），用户确认后才写完整 `UI-DESIGN.md`。
- 强制包含占位符策略表（图标、头像、图片占位规则），禁止编数据、用 emoji 凑图标。
- 绑定 `@reference/frontend-engineer-rules.md` 硬规则。

#### 8. `flow-kit/core/3-task.md` — 任务拆解
- 加载 `@skills/task-master.md`。
- 自动检测项目语言（扫描 package.json、go.mod 等），加载对应 `@reference/language-specs/{lang}.md`。
- 拆为 5-15 分钟原子任务，生成 `TASK.md`（XML 格式，模板见下方）。
- 标记 `[P]` 并行任务，检测文件冲突：若两个并行任务修改同一文件，自动改为串行。
- 老项目时每个任务强制声明 `read_files` / `write_files`（B3 边界约束）。
- 每个任务附带可执行 `verify` 命令。
- 扫描 LESSONS.md 历史拆解教训。

**XMl 任务模板示例（写入 `templates/TASK.md.template`）：**
```xml
<tasks change-id="{{change-id}}">
  <task id="001" parallel="false">
    <desc>创建数据库迁移脚本</desc>
    <files read="db/schema.sql" write="db/migrations/20240506_add_notification.sql"/>
    <verify>npx sequelize db:migrate --dry-run</verify>
  </task>
  <task id="002" parallel="true">
    <desc>创建 Notification 模型</desc>
    <files read="src/models/index.ts" write="src/models/Notification.ts"/>
    <verify>npx jest src/models/Notification.test.ts</verify>
  </task>
  ...
</tasks>
```

#### 9. `flow-kit/core/4-dev.md` — 开发执行
- 每个任务启动独立子代理，`【FRESH CONTEXT START】` 包裹，仅传入当前任务片段、护栏规则、硬规则。
- 严格 TDD（红/绿/重构），引用 `tdd-standard.md`。
- 执行 verify，失败自动修改（最多3次，仍失败标记 `FAILED`）。
- 老项目强制 B5 沿用抽象 grep：写新函数/组件前 grep 已有实现，优先复用。
- 错误诊断启动独立 `debugging.md` 子代理。
- 每任务输出极简 `SUMMARY.md`（caveman 模式）。

#### 10. `flow-kit/core/5-test.md` — 测试验证
- 运行：单元 → 集成 → 边界 → 迁移兼容性测试。
- 自动检测测试框架，输出覆盖率。
- BUG 自动回写新任务并闭环。

#### 11. `flow-kit/core/6-review.md` — 代码审查
- 三轮审查：意图合规、设计合规、代码质量。
- 跨模型 spot-check（若 Opus 可用），不可用则 Sonnet 多轮。
- 自动调用外部 lint（impeccable、brooks-lint），不可用则走内置规则。
- 强制执行 `@guardrails/security-checklist.md` 安全扫描。
- 所有问题 fix + re-review 通过。

#### 12. `flow-kit/core/7-integration.md` — 集成归档
- 自动 git commit，关联 change-id。
- 调用 `@archive/archive-change.md` 归档变更。
- 增量更新 `CONTEXT.md`（若老项目）。
- 提取经验教训写入 `LESSONS.md`。
- 提示回滚命令。

#### 13. `flow-kit/core/8-rollback.md` — 变更回滚
- 通过 `git revert` 回滚整个 change。
- 生成 `ROLLBACK.md` 并沉淀事故教训到 LESSONS.md。

#### 14. 模板文件（templates/）
生成所有 `.template` 文件，结构清晰，包含占位符和格式说明。

**历史教训匹配规则（用于多处扫描 LESSONS.md 的地方）：**
```
> 按以下优先级匹配：
> 1. 关键词匹配（功能、技术栈、变更类型如UI/DB/API）
> 2. 时间倒序，优先最近3个月
> 3. 展示格式：
> ⚠️ 【历史教训·日期】描述 + 关联 change-id + 预防措施
> 用户确认后继续。
```

#### 15. `archive/archive-change.md` — 归档逻辑
如何将 `.specs/{change-id}` 移至 `.specs/archive/` 并更新索引。

---

## 三、第二阶段：护栏与核心能力（3～5 天）

### 生成文件规范

#### 1. `guardrails/brownfield-guardrails.md` — 老项目六大护栏总纲
- B1 入场扫描：如何扫描项目、生成 CONTEXT.md。
- B2 架构对齐：设计阶段强制校验。
- B3 边界约束：任务文件声明 + git diff 校验越界回滚。
- B4 破坏性变更门槛（分级）：
  - **P0 核心风险**：核心框架、OpenAPI、删表/改字段类型 → 人工确认 + 审批文件 + 全量回归 + 回滚脚本。
  - **P1 中风险**：公共模块、内部公共接口、加字段 → 人工确认 + 全库引用扫描 + 回滚方案。
  - **P2 低风险**：业务代码删除 ≥5 行、非核心接口 → 自动扫描 + 人工确认。
- B5 沿用抽象 grep：任何新函数/组件前强制 grep 复用。
- B6 视觉语汇对齐：UI 变更前输出观察报告，用户确认。

#### 2. `guardrails/breaking-change.md` — 破坏性变更分级审批
详细的三级审批流程，P0 触发审批文件生成（.specs/pending-approvals/），等待人工写入 APPROVED/REJECTED。

#### 3. `guardrails/database-guardrails.md` — 数据库护栏
- 自动检测数据库类型（MySQL/PostgreSQL/SQL Server/MongoDB），推荐对应在线 DDL 工具。
- DDL 必须 dry run，大表 DDL 提示用 gh-ost 等。
- DML 必须先用 SELECT 验证，禁止无 WHERE 全表更新。
- 必须编写对等回滚脚本。

#### 4. `guardrails/security-checklist.md` — 安全检查清单（YAML 格式）
包含硬编码密钥、SQL 拼接、前端泄露内网、XSS 风险等，每项含 grep 正则和严重级别（block/warn）。

#### 5. `guardrails/ui-guardrails.md` — B6 视觉语汇对齐详细步骤
具体扫描 token、hover、缓动、elevation、图标库、文案调性，输出观察报告模板。

#### 6. 技能包（skills/）
- **requirement-clarify.md**：grill-me / grill-with-docs 对话模板。
- **task-master.md**：parse_prd → expand_task 两步法。
- **subagent-execution.md**：子代理任务包格式、隔离规则。
- **code-review.md**：CEO/Design/Eng 三层审查要点。
- **debugging.md**：独立诊断子代理。
- **parallel-dispatch.md**：并行冲突检测算法。
- **verification-before-completion.md**：交付前自检清单。

#### 7. 横向命令（commands/）
- **M-health.md**：代码健康度扫描。
- **I-intel-scan.md**：项目技术栈版本、遗留 TODO/FIXME 扫描。
- **update-context.md**：增量更新 CONTEXT.md 逻辑。
- **sync-team-config.md**：从团队仓库拉取配置。

#### 8. MCP 工具适配（mcp/）
- **mcp-tools-config.md**：core/standard/all 三级工具分层，通过工具白名单提示实现。
- **git-integration.md**：git 安全封装，离线模式下限制远程操作。
- **external-lint-adapter.md**：检测 impeccable/brooks-lint 是否存在，不存在走内置规则；离线模式跳过检测。

#### 9. 硬规则参考（reference/）
- **frontend-engineer-rules.md**：字体黑名单、动画分层、颜色变量、占位符策略、11条交付前检查。
- **backend-engineer-rules.md**：通用后端规范。
- **tdd-standard.md**：红/绿/重构步骤。
- **adr-template.md**：架构决策记录模板。
- **language-specs/ 下各语言文件**：定义公共接口识别方式、lint 工具、测试命令模板、破坏性变更检测规则。

#### 10. 配置
- **constitution.md**：全局最高约束（规范、禁用栈、安全红线、角色定义）。
- **default-user-config.md**：字段包含 `offline_mode`、`budget_per_change`、`model_pricing`（输入/输出价格）、`context_expiry.warn_days`、`context_expiry.force_days`、`project_type_override` 等。

---

## 四、第三阶段：全场景适配与优化（2～3 天）

### 核心工作
- 完善所有语言栈文件。
- 实现 CONTEXT.md 过期检测（读取 config 中的过期天数，15天提示，30天强制更新）。
- 实现 token 用量估算（用字符数粗略估算，1 token ≈ 4 英文字符/1.3 中文字符），每个阶段结束时输出估算并检查预算（达到 80% 警告，100% 中断）。
- 实现离线模式全面适配（git 远程限制、跳过外部工具检测、加载内置 lint 规则）。
- 确保极简模式跳过 test 和 review 时不加载相关护栏且 token 成本明显降低。
- 审批流文件交互完善（生成待审批文件，定期检测状态）。
- 确保 `7-integration.md` 自动调用归档。

---

## 五、第四阶段：团队协作与规模化（1～2 天）

### 核心工作
- 完善 `constitution.md` 中的角色定义。
- 在 P0 变更触发审批文件生成，流程依赖文件状态。
- `7-integration.md` 可选生成 PR 描述（含需求、设计、审查报告链接）。
- 团队配置同步命令 `sync-team-config.md` 完成。
- 月度成本报告 `COST-REPORT.md` 生成逻辑整合到 `GO.md` 或 `7-integration.md`。

---

## 六、生成时的输出规范
每次创建文件必须用以下格式：
```
--- BEGIN flow-kit/xxx.md ---
（文件完整内容，包括强制约束块）
--- END flow-kit/xxx.md ---
```

生成完毕后，提示：“所有文件已生成，您可以使用 `@flow-kit/GO.md` 启动第一个变更。”

---