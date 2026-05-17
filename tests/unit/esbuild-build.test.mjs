import { describe, it, expect, beforeAll } from 'vitest';
import { execSync } from 'child_process';
import { existsSync, readFileSync } from 'fs';
import { resolve } from 'path';

const PROJECT_ROOT = '/data/Code/pwl/code/plugins';

function runCmd(cmd) {
  try {
    return execSync(cmd, { cwd: PROJECT_ROOT, encoding: 'utf8', timeout: 30000 }).trim();
  } catch (e) {
    return null;
  }
}

describe('0.5 esbuild 构建配置', () => {
  beforeAll(() => {
    runCmd('npm run build');
  });

  it('esbuild.config.mjs 存在', () => {
    expect(existsSync(resolve(PROJECT_ROOT, 'esbuild.config.mjs'))).toBe(true);
  });

  it('package.json 包含 build script', () => {
    const pkg = JSON.parse(readFileSync(resolve(PROJECT_ROOT, 'package.json'), 'utf8'));
    expect(pkg.scripts.build).toBeDefined();
    expect(pkg.scripts.build).toContain('esbuild');
  });

  it('npm run build 成功退出', () => {
    const result = runCmd('npm run build');
    expect(result).not.toBeNull();
  });

  it('dist/mcp-server.cjs 生成', () => {
    const outPath = resolve(PROJECT_ROOT, 'dist/mcp-server.cjs');
    expect(existsSync(outPath)).toBe(true);
    const stats = readFileSync(outPath, 'utf8');
    expect(stats.length).toBeGreaterThan(0);
  });

  it('dist/mcp-server.cjs 可执行并输出 hello', () => {
    const result = runCmd('node dist/mcp-server.cjs 2>&1');
    expect(result).toBe('hello');
  });
});
