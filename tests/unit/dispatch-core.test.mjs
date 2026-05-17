import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { existsSync, rmSync, mkdirSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let splitTask, executeSubagents, waitForSubagents, collectResults, cleanupChildren;

const TEST_DIR = join(tmpdir(), 'dc-test-' + Date.now());
mkdirSync(TEST_DIR, { recursive: true });
const TASK_DIR = join(TEST_DIR, 'tasks');

describe('3.3 dispatch-core 模块', () => {
  beforeEach(async () => {
    process.env.DISPATCH_TASK_DIR = TASK_DIR;
    mkdirSync(TASK_DIR, { recursive: true });
    const dc = await import('../../src/lib/dispatch-core.mjs');
    splitTask = dc.splitTask;
    executeSubagents = dc.executeSubagents;
    waitForSubagents = dc.waitForSubagents;
    collectResults = dc.collectResults;
    cleanupChildren = dc.cleanupChildren;
  });

  afterEach(() => {
    rmSync(TEST_DIR, { recursive: true, force: true });
  });

  describe('splitTask()', () => {
    it('将任务均匀拆分为 n 个子任务', () => {
      const result = splitTask('实现用户认证', 3);
      expect(result).toHaveLength(3);
      expect(result[0]).toHaveProperty('id');
      expect(result[0]).toHaveProperty('role');
      expect(result[0]).toHaveProperty('prompt_file');
    });

    it('n > 子任务项数时每个子任务一项', () => {
      const result = splitTask('单任务', 5);
      expect(result.length).toBeGreaterThanOrEqual(1);
    });

    it('空任务列表返回空数组', () => {
      const result = splitTask('', 3);
      expect(result).toEqual([]);
    });
  });

  describe('executeSubagents()', () => {
    it('执行子代理并返回结果', async () => {
      const subtasks = splitTask('测试任务', 2);
      const results = await executeSubagents(subtasks);
      expect(results).toBeDefined();
      expect(Array.isArray(results)).toBe(true);
      expect(results.length).toBe(2);
    }, { timeout: 10000 });
  });

  describe('waitForSubagents()', () => {
    it('等待指定时间后超时返回', async () => {
      const result = await waitForSubagents(500);
      expect(result).toBeDefined();
      expect(result).toHaveProperty('timed_out');
    }, { timeout: 5000 });
  });

  describe('collectResults()', () => {
    it('返回聚合结果结构', () => {
      const result = collectResults();
      expect(result).toHaveProperty('total');
      expect(result).toHaveProperty('successful');
      expect(result).toHaveProperty('failed');
    });
  });

  describe('cleanupChildren()', () => {
    it('清理无异常', () => {
      expect(() => cleanupChildren()).not.toThrow();
    });
  });
});