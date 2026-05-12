# 归档命令

> flow-kit v1.12.10 命令

## 两种归档模式

flow-kit 提供两种归档模式，适用于不同场景：

### 快速归档（tarball）

```bash
./flow-kit.sh archive
```

将 `.planning/phases/` 目录打包为 `.flow-kit/archive/archive-{timestamp}.tar.gz`。

适用场景：临时清理、快速归档中间状态

### 结构化归档（长期保存）

参考 `@flow-kit/archive/archive-change.md` 了解详细的归档流程。

将 `.specs/{change-id}/` 结构化归档到 `archive/YYYY-MM/{change-id}/` 目录，保留元数据和原始文件。

适用场景：变更完成后的长期归档、知识沉淀

## 使用建议

- 日常开发：使用 `./flow-kit.sh archive` 快速归档
- 变更完成：参考 archive-change.md 进行结构化归档
- CI/CD 场景：两种模式都支持自动化执行
