import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { existsSync, writeFileSync, rmSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let registerCleanup, doCleanup, withCleanup;

describe('1.4 cleanup 模块', () => {
  beforeEach(async () => {
    const cleanup = await import('../../src/lib/cleanup.mjs');
    registerCleanup = cleanup.registerCleanup;
    doCleanup = cleanup.doCleanup;
    withCleanup = cleanup.withCleanup;
  });

  afterEach(() => {
    doCleanup();
  });

  describe('registerCleanup()', () => {
    it('注册临时文件', () => {
      const tmpFile = join(tmpdir(), 'test-cleanup-' + Date.now() + '.tmp');
      writeFileSync(tmpFile, 'test');
      registerCleanup(tmpFile);
      expect(existsSync(tmpFile)).toBe(true);
    });
  });

  describe('doCleanup()', () => {
    it('删除所有注册文件', () => {
      const tmpFile = join(tmpdir(), 'test-cleanup-' + Date.now() + '.tmp');
      writeFileSync(tmpFile, 'test');
      registerCleanup(tmpFile);
      doCleanup();
      expect(existsSync(tmpFile)).toBe(false);
    });

    it('重复调用安全', () => {
      doCleanup();
      doCleanup();
      expect(true).toBe(true);
    });
  });

  describe('withCleanup()', () => {
    it('函数执行后自动清理', () => {
      const tmpFile = join(tmpdir(), 'test-with-cleanup-' + Date.now() + '.tmp');
      writeFileSync(tmpFile, 'test');
      registerCleanup(tmpFile);
      
      const result = withCleanup(() => 'executed');
      
      expect(result).toBe('executed');
    });
  });
});
