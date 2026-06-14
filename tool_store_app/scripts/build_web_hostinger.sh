#!/usr/bin/env bash
# Production web build for Hostinger (paths from config/app_links.json).
set -euo pipefail
cd "$(dirname "$0")/.."

dart run scripts/sync_app_links_config.dart
# shellcheck source=config/app_links.env.sh
source config/app_links.env.sh

# Git Bash on Windows rewrites base-href unless excluded.
export MSYS2_ARG_CONV_EXCL="--base-href"

flutter build web --release --no-wasm-dry-run --base-href="$WEB_BASE_HREF"

node scripts/patch_flutter_bootstrap_no_sw.js
node scripts/stamp_build_version.js
node scripts/patch_flutter_bootstrap_versioned.js

echo ""
echo "Build MD5 (upload this build):"
md5sum build/web/main.dart.js 2>/dev/null || md5 build/web/main.dart.js
echo ""
echo "Optional zip for Hostinger upload:"
echo "  bash scripts/package_hostinger_deploy.sh"
echo ""
echo "Upload ALL contents of build/web/ to Hostinger:"
echo "  public_html${WEB_PATH_PREFIX}/"
echo "  (include canvaskit/ folder — required)"
echo ""
echo "After upload, verify:"
echo "  bash scripts/verify_hostinger_deploy.sh"
echo ""
echo "Open in Incognito (clear old service worker once):"
echo "  ${WEB_BASE}"
