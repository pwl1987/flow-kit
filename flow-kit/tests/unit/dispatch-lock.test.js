import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { execSync } from 'child_process';
import { mkdirSync, rmSync, existsSync, writeFileSync, readFileSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

const LIB_DIR = join(process.cwd(), 'lib');
const SCRIPTS_DIR = join(process.cwd(), 'scripts');

describe('dispatch-lock.sh — acquire_lock/release_lock/is_lock_stale', () => {
  const tmpDir = join(tmpdir(), `lock-test-${Date.now()}`);
  const lockDir = join(tmpDir, 'locks');

  beforeEach(() => {
    mkdirSync(lockDir, { recursive: true });
  });

  afterEach(() => {
    rmSync(tmpDir, { recursive: true, force: true });
  });

  function runShell(body) {
    const scriptFile = join(tmpDir, `test-${Date.now()}-${Math.random().toString(36).slice(2)}.sh`);
    const script = `#!/bin/bash
set -uo pipefail
LOCK_DIR="${lockDir}"
source "${LIB_DIR}/error-handler.sh"
source "${SCRIPTS_DIR}/dispatch-lock.sh"
set +e
${body}`;
    writeFileSync(scriptFile, script);
    try {
      const stdout = execSync(`bash ${scriptFile} 2>&1`, { encoding: 'utf8', timeout: 5000 });
      return { stdout, exitCode: 0 };
    } catch (e) {
      return { stdout: (e.stdout || '') + (e.stderr || ''), exitCode: e.status || 1 };
    }
  }

  it('acquire_lock 创建含 PID 的锁文件', () => {
    const result = runShell('acquire_lock "test-resource"\necho "exit:$?"');
    expect(result.exitCode).toBe(0);
    // 锁文件应存在
    const lockFile = join(lockDir, 'test-resource.lock');
    expect(existsSync(lockFile)).toBe(true);
    const content = readFileSync(lockFile, 'utf8');
    expect(content).toMatch(/PID:\d+/);
    expect(content).toMatch(/TIMESTAMP:\d+/);
  });

  it('acquire_lock 同资源二次获取失败', () => {
    const result = runShell('acquire_lock "dup-resource" || true\nif acquire_lock "dup-resource" 2>/dev/null; then echo "second:0"; else echo "second:1"; fi');
    expect(result.stdout).toContain('second:1');
  });

  it('release_lock 删除锁文件', () => {
    const lockFile = join(lockDir, 'release-test.lock');
    const result = runShell('acquire_lock "release-test"\nrelease_lock "release-test"\necho "done"');
    expect(result.exitCode).toBe(0);
    expect(existsSync(lockFile)).toBe(false);
  });

  it('is_lock_stale 超时后返回 true', () => {
    const lockFile = join(lockDir, 'stale-test.lock');
    // 写入一个过期锁文件（timestamp 设为 400 秒前）
    const oldTs = Math.floor(Date.now() / 1000) - 400;
    const pid = process.pid;
    writeFileSync(lockFile, `PID:${pid}\nTIMESTAMP:${oldTs}\n`);
    const result = runShell('is_lock_stale "stale-test" 300\necho "stale:$?"');
    expect(result.stdout).toContain('stale:0');
  });

  it('is_lock_stale 未超时返回 false', () => {
    const lockFile = join(lockDir, 'fresh-test.lock');
    const ts = Math.floor(Date.now() / 1000);
    // 用当前 shell 的 PID（存活进程），时间戳为当前
    const result = runShell(`echo "PID:$$\nTIMESTAMP:${ts}" > "${lockFile}"\nis_lock_stale "fresh-test" 300\necho "stale:$?"`);
    expect(result.stdout).toContain('stale:1');
  });

  it('进程已死但锁文件残留时 acquire_lock 可获取', () => {
    const lockFile = join(lockDir, 'dead-proc.lock');
    // 写入一个 PID 不存在的过期锁
    const oldTs = Math.floor(Date.now() / 1000) - 400;
    writeFileSync(lockFile, `PID:99999999\nTIMESTAMP:${oldTs}\n`);
    const result = runShell('acquire_lock "dead-proc"\necho "acquired:$?"');
    expect(result.stdout).toContain('acquired:0');
  });

  it('acquire_lock 超时等待后自动清理过期锁', () => {
    const lockFile = join(lockDir, 'timeout-test.lock');
    const oldTs = Math.floor(Date.now() / 1000) - 400;
    writeFileSync(lockFile, `PID:99999999\nTIMESTAMP:${oldTs}\n`);
    const result = runShell('LOCK_TIMEOUT=1 acquire_lock "timeout-test" 300\necho "result:$?"');
    expect(result.stdout).toContain('result:0');
  });
});
