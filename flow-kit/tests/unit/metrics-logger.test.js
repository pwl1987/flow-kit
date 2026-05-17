import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { execSync } from 'child_process';
import { mkdirSync, rmSync, existsSync, writeFileSync, readFileSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

const LIB_DIR = join(process.cwd(), 'lib');

describe('metrics-logger.sh', () => {
  const tmpDir = join(tmpdir(), `metrics-test-${Date.now()}`);
  const logsDir = join(tmpDir, 'logs');
  const metricsFile = join(logsDir, 'metrics.jsonl');

  beforeEach(() => {
    mkdirSync(tmpDir, { recursive: true });
  });

  afterEach(() => {
    rmSync(tmpDir, { recursive: true, force: true });
  });

  function runShell(body) {
    const scriptFile = join(tmpDir, `test-${Date.now()}-${Math.random().toString(36).slice(2)}.sh`);
    const script = `#!/bin/bash
set -uo pipefail
METRICS_LOG_DIR="${logsDir}"
METRICS_LOG_FILE="${metricsFile}"
source "${LIB_DIR}/error-handler.sh"
source "${LIB_DIR}/metrics-logger.sh"
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

  function writeMetricsLine(line) {
    mkdirSync(logsDir, { recursive: true });
    writeFileSync(metricsFile, line + '\n', { flag: 'a' });
  }

  it('metrics_log_event 写入合法 JSONL 行', () => {
    runShell('metrics_log_event "phase_complete" "phase=3 duration=12s"');
    expect(existsSync(metricsFile)).toBe(true);
    const lines = readFileSync(metricsFile, 'utf8').trim().split('\n');
    expect(lines.length).toBe(1);
    const obj = JSON.parse(lines[0]);
    expect(obj.event_type).toBe('phase_complete');
    expect(obj.detail).toContain('phase=3');
  });

  it('metrics_log_event 含 timestamp 字段', () => {
    runShell('metrics_log_event "test" "hello"');
    const line = readFileSync(metricsFile, 'utf8').trim();
    const obj = JSON.parse(line);
    expect(obj.timestamp).toMatch(/^\d{4}-\d{2}-\d{2}T/);
  });

  it('日志目录不存在时自动创建', () => {
    rmSync(logsDir, { recursive: true, force: true });
    expect(existsSync(logsDir)).toBe(false);
    runShell('metrics_log_event "auto_create" "test"');
    expect(existsSync(logsDir)).toBe(true);
    expect(existsSync(metricsFile)).toBe(true);
  });

  it('metrics_summary 输出聚合结果', () => {
    writeMetricsLine(JSON.stringify({ event_type: 'phase_complete', timestamp: '2026-01-01T00:00:00Z', detail: 'phase=3' }));
    writeMetricsLine(JSON.stringify({ event_type: 'phase_complete', timestamp: '2026-01-01T00:01:00Z', detail: 'phase=4' }));
    writeMetricsLine(JSON.stringify({ event_type: 'error', timestamp: '2026-01-01T00:02:00Z', detail: 'test' }));
    const result = runShell('metrics_summary');
    expect(result.stdout).toContain('phase_complete: 2');
    expect(result.stdout).toContain('error: 1');
    expect(result.stdout).toContain('total: 3');
  });

  it('metrics_query 按类型过滤', () => {
    writeMetricsLine(JSON.stringify({ event_type: 'alpha', timestamp: '2026-01-01T00:00:00Z', detail: 'a1' }));
    writeMetricsLine(JSON.stringify({ event_type: 'beta', timestamp: '2026-01-01T00:01:00Z', detail: 'b1' }));
    writeMetricsLine(JSON.stringify({ event_type: 'alpha', timestamp: '2026-01-01T00:02:00Z', detail: 'a2' }));
    const result = runShell('metrics_query "alpha"');
    expect(result.stdout).toContain('a1');
    expect(result.stdout).toContain('a2');
    expect(result.stdout).not.toContain('b1');
  });

  it('空文件查询返回空', () => {
    mkdirSync(logsDir, { recursive: true });
    writeFileSync(metricsFile, '');
    const result = runShell('metrics_summary');
    expect(result.stdout).toContain('total: 0');
  });

  it('并发写入不丢失行', () => {
    mkdirSync(logsDir, { recursive: true });
    const result = runShell(`
for i in $(seq 1 10); do
  metrics_log_event "concurrent" "item=$i" &
done
wait
`);
    expect(result.exitCode).toBe(0);
    const lines = readFileSync(metricsFile, 'utf8').trim().split('\n').filter(l => l.trim());
    expect(lines.length).toBe(10);
  });

  it('损坏行查询降级跳过', () => {
    writeMetricsLine('not-valid-json');
    writeMetricsLine(JSON.stringify({ event_type: 'valid', timestamp: '2026-01-01T00:00:00Z', detail: 'ok' }));
    const result = runShell('metrics_summary');
    expect(result.stdout).toContain('valid: 1');
    expect(result.exitCode).toBe(0);
  });
});
