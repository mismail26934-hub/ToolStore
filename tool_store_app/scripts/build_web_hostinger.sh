#!/usr/bin/env bash
# Production web build for Hostinger: https://strakin.tech/Tool-Monitoring/
set -euo pipefail
cd "$(dirname "$0")/.."

# Git Bash on Windows rewrites /Tool-Monitoring/ unless excluded.
export MSYS2_ARG_CONV_EXCL="--base-href"

flutter build web --release --no-wasm-dry-run --base-href=/Tool-Monitoring/

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
echo "  public_html/Tool-Monitoring/"
echo "  (include canvaskit/ folder — required)"
echo ""
echo "After upload, verify:"
echo "  bash scripts/verify_hostinger_deploy.sh"
echo ""
echo "Open in Incognito (clear old service worker once):"
echo "  https://strakin.tech/Tool-Monitoring/"
