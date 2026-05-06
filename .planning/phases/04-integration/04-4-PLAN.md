---
phase: 04-integration
plan: '04-4'
type: execute
wave: 2
depends_on:
  - '04-1'
  - '04-2'
files_modified:
  - flow-kit/commands/pr-description.md
  - flow-kit/commands/cost-report.md
  - flow-kit/commands/p0-approval.md
  - flow-kit/GO.md
  - flow-kit/lib/phase-executor.md
autonomous: true
requirements:
  - D4-6
  - D4-7
  - D4-8
user_setup: []

must_haves:
  truths:
    - "PR description auto-generated from git commit messages with context summary"
    - "Cost report shows: tokens used, estimated cost, phase progress, optimization recommendations"
    - "P0 changes block before Phase 7 until Admin or Reviewer approves"
    - "P0 approval is explicit and logged"
    - "Works in both normal and minimal modes"
  artifacts:
    - path: "flow-kit/commands/pr-description.md"
      provides: "PR description generation from git log"
      min_lines: 50
    - path: "flow-kit/commands/cost-report.md"
      provides: "Monthly cost report with metrics"
      min_lines: 50
    - path: "flow-kit/commands/p0-approval.md"
      provides: "P0 approval workflow trigger"
      min_lines: 40
  key_links:
    - from: "flow-kit/GO.md"
      to: "flow-kit/commands/pr-description.md"
      via: "command route /flow-kit:pr-description"
      pattern: "pr-description"
    - from: "flow-kit/GO.md"
      to: "flow-kit/commands/cost-report.md"
      via: "command route /flow-kit:cost-report"
      pattern: "cost-report"
    - from: "flow-kit/GO.md"
      to: "flow-kit/commands/p0-approval.md"
      via: "command route /flow-kit:p0"
      pattern: "p0-approval"
    - from: "flow-kit/lib/phase-executor.md"
      to: "flow-kit/commands/p0-approval.md"
      via: "pre-Phase-7 gate check"
      pattern: "Phase 7.*p0"
---

<objective>
Implement three workflow enhancement features: PR description generation (D4-6), cost report metrics (D4-7), and P0 approval workflow trigger (D4-8).
</objective>

<context>
@flow-kit/GO.md
@flow-kit/lib/phase-executor.md
@flow-kit/config/constitution.md
@flow-kit/.planning/phases/04-integration/04-CONTEXT.md

## D4-6: PR Description Generation
- Read git log for current branch to extract commit messages
- Auto-fill template: Change ID, Title, Summary, Affected files, Test results, Rollback plan
- AI supplements: Motivation, Technical details
- Output format: GitHub PR body template

## D4-7: Cost Report Metrics
- Total token consumption (reuse estimate-tokens.md logic from 04-1)
- Phase completion rate (% changes completing each phase)
- Average cost per change
- Change count in period
- Output: Markdown table + summary paragraph
- Available via `/flow-kit:cost-report`

## D4-8: P0 Approval Workflow
- Auto-trigger: BREAKING-CHANGE.md or DDL/DML files (.sql, migration/) in change set
- Manual trigger: `/flow-kit:p0` flag
- P0 definition from constitution.md G1: irreversible destructive operations
- Block before Phase 7 until Admin or Reviewer approves
- Approval logged
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create PR description generation module</name>
  <files>flow-kit/commands/pr-description.md</files>
  <action>
Create `flow-kit/commands/pr-description.md` implementing:

1. **Git log extraction:**
   - Run `git log --oneline -20` to get recent commits
   - Parse commit messages for change context

2. **PR body template (auto-filled fields):**
   ```
   ## Summary
   {change_title}
   {change_id}

   ## What Changed
   {affected_files}

   ## Test Results
   {phase_5_verification_summary}

   ## Rollback Plan
   {rollback_command_or_reference}
   ```

3. **AI-generated sections:**
   - **Motivation:** Why this change was needed (inferred from commit context)
   - **Technical Details:** Key implementation decisions, trade-offs

4. **Integration point:**
   - Called by phase-executor.md after Phase 7 (Integration) completion
   - Also available via `/flow-kit:pr-description` command

5. **Output format:** GitHub PR body compatible markdown
</action>
  <verify>
grep -c "git log\|Summary\|What Changed\|Motivation\|Technical Details" flow-kit/commands/pr-description.md</verify>
<done>pr-description.md exists with git log extraction and PR body template</done>
</task>

<task type="auto">
  <name>Task 2: Create cost report module</name>
  <files>flow-kit/commands/cost-report.md</files>
  <action>
Create `flow-kit/commands/cost-report.md` implementing:

1. **Token consumption calculation:**
   - Reuse LOC-based estimation from 04-1 estimate-tokens.md
   - Formula: `estimated_tokens = total_LOC * 1.5`
   - Monthly aggregation from phase file history

2. **Report metrics:**
   | Metric | Calculation |
   |--------|-------------|
   | Total Token consumption | Sum of estimated tokens for all phase files |
   | Phase completion rate | % of changes completing Phase 1-8 per period |
   | Avg cost per change | Total tokens / number of changes |
   | Change count | Total changes in period |

3. **Output format:**
   ```
   # Cost Report — {YYYY-MM}

   ## Token Consumption
   | Phase | LOC | Est. Tokens |
   |-------|-----|--------------|
   | 01    | xxx | xxx         |
   ...

   ## Phase Completion
   | Phase | Completion Rate |
   |-------|------------------|
   ...

   ## Summary
   {summary_paragraph}

   ## Recommendations
   - {optimization_tip_1}
   - {optimization_tip_2}
   ```

4. **Availability:** `/flow-kit:cost-report` command
</action>
<verify>
grep -c "Token\|Phase.*Completion\|Recommendations" flow-kit/commands/cost-report.md</verify>
<done>cost-report.md exists with token consumption, phase completion, and recommendations</done>
</task>

<task type="auto">
  <name>Task 3: Create P0 approval workflow module</name>
  <files>flow-kit/commands/p0-approval.md</files>
  <action>
Create `flow-kit/commands/p0-approval.md` implementing:

1. **P0 trigger detection:**
   - Auto-detect: check for BREAKING-CHANGE.md in change set
   - Auto-detect: check for .sql files or migration/ directory
   - Manual: `/flow-kit:p0` flag sets P0 mode

2. **P0 definition (per constitution.md G1):**
   - Irreversible destructive operations
   - Breaking changes to external contracts
   - Database schema changes (DDL/DML)

3. **Approval workflow:**
   - When P0 detected, halt before Phase 7
   - Display: `[P0] Approval required — {reason}`
   - Require explicit approval from Admin or Reviewer role
   - Log approval with timestamp and approver

4. **Approval prompt format:**
   ```
   [P0 BLOCK] High-risk change detected
   Reason: {auto-detected | manual-flag}
   Files: {affected_files}

   This change requires approval from Admin or Reviewer before proceeding.
   Approve? (yes/no)
   ```

5. **Works in minimal mode:** P0 approval is safety-critical and cannot be skipped

6. **Integration:** phase-executor.md checks P0 status before Phase 7
</action>
<verify>
grep -c "P0\|BREAKING-CHANGE\|approval\|Admin\|Reviewer" flow-kit/commands/p0-approval.md</verify>
<done>p0-approval.md exists with trigger detection, approval prompt, and role check</done>
</task>

<task type="auto">
  <name>Task 4: Add command routes and phase executor integration</name>
  <files>flow-kit/GO.md, flow-kit/lib/phase-executor.md</files>
  <action>
Update `flow-kit/GO.md` to add command routes:
```
| /flow-kit:pr-description | @flow-kit/commands/pr-description.md |
| /flow-kit:cost-report    | @flow-kit/commands/cost-report.md    |
| /flow-kit:p0             | @flow-kit/commands/p0-approval.md    |
```

Update `flow-kit/lib/phase-executor.md`:
1. Before Phase 7 execution, check if P0 approval is required
2. If P0 pending, call p0-approval.md and block until approved
3. After Phase 7 completion, call pr-description.md to generate PR body
4. Cost report can be generated independently via command

Keep existing routes and phase executor logic intact.
</action>
<verify>
grep -q "/flow-kit:pr-description\|/flow-kit:cost-report\|/flow-kit:p0" flow-kit/GO.md && \
grep -q "p0.*approval\|Phase 7" flow-kit/lib/phase-executor.md</verify>
<done>GO.md has routes for pr-description, cost-report, p0. Phase executor integrates P0 gate and PR generation.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| pr-description -> git | Reads git log, no write access |
| p0-approval -> phase-executor | p0-approval is gatekeeper for Phase 7 |
| cost-report -> estimate-tokens | Reuses existing token estimation |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-04-04 | Tampering | pr-description | mitigate | Template fields are auto-filled; AI sections are supplemental, not authoritative |
| T-04-05 | Denial of Service | p0-approval | mitigate | P0 approval cannot be bypassed in minimal mode; safety-critical gate |
| T-04-06 | Elevation of Privilege | cost-report | accept | Read-only metrics; no system modification |
</threat_model>

<verification>
1. PR description: `grep -q "git log\|Summary\|Motivation" flow-kit/commands/pr-description.md`
2. Cost report: `grep -q "Token\|Phase Completion\|Recommendations" flow-kit/commands/cost-report.md`
3. P0 approval: `grep -q "P0.*BLOCK\|Admin.*Reviewer\|approval" flow-kit/commands/p0-approval.md`
4. Routes: `grep -q "/flow-kit:pr-description\|/flow-kit:cost-report\|/flow-kit:p0" flow-kit/GO.md`
5. Phase executor: `grep -q "p0.*approval\|Phase 7" flow-kit/lib/phase-executor.md`
</verification>

<success_criteria>
1. `/flow-kit:pr-description` generates PR body from git log with template + AI sections
2. `/flow-kit:cost-report` outputs token consumption, phase completion, recommendations
3. P0 changes block before Phase 7 until Admin or Reviewer approves
4. P0 approval is explicit (yes/no) and logged with timestamp
5. Works in both normal and minimal modes (minimal mode does not bypass P0)
</success_criteria>

---

## PLAN COMPLETE
