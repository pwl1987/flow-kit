import { describe, it, expect, vi, beforeEach } from 'vitest';

let logInfo, logWarn, logError, die, safeExit, getTimestamp, aggregateErrors, ERROR_CODES;

const mockExit = vi.spyOn(process, 'exit').mockImplementation((() => {}));

describe('1.2 error-handler 模块', () => {
  beforeEach(async () => {
    vi.clearAllMocks();
    const eh = await import('../../src/lib/error-handler.mjs');
    logInfo = eh.logInfo;
    logWarn = eh.logWarn;
    logError = eh.logError;
    die = eh.die;
    safeExit = eh.safeExit;
    getTimestamp = eh.getTimestamp;
    aggregateErrors = eh.aggregateErrors;
    ERROR_CODES = eh.ERROR_CODES;
  });

  describe('ERROR_CODES', () => {
    it('EXIT_SUCCESS 为 0', () => expect(ERROR_CODES.EXIT_SUCCESS).toBe(0));
    it('EXIT_GENERAL_ERROR 为 1', () => expect(ERROR_CODES.EXIT_GENERAL_ERROR).toBe(1));
    it('EXIT_GUARD_BLOCK 为 2', () => expect(ERROR_CODES.EXIT_GUARD_BLOCK).toBe(2));
    it('EXIT_MISSING_DEPS 为 3', () => expect(ERROR_CODES.EXIT_MISSING_DEPS).toBe(3));
  });

  describe('getTimestamp()', () => {
    it('返回 ISO 格式时间戳', () => {
      const ts = getTimestamp();
      expect(ts).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/);
    });
  });

  describe('logInfo()', () => {
    it('调用 console.log', () => {
      const spy = vi.spyOn(console, 'log').mockImplementation(() => {});
      logInfo('mod', 'msg');
      expect(spy).toHaveBeenCalled();
      expect(spy.mock.calls[0][0]).toContain('[INFO]');
    });
  });

  describe('logWarn()', () => {
    it('调用 console.error', () => {
      const spy = vi.spyOn(console, 'error').mockImplementation(() => {});
      logWarn('mod', 'warn');
      expect(spy).toHaveBeenCalled();
      expect(spy.mock.calls[0][0]).toContain('[WARN]');
    });
  });

  describe('logError()', () => {
    it('调用 console.error', () => {
      const spy = vi.spyOn(console, 'error').mockImplementation(() => {});
      logError('mod', 'err');
      expect(spy).toHaveBeenCalled();
      expect(spy.mock.calls[0][0]).toContain('[ERROR]');
    });
  });

  describe('die()', () => {
    it('记录错误后调用 process.exit', () => {
      const spy = vi.spyOn(console, 'error').mockImplementation(() => {});
      die(1, 'mod', 'fatal');
      expect(spy).toHaveBeenCalled();
      expect(mockExit).toHaveBeenCalledWith(1);
    });
  });

  describe('safeExit()', () => {
    it('正常退出', () => {
      safeExit(0);
      expect(mockExit).toHaveBeenCalledWith(0);
    });
  });

  describe('aggregateErrors()', () => {
    it('汇总多个错误', () => {
      const result = aggregateErrors(['e1', 'e2', 'e3']);
      expect(result.total_errors).toBe(3);
      expect(result.errors).toEqual(['e1', 'e2', 'e3']);
    });

    it('空数组返回零错误', () => {
      const result = aggregateErrors([]);
      expect(result.total_errors).toBe(0);
      expect(result.errors).toEqual([]);
    });
  });
});
