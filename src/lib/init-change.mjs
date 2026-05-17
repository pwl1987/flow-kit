// init-change.mjs — 变更初始化
// v3.8.0 迁移自 scripts/init-change.sh

import { mkdirSync, existsSync, writeFileSync, readdirSync } from 'fs';
import { join } from 'path';
import { getTimestamp } from './time-utils.mjs';

const SPECS_DIR = process.env.SPECS_DIR || join(process.env.PROJECT_DIR || '.', '.specs');

function _cleanSlug(slug) {
  return slug
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .substring(0, 50);
}

function _getToday() {
  return new Date().toISOString().substring(0, 10).replace(/-/g, '');
}

export function checkCollision(slug) {
  if (!existsSync(SPECS_DIR)) {
    return null;
  }

  const today = _getToday();
  const entries = readdirSync(SPECS_DIR, { withFileTypes: true })
    .filter(e => e.isDirectory())
    .map(e => e.name);

  const todayMatches = entries.filter(name => name.startsWith(today + '-' + slug));

  if (todayMatches.length === 0) {
    const exactMatch = entries.find(name => name === slug || name.endsWith('-' + slug));
    if (exactMatch) {
      return { existing: true, changeId: exactMatch, collision: false };
    }
    return null;
  }

  const nextNum = todayMatches.length + 1;
  return {
    existing: true,
    changeId: `${today}-${slug}-${nextNum}`,
    collision: true,
    suggestion: `${today}-${slug}-${nextNum}`
  };
}

export function createSpecDir(changeId) {
  const specDir = join(SPECS_DIR, changeId);
  if (!existsSync(specDir)) {
    mkdirSync(specDir, { recursive: true });
  }

  const templates = ['REQUIREMENT.md', 'DESIGN.md', 'NOTES.md'];
  for (const tmpl of templates) {
    const filePath = join(specDir, tmpl);
    if (!existsSync(filePath)) {
      writeFileSync(filePath, `# ${tmpl.replace('.md', '')}\n\n`);
    }
  }

  return specDir;
}

export async function initChange(slug, description) {
  const cleanSlug = _cleanSlug(slug);
  const today = _getToday();

  let changeId = `${today}-${cleanSlug}`;

  const collision = checkCollision(cleanSlug);
  if (collision && collision.existing) {
    if (collision.collision) {
      changeId = collision.suggestion;
    } else {
      changeId = collision.changeId;
    }
  }

  const specDir = createSpecDir(changeId);

  const readmePath = join(specDir, 'README.md');
  if (!existsSync(readmePath)) {
    writeFileSync(readmePath, `# ${changeId}\n\n${description || ''}\n\n`);
  }

  return {
    changeId,
    slug: cleanSlug,
    specDir,
    createdAt: getTimestamp()
  };
}