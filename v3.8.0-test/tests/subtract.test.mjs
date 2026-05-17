import { describe, it, expect } from 'vitest';
import { subtract } from '../subtract.mjs';

describe('subtract', () => {
  it('returns difference of two numbers', () => {
    expect(subtract(3, 1)).toBe(2);
  });

  it('returns zero for both zeros', () => {
    expect(subtract(0, 0)).toBe(0);
  });

  it('returns zero for same negatives', () => {
    expect(subtract(-1, -1)).toBe(0);
  });

  it('handles floats', () => {
    expect(subtract(5.5, 0.5)).toBe(5);
  });
});
