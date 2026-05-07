> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为 P0 审批文件模板。
> D4-8: P0 Approval Record Template

# P0 Approval Record

## Change Information

- **Change ID**: {change_id}
- **Timestamp**: {timestamp}
- **Risk Level**: P0
- **Trigger**: {auto-detected|manual-flag}

## Affected Files

{files_list}

## Change Description

{change_description}

## Risk Assessment

| Category | Risk Level | Notes |
|----------|------------|-------|
| Data Impact | {high/medium/low} | |
| Reversibility | {irreversible/reversible} | |
| Scope | {global/local} | |

## Approval Decision

- **Approver**: {approver}
- **Role**: {admin|reviewer}
- **Decision**: {APPROVED|REJECTED}
- **Decision Time**: {YYYY-MM-DD HH:mm:ss}
- **Reason**: {reason}

## Constitution Compliance

This change has been reviewed against constitution.md safety rules:
- SEC-01~05: {compliant|violation}
- DATA-01~05: {compliant|violation}
- DEPLOY-01~05: {compliant|violation}
- GIT-01~05: {compliant|violation}

## Next Steps

- If APPROVED: Proceed to Phase 5-6 delivery verification
- If REJECTED: Modify change and re-trigger P0 approval
