# Phase 7 Plan 02: P0-approval Auto-generate + APPROVAL.md.template

**Area:** B - P0 审批流自动生成
**Requirements:** REQ-011, REQ-012
**Status:** Complete

---

## One-liner

P0 审批文件自动生成：新增 approval-template.md，更新 p0-approval.md 支持自动生成审批记录。

---

## Tasks Executed

| # | Task | Commit | Files |
|---|------|--------|-------|
| 1 | 创建 APPROVAL.md.template | c5314c9 | flow-kit/templates/approval/approval-template.md |
| 2 | 更新 p0-approval.md 自动生成逻辑 | d9f2f1c | flow-kit/commands/p0-approval.md |
| 3 | 验证集成 | - | p0-approval.md + approval-template.md |

---

## Key Decisions

- **Template location:** `flow-kit/templates/approval/approval-template.md` — follows existing template directory structure
- **Auto-generate trigger:** After APPROVED/REJECTED decision in p0-approval workflow
- **Output path:** `.flow-kit/approvals/{YYYYMMDD-HHMMSS}-P0-{change_id}.md`

---

## Deliverables

### Created
- `flow-kit/templates/approval/approval-template.md` — 49 lines, full approval record structure

### Modified
- `flow-kit/commands/p0-approval.md` — +10 lines, Section 5: Auto-generate Approval File

---

## Field Mapping (Task 3 Verification)

| Template Field | p0-approval.md Source |
|----------------|----------------------|
| Approver | `{user_id}` from approval log |
| Role | `{admin \| reviewer}` — validated against team-roles.md |
| Decision | APPROVED/REJECTED from user input |
| Timestamp | `{YYYY-MM-DD HH:mm:ss}` from approval log |

---

## Commits

- `c5314c9` feat(07-P2-enhancement): add P0 approval template
- `d9f2f1c` feat(07-P2-enhancement): add auto-generate approval file logic to p0-approval

---

## Self-Check

- [x] APPROVAL.md.template exists, structure complete
- [x] p0-approval.md contains auto-generate logic
- [x] Fields covered: change info, risk level, approver, timestamp, decision, reason
- [x] Template located at `flow-kit/templates/approval/approval-template.md`
- [x] p0-approval.md updated with auto-generate section

## Self-Check: PASSED
