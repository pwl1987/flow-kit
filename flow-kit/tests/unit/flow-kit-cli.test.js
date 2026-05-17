import { describe, it, expect } from 'vitest';
import { execSync } from 'child_process';
import path from 'path';

const SCRIPT = path.join(process.cwd(), 'flow-kit.sh');

describe('flow-kit.sh stub 命令', () => {
  it('health 输出命令内容', () => {
    const out = execSync(`bash ${SCRIPT} health 2>&1`, { encoding: 'utf8' });
    expect(out.length).toBeGreaterThan(100);
    expect(out).not.toContain('请在 Claude Code 中执行');
  });

  it('scan 输出命令内容', () => {
    const out = execSync(`bash ${SCRIPT} scan 2>&1`, { encoding: 'utf8' });
    expect(out.length).toBeGreaterThan(100);
  });

  it('cost-report 输出命令内容', () => {
    const out = execSync(`bash ${SCRIPT} cost-report 2>&1`, { encoding: 'utf8' });
    expect(out.length).toBeGreaterThan(50);
  });

  it('estimate-tokens 输出命令内容', () => {
    const out = execSync(`bash ${SCRIPT} estimate-tokens 2>&1`, { encoding: 'utf8' });
    expect(out.length).toBeGreaterThan(50);
  });

  it('check-expiry 输出命令内容', () => {
    const out = execSync(`bash ${SCRIPT} check-expiry 2>&1`, { encoding: 'utf8' });
    expect(out.length).toBeGreaterThan(50);
  });

  it('update-context 输出命令内容', () => {
    const out = execSync(`bash ${SCRIPT} update-context 2>&1`, { encoding: 'utf8' });
    expect(out.length).toBeGreaterThan(50);
  });

  it('p0 输出命令内容', () => {
    const out = execSync(`bash ${SCRIPT} p0 2>&1`, { encoding: 'utf8' });
    expect(out.length).toBeGreaterThan(50);
  });
});
