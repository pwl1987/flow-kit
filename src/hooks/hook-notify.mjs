// hook-notify.mjs — hook: send_notification
// v3.8.0

export function register(server) {
  server.tool('hook_send_notification', {
    description: '发送通知'
  }, async () => {
    return {
      content: [{ type: 'text', text: 'notification sent' }]
    };
  });
}