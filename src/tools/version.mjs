// version.mjs — MCP 工具：版本查询
// v3.8.0

import { readFileSync, existsSync } from 'fs';
import { join } from 'path';

export function register(server) {
  server.tool('flow_kit_version', {
    description: '查询 flow-kit 版本',
  }, async () => {
    const versionFile = join(process.env.CLAUDE_PLUGIN_ROOT || '.', 'VERSION');
    let version = 'unknown';

    if (existsSync(versionFile)) {
      version = readFileSync(versionFile, 'utf8').trim();
    }

    return {
      content: [{
        type: 'text',
        text: `flow-kit v${version}`
      }]
    };
  });
}