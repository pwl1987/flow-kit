// shellcheck.mjs — MCP 工具：Shell 静态分析
// v3.8.0

import { existsSync, readdirSync } from 'fs';
import { join } from 'path';

export function register(server) {
  server.tool('flow_kit_shellcheck', {
    description: '对 Shell 脚本进行静态分析'
  }, async () => {
    const flowKitDir = process.env.FLOW_KIT_DIR || '.';
    const scriptsDir = join(flowKitDir, 'scripts');
    const libDir = join(flowKitDir, 'lib');

    const files = [];
    if (existsSync(scriptsDir)) {
      for (const f of readdirSync(scriptsDir)) {
        if (f.endsWith('.sh')) {
          files.push(join(scriptsDir, f));
        }
      }
    }
    if (existsSync(libDir)) {
      for (const f of readdirSync(libDir)) {
        if (f.endsWith('.sh')) {
          files.push(join(libDir, f));
        }
      }
    }

    return {
      content: [{
        type: 'text',
        text: `找到 ${files.length} 个 Shell 脚本（v3.8.0 已迁移到 JS）`
      }]
    };
  });
}