---
phase: 04-integration
plan: '04-1'
type: execute
wave: 1
depends_on: []
files_modified:
  - flow-kit/GO.md
  - flow-kit/archive/archive-change.md
  - flow-kit/.planning/phases/04-integration/04-CONTEXT.md
autonomous: true
requirements:
  - D4-1
  - D4-2
user_setup: []

must_haves:
  truths:
    - "GO.md checks file modification dates on startup"
    - "Warning notification fires at 15 days of inactivity"
    - "Auto-archive occurs at 30 days of inactivity"
    - "Token estimation runs on phase load"
    - "Warning at 80% budget, block at 100%"
  artifacts:
    - path: "flow-kit/commands/check-expiry.md"
      provides: "Context expiry detection logic"
    - path: "flow-kit/commands/estimate-tokens.md"
      provides: "LOC-based token estimation"
    - path: "flow-kit/archive/archive-change.md"
      provides: "Extended archive logic for context expiry"
  key_links:
    - from: "flow-kit/GO.md"
      to: "flow-kit/commands/check-expiry.md"
      via: "startup hook"
      pattern: "load.*check-expiry"
    - from: "flow-kit/commands/check-expiry.md"
      to: "flow-kit/archive/archive-change.md"
      via: "archive trigger"
      pattern: "archive.*context"
---

<objective>
Implement context expiry detection (D4-1) and LOC-based token estimation (D4-2) for Phase 4.
</objective>

<context>
@flow-kit/GO.md
@flow-kit/archive/archive-change.md
@flow-kit/.planning/phases/04-integration/04-CONTEXT.md

**Key behaviors from D4-1:**
- At 15 days: warning notification — "Context will expire in 15 days"
- At 30 days: auto-archive to archive/ with one-click recovery command
- Reuses existing archive-change.md logic

**Key behaviors from D4-2:**
- Count lines in phase .md files (excluding templates)
- Formula: estimated_tokens = LOC * 1.5
- 80% budget: soft warning
- 100% budget: hard block
- No external API calls
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create expiry detection module</name>
  <files>flow-kit/commands/check-expiry.md</files>
  <action>
Create `flow-kit/commands/check-expiry.md` with:

1. **Expiry check logic:**
   - Scan `.planning/phases/` for last modification date of all `.md` files
   - Calculate days since most recent modification
   - If days >= 15 AND days < 30: output warning notification
   - If days >= 30: trigger archive operation

2. **Warning notification format:**
   ```
   [WARNING] Context will expire in {days_remaining} days (30-day auto-archive)
   Run `/flow-kit:archive` manually to archive early, or `flow-kit:recovery` to restore.
   ```

3. **Archive trigger behavior:**
   - When days >= 30, call archive logic with context (not change) archival mode
   - Archive target: `.planning/` directory compressed to `archive/{YYYY-MM}/context-{date}/`
   - Reuse directory structure from archive-change.md but target .planning/

4. **Recovery command:**
   - `flow-kit:recovery` command restores from archive/ back to active state
   - Format: `flow-kit:recovery {archive-path}`

Do NOT make external API calls. Use file system dates only.
  </action>
  <verify>
grep -c "15.*day\|30.*day\|warning\|archive" flow-kit/commands/check-expiry.md</verify>
  <done>check-expiry.md exists with 15d/30d warning logic, archive trigger, and recovery command</done>
</task>

<task type="auto">
  <name>Task 2: Extend archive logic for context archival</name>
  <files>flow-kit/archive/archive-change.md</files>
  <action>
Extend `flow-kit/archive/archive-change.md` to support **context archival mode**:

1. **Add context archival trigger condition:**
   - When triggered by check-expiry.md (days >= 30)
   - Archive target: `.planning/` directory
   - Creates `archive/{YYYY-MM}/context-{YYYY-MM-DD}/` with compressed context snapshot

2. **Context archive structure:**
   ```
   archive/{YYYY-MM}/context-{YYYY-MM-DD}/
     ├── README.md          # Context summary (which phases, last activity)
     ├── .planning/        # Full .planning directory snapshot
     └── metadata.yaml      # archived_at, original_path, reason: context-expiry
   ```

3. **Preserve existing change archival logic** (ARCH-90) unchanged:
   - Manual archive command
   - Deprecated/expired change detection
   - All existing trigger conditions remain functional

4. **Recovery entry point:**
   - Add "Recovery" section documenting how to restore from context archive
   - Command: move archive contents back to .planning/, update timestamps
  </action>
  <verify>
grep -c "context.*archive\|context-expiry\|recovery" flow-kit/archive/archive-change.md</verify>
  <done>archive-change.md supports context archival mode while preserving change archival</done>
</task>

<task type="auto">
  <name>Task 3: Create token estimation module</name>
  <files>flow-kit/commands/estimate-tokens.md</files>
  <action>
Create `flow-kit/commands/estimate-tokens.md` with:

1. **LOC counting logic:**
   - Scan `.planning/phases/*/` for all `.md` files
   - Exclude files matching `*template*` or `TEMPLATE*` in filename
   - Count total lines per phase using `wc -l`
   - Sum all phase line counts

2. **Token estimation formula:**
   ```
   estimated_tokens = total_LOC * 1.5
   ```

3. **Budget warnings:**
   - Define budget as a configurable value (default: 100000 tokens)
   - 80% budget: `[WARNING] Approaching token budget (80%). Consider archiving or condensing context.`
   - 100% budget: `[BLOCK] Token budget exhausted. Archive or condense context before continuing.`

4. **Output format:**
   ```
   Token Estimation Report
   ======================
   Phase 01: {LOC1} lines
   Phase 02: {LOC2} lines
   ...
   Total LOC: {total_LOC}
   Estimated Tokens: {estimated_tokens}
   Budget: {budget} ({budget_pct}% used)
   ```

5. **Integration point:**
   - Called by GO.md on phase load (startup hook)
   - Also available via `/flow-kit:estimate-tokens` command
  </action>
  <verify>
grep -c "LOC\|token\|budget\|80%\|100%" flow-kit/commands/estimate-tokens.md</verify>
  <done>estimate-tokens.md exists with LOC counting, formula, and 80%/100% budget warnings</done>
</task>

<task type="auto">
  <name>Task 4: Integrate expiry check into GO.md</name>
  <files>flow-kit/GO.md</files>
  <action>
Extend `flow-kit/GO.md` to add expiry check hook on startup:

1. **Add new command entry:**
   ```
   | `/flow-kit:estimate-tokens` | `@flow-kit/commands/estimate-tokens.md` |
   ```

2. **Add startup check behavior:**
   - When GO.md loads, automatically check context expiry
   - Call check-expiry.md logic silently (do not block on warnings)
   - If warning condition (15-30 days): display warning non-blocking
   - If archive condition (30+ days): prompt user before auto-archiving

3. **Placement:**
   - Add expiry check call after priority loading section (lines 1-8)
   - Before command routing begins

4. **Do NOT modify existing routing logic or Levenshtein implementation**
  </action>
  <verify>
grep -c "check-expiry\|estimate-tokens" flow-kit/GO.md</verify>
  <done>GO.md has expiry check hook on startup and estimate-tokens command entry</done>
</task>

</tasks>

<verification>
- GO.md startup flow includes expiry check
- `/flow-kit:estimate-tokens` command is routed
- archive-change.md handles both change and context archival
- check-expiry.md outputs correct warnings at 15 and 30 day thresholds
</verification>

<success_criteria>
1. GO.md checks file modification dates on startup (non-blocking warning)
2. Warning notification fires at 15 days of inactivity
3. Auto-archive trigger at 30 days of inactivity
4. Token estimation outputs to console/log on phase load
5. Warning at 80% budget, block message at 100%
6. Existing archive-change.md behavior preserved for change archival
</success_criteria>

---

## PLAN COMPLETE
