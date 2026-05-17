import { describe, it, expect } from 'vitest';

let estimateTokens, checkBudget, getBudgetStatus, triggerCompress;

describe('2.6 context-budget 模块', () => {
  beforeEach(async () => {
    const cb = await import('../../src/lib/context-budget.mjs');
    estimateTokens = cb.estimateTokens;
    checkBudget = cb.checkBudget;
    getBudgetStatus = cb.getBudgetStatus;
    triggerCompress = cb.triggerCompress;
  });

  describe('estimateTokens()', () => {
    it('纯英文文本估算', () => {
      const tokens = estimateTokens('hello world');
      expect(tokens).toBeGreaterThan(0);
      expect(Number.isInteger(tokens)).toBe(true);
    });

    it('纯中文文本估算', () => {
      const tokens = estimateTokens('你好世界');
      expect(tokens).toBeGreaterThan(0);
      expect(Number.isInteger(tokens)).toBe(true);
    });

    it('中英混合文本估算', () => {
      const tokens = estimateTokens('hello 你好 world 世界');
      expect(tokens).toBeGreaterThan(0);
    });

    it('空字符串返回 0', () => {
      const tokens = estimateTokens('');
      expect(tokens).toBe(0);
    });
  });

  describe('checkBudget()', () => {
    it('正常使用返回 ok', () => {
      const status = checkBudget(50, 100);
      expect(status.status).toBe('ok');
      expect(status.percent).toBe(50);
    });

    it('超过 80% 返回 warning', () => {
      const status = checkBudget(85, 100);
      expect(status.status).toBe('warning');
    });

    it('超过 95% 返回 critical', () => {
      const status = checkBudget(96, 100);
      expect(status.status).toBe('critical');
    });
  });

  describe('triggerCompress()', () => {
    it('生成压缩指令', () => {
      const result = triggerCompress('budget exceeded');
      expect(result).toBeDefined();
      expect(result.reason).toBe('budget exceeded');
    });
  });
});
