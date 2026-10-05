import fs from 'node:fs/promises';
import path from 'node:path';
await fs.rm('dist',{recursive:true,force:true});
await fs.mkdir('dist/server',{recursive:true});
await fs.mkdir('dist/.openai',{recursive:true});
const assets={};
async function scan(dir){for(const e of await fs.readdir(dir,{withFileTypes:true})){const file=path.join(dir,e.name);if(e.isDirectory())await scan(file);else{const ext=path.extname(file);const types={'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.css':'text/css; charset=utf-8','.woff2':'font/woff2','.txt':'text/plain; charset=utf-8'};assets['/'+path.relative('public',file)]={body:(await fs.readFile(file)).toString('base64'),type:types[ext]||'application/octet-stream'};}}}
await scan('public');
const server=await fs.readFile('server/index.js','utf8');
await fs.writeFile('dist/server/index.js',`const ASSETS=${JSON.stringify(assets)};\n`+server);
await fs.copyFile('.openai/hosting.json','dist/.openai/hosting.json');
await fs.cp('drizzle','dist/.openai/drizzle',{recursive:true});
console.log(`Built Worker with ${Object.keys(assets).length} local assets and D1 migrations.`);
