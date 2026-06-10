#!/usr/bin/env node
/**
 * Disables Flutter service worker registration (avoids stale main.dart.js on Hostinger).
 * Patches build/web/flutter_bootstrap.js after `flutter build web`.
 */
const fs = require('fs');
const path = require('path');

const bootstrapPath = path.join(
  __dirname,
  '..',
  'build',
  'web',
  'flutter_bootstrap.js'
);
let content = fs.readFileSync(bootstrapPath, 'utf8');

const patched = content.replace(
  /_flutter\.loader\.load\(\{\s*serviceWorkerSettings:\s*\{[\s\S]*?\}\s*\}\);/,
  '_flutter.loader.load();'
);

if (patched === content) {
  console.warn(
    'patch_flutter_bootstrap_no_sw: pattern not found, file unchanged'
  );
} else {
  fs.writeFileSync(bootstrapPath, patched);
  console.log('patch_flutter_bootstrap_no_sw: service worker disabled');
}
