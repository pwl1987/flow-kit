import { describe, it, expect, beforeEach } from 'vitest';
import { rmSync, writeFileSync, mkdirSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let classifyRequirement, detectConflict, detectFileConflict, handleConflictDecision;

const TEST_DIR = tmpdir() + '/cd-test-' + Date.now();
mkdirSync(TEST_DIR, { recursive: true });

describe('2.5 conflict-detector 模块', () => {
  beforeEach(async () => {
    process.env.SESSION_STATE_FILE = join(TEST_DIR, 'session.json');
    const cd = await import('../../src/lib/conflict-detector.mjs');
    classifyRequirement = cd.classifyRequirement;
    detectConflict = cd.detectConflict;
    detectFileConflict = cd.detectFileConflict;
    handleConflictDecision = cd.handleConflictDecision;
  });

  describe('classifyRequirement()', () => {
    it('分类 feature', () => {
      expect(classifyRequirement('add user login')).toBe('feature');
    });

    it('分类 bugfix', () => {
      expect(classifyRequirement('fix login bug')).toBe('bugfix');
    });

    it('分类 refactor', () => {
      expect(classifyRequirement('refactor auth module')).toBe('refactor');
    });

    it('分类 docs', () => {
      expect(classifyRequirement('update README')).toBe('docs');
    });

    it('未知类型返回 unknown', () => {
      expect(classifyRequirement('xyz abc 123')).toBe('unknown');
    });
  });

  describe('detectConflict()', () => {
    it('无冲突时返回 null', () => {
      const result = detectConflict({ type: 'feature', scope: 'auth' });
      expect(result).toBeNull();
    });
  });

  describe('detectFileConflict()', () => {
    it('未占用时返回 null', () => {
      const result = detectFileConflict('src/lib/new-file.mjs');
      expect(result).toBeNull();
    });
  });

  describe('handleConflictDecision()', () => {
    it('处理 merge 决策', () => {
      const result = handleConflictDecision('merge');
      expect(result).toBeDefined();
    });

    it('处理 override 决策', () => {
      const result = handleConflictDecision('override');
      expect(result).toBeDefined();
    });

    it('处理 defer 决策', () => {
      const result = handleConflictDecision('defer');
      expect(result).toBeDefined();
    });
  });
});
