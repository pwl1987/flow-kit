import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { existsSync, rmSync, mkdirSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let initChange, checkCollision, createSpecDir;

const TEST_DIR = join(tmpdir(), 'ic-test-' + Date.now());
mkdirSync(TEST_DIR, { recursive: true });

describe('3.6 init-change 模块', () => {
  beforeEach(async () => {
    process.env.SPECS_DIR = TEST_DIR;
    const ic = await import('../../src/lib/init-change.mjs');
    initChange = ic.initChange;
    checkCollision = ic.checkCollision;
    createSpecDir = ic.createSpecDir;
  });

  afterEach(() => {
    rmSync(TEST_DIR, { recursive: true, force: true });
    mkdirSync(TEST_DIR, { recursive: true });
  });

  describe('checkCollision()', () => {
    it('名称不存在时返回 null', () => {
      const result = checkCollision('nonexistent-change');
      expect(result).toBeNull();
    });

    it('名称已存在时返回冲突信息', () => {
      createSpecDir('20260101-test-change');
      const result = checkCollision('test-change');
      expect(result).not.toBeNull();
      expect(result.existing).toBe(true);
    });
  });

  describe('createSpecDir()', () => {
    it('创建正确的目录结构', () => {
      const changeId = '20260101-test';
      createSpecDir(changeId);
      expect(existsSync(join(TEST_DIR, changeId))).toBe(true);
    });
  });

  describe('initChange()', () => {
    it('完整初始化流程', async () => {
      const result = await initChange('test-change', '测试变更');
      expect(result).toHaveProperty('changeId');
      expect(result).toHaveProperty('slug');
    });

    it('slug 含特殊字符时清理为安全名称', async () => {
      const result = await initChange('Test@Change!', '测试');
      expect(result.slug).toMatch(/^[a-z0-9-]+$/);
    });
  });
});