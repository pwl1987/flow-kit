// hooks.test.mjs — Hook 工具测试
// v3.8.0

import { describe, it, expect } from 'vitest';
import { existsSync } from 'fs';
import { join } from 'path';

describe('6.9 Hook 工具测试', () => {
  const HOOKS_DIR = join(process.env.FLOW_KIT_DIR || '.', 'flow-kit/src/hooks');

  it('hooks 目录存在', () => {
    expect(existsSync(HOOKS_DIR)).toBe(true);
  });

  it('所有 hook 文件存在', () => {
    const hooks = ['hook-guard.mjs', 'hook-format.mjs', 'hook-quality.mjs', 'hook-session.mjs', 'hook-notify.mjs'];
    for (const hook of hooks) {
      expect(existsSync(join(HOOKS_DIR, hook))).toBe(true);
    }
  });
});