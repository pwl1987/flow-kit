---
phase: 04-integration
plan: '04-3'
type: execute
wave: 2
depends_on:
  - '04-1'
  - '04-2'
files_modified:
  - flow-kit/config/team-roles.md
  - flow-kit/commands/sync-team-config.md
autonomous: true
requirements:
  - D4-5
  - D4-9
user_setup: []

must_haves:
  truths:
    - "Team roles are defined in config/team-roles.md (admin, reviewer, developer, viewer)"
    - "Constitution.md remains immutable safety floor, roles do not modify safety rules"
    - "sync-team-config syncs both constitution.md and team-roles.md"
    - "Roles are validated on config load (no unknown roles accepted)"
  artifacts:
    - path: "flow-kit/config/team-roles.md"
      provides: "Role definitions with permission boundaries"
      min_lines: 30
    - path: "flow-kit/commands/sync-team-config.md"
      provides: "Extended to sync both constitution.md and team-roles.md"
      exports: ["constitution.md", "team-roles.md"]
  key_links:
    - from: "flow-kit/commands/sync-team-config.md"
      to: "flow-kit/config/team-roles.md"
      via: "sync target"
      pattern: "team-roles\\.md"
    - from: "flow-kit/config/team-roles.md"
      to: "flow-kit/config/constitution.md"
      via: "safety floor reference"
      pattern: "constitution.*safety"
---

<objective>
Create team role definitions and extend sync-team-config to sync both constitution and roles.

Purpose: Define clear permission boundaries for team members while maintaining constitution as immutable safety floor.
Output: `flow-kit/config/team-roles.md`, updated `flow-kit/commands/sync-team-config.md`
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@flow-kit/config/constitution.md
@flow-kit/commands/sync-team-config.md
@.planning/phases/04-integration/04-CONTEXT.md

**D4-5: Constitution Role Definitions**
- Create `config/team-roles.md` defining roles: admin, reviewer, developer, viewer
- Roles define what each team member can do
- Constitution.md remains immutable safety floor

**D4-9: Team Config Sync Scope**
- `sync-team-config` command syncs both constitution.md and team-roles.md
- Previously only synced constitution
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create team-roles.md with role definitions</name>
  <files>flow-kit/config/team-roles.md</files>
  <action>
Create `flow-kit/config/team-roles.md` with:

1. **Role definitions:**

   **admin**
   - Full access to all flow-kit commands
   - Can modify team configuration
   - Can sync and distribute team config
   - Cannot override Constitution safety rules

   **reviewer**
   - Can execute review commands
   - Can approve/reject changes
   - Cannot modify core configuration
   - Bound by Constitution safety rules

   **developer**
   - Can execute development workflow commands
   - Can commit and push within limits
   - Cannot modify team configuration
   - Bound by Constitution safety rules

   **viewer**
   - Read-only access to flow-kit outputs
   - Can view phase summaries and status
   - Cannot execute workflow commands
   - Cannot modify any configuration

2. **Permission boundary statement:**
   ```
   Constitution.md remains the immutable safety floor.
   Roles define workflow permissions only.
   No role can override SEC/DATA/DEPLOY/GIT rules.
   ```

3. **Role validation rule:**
   - Unknown roles rejected at config load
   - Fallback to `viewer` if no role specified

4. **Constitution reference:**
   - Explicitly reference constitution.md as safety floor
   - Roles are additive, not modifying safety rules
</action>
  <verify>
grep -c "admin\|reviewer\|developer\|viewer" flow-kit/config/team-roles.md && \
grep -q "constitution" flow-kit/config/team-roles.md && \
grep -q "safety.*floor\|immutable" flow-kit/config/team-roles.md</verify>
  <done>team-roles.md exists with all four role definitions and safety floor reference</done>
</task>

<task type="auto">
  <name>Task 2: Extend sync-team-config to sync both constitution and roles</name>
  <files>flow-kit/commands/sync-team-config.md</files>
  <action>
Update `flow-kit/commands/sync-team-config.md`:

1. **Add team-roles.md to sync targets:**

   In "What Gets Synced" table, add:
   ```
   | Constitution (safety floor) | `config/constitution.md` | Immutable, cannot be modified |
   | Team roles | `config/team-roles.md` | Team standard, defines permissions |
   ```

2. **Update sync behavior for constitution:**
   - Constitution syncs as immutable (read-only safety floor)
   - Never allow user override of constitution rules
   - If local constitution conflicts with team version, keep team version

3. **Update sync behavior for roles:**
   - Roles sync with team standard priority
   - User cannot override role definitions
   - Roles define workflow permissions, not safety rules

4. **Update execution section:**
   - Fetch both `config/constitution.md` and `config/team-roles.md`
   - Validate roles against schema (admin, reviewer, developer, viewer)
   - Reject unknown roles

5. **Update output table:**
   - Show constitution.md sync status
   - Show team-roles.md sync status

6. **Idempotent execution:**
   - Safe to run multiple times
   - No data loss on repeated sync
</action>
  <verify>
grep -q "constitution\\.md" flow-kit/commands/sync-team-config.md && \
grep -q "team-roles\\.md" flow-kit/commands/sync-team-config.md && \
grep -q "admin\|reviewer\|developer\|viewer" flow-kit/commands/sync-team-config.md</verify>
<done>sync-team-config.md updated to sync both constitution.md and team-roles.md with proper role validation</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| sync-team-config -> constitution.md | Constitution synced as immutable, cannot be overridden |
| sync-team-config -> team-roles.md | Roles synced with team priority, user cannot modify |
| team-roles.md -> constitution.md | Roles reference constitution as safety floor, cannot override |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-04-04 | Elevation of Privilege | team-roles.md | mitigate | Roles are additive only; Constitution SEC/DATA/DEPLOY/GIT rules cannot be bypassed via role assignment |
| T-04-05 | Tampering | sync-team-config | mitigate | Constitution syncs as immutable; roles validated against known schema before acceptance |
</threat_model>

<verification>
1. Roles defined: `grep -c "admin\|reviewer\|developer\|viewer" flow-kit/config/team-roles.md`
2. Safety floor: `grep -q "safety.*floor\|constitution" flow-kit/config/team-roles.md`
3. Sync targets: `grep -q "constitution\\.md.*team-roles\\.md\|team-roles\\.md.*constitution\\.md" flow-kit/commands/sync-team-config.md`
4. Role validation: `grep -q "unknown.*role\|reject\|validate" flow-kit/commands/sync-team-config.md`
</verification>

<success_criteria>
1. `config/team-roles.md` exists with all four role definitions (admin, reviewer, developer, viewer)
2. Roles have clear permission boundaries in the file
3. Constitution.md referenced as immutable safety floor
4. `sync-team-config` syncs both constitution.md and team-roles.md
5. Unknown roles rejected at config load
6. Phase 4 constitutional safety maintained (SEC/DATA/DEPLOY/GIT rules unchanged)
</success_criteria>

---

## PLAN COMPLETE
