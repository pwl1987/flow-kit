# resume

> flow-kit v3.0.0 命令

## 描述

恢复上次会话状态。读取 `.flow-kit/session-state.json`，输出当前变更、阶段、任务进度、阻塞项和下一步操作。

## 用法

```
/flow-kit:resume
```

## 行为

1. 读取 `.flow-kit/session-state.json`
2. 若存在 `.specs/{change-id}/PROGRESS.md`，附加进度信息
3. 若存在 `.specs/{change-id}/TASK.md`，附加任务清单
4. 输出 caveman 风格恢复摘要
