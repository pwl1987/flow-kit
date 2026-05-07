> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本命令提供三级生产安全护栏，激活破坏性命令警告，限制文件编辑范围。

## 三级生产安全护栏

### /careful（警告模式）

激活破坏性命令警告。检测到以下命令时暂停并要求确认：

**检测的破坏性命令模式：**
- `rm -rf`、`rm -r /`、`dd if=`
- `DROP TABLE`、`DELETE FROM`（无 WHERE）
- `git push --force`、`git reset --hard`
- `:!wq`（vim/nano 中的强制退出）
- 任何包含 `> /dev/sda` 或 `> /dev/null` 的重定向

**检测到破坏性命令时输出：**
```
⚠️ [DESTRUCTIVE COMMAND DETECTED]
Command: {command}
Risk: {risk_level}
Abort? [y/n]
```

---

### /freeze（限制编辑范围）

限制文件编辑范围。激活后：

- 只允许编辑 `allowed_dirs` 内的文件
- **默认允许：** 项目根目录、`flow-kit/`、`commands/`、`skills/`
- **禁止编辑：** `.git/`、`node_modules/`、生产配置
- 尝试编辑禁区文件时输出：
  ```
  🔒 [FROZEN] File {path} is in restricted zone. Unfreeze with /unfreeze to edit.
  ```

---

### /guard（组合模式）

同时激活 `/careful` 和 `/freeze`，提供完整保护。

---

### /unfreeze（解除限制）

解除 freeze 限制，允许编辑所有文件。

---

## 配置（可在 user-config.md 中设置）

```yaml
production_safety:
  auto_enable_on_production_branch: true
  freeze_allowed_dirs:
    - flow-kit/
    - commands/
    - skills/
    - phases/
    - templates/
  destructive_commands:
    - rm -rf
    - DROP TABLE
    - git push --force
```

---

## 触发条件

| 触发方式 | 说明 |
|---------|------|
| `/careful` | 用户手动激活 |
| `/freeze` | 用户手动激活，或在生产分支上自动启用 |
| `/guard` | 用户手动激活，或检测到关键操作时自动激活 |
| `/unfreeze` | 用户手动解除限制 |

**自动启用条件：** 检测到生产分支（main/master/prod）+ 破坏性命令

---

## 风险等级分类

| 等级 | 说明 | 示例 |
|------|------|------|
| CRITICAL | 不可逆数据丢失 | `rm -rf /`、`DROP TABLE` |
| HIGH | 系统级修改 | `git reset --hard`、`dd if=` |
| MEDIUM | 配置级修改 | `git push --force` |
| LOW | 潜在危险重定向 | `> /dev/null` |

---

## 参考来源

- [garrytan/gstack](https://github.com/garrytan/gstack) — /careful + /freeze + /guard 三级安全护栏
