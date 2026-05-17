import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { execSync } from 'child_process';
import { mkdirSync, rmSync, writeFileSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

const SCRIPTS_DIR = join(process.cwd(), 'scripts');
const SCRIPT = join(SCRIPTS_DIR, 'recall.sh');

describe('recall.sh', () => {
  const tmpDir = join(tmpdir(), `recall-test-${Date.now()}`);
  const flowKitDir = join(tmpDir, 'flow-kit');
  const projectDir = join(tmpDir, 'project');

  beforeEach(() => {
    mkdirSync(join(flowKitDir, 'scripts'), { recursive: true });
    mkdirSync(join(projectDir, '.flow-kit'), { recursive: true });
  });

  afterEach(() => {
    rmSync(tmpDir, { recursive: true, force: true });
  });

  function runCLI(args = '') {
    try {
      const stdout = execSync(
        `CLAUDE_PROJECT_DIR="${projectDir}" PATHS_PROJECT_DIR="${projectDir}" bash ${SCRIPT} ${args} 2>&1`,
        { encoding: 'utf8', timeout: 5000 }
      );
      return { stdout, exitCode: 0 };
    } catch (e) {
      return { stdout: (e.stdout || '') + (e.stderr || ''), exitCode: e.status || 1 };
    }
  }

  it('输出含版本号', () => {
    writeFileSync(join(flowKitDir, 'VERSION'), 'v3.7.0\n');
    const result = runCLI();
    expect(result.stdout).toContain('v3.7.0');
  });

  it('输出含当前阶段', () => {
    writeFileSync(join(projectDir, '.flow-kit', 'session-state.json'),
      JSON.stringify({ phase: '3-dev', status: 'wip' })
    );
    const result = runCLI();
    expect(result.stdout).toContain('3-dev');
    expect(result.stdout).toContain('wip');
  });

  it('缓存 5 分钟内不重新生成', () => {
    const cacheFile = join(projectDir, '.flow-kit', 'recall-cache.md');
    writeFileSync(cacheFile, '# 缓存内容\n旧摘要');
    const result = runCLI();
    expect(result.stdout).toContain('旧摘要');
  });

  it('--refresh 强制刷新', () => {
    const cacheFile = join(projectDir, '.flow-kit', 'recall-cache.md');
    writeFileSync(cacheFile, '# 旧缓存');
    writeFileSync(join(flowKitDir, 'VERSION'), 'v3.7.0\n');
    const result = runCLI('--refresh');
    expect(result.stdout).toContain('v3.7.0');
    expect(result.stdout).not.toContain('旧缓存');
  });

  it('无数据时不崩溃', () => {
    const result = runCLI();
    expect(result.exitCode).toBe(0);
    expect(result.stdout).toContain('项目上下文摘要');
  });
});
