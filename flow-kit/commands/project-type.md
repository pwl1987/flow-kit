# Command: /flow-kit:project-type

## 功能
- 检测并显示项目类型
- 手动覆盖项目类型

## 用法
- `/flow-kit:project-type` — 显示当前项目类型
- `/flow-kit:project-type detect` — 重新检测项目类型
- `/flow-kit:project-type brownfield` — 设为棕地
- `/flow-kit:project-type greenfield` — 设为绿地

## 检测信号
| 信号 | 棕地 | 绿地 |
|------|------|------|
| package.json + lock | 有 | 无 |
| Git remote | 有 | 无 |
| src/ LOC | > 5000 | < 5000 |

## 输出
- 写入 `.flow-kit/project-type` 文件
- 彩色输出检测结果摘要
