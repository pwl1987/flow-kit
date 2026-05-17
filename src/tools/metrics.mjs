// metrics.mjs — MCP 工具：指标查询
// v3.8.0

import { readFileSync, existsSync } from 'fs';
import { join } from 'path';

export function register(server) {
  server.tool('flow_kit_metrics', {
    description: '查询 flow-kit 指标统计',
  }, async () => {
    const metricsFile = join(process.env.HOME || '/tmp', '.flow-kit/metrics.json');
    let metrics = { events: 0, phases_completed: 0 };

    if (existsSync(metricsFile)) {
      try {
        metrics = JSON.parse(readFileSync(metricsFile, 'utf8'));
      } catch {}
    }

    return {
      content: [{
        type: 'text',
        text: JSON.stringify(metrics, null, 2)
      }]
    };
  });
}