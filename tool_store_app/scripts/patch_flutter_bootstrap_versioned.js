#!/usr/bin/env node
/**
 * Copies main.dart.js to a versioned filename and points flutter_bootstrap at it.
 * Bypasses Hostinger CDN cache stuck on main.dart.js.
 */
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const webDir = path.join(__dirname, '..', 'build', 'web');
const mainJs = path.join(webDir, 'main.dart.js');
const bootstrapPath = path.join(webDir, 'flutter_bootstrap.js');

const hash = crypto.createHash('md5').update(fs.readFileSync(mainJs)).digest('hex');
const short = hash.slice(0, 8);
const versionedName = `main.dart.${short}.js`;
const versionedPath = path.join(webDir, versionedName);

fs.copyFileSync(mainJs, versionedPath);

let bootstrap = fs.readFileSync(bootstrapPath, 'utf8');
bootstrap = bootstrap.replace(
  /"mainJsPath":"main\.dart\.js"/,
  `"mainJsPath":"${versionedName}"`,
);
// Replace any previous versioned entry from an earlier build.
bootstrap = bootstrap.replace(
  /"mainJsPath":"main\.dart\.[a-f0-9]{8}\.js"/,
  `"mainJsPath":"${versionedName}"`,
);
fs.writeFileSync(bootstrapPath, bootstrap);

console.log(`patch_flutter_bootstrap_versioned: ${versionedName}`);
