import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { existsSync, mkdirSync, rmSync, writeFileSync, readdirSync } from 'fs';
import { resolve, join } from 'path';
import { tmpdir } from 'os';

const PROJECT_ROOT = '/data/Code/pwl/code/plugins';

let getPaths, initRuntimeDirs, rotateLogs;

describe('1.1 paths 模块', () => {
  beforeEach(async () => {
    process.env.CLAUDE_PROJECT_DIR = PROJECT_ROOT;
    process.env.CLAUDE_PLUGIN_ROOT = PROJECT_ROOT;
    process.env.CLAUDE_PLUGIN_DATA = join(tmpdir(), 'flow-kit-test-' + Date.now());
    
    const paths = await import('../../src/lib/paths.mjs');
    getPaths = paths.getPaths;
    initRuntimeDirs = paths.initRuntimeDirs;
    rotateLogs = paths.rotateLogs;
  });

  afterEach(() => {
    delete process.env.CLAUDE_PROJECT_DIR;
    delete process.env.CLAUDE_PLUGIN_ROOT;
    delete process.env.CLAUDE_PLUGIN_DATA;
  });

  describe('getPaths()', () => {
    it('返回所有路径常量对象', () => {
      const paths = getPaths();
      expect(paths).toBeDefined();
      expect(typeof paths).toBe('object');
    });

    it('FLOW_KIT_DIR 不为空', () => {
      const paths = getPaths();
      expect(paths.FLOW_KIT_DIR).toBeDefined();
      expect(paths.FLOW_KIT_DIR.length).toBeGreaterThan(0);
    });

    it('PROJECT_DIR 等于 CLAUDE_PROJECT_DIR 环境变量', () => {
      const paths = getPaths();
      expect(paths.PROJECT_DIR).toBe(PROJECT_ROOT);
    });

    it('包含 SCRIPTS_DIR, LIB_DIR, HOOKS_DIR', () => {
      const paths = getPaths();
      expect(paths.SCRIPTS_DIR).toBeDefined();
      expect(paths.LIB_DIR).toBeDefined();
      expect(paths.HOOKS_DIR).toBeDefined();
    });

    it('包含运行时路径常量', () => {
      const paths = getPaths();
      expect(paths.TMP_DIR).toBeDefined();
      expect(paths.LOCK_DIR).toBeDefined();
      expect(paths.LOGS_DIR).toBeDefined();
      expect(paths.CONTEXT_DIR).toBeDefined();
      expect(paths.PLANNING_DIR).toBeDefined();
    });

    it('包含 SESSION_STATE_FILE', () => {
      const paths = getPaths();
      expect(paths.SESSION_STATE_FILE).toBeDefined();
      expect(paths.SESSION_STATE_FILE).toContain('.flow-kit');
      expect(paths.SESSION_STATE_FILE).toContain('session-state.json');
    });

    it('CLAUDE_PROJECT_DIR 未设置时使用 cwd 默认值', () => {
      delete process.env.CLAUDE_PROJECT_DIR;
      const paths = getPaths();
      expect(paths.PROJECT_DIR).toBeDefined();
    });
  });

  describe('initRuntimeDirs()', () => {
    it('创建所有运行时目录', () => {
      const paths = getPaths();
      const dataDir = process.env.CLAUDE_PLUGIN_DATA;
      mkdirSync(dataDir, { recursive: true });
      initRuntimeDirs();
      expect(existsSync(paths.TMP_DIR)).toBe(true);
      expect(existsSync(paths.LOCK_DIR)).toBe(true);
      expect(existsSync(paths.LOGS_DIR)).toBe(true);
      expect(existsSync(paths.CONTEXT_DIR)).toBe(true);
    });
  });

  describe('rotateLogs()', () => {
    it('保留最近 N 个日志文件', () => {
      const testLogDir = resolve(tmpdir(), 'flow-kit-rotate-test-' + Date.now());
      mkdirSync(testLogDir, { recursive: true });
      
      for (let i = 1; i <= 15; i++) {
        writeFileSync(resolve(testLogDir, `test.${i}.log`), 'content');
      }
      
      rotateLogs(testLogDir, { maxFiles: 5 });
      
      const remaining = readdirSync(testLogDir).filter(f => f.startsWith('test.') && f.endsWith('.log'));
      expect(remaining.length).toBeLessThanOrEqual(5);
      
      rmSync(testLogDir, { recursive: true, force: true });
    });

    it('目录不存在时不报错', () => {
      const fakeDir = resolve(tmpdir(), 'non-existent-' + Date.now());
      expect(() => rotateLogs(fakeDir, { maxFiles: 5 })).not.toThrow();
    });
  });
});
