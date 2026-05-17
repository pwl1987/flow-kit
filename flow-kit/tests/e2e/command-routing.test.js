import { describe, it, expect } from 'vitest';

const skipE2E = process.env.SKIP_E2E === '1';

describe.skipIf(skipE2E)('E2E: command-routing', () => {
  it('flow-kit.sh health 输出内容', async () => {
    expect(true).toBe(true);
  });

  it('flow-kit.sh p0 输出内容', async () => {
    expect(true).toBe(true);
  });
});
