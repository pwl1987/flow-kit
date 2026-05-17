// dispatch.mjs — MCP 工具：任务分发
// v3.8.0

import { splitTask, executeSubagents, collectResults } from '../lib/dispatch-core.mjs';

export function register(server) {
  server.tool('flow_kit_dispatch', {
    description: '分发任务到多个子代理并行执行'
  }, async () => {
    return {
      content: [{ type: 'text', text: '用法: /flow-kit:dispatch <n> <task-description>' }]
    };
  });
}

export function registerDispatch(server) {
  server.tool('flow_kit_dispatch', {
    n: server._zod.number().default(3).describe('并行子代理数量'),
    task: server._zod.string().describe('任务描述')
  }, async ({ n, task }) => {
    const subtasks = splitTask(task, n);
    const results = await executeSubagents(subtasks);
    const collected = collectResults();

    return {
      content: [{
        type: 'text',
        text: `已分发 ${n} 个子代理，完成 ${collected.successful}/${collected.total}`
      }]
    };
  });
}