import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { execSync } from 'child_process';
import { mkdirSync, rmSync, writeFileSync, existsSync, readFileSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

const SCRIPTS_DIR = join(process.cwd(), 'scripts');
const SCRIPT = join(SCRIPTS_DIR, 'metrics.sh');

describe('metrics.sh CLI', () => {
  const tmpDir = join(tmpdir(), `metrics-cmd-${Date.now()}`);
  const logsDir = join(tmpDir, 'logs');
  const metricsFile = join(logsDir, 'metrics.jsonl');

  beforeEach(() => {
    mkdirSync(logsDir, { recursive: true });
  });

  afterEach(() => {
    rmSync(tmpDir, { recursive: true, force: true });
  });

  function runCLI(args = '') {
    try {
      const stdout = execSync(
        `METRICS_LOG_DIR="${logsDir}" METRICS_LOG_FILE="${metricsFile}" bash ${SCRIPT} ${args} 2>&1`,
        { encoding: 'utf8', timeout: 5000 }
      );
      return { stdout, exitCode: 0 };
    } catch (e) {
      return { stdout: (e.stdout || '') + (e.stderr || ''), exitCode: e.status || 1 };
    }
  }

  it('--summary 输出聚合摘要', () => {
    writeFileSync(metricsFile,
      '{"event_type":"phase_complete","timestamp":"2026-01-01T00:00:00Z","detail":"ok"}\n' +
      '{"event_type":"error","timestamp":"2026-01-01T00:01:00Z","detail":"fail"}\n'
    );
    const result = runCLI('--summary');
    expect(result.stdout).toContain('phase_complete: 1');
    expect(result.stdout).toContain('error: 1');
    expect(result.stdout).toContain('total: 2');
  });

  it('--clear 清空日志文件', () => {
    writeFileSync(metricsFile, '{"event_type":"test"}\n');
    expect(existsSync(metricsFile)).toBe(true);
    const result = runCLI('--clear');
    expect(result.stdout).toContain('已清空');
    const content = readFileSync(metricsFile, 'utf8');
    expect(content.trim()).toBe('');
  });

  it('无数据时不报错', () => {
    rmSync(metricsFile, { force: true });
    const result = runCLI('--summary');
    expect(result.exitCode).toBe(0);
    expect(result.stdout).toContain('total: 0');
  });
});
