// hook-session.mjs — hook: session_restore
// v3.8.0

export function register(server) {
  server.tool('hook_session_restore', {
    description: '新会话时恢复状态'
  }, async () => {
    return {
      content: [{ type: 'text', text: 'session restored' }]
    };
  });
}