// project-info.mjs — 项目信息获取
// v3.8.0 迁移自 lib/project-info.sh

import { execSync } from 'child_process';
import { readFileSync, existsSync } from 'fs';
import { join, basename } from 'path';

const PROJECT_DIR = process.env.PROJECT_DIR || process.cwd();

function safeExec(cmd, fallback = '') {
  try {
    return execSync(cmd, { encoding: 'utf8', stdio: 'pipe' }).trim();
  } catch {
    return fallback;
  }
}

export function getGitInfo() {
  const branch = safeExec('git branch --show-current', 'unknown');
  const commit = safeExec('git rev-parse HEAD', 'unknown');
  const remote = safeExec('git remote get-url origin 2>/dev/null || echo', '');

  return {
    branch,
    commit: commit.substring(0, 7),
    remote,
    isGitRepo: existsSync(join(PROJECT_DIR, '.git'))
  };
}

export function getVersion() {
  const versionFile = join(PROJECT_DIR, 'VERSION');
  if (existsSync(versionFile)) {
    try {
      return readFileSync(versionFile, 'utf8').trim();
    } catch {
      return 'unknown';
    }
  }
  return 'unknown';
}

export function getProjectName() {
  const pkgFile = join(PROJECT_DIR, 'package.json');
  if (existsSync(pkgFile)) {
    try {
      const pkg = JSON.parse(readFileSync(pkgFile, 'utf8'));
      if (pkg.name) return pkg.name;
    } catch {}
  }
  return basename(PROJECT_DIR);
}
