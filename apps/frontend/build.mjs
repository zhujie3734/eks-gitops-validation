import {build} from 'esbuild';
import {mkdir, writeFile} from 'node:fs/promises';
await mkdir('dist', {recursive:true});
await build({
  entryPoints:['src/main.jsx'], bundle:true, minify:true, outfile:'dist/app.js',
  define:{'process.env.NODE_ENV':'"production"', '__APP_VERSION__':JSON.stringify(process.env.VITE_APP_VERSION || 'dev')},
  logLevel:'info'
});
await writeFile('dist/index.html', '<!doctype html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>GitOps Lab</title><link rel="stylesheet" href="/app.css"></head><body><div id="root"></div><script src="/app.js"></script></body></html>');
