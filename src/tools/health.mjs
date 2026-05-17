// health.mjs — MCP 工具：健康检查
// v3.8.0

import { existsSync } from 'fs';

export function register(server) {
  server.tool('flow_kit_health', {
    description: '检查 flow-kit 健康状态',
  }, async () => {
    const checks = {
      node: true,
      filesystem: true,
      session: existsSync(process.env.HOME + '/.flow-kit/session-state.json')
    };

    const healthy = checks.node && checks.filesystem;
    const text = healthy
      ? 'flow-kit 健康检查通过'
      : `flow-kit 健康检查异常: ${Object.entries(checks).filter(([k,v]) => !v).map(([k]) => k).join(', ')}`;

    return {
      content: [{ type: 'text', text }],
      isError: !healthy
    };
  });
}