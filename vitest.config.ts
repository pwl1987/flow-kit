import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: [
      'tests/**/*.test.js',
      'tests/unit/**/*.test.mjs',
      'tests/tools/**/*.test.mjs',
      'tests/hooks/**/*.test.mjs',
      'tests/e2e/**/*.test.mjs',
      'tests/build/**/*.test.mjs',
    ],
  },
});
