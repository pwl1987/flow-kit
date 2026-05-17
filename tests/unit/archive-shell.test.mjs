import { describe, it, expect } from 'vitest';
import { execSync } from 'child_process';
import { existsSync, readFileSync } from 'fs';
import { resolve } from 'path';

const PROJECT_ROOT = '/data/Code/pwl/code/plugins';

function runCmd(cmd) {
  try {
    return execSync(cmd, { cwd: PROJECT_ROOT, encoding: 'utf8', timeout: 10000 }).trim();
  } catch (e) {
    return null;
  }
}

function md5(file) {
  try {
    return execSync(`md5sum ${file} | cut -d' ' -f1`, { cwd: PROJECT_ROOT, encoding: 'utf8' }).trim();
  } catch (e) {
    return null;
  }
}

describe('0.2 Shell 脚本归档', () => {
  const sourceDirs = [
    { src: 'flow-kit/lib', dst: 'archive/v3.7.0-shell/lib' },
    { src: 'flow-kit/scripts', dst: 'archive/v3.7.0-shell/scripts' },
    { src: 'flow-kit/hooks', dst: 'archive/v3.7.0-shell/hooks' }
  ];

  it('归档目录文件数量与源目录一致', () => {
    for (const { src, dst } of sourceDirs) {
      const srcCount = runCmd(`ls ${src}/*.sh 2>/dev/null | wc -l`);
      const dstCount = runCmd(`ls ${dst}/*.sh 2>/dev/null | wc -l`);
      expect(parseInt(dstCount)).toBe(parseInt(srcCount));
    }
  });

  it('每个源 Shell 文件在归档目录中存在对应副本', () => {
    for (const { src, dst } of sourceDirs) {
      const files = runCmd(`ls ${src}/*.sh 2>/dev/null`).split('\n');
      for (const file of files) {
        if (file.trim()) {
          const srcFile = resolve(PROJECT_ROOT, file.trim());
          const dstFile = srcFile.replace(src, dst);
          expect(existsSync(dstFile)).toBe(true);
        }
      }
    }
  });

  it('归档文件内容与源文件一致（md5sum）', () => {
    for (const { src, dst } of sourceDirs) {
      const files = runCmd(`ls ${src}/*.sh 2>/dev/null`).split('\n');
      for (const file of files) {
        if (file.trim()) {
          const srcFile = resolve(PROJECT_ROOT, file.trim());
          const dstFile = srcFile.replace(src, dst);
          const srcMd5 = md5(srcFile);
          const dstMd5 = md5(dstFile);
          expect(dstMd5).toBe(srcMd5);
        }
      }
    }
  });

  it('归档目录中无非 Shell 临时文件', () => {
    for (const { dst } of sourceDirs) {
      const extra = runCmd(`ls ${dst}/ 2>/dev/null | grep -v '\\.sh$' || true`);
      expect(extra.trim()).toBe('');
    }
  });
});
