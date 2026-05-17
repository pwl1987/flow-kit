// validate.mjs — MCP 工具：产物验证
// v3.8.0

import { validateArtifacts, validateSchema } from '../lib/validate-phase.mjs';

export function register(server) {
  server.tool('flow_kit_validate', {
    phase: server._zod.number().default(1).describe('要验证的 phase 编号 (1-8)')
  }, async ({ phase }) => {
    const result = await validateArtifacts(phase);

    return {
      content: [{
        type: 'text',
        text: result.valid
          ? `Phase ${phase} 验证通过`
          : `Phase ${phase} 验证失败，缺失: ${result.missing.join(', ')}`
      }],
      isError: !result.valid
    };
  });
}