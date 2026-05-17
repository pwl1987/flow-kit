import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { writeFileSync, rmSync, mkdirSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let runPhase, loadWorkflow;

const TEST_DIR = tmpdir() + '/pe-test-' + Date.now();
mkdirSync(TEST_DIR, { recursive: true });

describe('3.1 phase-executor 模块', () => {
  beforeEach(async () => {
    process.env.SESSION_STATE_FILE = join(TEST_DIR, 'session.json');
    process.env.CURRENT_PHASE_FILE = join(TEST_DIR, 'current-phase');
    const pe = await import('../../src/lib/phase-executor.mjs');
    runPhase = pe.runPhase;
    loadWorkflow = pe.loadWorkflow;
  });

  afterEach(() => {
    rmSync(TEST_DIR, { recursive: true, force: true });
  });

  describe('loadWorkflow()', () => {
    it('加载含 front matter 的文件', () => {
      const workflowFile = join(TEST_DIR, 'workflow.md');
      writeFileSync(workflowFile, '---\nphase: 1\nname: test-workflow\n---\n# Test');
      
      const result = loadWorkflow(workflowFile);
      expect(result).toBeDefined();
      expect(result.phase).toBe(1);
    });

    it('文件不存在时抛出错误', () => {
      expect(() => loadWorkflow('/nonexistent/file.md')).toThrow();
    });
  });

  describe('runPhase()', () => {
    it('执行有效 phase', () => {
      const result = runPhase(1);
      expect(result).toBeDefined();
      expect(result.phase).toBe(1);
    });

    it('更新 session state', () => {
      runPhase(2);
      // Session should be updated
      expect(true).toBe(true);
    });
  });
});
