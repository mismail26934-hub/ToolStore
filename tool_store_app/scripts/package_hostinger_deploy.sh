#!/usr/bin/env bash
# Zip build/web for upload via Hostinger File Manager.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f build/web/main.dart.js ]]; then
  echo "Run: bash scripts/build_web_hostinger.sh"
  exit 1
fi

OUT="dist/tool-monitoring-web.zip"
mkdir -p dist
rm -f "$OUT"
if command -v zip >/dev/null 2>&1; then
  (cd build/web && zip -r "../../$OUT" .)
elif command -v powershell.exe >/dev/null 2>&1; then
  powershell -Command "Compress-Archive -Path 'build/web/*' -DestinationPath '$OUT' -Force"
else
  echo "Install zip or use PowerShell to create archive"
  exit 1
fi

echo ""
echo "Created: $OUT"
echo "Hostinger: File Manager -> public_html/Tool-Monitoring -> Upload zip -> Extract"
echo "MD5: $(md5sum build/web/main.dart.js 2>/dev/null || md5 -q build/web/main.dart.js)"
