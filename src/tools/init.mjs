// init.mjs — MCP 工具：变更初始化
// v3.8.0

import { initChange } from '../lib/init-change.mjs';

export function register(server) {
  server.tool('flow_kit_init', {
    description: '初始化新变更'
  }, async () => {
    return {
      content: [{ type: 'text', text: '请提供变更名称：/flow-kit:init <name>' }]
    };
  });
}

export function registerInit(server) {
  server.tool('flow_kit_init', {
    name: server._zod.string().describe('变更名称'),
    description: server._zod.string().optional().describe('变更描述')
  }, async ({ name, description }) => {
    const result = await initChange(name, description || '');
    return {
      content: [{
        type: 'text',
        text: `变更已创建: ${result.changeId}`
      }]
    };
  });
}