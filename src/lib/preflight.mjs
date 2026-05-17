// preflight.mjs — 统一依赖预检
// v3.8.0 迁移自 lib/preflight.sh

import { execSync } from 'child_process';

const _cache = new Map();

export function requireTool(name, cmd) {
  if (_cache.has(name)) {
    return _cache.get(name);
  }

  try {
    execSync(`which ${cmd}`, { stdio: 'pipe' });
    _cache.set(name, true);
    return true;
  } catch {
    const err = new Error(`依赖 ${name} 未安装 (命令: ${cmd})`);
    _cache.set(name, false);
    throw err;
  }
}

export function requireJq() {
  return requireTool('jq', 'jq');
}

export function requireBash4() {
  // Node.js 环境不需要 bash 检查
  return true;
}
