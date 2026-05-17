import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { existsSync, mkdirSync, rmSync, writeFileSync, readFileSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

const PROJECT_ROOT = '/data/Code/pwl/code/plugins';
const TEST_LOCK_DIR = join(tmpdir(), 'flow-kit-lock-test-' + Date.now());

let acquireLock, releaseLock, isLockStale, acquireSlot, releaseSlot;

describe('1.3 lock 模块', () => {
  beforeEach(async () => {
    mkdirSync(TEST_LOCK_DIR, { recursive: true });
    process.env.LOCK_DIR = TEST_LOCK_DIR;
    process.env.TMP_DIR = tmpdir();
    
    const lock = await import('../../src/lib/lock.mjs');
    acquireLock = lock.acquireLock;
    releaseLock = lock.releaseLock;
    isLockStale = lock.isLockStale;
    acquireSlot = lock.acquireSlot;
    releaseSlot = lock.releaseSlot;
  });

  afterEach(() => {
    rmSync(TEST_LOCK_DIR, { recursive: true, force: true });
    delete process.env.LOCK_DIR;
  });

  describe('acquireLock()', () => {
    it('成功获取锁', () => {
      const result = acquireLock('test-resource');
      expect(result).toBe(true);
      expect(existsSync(join(TEST_LOCK_DIR, 'test-resource.lock'))).toBe(true);
    });

    it('同一资源不能重复获取', () => {
      acquireLock('test-resource');
      const result = acquireLock('test-resource');
      expect(result).toBe(false);
    });

    it('释放锁后可重新获取', () => {
      acquireLock('test-resource');
      releaseLock('test-resource');
      const result = acquireLock('test-resource');
      expect(result).toBe(true);
    });
  });

  describe('releaseLock()', () => {
    it('释放不存在的锁不报错', () => {
      expect(() => releaseLock('non-existent')).not.toThrow();
    });
  });

  describe('isLockStale()', () => {
    it('不存在的锁返回 false', () => {
      expect(isLockStale('non-existent')).toBe(false);
    });
  });

  describe('acquireSlot()', () => {
    it('获取槽位成功', () => {
      const slot = acquireSlot(3);
      expect(slot).toBeDefined();
      expect(slot).toBeGreaterThanOrEqual(0);
    });
  });

  describe('releaseSlot()', () => {
    it('释放槽位安全处理', () => {
      const slot = acquireSlot(3);
      expect(() => releaseSlot()).not.toThrow();
    });
  });
});
