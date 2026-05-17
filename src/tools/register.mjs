// register.mjs — MCP 工具：命令注册
// v3.8.0

import { registerAllCommands } from '../lib/command-gen.mjs';

export function register(server) {
  server.tool('flow_kit_register', {
    description: '注册所有 flow-kit 斜杠命令'
  }, async () => {
    const result = registerAllCommands();

    return {
      content: [{
        type: 'text',
        text: `已注册 ${result.total} 个命令`
      }]
    };
  });
}