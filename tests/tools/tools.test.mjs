// tools.test.mjs — MCP 工具集成测试
// v3.8.0

import { describe, it, expect } from 'vitest';
import { existsSync } from 'fs';
import { join } from 'path';

describe('6.8 MCP 工具集成测试', () => {
  const TOOLS_DIR = join(process.env.FLOW_KIT_DIR || '.', 'flow-kit/src/tools');

  it('tools 目录存在', () => {
    expect(existsSync(TOOLS_DIR)).toBe(true);
  });

  it('核心工具文件存在', () => {
    const tools = ['status.mjs', 'version.mjs', 'health.mjs', 'recall.mjs', 'metrics.mjs', 'validate.mjs', 'phase.mjs', 'init.mjs', 'dispatch.mjs', 'shellcheck.mjs', 'register.mjs', 'watch.mjs'];
    for (const tool of tools) {
      expect(existsSync(join(TOOLS_DIR, tool))).toBe(true);
    }
  });
});