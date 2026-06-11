#!/usr/bin/env bash
# Production web build for local backend: http://10.40.102.69:8080/web/
set -euo pipefail
cd "$(dirname "$0")/.."

API_BASE="${API_BASE:-http://10.40.102.69:8080/}"
WEB_APP_BASE="${WEB_APP_BASE:-http://10.40.102.69:8080/web/}"

# Git Bash on Windows rewrites /web/ unless excluded.
export MSYS2_ARG_CONV_EXCL="--base-href"

flutter build web --release --no-wasm-dry-run \
  --base-href=/web/ \
  --dart-define=API_BASE="$API_BASE" \
  --dart-define=WEB_APP_BASE="$WEB_APP_BASE"

node scripts/patch_flutter_bootstrap_no_sw.js
node scripts/stamp_build_version.js
node scripts/patch_flutter_bootstrap_versioned.js

echo ""
echo "Build MD5 (upload this build):"
md5sum build/web/main.dart.js 2>/dev/null || md5 build/web/main.dart.js
echo ""
echo "Upload ALL contents of build/web/ to server folder:"
echo "  web/   (under document root on 10.40.102.69:8080)"
echo "  (include canvaskit/ folder — required)"
echo ""
echo "Open:"
echo "  ${WEB_APP_BASE}"
echo ""
