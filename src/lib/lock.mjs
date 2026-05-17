// lock.mjs — 锁管理模块
// v3.8.0 迁移自 scripts/dispatch-lock.sh

import { mkdirSync, rmSync, writeFileSync, existsSync, readFileSync } from 'fs';
import { join } from 'path';

const LOCK_TIMEOUT = 300;

function getLockDir() {
  return process.env.LOCK_DIR || '/tmp/flow-kit/locks';
}

function getTmpDir() {
  return process.env.TMP_DIR || '/tmp';
}

export function acquireLock(resource, timeout = LOCK_TIMEOUT) {
  const lockDir = getLockDir();
  const lockFile = join(lockDir, `${resource}.lock`);

  mkdirSync(lockDir, { recursive: true });

  // 检查现有锁是否过期
  if (existsSync(lockFile)) {
    if (isLockStale(resource, timeout)) {
      rmSync(lockFile, { force: true });
    } else {
      return false;
    }
  }

  // 原子写入锁文件
  const ts = Math.floor(Date.now() / 1000);
  writeFileSync(lockFile, `PID:${process.pid}\nTIMESTAMP:${ts}\n`);
  return true;
}

export function releaseLock(resource) {
  const lockFile = join(getLockDir(), `${resource}.lock`);
  rmSync(lockFile, { force: true });
}

export function isLockStale(resource, timeout = LOCK_TIMEOUT) {
  const lockFile = join(getLockDir(), `${resource}.lock`);

  if (!existsSync(lockFile)) {
    return false;
  }

  try {
    const content = readFileSync(lockFile, 'utf8');
    const pidMatch = content.match(/^PID:(\d+)/m);
    const tsMatch = content.match(/^TIMESTAMP:(\d+)/m);

    const lockPid = pidMatch ? pidMatch[1] : null;
    const lockTs = tsMatch ? parseInt(tsMatch[1]) : null;

    // 进程已死 → 过期
    if (lockPid) {
      try {
        process.kill(lockPid, 0);
      } catch {
        return true; // 进程不存在
      }
    }

    // 时间戳超时 → 过期
    if (lockTs) {
      const now = Math.floor(Date.now() / 1000);
      if (now - lockTs > timeout) {
        return true;
      }
    }

    return false;
  } catch {
    return true;
  }
}

let slotCounter = 0;

export function acquireSlot(maxConc = 3) {
  const tmpDir = getTmpDir();

  for (let i = 0; i < maxConc; i++) {
    const slotDir = join(tmpDir, `slot-${i}.lock`);
    try {
      mkdirSync(slotDir, { recursive: true });
      writeFileSync(join(tmpDir, `slot-${process.pid}.id`), `${i}`);
      slotCounter++;
      return i;
    } catch {
      // Slot occupied, try next
    }
  }
  return -1;
}

export function releaseSlot() {
  const tmpDir = getTmpDir();
  const idFile = join(tmpDir, `slot-${process.pid}.id`);

  try {
    if (existsSync(idFile)) {
      const slotNum = readFileSync(idFile, 'utf8').trim();
      const slotDir = join(tmpDir, `slot-${slotNum}.lock`);
      rmSync(slotDir, { recursive: true, force: true });
      rmSync(idFile, { force: true });
      slotCounter--;
    }
  } catch (e) {
    // Ignore cleanup errors
  }
}