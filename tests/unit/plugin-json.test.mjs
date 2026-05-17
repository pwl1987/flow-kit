import { describe, it, expect } from 'vitest';
import { readFileSync, existsSync } from 'fs';
import { resolve } from 'path';

const PROJECT_ROOT = '/data/Code/pwl/code/plugins';

describe('0.3 创建 plugin.json', () => {
  it('plugin.json 存在且可解析', () => {
    const path = resolve(PROJECT_ROOT, '.claude-plugin/plugin.json');
    expect(existsSync(path)).toBe(true);
    const data = JSON.parse(readFileSync(path, 'utf8'));
    expect(data).toBeDefined();
  });

  it('name 字段为 flow-kit', () => {
    const data = JSON.parse(readFileSync(resolve(PROJECT_ROOT, '.claude-plugin/plugin.json'), 'utf8'));
    expect(data.name).toBe('flow-kit');
  });

  it('version 字段为 3.8.0', () => {
    const data = JSON.parse(readFileSync(resolve(PROJECT_ROOT, '.claude-plugin/plugin.json'), 'utf8'));
    expect(data.version).toBe('3.8.0');
  });

  it('hooks 路径存在', () => {
    const data = JSON.parse(readFileSync(resolve(PROJECT_ROOT, '.claude-plugin/plugin.json'), 'utf8'));
    expect(data.hooks).toBeDefined();
    expect(existsSync(resolve(PROJECT_ROOT, data.hooks))).toBe(true);
  });

  it('mcpServers 路径存在', () => {
    const data = JSON.parse(readFileSync(resolve(PROJECT_ROOT, '.claude-plugin/plugin.json'), 'utf8'));
    expect(data.mcpServers).toBeDefined();
    expect(existsSync(resolve(PROJECT_ROOT, data.mcpServers))).toBe(true);
  });

  it('interface 配置完整', () => {
    const data = JSON.parse(readFileSync(resolve(PROJECT_ROOT, '.claude-plugin/plugin.json'), 'utf8'));
    expect(data.interface).toBeDefined();
    expect(data.interface.displayName).toBe('Flow Kit');
    expect(data.interface.shortDescription).toBeDefined();
    expect(data.interface.category).toBe('development-workflow');
    expect(data.interface.capabilities).toBeDefined();
    expect(Array.isArray(data.interface.capabilities)).toBe(true);
  });
});
