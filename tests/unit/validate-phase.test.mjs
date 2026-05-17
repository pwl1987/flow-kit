import { describe, it, expect, beforeEach } from 'vitest';
import { writeFileSync, mkdirSync, rmSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let validateArtifacts, recordEvidence, validateSchema;

const TEST_DIR = join(tmpdir(), 'vp-test-' + Date.now());
mkdirSync(TEST_DIR, { recursive: true });

describe('3.7 validate-phase 模块', () => {
  beforeEach(async () => {
    process.env.PROJECT_DIR = TEST_DIR;
    const vp = await import('../../src/lib/validate-phase.mjs');
    validateArtifacts = vp.validateArtifacts;
    recordEvidence = vp.recordEvidence;
    validateSchema = vp.validateSchema;
  });

  afterEach(() => {
    rmSync(TEST_DIR, { recursive: true, force: true });
    mkdirSync(TEST_DIR, { recursive: true });
  });

  describe('validateArtifacts()', () => {
    it('所有产物存在时返回有效', async () => {
      const phaseFile = join(TEST_DIR, 'phase-1.md');
      writeFileSync(phaseFile, `---\nphase: 1\nexpected_artifacts:\n  - README.md\n---\n# Phase 1`);
      writeFileSync(join(TEST_DIR, 'README.md'), '# Test');

      const result = await validateArtifacts(1);
      expect(result.valid).toBe(true);
      expect(result.missing).toEqual([]);
    });

    it('部分产物缺失时返回无效', async () => {
      const phaseFile = join(TEST_DIR, 'phase-2.md');
      writeFileSync(phaseFile, `---\nphase: 2\nexpected_artifacts:\n  - README.md\n  - CHANGELOG.md\n---\n# Phase 2`);
      writeFileSync(join(TEST_DIR, 'README.md'), '# Test');

      const result = await validateArtifacts(2);
      expect(result.valid).toBe(false);
      expect(result.missing).toContain('CHANGELOG.md');
    });
  });

  describe('recordEvidence()', () => {
    it('记录验证证据到 session', async () => {
      const data = { phase: 1, valid: true, checked: ['README.md'] };
      const result = await recordEvidence(1, data);
      expect(result).toHaveProperty('recorded');
    });
  });

  describe('validateSchema()', () => {
    it('产物符合 schema 定义', async () => {
      const output = { name: 'test', version: '1.0.0' };
      const result = await validateSchema('phase-1', output);
      expect(result).toHaveProperty('valid');
    });
  });
});