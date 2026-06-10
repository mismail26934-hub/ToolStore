#!/usr/bin/env node
const fs = require('fs');
const crypto = require('crypto');
const path = require('path');

const webDir = path.join(__dirname, '..', 'build', 'web');
const mainJs = path.join(webDir, 'main.dart.js');
const versionPath = path.join(webDir, 'version.json');
const indexPath = path.join(webDir, 'index.html');

const hash = crypto.createHash('md5').update(fs.readFileSync(mainJs)).digest('hex');
const builtAt = new Date().toISOString();

let version = {};
try {
  version = JSON.parse(fs.readFileSync(versionPath, 'utf8'));
} catch (_) {}

version.build_md5 = hash;
version.built_at = builtAt;
fs.writeFileSync(versionPath, JSON.stringify(version));

let index = fs.readFileSync(indexPath, 'utf8');
const meta = `<meta name="app-build-md5" content="${hash}">`;
if (index.includes('name="app-build-md5"')) {
  index = index.replace(
    /<meta name="app-build-md5" content="[^"]*">/,
    meta,
  );
} else {
  index = index.replace('</head>', `  ${meta}\n</head>`);
}
fs.writeFileSync(indexPath, index);

console.log(`stamp_build_version: ${hash} @ ${builtAt}`);
