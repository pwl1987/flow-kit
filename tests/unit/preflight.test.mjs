import { describe, it, expect } from 'vitest';
import { execSync } from 'child_process';

let requireTool, requireJq;

function which(cmd) {
  try {
    execSync(`which ${cmd}`, { stdio: 'pipe' });
    return true;
  } catch {
    return false;
  }
}

describe('1.6 preflight 模块', () => {
  beforeEach(async () => {
    const preflight = await import('../../src/lib/preflight.mjs');
    requireTool = preflight.requireTool;
    requireJq = preflight.requireJq;
  });

  describe('requireTool()', () => {
    it('git 存在时返回 true', () => {
      if (which('git')) {
        expect(requireTool('git', 'git')).toBe(true);
      }
    });

    it('nonexistent_xyz 不存在时抛出错误', () => {
      expect(() => requireTool('nonexistent', 'nonexistent_xyz')).toThrow();
    });

    it('错误信息包含工具名称', () => {
      try {
        requireTool('test-tool', 'test-tool-xyz');
      } catch (e) {
        expect(e.message).toContain('test-tool');
      }
    });
  });

  describe('requireJq()', () => {
    it('jq 存在时返回 true', () => {
      if (which('jq')) {
        expect(requireJq()).toBe(true);
      }
    });
  });
});
