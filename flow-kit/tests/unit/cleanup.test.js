import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { execSync } from 'child_process';
import { mkdirSync, rmSync, existsSync, writeFileSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

const LIB_DIR = join(process.cwd(), 'lib');

describe('cleanup.sh', () => {
  const tmpDir = join(tmpdir(), `cleanup-test-${Date.now()}`);

  beforeEach(() => {
    mkdirSync(tmpDir, { recursive: true });
  });

  afterEach(() => {
    rmSync(tmpDir, { recursive: true, force: true });
  });

  function runShell(body) {
    const scriptFile = join(tmpDir, `test-${Date.now()}-${Math.random().toString(36).slice(2)}.sh`);
    const script = `#!/bin/bash\nset -uo pipefail\nsource "${LIB_DIR}/error-handler.sh"\nsource "${LIB_DIR}/cleanup.sh"\n${body}`;
    writeFileSync(scriptFile, script);
    try {
      const stdout = execSync(`bash ${scriptFile} 2>&1`, { encoding: 'utf8', timeout: 5000 });
      return { stdout, exitCode: 0 };
    } catch (e) {
      return { stdout: (e.stdout || '') + (e.stderr || ''), exitCode: e.status || 1 };
    }
  }

  it('register_cleanup 注册的文件在 EXIT 时被删除', () => {
    const tmpFile = join(tmpDir, 'test-cleanup-file');
    writeFileSync(tmpFile, 'test');
    expect(existsSync(tmpFile)).toBe(true);
    runShell(`register_cleanup "${tmpFile}"\nexit 0`);
    expect(existsSync(tmpFile)).toBe(false);
  });

  it('register_cleanup_dir 注册的目录在 EXIT 时被删除', () => {
    const tmpSub = join(tmpDir, 'test-cleanup-dir');
    mkdirSync(tmpSub);
    expect(existsSync(tmpSub)).toBe(true);
    runShell(`register_cleanup_dir "${tmpSub}"\nexit 0`);
    expect(existsSync(tmpSub)).toBe(false);
  });

  it('with_cleanup 自动注册 EXIT trap', () => {
    const tmpFile = join(tmpDir, 'wc-file');
    writeFileSync(tmpFile, 'temp');
    runShell(`with_cleanup\ntouch "${tmpFile}.keep"\nregister_cleanup "${tmpFile}"\nexit 0`);
    expect(existsSync(tmpFile)).toBe(false);
    expect(existsSync(`${tmpFile}.keep`)).toBe(true);
  });

  it('异常退出时临时文件仍被清理', () => {
    const tmpFile = join(tmpDir, 'crash-file');
    writeFileSync(tmpFile, 'temp');
    const result = runShell(`with_cleanup\nregister_cleanup "${tmpFile}"\nexit 1`);
    expect(existsSync(tmpFile)).toBe(false);
    expect(result.exitCode).toBe(1);
  });

  it('do_cleanup 可手动调用', () => {
    const tmpFile = join(tmpDir, 'manual-file');
    writeFileSync(tmpFile, 'temp');
    runShell(`register_cleanup "${tmpFile}"\ndo_cleanup`);
    expect(existsSync(tmpFile)).toBe(false);
  });

  it('多次注册不会重复删除报错', () => {
    const tmpFile = join(tmpDir, 'multi-file');
    writeFileSync(tmpFile, 'temp');
    const result = runShell(`register_cleanup "${tmpFile}"\nregister_cleanup "${tmpFile}"\ndo_cleanup\nexit 0`);
    expect(result.exitCode).toBe(0);
    expect(existsSync(tmpFile)).toBe(false);
  });
});
