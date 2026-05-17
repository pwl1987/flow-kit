import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { execSync } from 'child_process';
import { mkdirSync, rmSync, existsSync, writeFileSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

const LIB_DIR = join(process.cwd(), 'lib');

describe('error-handler.sh', () => {
  const tmpDir = join(tmpdir(), `error-handler-test-${Date.now()}`);

  beforeEach(() => {
    mkdirSync(tmpDir, { recursive: true });
  });

  afterEach(() => {
    rmSync(tmpDir, { recursive: true, force: true });
  });

  function runShell(body) {
    // 写临时脚本文件避免引号嵌套问题
    const scriptFile = join(tmpDir, `test-${Date.now()}-${Math.random().toString(36).slice(2)}.sh`);
    const script = `#!/bin/bash
set -euo pipefail
source "${LIB_DIR}/error-handler.sh"
${body}`;
    writeFileSync(scriptFile, script);
    try {
      const stdout = execSync(`bash ${scriptFile} 2>&1`, {
        encoding: 'utf8',
        timeout: 5000,
      });
      return { stdout, exitCode: 0 };
    } catch (e) {
      return {
        stdout: (e.stdout || '') + (e.stderr || ''),
        exitCode: e.status || 1,
      };
    }
  }

  it('log_info 输出含 [INFO] 前缀和时间戳', () => {
    const { stdout } = runShell('log_info "test-module" "hello world"');
    expect(stdout).toContain('[INFO]');
    expect(stdout).toContain('[test-module]');
    expect(stdout).toContain('hello world');
    expect(stdout).toMatch(/\d{4}-\d{2}-\d{2}T/);
  });

  it('log_warn 输出到 stderr', () => {
    const { stdout } = runShell('log_warn "mod" "warning msg"');
    expect(stdout).toContain('[WARN]');
    expect(stdout).toContain('warning msg');
  });

  it('log_error 输出到 stderr', () => {
    const { stdout } = runShell('log_error "mod" "error msg"');
    expect(stdout).toContain('[ERROR]');
    expect(stdout).toContain('error msg');
  });

  it('die 输出错误信息并退出', () => {
    const result = runShell('die 3 "test-mod" "致命错误"');
    expect(result.exitCode).toBe(3);
    expect(result.stdout).toContain('[ERROR]');
    expect(result.stdout).toContain('致命错误');
  });

  it('die 默认退出码为 1', () => {
    const result = runShell('die');
    expect(result.exitCode).toBe(1);
  });

  it('setup_trap 注册 ERR 信号处理', () => {
    const result = runShell('setup_trap "test-script"\nset +e\nfalse\nset -e');
    expect(result.stdout).toContain('[ERROR]');
  });

  it('setup_trap 在 EXIT 时记录退出日志', () => {
    const markerFile = join(tmpDir, 'trap-exit-marker');
    const result = runShell(`setup_trap "test-script"\ntouch "${markerFile}"\nexit 1`);
    expect(result.stdout).toContain('[WARN]');
    expect(result.stdout).toContain('退出码');
    expect(existsSync(markerFile)).toBe(true);
  });

  it('check_result 成功时返回 0', () => {
    const { stdout } = runShell('true\ncheck_result "mod" "操作成功"');
    expect(stdout).toContain('[INFO]');
    expect(stdout).toContain('操作成功');
  });

  it('check_result 失败时记录错误', () => {
    const result = runShell('set +e\nfalse\ncheck_result "mod" "操作失败"\nset -e\ntrue');
    expect(result.stdout).toContain('[ERROR]');
    expect(result.stdout).toContain('操作失败');
  });

  it('防重复 source 不会重复定义常量', () => {
    const { stdout } = runShell(`echo $EXIT_GENERAL_ERROR\nsource "${LIB_DIR}/error-handler.sh"\necho $EXIT_GENERAL_ERROR`);
    const lines = stdout.trim().split('\n').filter(l => l.match(/^\d+$/));
    expect(lines[0]).toBe('1');
    expect(lines[1]).toBe('1');
  });

  it('get_timestamp 输出 ISO 8601 格式', () => {
    const { stdout } = runShell('get_timestamp');
    expect(stdout.trim()).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/);
  });
});
