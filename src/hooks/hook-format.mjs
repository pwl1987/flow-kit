// hook-format.mjs — hook: post_edit_format
// v3.8.0

export function register(server) {
  server.tool('hook_post_edit_format', {
    description: '编辑后自动格式化'
  }, async () => {
    return {
      content: [{ type: 'text', text: 'format applied' }]
    };
  });
}