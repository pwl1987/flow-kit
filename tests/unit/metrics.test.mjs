import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { existsSync, readFileSync, rmSync, appendFileSync, mkdirSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let logEvent, query, summary, clear;

const TEST_METRICS_FILE = join(tmpdir(), 'flow-kit-metrics-' + Date.now() + '.jsonl');

describe('2.2 metrics 模块', () => {
  beforeEach(async () => {
    process.env.METRICS_LOG_FILE = TEST_METRICS_FILE;
    mkdirSync(tmpdir(), { recursive: true });
    const metrics = await import('../../src/lib/metrics.mjs');
    logEvent = metrics.logEvent;
    query = metrics.query;
    summary = metrics.summary;
    clear = metrics.clear;
  });

  afterEach(() => {
    rmSync(TEST_METRICS_FILE, { force: true });
    delete process.env.METRICS_LOG_FILE;
  });

  describe('logEvent()', () => {
    it('写入单条事件', () => {
      logEvent('test-event', { key: 'value' });
      expect(existsSync(TEST_METRICS_FILE)).toBe(true);
      const content = readFileSync(TEST_METRICS_FILE, 'utf8');
      expect(content).toContain('test-event');
    });

    it('写入多条事件', () => {
      logEvent('event1', 'detail1');
      logEvent('event2', 'detail2');
      const lines = readFileSync(TEST_METRICS_FILE, 'utf8').trim().split('\n');
      expect(lines.length).toBeGreaterThanOrEqual(2);
    });
  });

  describe('query()', () => {
    it('按事件类型过滤', () => {
      logEvent('unique-event-type', 'detail');
      const results = query('unique-event-type');
      expect(results.length).toBeGreaterThan(0);
      expect(results[0].event_type).toBe('unique-event-type');
    });

    it('空结果返回空数组', () => {
      const results = query('nonexistent-type');
      expect(Array.isArray(results)).toBe(true);
    });
  });

  describe('summary()', () => {
    it('返回事件计数', () => {
      logEvent('type-a', 'd1');
      logEvent('type-a', 'd2');
      logEvent('type-b', 'd3');
      const sum = summary();
      expect(sum.total).toBeGreaterThanOrEqual(3);
    });
  });

  describe('clear()', () => {
    it('清空日志文件', () => {
      logEvent('test', 'data');
      clear();
      const content = readFileSync(TEST_METRICS_FILE, 'utf8').trim();
      expect(content).toBe('');
    });
  });
});
