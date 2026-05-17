import { describe, it, expect, beforeEach } from 'vitest';
import { writeFileSync, rmSync, mkdirSync } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

let parseFrontMatter, getField;

const TEST_DIR = tmpdir() + '/fm-test-' + Date.now();
mkdirSync(TEST_DIR, { recursive: true });

describe('2.3 front-matter 模块', () => {
  beforeEach(async () => {
    const fm = await import('../../src/lib/front-matter.mjs');
    parseFrontMatter = fm.parseFrontMatter;
    getField = fm.getField;
  });

  it('解析含 front matter 文件', () => {
    const file = join(TEST_DIR, 'with-fm.md');
    writeFileSync(file, '---\nphase: 3\ntitle: Test\n---\nContent');
    const result = parseFrontMatter(file);
    expect(result.phase).toBe(3);
    expect(result.title).toBe('Test');
  });

  it('不含 front matter 返回 phase=-1', () => {
    const file = join(TEST_DIR, 'no-fm.md');
    writeFileSync(file, 'Just content');
    const result = parseFrontMatter(file);
    expect(result.phase).toBe(-1);
  });

  it('空文件返回 phase=-1', () => {
    const file = join(TEST_DIR, 'empty.md');
    writeFileSync(file, '');
    const result = parseFrontMatter(file);
    expect(result.phase).toBe(-1);
  });

  it('getField 获取存在的字段', () => {
    const file = join(TEST_DIR, 'field-test.md');
    writeFileSync(file, '---\nname: test-value\n---\n');
    expect(getField(file, 'name')).toBe('test-value');
  });

  it('getField 不存在的字段返回空字符串', () => {
    const file = join(TEST_DIR, 'no-fm.md');
    writeFileSync(file, 'No front matter');
    expect(getField(file, 'nonexistent')).toBe('');
  });
});
