import { describe, it, expect, beforeEach } from 'vitest';
import { existsSync, readFileSync } from 'fs';
import { join } from 'path';

const SKILL_DIR = join(process.env.FLOW_KIT_DIR || '.', 'flow-kit/skills/phase-0');

describe('5.1 skill-phase-0 迁移', () => {
  it('SKILL.md 存在', () => {
    expect(existsSync(join(SKILL_DIR, 'SKILL.md'))).toBe(true);
  });

  it('reference.md 存在', () => {
    expect(existsSync(join(SKILL_DIR, 'reference.md'))).toBe(true);
  });

  it('SKILL.md 包含 YAML frontmatter', () => {
    const content = readFileSync(join(SKILL_DIR, 'SKILL.md'), 'utf8');
    expect(content.startsWith('---')).toBe(true);
    expect(content).toContain('name: phase-0');
    expect(content).toContain('description:');
  });
});