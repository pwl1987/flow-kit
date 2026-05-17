import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { existsSync, writeFileSync, rmSync, mkdirSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let doStatus, doNext, recommendNextStep, validateCurrentPhase, createPlan;

const TEST_DIR = tmpdir() + '/ap-test-' + Date.now();
mkdirSync(TEST_DIR, { recursive: true });
const AUTO_PLAN_FILE = join(TEST_DIR, '.flow-kit/auto-plan.json');
const SESSION_STATE_FILE = join(TEST_DIR, 'session-state.json');

describe('3.2 auto-pilot 模块', () => {
  beforeEach(async () => {
    process.env.PROJECT_DIR = TEST_DIR;
    process.env.PATHS_PROJECT_DIR = TEST_DIR;
    process.env.SESSION_STATE_FILE = SESSION_STATE_FILE;
    const ap = await import('../../src/lib/auto-pilot.mjs');
    doStatus = ap.doStatus;
    doNext = ap.doNext;
    recommendNextStep = ap.recommendNextStep;
    validateCurrentPhase = ap.validateCurrentPhase;
    createPlan = ap.createPlan;
  });

  afterEach(() => {
    rmSync(TEST_DIR, { recursive: true, force: true });
  });

  describe('doStatus()', () => {
    it('返回当前状态', () => {
      const status = doStatus();
      expect(status).toBeDefined();
      expect(status).toHaveProperty('phase');
    });

    it('无 session 时返回初始状态', () => {
      rmSync(SESSION_STATE_FILE, { force: true });
      const status = doStatus();
      expect(status.phase).toBe(0);
    });
  });

  describe('recommendNextStep()', () => {
    it('根据当前 phase 推荐下一步', () => {
      const rec = recommendNextStep();
      expect(rec).toBeDefined();
      expect(typeof rec).toBe('string');
    });
  });

  describe('validateCurrentPhase()', () => {
    it('phase 有效时返回 true', () => {
      const result = validateCurrentPhase();
      expect(result).toBe(true);
    });
  });

  describe('createPlan()', () => {
    it('生成 auto-plan.json 结构', () => {
      createPlan();
      expect(existsSync(AUTO_PLAN_FILE)).toBe(true);
      const plan = JSON.parse(require('fs').readFileSync(AUTO_PLAN_FILE, 'utf8'));
      expect(plan).toHaveProperty('current_phase');
      expect(plan).toHaveProperty('task_depth');
    });
  });

  describe('doNext()', () => {
    it('执行下一步并更新 session', () => {
      createPlan();
      const result = doNext();
      expect(result).toBeDefined();
      expect(result).toHaveProperty('next_phase');
    });
  });
});