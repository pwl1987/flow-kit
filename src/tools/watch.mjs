// watch.mjs — MCP 工具：监控
// v3.8.0

export function register(server) {
  server.tool('flow_kit_watch', {
    description: '监控 flow-kit 运行状态'
  }, async () => {
    return {
      content: [{ type: 'text', text: 'watching...' }]
    };
  });
}