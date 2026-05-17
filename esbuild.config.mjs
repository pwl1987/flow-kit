import { build } from 'esbuild';

build({
  entryPoints: ['src/server.mjs'],
  bundle: true,
  platform: 'node',
  outfile: 'dist/mcp-server.cjs',
  format: 'cjs',
  external: [],
  target: 'node18',
}).then(() => console.log('构建完成')).catch(() => process.exit(1));
