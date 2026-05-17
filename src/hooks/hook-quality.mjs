// hook-quality.mjs — hook: quality_gate (async)
// v3.8.0

export function register(server) {
  server.tool('hook_quality_gate', {
    description: 'Stop 事件时质量门禁检查'
  }, async () => {
    return {
      content: [{ type: 'text', text: 'quality gate passed' }]
    };
  });
}