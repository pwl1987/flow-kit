import { describe, it, expect, beforeEach } from 'vitest';
import { existsSync, readFileSync, rmSync, mkdirSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let generateEntry, generatePhaseEntry, registerAllCommands;

const TEST_DIR = join(tmpdir(), 'cg-test-' + Date.now());
mkdirSync(TEST_DIR, { recursive: true });

describe('3.5 command-gen 模块', () => {
  beforeEach(async () => {
    process.env.OUTPUT_PATH = TEST_DIR;
    mkdirSync(TEST_DIR, { recursive: true });
    const cg = await import('../../src/lib/command-gen.mjs');
    generateEntry = cg.generateEntry;
    generatePhaseEntry = cg.generatePhaseEntry;
    registerAllCommands = cg.registerAllCommands;
  });

  afterEach(() => {
    rmSync(TEST_DIR, { recursive: true, force: true });
  });

  describe('generateEntry()', () => {
    it('生成正确格式的命令条目', () => {
      const outputFile = join(TEST_DIR, 'flow-kit:test.md');
      generateEntry('test', '测试命令', 'flow-kit/commands/test.md', outputFile);
      expect(existsSync(outputFile)).toBe(true);
      const content = readFileSync(outputFile, 'utf8');
      expect(content).toContain('description:');
      expect(content).toContain('category: dev');
      expect(content).toContain('reference:');
      expect(content).toContain('/flow-kit:test:');
    });

    it('outputFile 不存在时自动创建', () => {
      const outputFile = join(TEST_DIR, 'new-dir', 'flow-kit:new.md');
      generateEntry('new', '新命令', 'ref.md', outputFile);
      expect(existsSync(outputFile)).toBe(true);
    });
  });

  describe('generatePhaseEntry()', () => {
    it('生成阶段命令条目', () => {
      const outputFile = join(TEST_DIR, 'flow-kit:phase-1.md');
      generatePhaseEntry('phase-1', '需求澄清', '1-requirement', outputFile);
      expect(existsSync(outputFile)).toBe(true);
      const content = readFileSync(outputFile, 'utf8');
      expect(content).toContain('phase-1');
      expect(content).toContain('需求澄清');
    });
  });

  describe('registerAllCommands()', () => {
    it('生成所有核心命令', () => {
      const result = registerAllCommands();
      expect(result).toHaveProperty('total');
      expect(result).toHaveProperty('commands');
    });
  });
});