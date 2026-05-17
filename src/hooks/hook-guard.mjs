// hook-guard.mjs — hook: pre_tool_guard
// v3.8.0

export function register(server) {
  server.tool('hook_pre_tool_guard', {
    description: '工具执行前守卫检查'
  }, async () => {
    return {
      content: [{ type: 'text', text: 'guard check passed' }]
    };
  });
}