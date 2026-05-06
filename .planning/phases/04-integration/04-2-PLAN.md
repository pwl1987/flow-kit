---
phase: 04-integration
plan: 02
type: execute
wave: 1
depends_on: []
files_modified:
  - flow-kit/GO.md
  - flow-kit/commands/offline-mode.md
  - flow-kit/commands/minimal-mode.md
  - flow-kit/lib/phase-executor.md
autonomous: true
requirements:
  - D4-3
  - D4-4
must_haves:
  truths:
    - "Offline mode skips external tool detection and uses built-in file structure lint"
    - "Minimal mode skips Phase 5 (Test) and Phase 6 (Review) execution"
    - "Constitution safety rules remain enforced in both modes"
  artifacts:
    - path: "flow-kit/commands/offline-mode.md"
      provides: "Offline mode detection and fallback logic"
      min_lines: 40
    - path: "flow-kit/commands/minimal-mode.md"
      provides: "Minimal mode whitelist and phase skip logic"
      min_lines: 40
    - path: "flow-kit/GO.md"
      provides: "Command routing for /flow-kit:offline and /flow-kit:minimal"
      exports: ["offline", "minimal"]
  key_links:
    - from: "flow-kit/GO.md"
      to: "flow-kit/commands/offline-mode.md"
      via: "command route /flow-kit:offline"
      pattern: "offline-mode"
    - from: "flow-kit/lib/phase-executor.md"
      to: "flow-kit/commands/minimal-mode.md"
      via: "phase skip check"
      pattern: "minimal.*skip"
    - from: "flow-kit/commands/offline-mode.md"
      to: "flow-kit/config/constitution.md"
      via: "safety rule enforcement"
      pattern: "constitution"
---

<objective>
Implement execution flexibility modes: offline mode (hybrid detection + built-in lint fallback) and minimal mode (whitelist-driven phase skip).

Purpose: Provide graceful degradation when offline and efficient single-file workflows while maintaining safety guarantees.
Output: `flow-kit/commands/offline-mode.md`, `flow-kit/commands/minimal-mode.md`, updated `GO.md` and `phase-executor.md`
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/phases/04-integration/04-CONTEXT.md
@flow-kit/GO.md
@flow-kit/config/constitution.md

## D4-3 Offline Mode Specification

Detection:
- **Manual trigger:** `/flow-kit:offline` command activates offline mode
- **Auto-detect:** On network error/timeout/tool unreachable, auto-degrade (one-shot failover)
- **Resume:** User can re-enable online mode manually

Offline built-in lint scope (file structure integrity only):
- Placeholder completeness check (`{{PLACEHOLDER}}` format)
- Required files existence (per phase requirements)
- YAML/JSON format validation
- **Excluded:** No code content analysis (deferred to online mode)

## D4-4 Minimal Mode Specification

Auto-minimal whitelist:
- `README.md`, `CHANGELOG.md`, `LICENSE`
- `*.config.js`, `*.config.ts`, `*.config.json`, `*.yaml`, `*.yml`
- Single-file changes with <50 lines diff and <3 files changed
- `flow-kit/` internal files

User override:
- `/flow-kit:minimal` forces minimal mode on any change
- Minimal mode skips Phase 5 (Test) and Phase 6 (Review)

**Safety guarantee:** Constitution rules (SEC/DATA/DEPLOY/GIT) remain enforced in both modes.
</context>

<tasks>

<task type="auto">
  <name>Task 1: Implement offline mode detection and built-in lint</name>
  <files>flow-kit/commands/offline-mode.md, flow-kit/lib/phase-executor.md</files>
  <action>
Create `flow-kit/commands/offline-mode.md` implementing:

1. **Offline state tracking:**
   - `isOffline` boolean flag (default false)
   - `offlineReason` string (manual | auto-failover | null)

2. **Manual trigger:** `/flow-kit:offline` sets `isOffline=true, offlineReason=manual`

3. **Auto-detect failover** (called on tool failure):
   - Check network: attempt `curl -s --max-time 3 https://example.com` or check `git remote -v`
   - If no network: set `isOffline=true, offlineReason=auto-failover`
   - Log: "Auto-switching to offline mode due to: {error}"

4. **Built-in lint adapter** (used instead of external linters when offline):
   - `lintPlaceholderCompleteness(files)`: check for `{{PLACEHOLDER}}` patterns
   - `lintRequiredFiles(phase, files)`: verify phase-required files exist
   - `lintYamlJsonFormat(files)`: basic YAML/JSON parse validation
   - Returns `{valid: boolean, issues: string[]}`

5. **Safety enforcement:** All constitution rules remain active; offline mode only affects external tool detection.

Then update `flow-kit/lib/phase-executor.md`:
- Before running external lint tools, check `isOffline` flag
- If offline, invoke built-in lint adapter instead
- Log which mode is active
</action>
  <verify>
grep -c "isOffline" flow-kit/commands/offline-mode.md && \
grep -c "lintPlaceholderCompleteness\|lintRequiredFiles\|lintYamlJsonFormat" flow-kit/commands/offline-mode.md && \
grep -q "if.*isOffline.*true" flow-kit/lib/phase-executor.md</verify>
  <done>Offline mode command file exists with offline detection and built-in lint. Phase executor checks offline flag before external tools.</done>
</task>

<task type="auto">
  <name>Task 2: Implement minimal mode whitelist and phase skip logic</name>
  <files>flow-kit/commands/minimal-mode.md, flow-kit/lib/phase-executor.md</files>
  <action>
Create `flow-kit/commands/minimal-mode.md` implementing:

1. **Minimal state tracking:**
   - `isMinimal` boolean flag (default false)
   - `minimalReason` string (whitelist | manual | null)

2. **Manual trigger:** `/flow-kit:minimal` sets `isMinimal=true, minimalReason=manual`

3. **Auto-detection whitelist:**
   - Check if all changed files match ANY of:
     - `README.md`, `CHANGELOG.md`, `LICENSE`
     - `*.config.js`, `*.config.ts`, `*.config.json`, `*.yaml`, `*.yml`
     - Files under `flow-kit/` directory
   - Check diff size: if single file changed with <50 lines diff and total <3 files
   - If whitelist match: set `isMinimal=true, minimalReason=whitelist`

4. **Phase skip execution:**
   - When `isMinimal=true`, skip Phase 5 (Test) and Phase 6 (Review)
   - Proceed: Phase 4 (Dev) -> Phase 7 (Integration)
   - Log: "Minimal mode active ({reason}). Skipping Phase 5/6."

5. **Safety enforcement:** Constitution rules (SEC/DATA/DEPLOY/GIT) remain enforced regardless of minimal mode.

Then update `flow-kit/lib/phase-executor.md`:
- Add minimal mode check before Phase 5
- If minimal mode active, skip Phase 5 and Phase 6
- Always run constitution safety checks
</action>
  <verify>
grep -c "isMinimal" flow-kit/commands/minimal-mode.md && \
grep -c "whitelist\|README\|config" flow-kit/commands/minimal-mode.md && \
grep -q "Phase 5\|Phase 6.*skip" flow-kit/lib/phase-executor.md</verify>
  <done>Minimal mode command file exists with whitelist detection and phase skip logic. Phase executor skips Phase 5/6 when minimal active.</done>
</task>

<task type="auto">
  <name>Task 3: Add command routes for offline and minimal modes</name>
  <files>flow-kit/GO.md</files>
  <action>
Update `flow-kit/GO.md`:

1. Add to "Available Commands" table:
   ```
   | /flow-kit:offline | @flow-kit/commands/offline-mode.md |
   | /flow-kit:minimal | @flow-kit/commands/minimal-mode.md |
   ```

2. Add to "Available Commands" list in routing logic section:
   - `/flow-kit:offline` — activates offline mode with built-in lint fallback
   - `/flow-kit:minimal` — forces minimal mode, skips Phase 5/6

3. Add command descriptions to Levenshtein section (if fuzzy match needed).

Keep existing commands intact. Only append new entries.
</action>
  <verify>
grep -q "/flow-kit:offline" flow-kit/GO.md && \
grep -q "/flow-kit:minimal" flow-kit/GO.md && \
grep -q "offline-mode\|minimal-mode" flow-kit/GO.md</verify>
  <done>GO.md updated with /flow-kit:offline and /flow-kit:minimal command routes.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| offline-mode -> constitution | Offline mode reads constitution rules but cannot disable them |
| minimal-mode -> phase-executor | Minimal mode signals skip preference, phase-executor enforces safety |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-04-01 | Denial of Service | offline-mode | mitigate | Offline mode limited to built-in lint; external tool failures trigger mode switch, not infinite retry |
| T-04-02 | Elevation of Privilege | minimal-mode | mitigate | Minimal mode skips Phase 5/6 only; constitution rules (SEC/DATA/DEPLOY/GIT) cannot be bypassed per D4-4 spec |
| T-04-03 | Security Bypass | offline-mode | mitigate | Safety enforcement (constitution) runs regardless of offline status; offline only affects external tool detection |
</threat_model>

<verification>
1. Offline mode: `grep -q "isOffline" flow-kit/commands/offline-mode.md && grep -q "built-in\|builtin" flow-kit/commands/offline-mode.md`
2. Minimal mode: `grep -q "isMinimal" flow-kit/commands/minimal-mode.md && grep -q "whitelist" flow-kit/commands/minimal-mode.md`
3. Safety: `grep -q "constitution\|SEC-\|DATA-" flow-kit/commands/offline-mode.md && grep -q "constitution\|SEC-\|DATA-" flow-kit/commands/minimal-mode.md`
4. Routes: `grep -q "/flow-kit:offline" flow-kit/GO.md && grep -q "/flow-kit:minimal" flow-kit/GO.md`
</verification>

<success_criteria>
1. `/flow-kit:offline` command route exists in GO.md
2. Offline mode skips external tool detection (verified by isOffline check in phase-executor)
3. Built-in lint adapter provides placeholder, required files, YAML/JSON checks
4. `/flow-kit:minimal` command route exists in GO.md
5. Minimal mode skips Phase 5 and Phase 6 execution when active
6. Constitution safety rules (SEC/DATA/DEPLOY/GIT) remain enforced in both modes
</success_criteria>

---

## PLAN COMPLETE
