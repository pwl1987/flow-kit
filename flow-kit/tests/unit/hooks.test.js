import { describe, it, expect } from 'vitest';
import { readdirSync, readFileSync } from 'fs';
import { join } from 'path';

const HOOKS_DIR = join(process.cwd(), 'hooks');

describe('hooks strict mode', () => {
  const hookFiles = readdirSync(HOOKS_DIR).filter(f => f.endsWith('.sh'));

  it('hooks 目录非空', () => {
    expect(hookFiles.length).toBeGreaterThan(0);
  });

  it('每个 hook 含 set -uo pipefail（或 set -euo pipefail）', () => {
    for (const f of hookFiles) {
      const content = readFileSync(join(HOOKS_DIR, f), 'utf8');
      const hasStrict = /set\s+-[eu]*o?\s*pipefail/.test(content) || /set\s+-uo\s+pipefail/.test(content);
      expect(hasStrict, `${f} 缺少 pipefail 设置`).toBe(true);
    }
  });

  it('无 hook 缺少 nounset (set -u)', () => {
    for (const f of hookFiles) {
      const content = readFileSync(join(HOOKS_DIR, f), 'utf8');
      expect(content, `${f} 缺少 set -u`).toMatch(/set\s+.*u/);
    }
  });
});
