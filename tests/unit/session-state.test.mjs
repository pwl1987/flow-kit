import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { existsSync, readFileSync, rmSync, mkdirSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let sessionInit, sessionSet, sessionGet, sessionTaskSet, sessionNext, sessionBlock;
let sessionResumePrompt, sessionHistoryAdd, sessionDecisionAdd;

const TEST_SESSION_FILE = join(tmpdir(), 'flow-kit-test-session-' + Date.now() + '.json');

describe('2.1 session-state 模块', () => {
  beforeEach(async () => {
    process.env.SESSION_STATE_FILE = TEST_SESSION_FILE;
    mkdirSync(tmpdir(), { recursive: true });
    const ss = await import('../../src/lib/session-state.mjs');
    sessionInit = ss.sessionInit;
    sessionSet = ss.sessionSet;
    sessionGet = ss.sessionGet;
    sessionTaskSet = ss.sessionTaskSet;
    sessionNext = ss.sessionNext;
    sessionBlock = ss.sessionBlock;
    sessionResumePrompt = ss.sessionResumePrompt;
    sessionHistoryAdd = ss.sessionHistoryAdd;
    sessionDecisionAdd = ss.sessionDecisionAdd;
  });

  afterEach(() => {
    rmSync(TEST_SESSION_FILE, { force: true });
    delete process.env.SESSION_STATE_FILE;
  });

  describe('sessionInit()', () => {
    it('创建 session-state.json', () => {
      sessionInit('test-change', 'green');
      expect(existsSync(TEST_SESSION_FILE)).toBe(true);
    });

    it('包含 change 和 ptype 字段', () => {
      sessionInit('test-change', 'green');
      const data = JSON.parse(readFileSync(TEST_SESSION_FILE, 'utf8'));
      expect(data.change).toBe('test-change');
      expect(data.ptype).toBe('green');
    });
  });

  describe('sessionSet/sessionGet', () => {
    it('设置并读取值', () => {
      sessionInit('test', 'green');
      sessionSet('testKey', 'testValue');
      expect(sessionGet('testKey')).toBe('testValue');
    });

    it('读取不存在的键返回 undefined', () => {
      sessionInit('test', 'green');
      expect(sessionGet('nonexistent')).toBeUndefined();
    });
  });

  describe('sessionNext/sessionBlock', () => {
    it('设置 next', () => {
      sessionInit('test', 'green');
      sessionNext('phase-1');
      expect(sessionGet('next')).toBe('phase-1');
    });

    it('设置 block', () => {
      sessionInit('test', 'green');
      sessionBlock('waiting-review');
      expect(sessionGet('blockers')).toBe('waiting-review');
    });
  });

  describe('sessionResumePrompt()', () => {
    it('返回非空字符串', () => {
      sessionInit('test', 'green');
      const prompt = sessionResumePrompt();
      expect(typeof prompt).toBe('string');
      expect(prompt.length).toBeGreaterThan(0);
    });
  });

  describe('sessionHistoryAdd()', () => {
    it('追加历史记录', () => {
      sessionInit('test', 'green');
      sessionHistoryAdd('test action');
      const data = JSON.parse(readFileSync(TEST_SESSION_FILE, 'utf8'));
      expect(data.history).toContain('test action');
    });
  });

  describe('sessionDecisionAdd()', () => {
    it('追加决策记录', () => {
      sessionInit('test', 'green');
      sessionDecisionAdd('type1', { key: 'value' });
      const data = JSON.parse(readFileSync(TEST_SESSION_FILE, 'utf8'));
      expect(data.decisions).toBeDefined();
    });
  });
});
