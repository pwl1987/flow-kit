import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: [
      'lib/detection/**/*.test.js',
      'tests/**/*.test.js'
    ],
    globals: true,
    environment: 'node',
    coverage: {
      reporter: ['text', 'html'],
      exclude: ['**/*.test.js', 'node_modules/']
    }
  }
});