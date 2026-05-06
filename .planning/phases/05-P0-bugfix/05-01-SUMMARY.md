---
phase: "05-P0-bugfix"
plan: "01"
status: "complete"
---

## What Was Built

`flow-kit/lib/detection/project-type.js` implementing brownfield/greenfield project detection with:

- `detectProjectType(cwd)` - returns `{ isBrownfield, signals, businessLines }`
- `countBusinessCode(cwd, whitelist)` - recursively counts lines excluding whitelist + config files
- `writeProjectTypeFile(cwd, result)` - writes `.flow-kit/project-type` marker file
- `WHITELIST` - 14 config files excluded from line counting

Detection logic: project is brownfield if business code lines > 1000 OR lock files exist.

## Key Decisions

- Placed detection module under `flow-kit/lib/detection/` (not `flow-kit/guardrails/`) since it's shared utility
- Marker file format: `project_type/detected_at/detection_signals/business_code_lines` on separate lines
- flow-kit project itself detected as greenfield (484 lines, below 1000 threshold)
- Updated brownfield-guardrails.md to reference Phase 5 auto-detection module