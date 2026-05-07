---
phase: "05-P0-bugfix"
reviewed: 2026-05-07T06:45:00Z
depth: "standard"
files_reviewed: 7
files_reviewed_list:
  - flow-kit/lib/detection/project-type.js
  - flow-kit/lib/detection/checkpoint.js
  - flow-kit/lib/detection/database-type.js
  - flow-kit/lib/validation/validate-skills.js
  - flow-kit/lib/phase-executor.md
  - flow-kit/guardrails/brownfield-guardrails.md
  - flow-kit/guardrails/database-guardrails.md
findings:
  critical: 1
  warning: 3
  info: 2
  total: 6
status: "issues"
severity: "medium"
---

## Findings

### CR-01: Unchecked JSON.parse in checkpoint.js (BLOCKER)

**File:** `flow-kit/lib/detection/checkpoint.js:26`
**Issue:** `readCheckpoint()` uses `JSON.parse()` without try/catch. If the checkpoint file is corrupted or contains invalid JSON, the process will crash.
**Fix:**
```javascript
function readCheckpoint(cwd) {
  const filePath = path.join(cwd, CHECKPOINT_FILE);
  if (!fs.existsSync(filePath)) {
    return null;
  }
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (e) {
    return null; // Treat corrupted checkpoint as no checkpoint
  }
}
```

---

## Warnings

### WR-01: Weak connection string matching

**File:** `flow-kit/lib/detection/database-type.js:110`
**Issue:** `detectFromConnectionString()` uses `connString.includes(key)` which can false-match. For example, a hostname like `mysql-server.example.com` would incorrectly trigger `DATABASE_TYPES.MYSQL`.
**Fix:** Use structured parsing (URL module or regex for `://host/`) rather than simple substring matching.

### WR-02: Silent empty catch blocks

**File:** `flow-kit/lib/detection/project-type.js:25-27, 54-56`
**Issue:** Empty catch blocks silently suppress errors, making debugging impossible when file reads fail.
**Fix:** At minimum, log a warning:
```javascript
} catch (e) {
  console.warn(`Failed to read directory: ${dir}`, e);
  return;
}
```

### WR-03: Dead code - unused glob patterns

**File:** `flow-kit/lib/detection/database-type.js:179-183`
**Issue:** `dbFilePatterns` array defines glob patterns but they are never used. The code instead uses `fs.readdirSync(projectRoot, { recursive: true })`.
**Fix:** Either remove dead code or implement proper glob matching.

---

## Info

### IN-01: Magic number for brownfield threshold

**File:** `flow-kit/lib/detection/project-type.js:16`
**Issue:** `BROWNFIELD_LINE_THRESHOLD = 1000` is hardcoded with no explanation.
**Fix:** Consider making configurable or adding comment explaining rationale.

### IN-02: Overly broad hidden file skip

**File:** `flow-kit/lib/detection/project-type.js:33`
**Issue:** `entry.name.startsWith('.')` skips ALL hidden directories, including `.flow-kit/` which contains project metadata used by the system.
**Fix:** Use explicit skip list like `['node_modules', '.git', ...]` instead of blanket-hidden skip.

---

## Severity Summary
- Critical: 1 (CR-01: Unchecked JSON.parse)
- High: 0
- Medium: 3 (WR-01, WR-02, WR-03)
- Low: 0
- Info: 2 (IN-01, IN-02)

---

_Reviewed: 2026-05-07T06:45:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_