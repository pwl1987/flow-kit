--- BEGIN flow-kit/commands/sync-team-config.md ---
> 【CLAUDE CODE INSTRUCTION 强制约束】

## 优先级加载（任何逻辑不得违反）

1. **立即加载** `@flow-kit/config/constitution.md`（全局最高优先级）
2. **立即加载** `@flow-kit/config/default-user-config.md`，若存在 `.flow-kit/user-config.md` 则优先加载用户自定义配置
3. 后续所有逻辑必须遵守这两份配置

---

# Sync Team Config

## Command

`/flow-kit:sync-team`

## Purpose

Sync team configuration across team members. Merge team conventions, shared settings, and user preferences while resolving conflicts.

## Input

1. **Team config source** — git URL, local path, or shared network location
2. **Target location** — `.flow-kit/user-config.md`

## What Gets Synced

| Config | Location | Sync Strategy |
|--------|----------|---------------|
| Constitution (safety floor) | `config/constitution.md` | Immutable, cannot be modified, team version always wins |
| Team roles | `config/team-roles.md` | Team standard, defines permissions, user cannot override |
| User preferences | `.flow-kit/user-config.md` | User wins on conflict |
| Team conventions | `.flow-kit/conventions.md` | Team default, user can override |
| Code style | `.flow-kit/style.md` | Merge, keep strictest |
| Review process | `.flow-kit/review.md` | Team standard |
| Decision log | `.flow-kit/decisions.md` | Append only |

### Constitution Sync Rules

- Constitution syncs as **immutable** (read-only safety floor)
- User cannot override Constitution rules (SEC/DATA/DEPLOY/GIT)
- If local constitution conflicts with team version, **team version wins**
- Constitution always loads first, enforces last

### Team Roles Sync Rules

- Roles sync with **team standard priority**
- User cannot modify role definitions
- Roles validated against schema: `admin`, `reviewer`, `developer`, `viewer`
- **Unknown roles rejected** at config load with error
- Default fallback: `viewer` if no role specified

## Execution

### 0. Backup Before Merge

Before writing any config:
```bash
# Create backup directory with timestamp
BACKUP_DIR=".flow-kit/backup/$(date -u +'%Y%m%d_%H%M%S')"
mkdir -p "${BACKUP_DIR}"

# Backup existing configs
[ -f ".flow-kit/user-config.md" ] && cp .flow-kit/user-config.md "${BACKUP_DIR}/"
[ -f ".flow-kit/conventions.md" ] && cp .flow-kit/conventions.md "${BACKUP_DIR}/"
[ -f ".flow-kit/style.md" ] && cp .flow-kit/style.md "${BACKUP_DIR}/"
[ -f ".flow-kit/review.md" ] && cp .flow-kit/review.md "${BACKUP_DIR}/"
[ -f ".flow-kit/decisions.md" ] && cp .flow-kit/decisions.md "${BACKUP_DIR}/"

# Log backup location
echo "Backup created at: ${BACKUP_DIR}"
```

### 1. Fetch Team Config

**Git source (clone if not exists):**
```bash
TEMP_DIR="/tmp/team-config-sync"

# Clone if not exists
if [ ! -d "${TEMP_DIR}" ]; then
  git clone {git_url} "${TEMP_DIR}"
else
  # Fetch if exists
  cd "${TEMP_DIR}"
  git fetch origin
  git checkout origin/team-config
fi

# Copy to local
cp -r "${TEMP_DIR}/.flow-kit/" .flow-kit/
cp -r "${TEMP_DIR}/flow-kit/config/" flow-kit/config/
```

**Local path source:**
```bash
cp -r /path/to/team-config/.flow-kit/* .flow-kit/
cp -r /path/to/team-config/flow-kit/config/* flow-kit/config/
```

### 2. Merge Strategy

**Constitution and roles**: Team version always wins (immutable)
**User preferences**: User wins on conflicts

For each config file:
1. Read team config (constitution, roles first)
2. Validate roles against known schema
3. Reject unknown roles
4. Read local user config
5. Merge with role priority

**Role Validation Schema:**
| Role | Access Level | P0 Approval | Deploy | Notes |
|------|--------------|-------------|--------|-------|
| admin | Full access | Yes | Yes | All permissions |
| reviewer | Review access | Yes | No | Can approve P0 |
| developer | Read/write | No | No | No P0 or deploy |
| viewer | Read-only | No | No | No modifications |

### 3. Conflict Resolution Logic

| Config | Team Wins | User Wins | Notes |
|--------|-----------|-----------|-------|
| constitution.md | Yes | No | Immutable safety floor |
| team-roles.md | Yes | No | Role definitions immutable |
| user-config.md | No | Yes | User preferences win |
| conventions.md | Default | Override | Team default, user can override |
| style.md | Merge | Keep strictest | Both styles preserved |
| review.md | Yes | No | Team standard process |

| Conflict Type | Resolution |
|--------------|------------|
| Personal preference vs team standard | User preference wins |
| Code style (tabs vs spaces) | Merge, keep strictest |
| Review process steps | Team standard |
| Tool configuration | Merge, keep both if compatible |

### 3. Validation Checks

Validate merged config for:
- **Schema compliance** — matches expected structure
- **Value validity** — settings within acceptable ranges
- **No conflicts** — important settings not contradictory
- **Completeness** — required fields present

**Role Validation**:
- Known roles: `admin`, `reviewer`, `developer`, `viewer`
- Unknown roles rejected with error: "Unknown role: {role}. Valid roles: admin, reviewer, developer, viewer"
- Default fallback: `viewer` if no role specified

### 4. Conflict Resolution

| Conflict Type | Resolution |
|--------------|------------|
| Personal preference vs team standard | User preference wins |
| Code style (tabs vs spaces) | User preference wins |
| Review process steps | Team standard |
| Tool configuration | Merge, keep both if compatible |

### 5. Write Merged Config

Write to `.flow-kit/user-config.md` with original values preserved.

## Output

```
## Team Config Synced

**Source**: [git URL or path]
**Timestamp**: [when sync completed]

| Config File | Status | Changes |
|-------------|--------|---------|
| constitution.md | Synced (immutable) | Team version applied |
| team-roles.md | Synced (validated) | 4 roles validated |
| user-config.md | Merged | 3 overrides applied |
| conventions.md | Updated | 1 new convention |
| style.md | Merged | 2 conflicts resolved |

**Next Steps**:
- Review `.flow-kit/user-config.md` for your overrides
- Update local settings as needed
```

## Usage

```bash
@flow-kit/commands/sync-team-config.md
```

## Safety Rules

1. **Never force overwrite user preferences** — user config takes priority
2. **Backup before merge** — keep original in `.flow-kit/backup/`
3. **Validate before write** — ensure merged config is valid
4. **Log all changes** — record what was merged and why

--- END flow-kit/commands/sync-team-config.md ---