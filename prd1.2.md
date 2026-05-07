# flow-kit v1.2 开发规范（Claude Code 可执行版）

> 本规范用于指导 Claude Code **基于现有 v1.1 仓库**，对标五个参考库的最优实践，对 flow-kit 进行增量升级。  
> **核心目标：** 吸收 `andrej‑karpathy‑skills` 的行为约束、`mattpocock/skills` 的领域语言对齐与 grilled‑docs 机制、以及 `graphify` 的依赖关系导航思想，补齐 v1.1 在“需求澄清质量、术语一致性、老项目上下文结构化”上的短板。  
> **零破坏：** 所有修改均为增量，不改动现有流程主骨架，新增文件均放在已有目录下。

---

## 前置要求
- 确保你已 checkout 到 `flow-kit` 仓库的 **v1.1 版本**（或包含所有核心模块的最新 main 分支）。
- 本规范以“现有 v1.1 文件”为基础，命令 Claude Code 对其进行修改和新增。
- 所有修改必须保持 `@` 引用机制，所有输出使用 `--- BEGIN 文件名 ---` / `--- END 文件名 ---` 包裹。

---

## 升级清单总览

| 编号 | 模块 | 操作 | 借鉴来源 |
|------|------|------|----------|
| 1 | `config/constitution.md` | **修改**：融入 Karpathy 四原则，作为最高行为约束 | andrej-karpathy-skills |
| 2 | `skills/requirement-clarify.md` | **重写**：整合 grill‑with‑docs，增加术语冲突检测、一次一问、实时更新 CONTEXT.md | mattpocock/skills |
| 3 | `skills/ubiquitous-language.md` | **新增**：领域语言统一技能，全流程术语检查 | mattpocock/skills |
| 4 | `guardrails/brownfield-guardrails.md` | **修改**：B1 入场扫描增加模块依赖关系表生成 | graphify |
| 5 | `core/1-requirement.md` | **修改**：增加术语对齐前置步骤 + 历史教训自动检索 | mattpocock/skills + compound‑engineering 思想 |
| 6 | `core/4-dev.md` | **修改**：在 TDD 步骤中强化“Goal‑Driven Execution”（先写验证再实现） | Karpathy 四原则 |
| 7 | `templates/GLOSSARY.md.template` | **新增**：术语表模板，供 ubiquitous‑language 使用 | mattpocock/skills |
| 8 | `commands/cross-session-search.md` | **新增**：跨会话经验搜索命令，方便团队复用历史教训 | compound‑engineering‑plugin |

---

## 详细修改规范

### 1. 修改 `config/constitution.md` —— 融入 Karpathy 四原则

**修改位置**：在现有安全规则（SAFETY FLOOR）之后，技术栈约束（TECH‑01）之前，插入一个新的段落 `BEHAVIORAL PRINCIPLES`。

**需要加入的内容：**

```markdown
### BEHAVIORAL PRINCIPLES (Highest Priority for All Agents)

All agents, sub‑agents, and review processes MUST adhere to the following four principles at all times. No other rule, instruction, or optimization may override them.

1. **Think Before Coding**
   - Always state assumptions explicitly. If uncertain, ask before acting.
   - When multiple interpretations are possible, list them and choose the most conservative.
   - If a simpler implementation is possible, point it out before writing code.
   - If confused, stop and request clarification. Never guess silently.

2. **Simplicity First**
   - Solve the problem with the minimum amount of code.
   - Do not add features, abstractions, or configurations that were not requested.
   - Do not introduce a new abstraction for single‑use code.
   - If a 200‑line module can be reduced to 50 lines without losing clarity, refactor immediately.

3. **Surgical Changes**
   - Only modify code that is directly required by the change. Do not touch adjacent files, comments, formatting, or unrelated code.
   - Clean up only the orphaned references you yourself created. Do not “fix” pre‑existing style issues unless explicitly asked.

4. **Goal‑Driven Execution**
   - Translate every imperative task into a verifiable goal. “Add validation” → write a failing test first, then make it pass.
   - “Fix a bug” → write a reproduction test first, then fix.
   - Never implement without a clear, testable definition of “done”.
```

**此外，在 `ROLE‑01` 之后补充一句**：
```markdown
- All role‑based approvals must respect the BEHAVIORAL PRINCIPLES above: if a design violates “Simplicity First”, the architect must reject it.
```

---

### 2. 重写 `skills/requirement-clarify.md` —— 整合 grill‑with‑docs

**完全替换原有内容**，新的文件需包含：

```markdown
> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本技能用于需求澄清阶段，整合 grill‑me 与 grill‑with‑docs。执行时严格遵守“一次一问”原则，禁止堆叠问题。

#### Phase 1: Alignment Check (based on existing docs)
1. Load `.specs/CONTEXT.md` (if exists) and `config/constitution.md`, `reference/frontend-engineer-rules.md` or `reference/backend-engineer-rules.md`.
2. Load `skills/ubiquitous-language.md` to activate terminology alignment.
3. Ask user: “I have reviewed the project context. Do you want to proceed with the standard requirements process, or do you have specific domain documents (PRD, design doc) I should study first?” Wait for response.

#### Phase 2: Deep Dive (one question at a time)
For each question, wait for user response before proceeding. Never ask multiple questions together.

4. **Target Users:** “Who are the primary users of this feature? Are there secondary personas (admins, operators) I should consider?”
5. **Core Scenario:** “Describe the single most important workflow. Be specific: ‘User clicks X, sees Y, can do Z’.”
6. **Acceptance Criteria:** “What must be true for you to consider this change complete? Please list 3‑5 measurable criteria (e.g., ‘Page loads within 2 seconds’, ‘You can send a notification without errors’).”
7. **Non‑functional Requirements:** “Are there specific performance, security, accessibility, or compliance constraints I should know about?”
8. **Domain Terminology:** (Use `skills/ubiquitous-language.md`) “I notice your CONTEXT.md uses term A, but you just said B. Which is the canonical term? Should I align everything to A?”
9. **Edge Cases:** “What should happen when the notification list is empty? When the user has 10,000 notifications? When the network fails?”
10. **Existing Abstractions:** “Are you aware of any existing components, hooks, or utilities in the project that do something similar? I will grep for them later, but your insight helps.”

#### Phase 3: Verification & Documentation
11. After all questions are answered, immediately write a draft `REQUIREMENT.md` with checkable acceptance criteria.
12. If a term was clarified or defined, update `GLOSSARY.md` (or create it from `templates/GLOSSARY.md.template`).
13. If an architecture decision was made during clarification, create an ADR using `reference/adr-template.md`.
14. Present the final `REQUIREMENT.md` and ask for explicit user approval before the next phase.

> 【强制清窗】本技能执行完毕后，主对话中只保留 `REQUIREMENT.md` 的 @链接、术语澄清记录，其余对话历史清空。
```

---

### 3. 新增 `skills/ubiquitous-language.md` —— 领域语言统一技能

**创建新文件 `flow-kit/skills/ubiquitous-language.md`**：

```markdown
> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本技能维护项目专属术语表，贯穿需求、设计、编码、审查全流程。
> 若项目根无 `GLOSSARY.md`，使用 `templates/GLOSSARY.md.template` 初始化。

#### Trigger
Activated automatically in:
- `1-requirement` (grill‑with‑docs)
- `2-design` (architecture naming)
- `4-dev` (code generation)
- `6-review` (terminology check)

#### Core Rules
1. **Single Source of Truth**: Maintain `GLOSSARY.md` at project root (`.specs/GLOSSARY.md`). All agents read and update it.
2. **Conflict Detection**: When user or code uses a term that differs from the glossary, flag it immediately:
   “⚠️ Glossary defines ‘Account’ as the billing entity. You are using ‘User’. These are distinct in our domain. Which one should be used here?”
3. **Proactive Alignment**: In code generation, replace vague names with glossary‑precise names.
4. **Review Enforcement**: During `6-review`, automatically scan new code for terms not in glossary and suggest additions.

#### Glossary Structure
Each entry:
```yaml
- term: "Notification"
  definition: "A message pushed to the user via WebSocket or email."
  alternatives: ["Alert", "Notice"]
  context: "use Notification for push events, Alert for in‑line warnings"
  added_by: "requirement-clarify 2024‑05‑08"
```
```

---

### 4. 修改 `guardrails/brownfield-guardrails.md` —— B1 入场扫描增加依赖关系表

**在 B1 小节末尾追加以下内容：**

```markdown
#### B1‑extra: Dependency Map Output
After the initial scan, produce a **Module Dependency Table** in addition to CONTEXT.md. Store it as `.specs/dependency-map.md`.

The table must include:
| Module | Exports | Imported by | Depends on | Key Abstractions |
|--------|---------|-------------|------------|------------------|
| src/utils/http | `request`, `post` | modules: `auth`, `notification` | `axios` | HTTP client wrapper |
| src/components/Button | `Button`, `ButtonProps` | 17 files in `pages/` | `react`, `clsx` | Primary UI component |
...

This table is used by B5 (abstract grep) and B3 (boundary check) to quickly locate existing abstractions without full‑text grep.
```

---

### 5. 修改 `core/1-requirement.md` —— 加强术语对齐与历史检索

**在文件开头 “加载技能” 之后，立即增加：**

```markdown
> 【CLAUDE CODE INSTRUCTION 强制约束·术语前置】
> 1. 激活 @flow-kit/skills/ubiquitous-language.md，检查 `GLOSSARY.md` 是否存在。
> 2. 在开始问答前，先输出：“已加载项目术语表（共 N 个术语），本次需求澄清将强制对齐术语。”
> 3. 在需求澄清的每一次用户输入中，若检测到术语冲突，立即调用 ubiquitous‑language 冲突处理。

> 【CLAUDE CODE INSTRUCTION 强制约束·历史教训检索】
> 1. 加载 `.specs/LESSONS.md`。按关键词匹配（功能、技术栈、变更类型）提取相关历史教训。
> 2. 在需求文件顶部列出匹配的教训，格式：
> ⚠️ 【历史教训·{日期}】{描述} → {预防措施}
> 3. 询问用户：“这些历史教训是否与本次变更相关？是否需要我调整需求以规避已知风险？”
```

---

### 6. 修改 `core/4-dev.md` —— 强化 Goal‑Driven Execution

**在 TDD 小节内，强化“先写验证”规则：**

```markdown
#### Strict TDD with Goal‑Driven Execution
For every task in TASK.md:
1. **Goal Definition**: Before writing any code, define the acceptance test in plain language: “When user clicks bell, unread count decreases by 1.”
2. **Red**: Write the test that proves the goal is NOT yet achieved. Run it, confirm failure.
3. **Green**: Write the minimum code to pass the test.
4. **Refactor**: Only after green, consider simplifying the code while keeping tests green.

If the goal cannot be expressed as a testable condition, **do not start coding**. Flag the task as “needs clarification” and return to requirement phase.
```

---

### 7. 新增模板 `templates/GLOSSARY.md.template`

```markdown
--- BEGIN templates/GLOSSARY.md.template ---
# {{Project Name}} Glossary

> Maintained by `skills/ubiquitous-language.md`. This glossary is the single source of truth for domain terminology.

## Terms

| Term | Definition | Alternatives | Context | Added |
|------|------------|--------------|---------|-------|
| (example) Notification | A message pushed via WebSocket or email | Alert, Notice | Use 'Notification' for push events, 'Alert' for in‑line warnings | 2024-05-08 |
| ... | ... | ... | ... | ... |

## Usage Rules
- All code, documentation, and commit messages MUST use terms from this glossary.
- If a new term is introduced, it MUST be added to this table within the same change.
- If an existing term is found to be ambiguous, flag it in the review stage.
--- END templates/GLOSSARY.md.template ---
```

---

### 8. 新增横向命令 `commands/cross-session-search.md`

```markdown
> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本命令搜索所有历史 change 的经验教训，支持跨会话查询。

#### Command: `/flow-kit:search-lessons`
1. Load `.specs/LESSONS.md`.
2. Ask user for a keyword or phrase.
3. Search all lesson entries for matches in description, change‑id, or tags.
4. Present results in chronological order with change‑id links.
5. Optionally, if `offline_mode: false`, allow searching external PR/MR comments linked in lessons.

#### Auto‑trigger
In `1-requirement`, this command is implicitly called to retrieve relevant historical lessons.
```

---

## v1.3 / v2.0 路线图概览（非本次执行内容）

- **v1.3**: 引入 `cep` 的知识复合闭环（LESSONS.md 实时注入）、`oh-my-claudecode` 的智能模型路由建议、`ce-code-review` 的 diff 感知审查者选择。
- **v2.0**: 深度集成 `graphify` 依赖图引擎（`/flow-kit:graph` 命令），实现 71.5x Token 压缩的导航式上下文。

---

## 执行指令与验证

将本规范复制到 Claude Code 对话中，并输入：
```
请基于当前 flow-kit v1.1 仓库，严格按照这份 v1.2 开发规范，逐文件修改和新增。
```

完成后，自行验证：
1. `constitution.md` 是否包含了 4 条行为原则。
2. `requirement-clarify.md` 是否执行“一次一问”、术语冲突检测。
3. 是否生成了 `ubiquitous-language.md` 和 `GLOSSARY.md.template`。
4. 老项目入场扫描后是否生成了 `dependency-map.md`。
5. `4-dev.md` 中 TDD 部分是否强制要求“先写验证再实现”。

全部通过后即可打包为 v1.2 版本。

---

> 以上方案可直接交付给 Claude Code 执行，完全基于现有架构，吸收五库精华，无需任何外部依赖。