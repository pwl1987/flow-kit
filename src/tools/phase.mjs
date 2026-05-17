// phase.mjs — MCP 工具：阶段控制 (next_phase + run_phase)
// v3.8.0

import { runPhase } from '../lib/phase-executor.mjs';
import { doNext } from '../lib/auto-pilot.mjs';

export function register(server) {
  server.tool('flow_kit_next_phase', {
    description: '推进到下一个阶段'
  }, async () => {
    const result = doNext();
    return {
      content: [{ type: 'text', text: result.message }]
    };
  });

  server.tool('flow_kit_run_phase', {
    phase: server._zod.number().min(0).max(8).describe('要执行的阶段编号 (0-8)')
  }, async ({ phase }) => {
    const result = runPhase(phase);
    return {
      content: [{
        type: 'text',
        text: `Phase ${phase} 执行完成`
      }]
    };
  });
}