// cleanup.mjs — 临时文件统一管理
// v3.8.0 迁移自 lib/cleanup.sh

import { rmSync } from 'fs';

const _cleanupFiles = new Set();
const _cleanupDirs = new Set();
let _cleanupTrapSet = false;

export function registerCleanup(file) {
  _cleanupFiles.add(file);
  if (!_cleanupTrapSet) {
    setupCleanupTrap();
  }
}

export function registerCleanupDir(dir) {
  _cleanupDirs.add(dir);
  if (!_cleanupTrapSet) {
    setupCleanupTrap();
  }
}

function setupCleanupTrap() {
  if (!_cleanupTrapSet) {
    _cleanupTrapSet = true;
    process.on('exit', () => doCleanup());
  }
}

export function doCleanup() {
  for (const f of _cleanupFiles) {
    try {
      rmSync(f, { force: true });
    } catch {
      // Ignore
    }
  }
  _cleanupFiles.clear();

  for (const d of _cleanupDirs) {
    try {
      rmSync(d, { recursive: true, force: true });
    } catch {
      // Ignore
    }
  }
  _cleanupDirs.clear();
}

export function withCleanup(fn) {
  if (!_cleanupTrapSet) {
    _cleanupTrapSet = true;
    process.on('exit', () => doCleanup());
  }

  try {
    const result = fn();
    if (result && typeof result.then === 'function') {
      return result.finally(() => doCleanup());
    }
    doCleanup();
    return result;
  } catch (e) {
    doCleanup();
    throw e;
  }
}

// For testing - expose internal state
export function _resetCleanup() {
  _cleanupFiles.clear();
  _cleanupDirs.clear();
  _cleanupTrapSet = false;
}