import { describe, it, expect } from 'vitest';

let createServer;

describe('4.1 MCP Server 入口', () => {
  beforeEach(async () => {
    const server = await import('../../src/server.mjs');
    createServer = server.createServer;
  });

  it('createServer 返回对象包含 server 和 transport', () => {
    const result = createServer();
    expect(result).toHaveProperty('server');
    expect(result).toHaveProperty('transport');
  });

  it('server 有 tool 方法', () => {
    const { server } = createServer();
    expect(typeof server.tool).toBe('function');
  });
});