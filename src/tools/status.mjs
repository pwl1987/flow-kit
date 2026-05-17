// status.mjs — MCP 工具：状态查询
// v3.8.0

import { readFileSync, existsSync } from 'fs';
import { join } from 'path';

export function register(server) {
  server.tool('flow_kit_status', {
    description: '查询 flow-kit 当前状态',
  }, async () => {
    const sessionFile = join(process.env.HOME || '/tmp', '.flow-kit/session-state.json');
    let status = { phase: 0, change: '', status: 'init' };

    if (existsSync(sessionFile)) {
      try {
        status = JSON.parse(readFileSync(sessionFile, 'utf8'));
      } catch {}
    }

    return {
      content: [{
        type: 'text',
        text: JSON.stringify({
          version: '3.8.0',
          ...status
        }, null, 2)
      }]
    };
  });
}