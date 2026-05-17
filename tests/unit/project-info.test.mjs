import { describe, it, expect } from 'vitest';
import { existsSync, writeFileSync, rmSync, mkdirSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let getGitInfo, getVersion, getProjectName;

const TEST_DIR = tmpdir() + '/pi-test-' + Date.now();
mkdirSync(TEST_DIR, { recursive: true });

describe('2.7 project-info 模块', () => {
  beforeEach(async () => {
    process.env.PROJECT_DIR = TEST_DIR;
    const pi = await import('../../src/lib/project-info.mjs');
    getGitInfo = pi.getGitInfo;
    getVersion = pi.getVersion;
    getProjectName = pi.getProjectName;
  });

  describe('getGitInfo()', () => {
    it('返回包含 branch', () => {
      const info = getGitInfo();
      expect(info).toHaveProperty('branch');
    });

    it('返回包含 commit', () => {
      const info = getGitInfo();
      expect(info).toHaveProperty('commit');
    });
  });

  describe('getVersion()', () => {
    it('VERSION 文件存在时读取版本号', () => {
      writeFileSync(join(TEST_DIR, 'VERSION'), '3.8.0');
      const version = getVersion();
      expect(version).toBe('3.8.0');
    });

    it('VERSION 文件不存在时返回 unknown', () => {
      const version = getVersion();
      expect(version).toBe('unknown');
    });
  });

  describe('getProjectName()', () => {
    it('从 package.json 读取项目名', () => {
      writeFileSync(join(TEST_DIR, 'package.json'), JSON.stringify({ name: 'flow-kit-test' }));
      const name = getProjectName();
      expect(name).toBe('flow-kit-test');
    });
  });
});
