import { describe, it, expect } from 'vitest';

let parseArgs, parseManifest, parseSubtask;

describe('3.4 dispatch-parse 模块', () => {
  beforeEach(async () => {
    const dp = await import('../../src/lib/dispatch-parse.mjs');
    parseArgs = dp.parseArgs;
    parseManifest = dp.parseManifest;
    parseSubtask = dp.parseSubtask;
  });

  describe('parseArgs()', () => {
    it('解析任务描述和并行数', () => {
      const result = parseArgs('3', '实现用户认证');
      expect(result.parallel_n).toBe(3);
      expect(result.task_desc).toBe('实现用户认证');
    });

    it('默认并行数为 3', () => {
      const result = parseArgs('实现用户认证');
      expect(result.parallel_n).toBe(3);
    });

    it('解析 --execute 模式', () => {
      const result = parseArgs('--execute', '3', '任务');
      expect(result.execute_mode).toBe(true);
    });

    it('解析 --wait 模式', () => {
      const result = parseArgs('--wait');
      expect(result.wait_mode).toBe(true);
      expect(result.aggregate_mode).toBe(false);
    });

    it('解析 --aggregate 模式', () => {
      const result = parseArgs('--aggregate');
      expect(result.aggregate_mode).toBe(true);
    });

    it('解析 --timeout', () => {
      const result = parseArgs('--wait', '--timeout', '600');
      expect(result.timeout).toBe(600);
    });

    it('缺少任务描述时返回错误', () => {
      expect(() => parseArgs()).toThrow();
    });
  });

  describe('parseManifest()', () => {
    it('解析有效 JSON manifest', () => {
      const data = {
        task_id: 'task-1',
        task_desc: '测试任务',
        parallel_n: 3,
        agents: [{ id: 'agent-1' }, { id: 'agent-2' }]
      };
      const result = parseManifest(data);
      expect(result.task_id).toBe('task-1');
      expect(result.agents).toHaveLength(2);
    });

    it('无效 JSON 抛出错误', () => {
      expect(() => parseManifest('not json')).toThrow();
    });

    it('缺少必要字段时抛出错误', () => {
      expect(() => parseManifest({})).toThrow();
    });
  });

  describe('parseSubtask()', () => {
    it('解析子任务定义', () => {
      const data = { id: 'agent-1', command: 'test', args: ['arg1'] };
      const result = parseSubtask(data);
      expect(result.id).toBe('agent-1');
      expect(result.command).toBe('test');
    });

    it('缺少 id 时自动生成', () => {
      const data = { command: 'test' };
      const result = parseSubtask(data);
      expect(result.id).toMatch(/^agent-\d+$/);
    });

    it('空 args 默认为空数组', () => {
      const data = { id: 'agent-1', command: 'test' };
      const result = parseSubtask(data);
      expect(result.args).toEqual([]);
    });
  });
});