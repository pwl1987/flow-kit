// recall.mjs — MCP 工具：会话恢复
// v3.8.0

import { readFileSync, existsSync } from 'fs';
import { join } from 'path';

export function register(server) {
  server.tool('flow_kit_recall', {
    description: '恢复上次会话状态',
  }, async () => {
    const sessionFile = join(process.env.HOME || '/tmp', '.flow-kit/session-state.json');

    if (!existsSync(sessionFile)) {
      return {
        content: [{ type: 'text', text: '无历史会话可恢复' }],
        isError: true
      };
    }

    try {
      const data = JSON.parse(readFileSync(sessionFile, 'utf8'));
      const summary = [
        `变更: ${data.change || '未设置'}`,
        `Phase: ${data.phase || 0}`,
        `状态: ${data.status || 'init'}`
      ].join(' | ');

      return {
        content: [{ type: 'text', text: summary }]
      };
    } catch {
      return {
        content: [{ type: 'text', text: '会话数据损坏' }],
        isError: true
      };
    }
  });
}