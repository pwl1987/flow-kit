// front-matter.mjs — YAML front matter 解析器
// v3.8.0 迁移自 lib/front-matter.sh

import { readFileSync, existsSync } from 'fs';
import yaml from 'yaml';

const _cache = new Map();

export function parseFrontMatter(filePath) {
  if (_cache.has(filePath)) {
    return _cache.get(filePath);
  }

  if (!existsSync(filePath)) {
    return { phase: -1 };
  }

  try {
    const content = readFileSync(filePath, 'utf8');
    const firstLine = content.split('\n')[0].trim();

    if (firstLine !== '---') {
      return { phase: -1 };
    }

    const fmMatch = content.match(/^---\n([\s\S]*?)\n---/);
    if (!fmMatch || !fmMatch[1].trim()) {
      return { phase: -1 };
    }

    const result = yaml.parse(fmMatch[1]) || { phase: -1 };
    _cache.set(filePath, result);
    return result;
  } catch {
    return { phase: -1 };
  }
}

export function getField(filePath, field) {
  const data = parseFrontMatter(filePath);
  return data[field] !== undefined ? String(data[field]) : '';
}
