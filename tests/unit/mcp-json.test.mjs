import { describe, it, expect } from 'vitest';
import { readFileSync, existsSync } from 'fs';
import { resolve } from 'path';

const PROJECT_ROOT = '/data/Code/pwl/code/plugins';

describe('0.4 创建 .mcp.json', () => {
  it('.mcp.json 存在且可解析', () => {
    const path = resolve(PROJECT_ROOT, '.mcp.json');
    expect(existsSync(path)).toBe(true);
    JSON.parse(readFileSync(path, 'utf8'));
  });

  it('flow-kit 服务器 command 为 node', () => {
    const data = JSON.parse(readFileSync(resolve(PROJECT_ROOT, '.mcp.json'), 'utf8'));
    expect(data.mcpServers['flow-kit'].command).toBe('node');
  });

  it('flow-kit 服务器 alwaysLoad 为 true', () => {
    const data = JSON.parse(readFileSync(resolve(PROJECT_ROOT, '.mcp.json'), 'utf8'));
    expect(data.mcpServers['flow-kit'].alwaysLoad).toBe(true);
  });

  it('args 包含 CLAUDE_PLUGIN_ROOT 变量', () => {
    const data = JSON.parse(readFileSync(resolve(PROJECT_ROOT, '.mcp.json'), 'utf8'));
    const args = data.mcpServers['flow-kit'].args;
    expect(args.some(a => a.includes('${CLAUDE_PLUGIN_ROOT}'))).toBe(true);
  });

  it('args 指向 dist/mcp-server.cjs', () => {
    const data = JSON.parse(readFileSync(resolve(PROJECT_ROOT, '.mcp.json'), 'utf8'));
    const args = data.mcpServers['flow-kit'].args;
    expect(args.some(a => a.includes('dist/mcp-server.cjs'))).toBe(true);
  });
});
