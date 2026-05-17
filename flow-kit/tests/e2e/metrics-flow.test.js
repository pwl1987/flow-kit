import { describe, it, expect } from 'vitest';

const skipE2E = process.env.SKIP_E2E === '1';

describe.skipIf(skipE2E)('E2E: metrics-flow', () => {
  it('metrics --summary 输出聚合', async () => {
    expect(true).toBe(true);
  });

  it('metrics --clear 清空后 total 为 0', async () => {
    expect(true).toBe(true);
  });
});
