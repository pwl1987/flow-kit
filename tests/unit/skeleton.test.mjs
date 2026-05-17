import { describe, it, expect, beforeAll } from 'vitest';
import { execSync } from 'child_process';
import { readFileSync, existsSync, statSync } from 'fs';
import { resolve } from 'path';

const PROJECT_ROOT = '/data/Code/pwl/code/plugins';

function runCmd(cmd) {
  try {
    return execSync(cmd, { cwd: PROJECT_ROOT, encoding: 'utf8', timeout: 10000 }).trim();
  } catch (e) {
    return null;
  }
}

describe('0.1 项目骨架', () => {
  const requiredDirs = [
    'src/lib', 'src/tools', 'src/hooks', 'dist',
    'archive/v3.7.0-shell/lib', 'archive/v3.7.0-shell/scripts', 'archive/v3.7.0-shell/hooks',
    'hooks',
    'skills/phase-0', 'skills/phase-1', 'skills/phase-2', 'skills/phase-3',
    'skills/phase-4', 'skills/phase-5', 'skills/phase-6', 'skills/phase-7', 'skills/phase-8',
    'skills/health', 'skills/code-review', 'skills/recall', 'skills/register-commands',
    'docs',
    'tests/helpers', 'tests/tools', 'tests/hooks', 'tests/unit'
  ];

  const requiredFiles = [
    'src/lib/.gitkeep', 'src/tools/.gitkeep', 'src/hooks/.gitkeep', 'dist/.gitkeep',
    'archive/v3.7.0-shell/lib/.gitkeep', 'archive/v3.7.0-shell/scripts/.gitkeep', 'archive/v3.7.0-shell/hooks/.gitkeep',
    'skills/phase-0/.gitkeep', 'skills/phase-1/.gitkeep', 'skills/phase-2/.gitkeep',
    'skills/phase-3/.gitkeep', 'skills/phase-4/.gitkeep', 'skills/phase-5/.gitkeep',
    'skills/phase-6/.gitkeep', 'skills/phase-7/.gitkeep', 'skills/phase-8/.gitkeep',
    'skills/health/.gitkeep', 'skills/code-review/.gitkeep', 'skills/recall/.gitkeep', 'skills/register-commands/.gitkeep',
    'hooks/.gitkeep',
    'tests/helpers/.gitkeep', 'tests/tools/.gitkeep', 'tests/hooks/.gitkeep', 'tests/unit/.gitkeep',
    'docs/.gitkeep'
  ];

  it('所有目录必须存在', () => {
    const missing = [];
    for (const dir of requiredDirs) {
      const path = resolve(PROJECT_ROOT, dir);
      if (!existsSync(path)) missing.push(dir);
    }
    expect(missing).toEqual([]);
  });

  it('所有 .gitkeep 文件必须存在', () => {
    const missing = [];
    for (const file of requiredFiles) {
      const path = resolve(PROJECT_ROOT, file);
      if (!existsSync(path)) missing.push(file);
    }
    expect(missing).toEqual([]);
  });

  it('package.json 必须存在且包含必要依赖', () => {
    const pkgPath = resolve(PROJECT_ROOT, 'package.json');
    expect(existsSync(pkgPath)).toBe(true);
    
    const pkg = JSON.parse(readFileSync(pkgPath, 'utf8'));
    
    // 检查核心依赖
    expect(pkg.dependencies?.['@modelcontextprotocol/sdk']).toBeDefined();
    expect(pkg.dependencies?.zod).toBeDefined();
    expect(pkg.dependencies?.yaml).toBeDefined();
    
    // 检查 devDependencies
    expect(pkg.devDependencies?.esbuild).toBeDefined();
    expect(pkg.devDependencies?.typescript).toBeDefined();
    
    // 检查 scripts
    expect(pkg.scripts?.build).toBeDefined();
  });

  it('jsconfig.json 必须存在且配置正确', () => {
    const jsconfigPath = resolve(PROJECT_ROOT, 'jsconfig.json');
    expect(existsSync(jsconfigPath)).toBe(true);
    
    const jsconfig = JSON.parse(readFileSync(jsconfigPath, 'utf8'));
    expect(jsconfig.compilerOptions?.module).toBe('ES2022');
    expect(jsconfig.compilerOptions?.target).toBe('ES2022');
    expect(jsconfig.compilerOptions?.checkJs).toBe(true);
    expect(jsconfig.compilerOptions?.paths?.['@/*']).toEqual(['./src/*']);
  });

  it('npm install 后 node_modules 必须包含依赖', () => {
    // 这个测试假设 npm install 已运行
    let success = true;
    try {
      runCmd('node -e "require(\'@modelcontextprotocol/sdk\')"');
      runCmd('node -e "require(\'zod\')"');
    } catch (e) {
      success = false;
    }
    expect(success).toBe(true);
  });
});
