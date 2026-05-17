import { describe, it, expect } from 'vitest';

let getEpochMs, dateToEpoch, getTimestamp;

describe('1.5 time-utils 模块', () => {
  beforeEach(async () => {
    const tu = await import('../../src/lib/time-utils.mjs');
    getEpochMs = tu.getEpochMs;
    dateToEpoch = tu.dateToEpoch;
    getTimestamp = tu.getTimestamp;
  });

  describe('getEpochMs()', () => {
    it('返回正整数', () => {
      const ms = getEpochMs();
      expect(Number.isInteger(ms)).toBe(true);
      expect(ms).toBeGreaterThan(0);
    });

    it('返回值在合理范围内', () => {
      const ms = getEpochMs();
      expect(ms).toBeGreaterThan(1700000000000);
    });
  });

  describe('dateToEpoch()', () => {
    it('转换 ISO 日期字符串', () => {
      const epoch = dateToEpoch('2024-01-01T00:00:00Z');
      expect(epoch).toBe(1704067200000);
    });

    it('转换 YYYY-MM-DD HH:mm:ss 格式', () => {
      const epoch = dateToEpoch('2024-01-01 12:00:00');
      expect(epoch).toBeGreaterThan(0);
    });

    it('无效日期返回 0', () => {
      const epoch = dateToEpoch('invalid');
      expect(epoch).toBe(0);
    });

    it('null 返回 0', () => {
      const epoch = dateToEpoch(null);
      expect(epoch).toBe(0);
    });
  });

  describe('getTimestamp()', () => {
    it('返回 ISO 格式时间戳', () => {
      const ts = getTimestamp();
      expect(ts).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/);
    });

    it('返回格式一致', () => {
      const ts1 = getTimestamp();
      const ts2 = getTimestamp();
      expect(ts1).toBe(ts2);
    });
  });
});
