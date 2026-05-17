// test-utils.mjs — 测试辅助工具
// v3.8.0

import { rmSync, mkdirSync, writeFileSync, existsSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

export function createTestDir(prefix = 'fk-test') {
  const dir = join(tmpdir(), `${prefix}-${Date.now()}`);
  mkdirSync(dir, { recursive: true });
  return dir;
}

export function cleanupTestDir(dir) {
  rmSync(dir, { recursive: true, force: true });
}

export function createMockSession(dir, data = {}) {
  const sessionFile = join(dir, 'session-state.json');
  const defaultData = {
    v: 2,
    change: 'test-change',
    phase: 0,
    status: 'init',
    ptype: 'green',
    ts: new Date().toISOString()
  };
  writeFileSync(sessionFile, JSON.stringify({ ...defaultData, ...data }));
  return sessionFile;
}

export function createMockPhaseFile(dir, phase, artifacts = []) {
  const phaseFile = join(dir, `phase-${phase}.md`);
  const fm = {
    phase,
    expected_artifacts: artifacts
  };
  const content = `---\n${JSON.stringify(fm, null, 2).replace(/"/g, "'")}\n---\n# Phase ${phase}`;
  writeFileSync(phaseFile, content);
  return phaseFile;
}

export function waitFor(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}