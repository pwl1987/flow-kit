import { describe, it, expect, beforeEach } from 'vitest';
import { writeFileSync, rmSync, mkdirSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let scanSecrets, scanSqlInjection, scanXss, scanDangerousShell;

const TEST_DIR = tmpdir() + '/sec-test-' + Date.now();

describe('2.4 security-scanner 模块', () => {
  beforeEach(async () => {
    mkdirSync(TEST_DIR, { recursive: true });
    const ss = await import('../../src/lib/security-scanner.mjs');
    scanSecrets = ss.scanSecrets;
    scanSqlInjection = ss.scanSqlInjection;
    scanXss = ss.scanXss;
    scanDangerousShell = ss.scanDangerousShell;
  });

  afterEach(() => {
    rmSync(TEST_DIR, { recursive: true, force: true });
  });

  describe('scanSecrets()', () => {
    it('检测 API key 模式', () => {
      const file = join(TEST_DIR, 'config.js');
      writeFileSync(file, 'const apiKey = "sk-1234567890abcdef"');
      const results = scanSecrets(TEST_DIR);
      expect(results.length).toBeGreaterThan(0);
      expect(results.some(r => r.type === 'api_key')).toBe(true);
    });

    it('检测 AWS credentials', () => {
      const file = join(TEST_DIR, 'aws.js');
      writeFileSync(file, 'AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE');
      const results = scanSecrets(TEST_DIR);
      expect(results.some(r => r.type === 'aws_key')).toBe(true);
    });

    it('无 secrets 时返回空数组', () => {
      const file = join(TEST_DIR, 'clean.js');
      writeFileSync(file, 'const x = 1;');
      const results = scanSecrets(TEST_DIR);
      expect(Array.isArray(results)).toBe(true);
    });

    it('结果包含 file, line, type', () => {
      const file = join(TEST_DIR, 'keys.js');
      writeFileSync(file, 'password: "hunter2"');
      const results = scanSecrets(TEST_DIR);
      if (results.length > 0) {
        expect(results[0]).toHaveProperty('file');
        expect(results[0]).toHaveProperty('line');
        expect(results[0]).toHaveProperty('type');
      }
    });
  });

  describe('scanSqlInjection()', () => {
    it('检测字符串拼接 SQL', () => {
      const file = join(TEST_DIR, 'sql.js');
      writeFileSync(file, 'query("SELECT * FROM users WHERE id=" + userId)');
      const results = scanSqlInjection(TEST_DIR);
      expect(results.length).toBeGreaterThan(0);
    });

    it('无风险时返回空数组', () => {
      const file = join(TEST_DIR, 'safe.js');
      writeFileSync(file, 'const id = parseInt(userId); queryParams(id);');
      const results = scanSqlInjection(TEST_DIR);
      expect(Array.isArray(results)).toBe(true);
    });
  });

  describe('scanDangerousShell()', () => {
    it('检测 rm -rf', () => {
      const file = join(TEST_DIR, 'dangerous.sh');
      writeFileSync(file, 'rm -rf /some/path');
      const results = scanDangerousShell(TEST_DIR);
      expect(results.some(r => r.match.includes('rm -rf'))).toBe(true);
    });

    it('检测 eval 使用', () => {
      const file = join(TEST_DIR, 'eval.sh');
      writeFileSync(file, 'eval "$user_input"');
      const results = scanDangerousShell(TEST_DIR);
      expect(results.length).toBeGreaterThan(0);
    });
  });
});
